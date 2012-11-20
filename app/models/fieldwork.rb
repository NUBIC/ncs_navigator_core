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

require 'celluloid'
require 'uuidtools'

class Fieldwork < ActiveRecord::Base
  include Field::ModelResolution
  include Field::Serialization

  has_many :merges, :inverse_of => :fieldwork

  # This callback order is important.  Don't change it unless you've got a good
  # reason.
  before_create :set_default_id

  with_options(:if => :collections_changed?) do |fw|
    fw.before_save :reify_and_save_implied_models
    fw.before_save :cache_serialized_representation
  end

  attr_accessible :client_id
  attr_accessible :end_date
  attr_accessible :start_date

  validates_presence_of :client_id
  validates_presence_of :end_date
  validates_presence_of :generated_for
  validates_presence_of :staff_id
  validates_presence_of :start_date

  attr_accessor :logger

  ##
  # Collections of entities modified when populating a fieldwork set.
  COLLECTIONS = %w(contact_links contacts events instruments instrument_plans people surveys)

  ##
  # Collections are saved to this record.  The JSON for this set is regenerated
  # when they change.
  COLLECTIONS.each { |c| serialize c }

  ##
  # This looks nicer in specs.  Other external references to fieldwork
  # collections might also find it useful.
  def self.collections
    COLLECTIONS
  end

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
  # Populates this fieldwork set using data from PSC.
  #
  # This method sets the following attributes on the fieldwork set:
  #
  # * {#contact_links}
  # * {#contacts}
  # * {#events}
  # * {#instrument_plans}
  # * {#instruments}
  # * {#people}
  # * {#surveys}
  #
  # Those collections are later used by {#reify_models} and {#as_json}.
  def populate_from_psc(psc)
    ensure_logger

    begin
      t1 = Celluloid::Future.new { add_event_template_data(psc) }
      t2 = Celluloid::Future.new { add_scheduled_activity_report_data(psc) }
      ok = [t1, t2].all?(&:value)
    ensure
      store_log
    end
  end

  def add_event_template_data(psc)
  end

  def add_scheduled_activity_report_data(psc)
    params = {
      :current_user => generated_for,
      :end_date => end_date,
      :start_date => start_date,
      :state => Psc::ScheduledActivity::SCHEDULED
    }

    report = Field::ScheduledActivityReport.from_psc(psc, params)

    report.logger = logger
    report.process

    COLLECTIONS.each do |c|
      send("#{c}=", report.send(c))
    end
  end

  def collections_changed?
    COLLECTIONS.any? { |c| send("#{c}_changed?") }
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
    cached = latest_proposed_data || original_data

    if cached
      JSON.parse(cached)
    else
      default_collections_to_empty
      super
    end
  end

  def reify_and_save_implied_models
    begin
      prepare_to_save_implications
      reify_models
      save_models
    ensure
      store_log
    end
  end

  def default_collections_to_empty
    COLLECTIONS.each do |c|
      send("#{c}=", []) unless send(c)
    end
  end

  def prepare_to_save_implications
    # All collections must be enumerable, so make them that way if they aren't.
    default_collections_to_empty

    # We need to make sure we have a logger.
    ensure_logger
  end

  def cache_serialized_representation
    self.original_data = to_json
  end

  def ensure_logger
    return if @sio && @logger

    @sio = StringIO.new
    @logger = Logger.new(@sio).tap do |l|
      l.formatter = Logger::Formatter.new
    end
  end

  def store_log
    self.generation_log = @sio.string
  end
end
