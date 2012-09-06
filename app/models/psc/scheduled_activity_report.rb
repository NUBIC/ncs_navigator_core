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

      @contact_links = Collection.new
      @contacts = Collection.new
      @events = Collection.new
      @instruments = Collection.new
      @people = Collection.new

      @instrument_plans = {}
    end

    ##
    # Generates intermediate representations of Cases entities from the report.
    def process
      logger.info 'Mapping started'

      [contact_links, contacts, events, instruments, instrument_plans, people].each(&:clear)

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

        add_plan(plan)
      end

      logger.info 'Mapping complete'
    end

    ##
    # @private
    def add_plan(plan)
      instrument_plans[plan.root] = plan.activities.map do |a|
        { :template => a.survey, :participant_type => a.participant_type_label }
      end
    end

    ##
    # A collection of IRs.
    class Collection
      include Enumerable

      def initialize
        @set = {}
      end

      ##
      # Given two value objects v1 and v2 that are eql but not equal[0],
      # selects the first of [v1, v2] added to the collection, and returns it
      # for all subsequent << operations.
      #
      # We do this because mutating non-comparable state on value objects is
      # quite convenient when it comes to model resolution.
      #
      # [0]: See http://ruby-doc.org/core-1.9.3/Object.html#method-i-eql-3F.
      #
      # In short:
      #
      #     class S < Struct.new(:foo); end
      #
      #     a = S.new
      #     b = S.new
      #
      #     a.object_id != b.object_id  # => true
      #
      #     a.eql?(b)   # => true
      #     a.equal?(b) # => false
      def <<(item)
        if @set.has_key?(item)
          @set[item]
        else
          @set[item] = item
        end

        @set[item]
      end

      def each
        @set.values.each { |v| yield v }
      end

      def clear
        @set.clear
      end

      ##
      # For testing.
      def ==(other)
        Set.new(@set.values) == Set.new(other)
      end

      ##
      # For testing.
      def models
        Set.new(map(&:model))
      end
    end
  end
end
