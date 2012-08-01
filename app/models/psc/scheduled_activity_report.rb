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
      @surveys = Collection.new
    end

    ##
    # Generates intermediate representations of Cases entities from the report.
    def process
      logger.info 'Mapping started'

      [contact_links, contacts, events, instruments, people, surveys].each(&:clear)

      activities.each do |activity|
        p = add_person(activity)
        c = add_contact(activity, p)
        e = add_event(activity, c, p)
        s = add_survey(activity)
        i = add_instrument(activity, s, e, p) if s && e

        add_contact_link(p, c, e, i)
      end

      logger.info 'Mapping complete'
    end

    ##
    # @private
    def add_contact_link(person, contact, event, instrument)
      contact_links << ContactLink.new(person, contact, event, instrument)
    end

    ##
    # @private
    def add_contact(activity, person)
      contacts << Contact.new(activity.activity_date, person)
    end

    ##
    # @private
    def add_event(activity, contact, person)
      el = activity.event_label

      events << Event.new(el, activity.ideal_date, contact, person) if el
    end

    ##
    # @private
    def add_instrument(activity, survey, event, person)
      instruments << Instrument.new(survey, activity.activity_name, event, person)
    end

    ##
    # @private
    def add_person(activity)
      people << Person.new(activity.person_id)
    end

    ##
    # @private
    def add_survey(activity)
      il = activity.instrument_label

      surveys << Survey.new(il) if il
    end

    # Intermediate representatations start here.
    #
    # These are used to map entities in the scheduled activity report to Cases'
    # entities.

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

    ##
    # {ContactLink} representation.
    class ContactLink < Struct.new(:person, :contact, :event, :instrument)
      attr_accessor :model
    end

    ##
    # Representation of a {Contact} from an SA report.
    class Contact < Struct.new(:scheduled_date, :person)
      attr_accessor :model
    end

    ##
    # {Event} representation.
    class Event < Struct.new(:label, :ideal_date, :contact, :person)
      attr_accessor :model
    end

    ##
    # {Instrument} representation.
    class Instrument < Struct.new(:survey, :name, :event, :person)
      attr_accessor :model
    end

    ##
    # {Person} representation.
    class Person < Struct.new(:person_id)
      attr_accessor :model
      attr_accessor :participant_model
    end

    ##
    # {Survey} representation.
    class Survey < Struct.new(:instrument_label)
      attr_accessor :model

      def access_code
        instrument_label.match(/^instrument:(.+)_v[\d\.]+/i)[1]
      end
    end
  end
end
