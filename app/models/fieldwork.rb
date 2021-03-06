# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130129202515
#
# Table name: fieldworks
#
#  client_id           :string(255)
#  contact_links       :text
#  contacts            :text
#  created_at          :datetime
#  end_date            :date
#  event_templates     :text
#  events              :text
#  fieldwork_id        :string(36)
#  generated_for       :string(255)
#  generation_log      :text
#  id                  :integer          not null, primary key
#  instrument_plans    :text
#  instruments         :text
#  latest_merge_id     :integer
#  latest_merge_status :string(255)
#  original_data       :binary
#  people              :text
#  staff_id            :string(255)
#  start_date          :date
#  surveys             :text
#  updated_at          :datetime
#

require 'celluloid'
require 'set'
require 'stringio'
require 'thread'
require 'uuidtools'

class Fieldwork < ActiveRecord::Base
  include Field::ModelResolution
  include Field::Serialization
  include NcsNavigator::Core::Field

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
  COLLECTIONS = {
    contact_links:    lambda { Set.new },
    contacts:         lambda { Set.new },
    event_templates:  lambda { Set.new },
    events:           lambda { Set.new },
    instrument_plans: lambda { Set.new },
    instruments:      lambda { SortedSet.new },
    people:           lambda { Set.new },
    surveys:          lambda { SortedSet.new }
  }

  ##
  # Collections are saved to this record.  The JSON for this set is regenerated
  # when they change.
  COLLECTIONS.keys.each { |k| serialize k }

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
    prepare_for_population

    @coll_lock = Mutex.new

    begin
      t1 = Celluloid::Future.new { add_event_template_data(psc) }
      t2 = Celluloid::Future.new { add_scheduled_activity_report_data(psc) }
      ok = [t1, t2].all?(&:value)
    ensure
      store_log
    end
  end

  def add_event_template_data(psc)
    etg = Field::EventTemplateGenerator.new(logger)
    etg.populate_from_psc(psc, start_date, etg.templates)
    etg.generate

    @coll_lock.synchronize do
      self.event_templates += etg.event_templates
      self.instrument_plans += etg.instrument_plans
      self.surveys += etg.surveys
    end
  end

  def add_scheduled_activity_report_data(psc)
    params = {
      :current_user => generated_for,
      :end_date => end_date,
      :start_date => start_date,
      :state => Psc::ScheduledActivity::SCHEDULED
    }

    report = Field::ScheduledActivityReport.new(logger)
    report.populate_from_psc(psc, params)
    report.derive_models

    @coll_lock.synchronize do
      self.contact_links += report.contact_links
      self.contacts += report.contacts
      self.events += report.events
      self.instrument_plans += report.instrument_plans
      self.instruments += report.instruments
      self.people += report.people
      self.surveys += report.surveys
    end
  end

  def collections_changed?
    COLLECTIONS.keys.any? { |k| send("#{k}_changed?") }
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
    prepare_for_population

    begin
      reify_models
      save_models
    ensure
      store_log
    end
  end

  def default_collections_to_empty
    COLLECTIONS.each do |k, gen|
      send("#{k}=", gen.call) unless send(k)
    end
  end

  def prepare_for_population
    # All collections must be enumerable, so make them that way if they aren't.
    default_collections_to_empty

    # We need to make sure we have a logger.
    ensure_logger
  end

  def cache_serialized_representation
    self.original_data = to_json
  end

  def ensure_logger
    return if @logdev && @logger

    @logdev = LogDevice.new(StringIO.new)
    @logger = Logger.new(@logdev).tap do |l|
      l.formatter = LogFormatter.new(self)
    end
  end

  def store_log
    @logdev.rewind
    self.generation_log = @logdev.read
  end
end
