# == Schema Information
# Schema version: 20120507183332
#
# Table name: fieldworks
#
#  fieldwork_id    :string(36)      primary key
#  received_data   :binary
#  created_at      :datetime
#  updated_at      :datetime
#  client_id       :string(255)
#  end_date        :date
#  start_date      :date
#  original_data   :binary
#  generation_log  :text
#  merge_log       :text
#  merged          :boolean
#  conflict_report :text
#

# -*- coding: utf-8 -*-

require 'logger'
require 'ncs_navigator/core/psc'
require 'patient_study_calendar'
require 'stringio'
require 'uuidtools'

class Fieldwork < ActiveRecord::Base
  include NcsNavigator::Core::Fieldwork
  include NcsNavigator::Core::Psc

  set_primary_key :fieldwork_id

  before_create :set_default_id
  before_save :serialize_report

  attr_accessible :client_id
  attr_accessible :end_date
  attr_accessible :start_date

  validates_presence_of :client_id
  validates_presence_of :end_date
  validates_presence_of :start_date

  ##
  # An ephemeral attribute that, if set, should point to a
  # {ScheduledActivityReport}.
  #
  # When this is set on a Fieldwork instance FW and FW is saved, the following
  # actions occur in a before_save hook on FW:
  #
  # 1) All new entities associated with the report are saved.
  # 2) FW's original_data attribute is set to a Fieldwork-specific JSON
  #    representation of the report.
  #
  # For more information on said representation, see the fieldwork schema in
  # the ncs_navigator_schema repository.
  #
  # @see https://github.com/NUBIC/ncs_navigator_schema
  attr_accessor :report

  ##
  # An ephemeral attribute that, if set, names the user responsible for
  # generating fieldwork data.
  attr_accessor :staff_id

  ##
  # Retrieves a fieldwork set by ID.  If no fieldwork set by that ID can be
  # found, initializes an empty set, saves it, and returns that set.
  #
  # This method therefore has the ability to violate the presence validations
  # listed above.  This privilege is intentional: we want to be able to save
  # datasets from field clients even if they give us a fieldwork ID that we
  # know nothing about, but we also want to encode the idea that we _usually_
  # expect a date range and client ID.
  def self.for(id)
    find_or_initialize_by_fieldwork_id(id).tap do |r|
      r.save!(:validate => false) if r.new_record?
    end
  end

  ##
  # Retrieves scheduled activities from PSC for a given closed date interval
  # and builds a fieldwork set from that data.
  #
  # The constructed fieldwork set will be associated with other unpersisted
  # model objects that will be saved once the fieldwork set is saved.
  #
  # The following parameters are required:
  #
  # * `:start_date`: the start date
  # * `:end_date`: the end date
  # * `:client_id`: the ID of the field client
  #
  # This method stores logs about the PSC -> Core entity mapping process in
  # {#generation_log}.
  #
  # @param Hash params fieldwork parameters
  # @param PatientStudyCalendar psc a PSC client instance
  # @param staff_id the name of the user running this process;
  #   should usually be the value of ApplicationController#current_staff_id
  # @return [Fieldwork]
  def self.from_psc(params, psc, staff_id)
    sd = params[:start_date]
    ed = params[:end_date]
    cid = params[:client_id]

    new(:start_date => sd, :end_date => ed, :client_id => cid).tap do |f|
      sio = StringIO.new
      report = ScheduledActivityReport.from_psc(psc, :start_date => sd, :end_date => ed, :state => PatientStudyCalendar::ACTIVITY_SCHEDULED)
      report.logger = ::Logger.new(sio).tap { |l| l.formatter = ::Logger::Formatter.new }

      report.map_entities

      f.generation_log = sio.string
      f.report = report
      f.staff_id = staff_id
    end
  end

  ##
  # Merges a fieldwork set with Core's datastore.  The log of the operation is
  # written to #merge_log.  If the merge completes without conflicts, #merged
  # will be set to true; otherwise, #merged will be false and the conflicts
  # will be in the merge log.
  #
  # The merge only proceeds if both JSON objects in original_data and
  # received_data conform to the fieldwork data schema.
  #
  # If the merge completed without conflicts and all data was saved, returns
  # true; otherwise, returns false.
  def merge
    begin
      sio = StringIO.new
      logger = ::Logger.new(sio).tap { |l| l.formatter = ::Logger::Formatter.new }
      violations = schema_violations

      unless violations.values.all? { |v| v.empty? }
        violations[:original_data].each do |violation|
          logger.fatal { "[original] #{violation}" }
        end
        violations[:received_data].each do |violation|
          logger.fatal { "[received] #{violation}" }
        end

        logger.fatal { "Schema violations detected; aborting merge" }

        return
      end

      sp = Superposition.new
      sp.logger = logger
      sp.set_original(JSON.parse(original_data))
      sp.set_proposed(JSON.parse(received_data))
      sp.resolve_current

      sp.merge

      (sp.save unless sp.conflicted?).tap do |ok|
        update_attributes(:merged => ok, :conflict_report => sp.conflicts.to_json)
      end
    ensure
      update_attribute(:merge_log, sio.string)
    end
  end

  def set_default_id
    self.fieldwork_id ||= UUIDTools::UUID.random_create.to_s
  end

  def as_json(options = nil)
    JSON.parse(received_data || original_data)
  end

  ##
  # Returns the fieldwork schema violations, if any, in the #original_data
  # and #received_data JSON objects.  The return value is as follows:
  #
  #     {
  #       :original_data => [violations],
  #       :received_data => [violations]
  #     }
  #
  # If either field is blank, then {} is validated in lieu of that field.
  # (At present, this will generate schema errors, but that's acceptable: the
  # lack of an object is arguably a violation.)
  def schema_violations
    validator = Validator.new

    {
      :original_data => validator.fully_validate(JSON.parse(original_data || '{}')),
      :received_data => validator.fully_validate(JSON.parse(received_data || '{}'))
    }
  end

  def serialize_report
    return true unless report

    report.extend(NcsNavigator::Core::Psc::ScheduledActivityReport::JsonForFieldwork)

    report.save_entities(staff_id) and self.original_data = {
      'contacts' => report.contacts_as_json,
      'instrument_templates' => report.instrument_templates_as_json,
      'participants' => report.participants_as_json
    }.to_json
  end
end
