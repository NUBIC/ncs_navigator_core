# -*- coding: utf-8 -*-

require 'set'

module Psc
  ##
  # Wraps PSC's scheduled activities report.
  class ScheduledActivityReport
    ##
    # Logger.  Defaults to Rails.logger.
    attr_accessor :logger

    # These are collections of entities implied by the report.  They're
    # intermediate representations of entities; see below for more information.

    attr_reader :contact_links
    attr_reader :contacts
    attr_reader :events
    attr_reader :instruments
    attr_reader :instrument_plans
    attr_reader :people
    attr_reader :surveys

    ##
    # Filters used in generating the report.
    #
    # @return Hash
    attr_reader :filters

    ##
    # The backing ScheduledActivityCollection.
    attr_reader :activities

    ##
    # Builds a ScheduledActivityReport from PSC data.
    #
    # See {PatientStudyCalendar#scheduled_activities_report} for available
    # filters.
    #
    # @param [#scheduled_activities_report] psc a PSC client
    # @param Hash filters report filters
    def self.from_psc(psc, filters)
      data = psc.scheduled_activities_report(filters)

      from_json(data)
    end

    ##
    # Builds a ScheduledActivityReport from parsed JSON data.
    def self.from_json(data)
      coll = ScheduledActivityCollection.from_report(data)

      new(coll, data['filters'])
    end

    def initialize(coll = ScheduledActivityCollection.new, filters = {})
      self.logger = Rails.logger

      @filters = filters
      @activities = coll

      @contact_links = Set.new
      @contacts = Set.new
      @events = Set.new
      @instruments = Set.new
      @instrument_plans = Set.new
      @people = Set.new
      @surveys = Set.new
    end

    ##
    # Generates intermediate representations of Cases entities from the report.
    def process
      logger.info 'Mapping started'

      [contact_links, contacts, events, instruments, instrument_plans, people, surveys].each(&:clear)

      activities.each do |activity|
        activity.derive_implied_entities

        people << activity.person
        contacts << activity.contact
        events << activity.event
        contact_links << activity.contact_link
      end

      plans = InstrumentPlanCollection.for(activities)

      plans.each do |plan|
        instruments << plan.root
        instrument_plans << plan

        plan.surveys.each { |s| surveys << s }
      end

      logger.info 'Mapping complete'
    end
  end
end
