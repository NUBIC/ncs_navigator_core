# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: fieldworks
#
#  client_id           :string(255)
#  created_at          :datetime
#  end_date            :date
#  fieldwork_id        :string(36)
#  generation_log      :text
#  id                  :integer          not null, primary key
#  latest_merge_id     :integer
#  latest_merge_status :string(255)
#  original_data       :binary
#  staff_id            :string(255)
#  start_date          :date
#  updated_at          :datetime
#

require 'patient_study_calendar'
require 'uuidtools'

class Fieldwork < ActiveRecord::Base
  has_many :merges, :inverse_of => :fieldwork

  # This order is important.  Don't change it unless you've got a good reason.
  before_create :set_default_id
  before_save :persist_report_models
  before_save :serialize_fieldwork_set

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
  # When this and {#event_templates} are set, the JSON for this set is
  # regenerated.
  #
  # @private
  attr_accessor :report

  ##
  # An ephemeral attribute that, if set, should point to a
  # {Field::EventTemplateCollection}.
  #
  # When this and {#report} are set, the JSON for this set is regenerated.
  #
  # @private
  attr_accessor :event_templates

  ##
  # Retrieves a fieldwork set by ID.  If no fieldwork set by that ID can be
  # found, initializes an empty set, saves it, and returns that set.
  #
  # This method therefore has the ability to violate the presence validations
  # listed above.  This privilege is intentional: we want to be able to save
  # datasets from field clients even if they give us a fieldwork ID that we
  # know nothing about, but we also want to encode the idea that we _usually_
  # expect a date range and client ID.
  def self.for(id, staff_id)
    find_or_initialize_by_fieldwork_id(id).tap do |r|
      r.staff_id = staff_id

      r.save!(:validate => false)
    end
  end

  ##
  # Shows all conflicting fieldwork records (as determined by latest merge
  # status) first, followed by all other fieldwork records.
  def self.for_report
    order("(CASE latest_merge_status WHEN 'conflict' THEN 1 ELSE 0 END) DESC, updated_at DESC")
  end

  ##
  # Retrieves scheduled activities from PSC for a given closed date interval
  # and builds a fieldwork set from that data.
  #
  # The constructed fieldwork set will be associated with other unpersisted
  # model objects that will be saved once the fieldwork set is saved.
  #
  # This method stores logs about the PSC -> Core entity mapping process in
  # {#generation_log}.
  def self.from_psc(start_date, end_date, client_id, psc, staff_id, current_username)
    sd = start_date
    ed = end_date
    cid = client_id

    new(:start_date => sd, :end_date => ed, :client_id => cid).tap do |f|
      sio = StringIO.new
      report = Field::ScheduledActivityReport.from_psc(psc, :start_date => sd, :end_date => ed, :state => Psc::ScheduledActivity::SCHEDULED, :current_user => current_username)
      report.logger = ::Logger.new(sio).tap { |l| l.formatter = ::Logger::Formatter.new }
      report.staff_id = staff_id

      report.process

      f.generation_log = sio.string
      f.report = report
      f.staff_id = staff_id
    end
  end

  def set_default_id
    self.fieldwork_id ||= UUIDTools::UUID.random_create.to_s
  end

  def latest_merge
    merges.order(:created_at).last
  end

  def latest_proposed_data
    latest_merge.try(:proposed_data)
  end

  def as_json(options = nil)
    JSON.parse(latest_proposed_data || original_data)
  end

  def persist_report_models
    return true unless report

    report.save_models
  end

  def serialize_fieldwork_set
    return true unless report

    doc = report.as_json

    if event_templates
      doc.update(event_templates.as_json)
    end

    self.original_data = doc.to_json
  end
end
