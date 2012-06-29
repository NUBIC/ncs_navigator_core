# -*- coding: utf-8 -*-

require 'logger'
require 'ncs_navigator/core'

module NcsNavigator::Core::Psc
  ##
  # Wraps PSC's scheduled activities report.
  class ScheduledActivityReport
    autoload :JsonForFieldwork, 'ncs_navigator/core/psc/scheduled_activity_report/json_for_fieldwork'
    autoload :Logging,          'ncs_navigator/core/psc/scheduled_activity_report/logging'
    autoload :Merge,            'ncs_navigator/core/psc/scheduled_activity_report/merge'

    include ActiveSupport::Callbacks

    define_callbacks :map_entities
    define_callbacks :map_persons, :map_events, :map_instruments, :map_contacts

    include JsonForFieldwork
    include Logging

    ##
    # Associations (rooted at {Person}) to eager-load when mapping report rows
    # to Core entities.
    MAPPING_ASSOCIATIONS = [
      # for mapping entities
      {
        :participant_person_links => {
          :participant => [
            {
              :events => [
                :instruments, :contacts
              ],
            },
            {
              :people => [
                { :addresses => :state },
                :telephones,
                :emails
              ]
            }
          ]
        }
      },

      # for Instrument#link_to
      :contact_links
    ]

    ##
    # Filters used in generating the report.
    #
    # @return Hash
    attr_accessor :filters

    ##
    # Rows of the report.
    #
    # @return Array
    attr_accessor :rows

    ##
    # This report's logger.  By default, this is a Logger that bit-buckets its
    # messages; set it to another Logger-like object if you want logs.
    attr_accessor :logger

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

      new.tap do |r|
        r.filters = data['filters']
        r.rows = data['rows'].map { |r| Row.new(r) }
      end
    end

    def initialize
      self.rows = []
      self.logger = ::Logger.new(nil)
    end

    ##
    # Maps entities referenced in the scheduled activities report to Core entities.
    def map_entities
      run_callbacks :map_entities do
        map_persons
        map_events
        map_instruments
        map_contacts
      end
    end

    ##
    # Invokes #save across all dirty entities in an all-or-nothing fashion.
    # Requires the name of the user performing the save.
    #
    # If any entity could not be saved, returns false; otherwise, returns
    # true.
    def save_entities(staff_id)
      ActiveRecord::Base.transaction do
        contacts_ok = rows.select(&:contact).all? { |r| r.contact.save }

        raise ActiveRecord::Rollback unless contacts_ok

        instruments_ok = rows.select(&:instrument).all? do |r|
          instr = r.instrument

          instr.save and
            instr.link_to(r.person, r.contact, r.event, staff_id).save
        end

        raise ActiveRecord::Rollback unless instruments_ok

        contacts_ok && instruments_ok
      end
    end

    ##
    # For each row, maps #subject/person_id to the {Person} having that person_id.
    # with the {Person} having that person_id.  If no such mapping can be
    # made, maps the person_id to nil.
    #
    # NB: {Participant} access is accomplished via Person#participant.  See
    # {Row} for more information.
    def map_persons
      run_callbacks :map_persons do
        ids = rows.map(&:person_id).uniq

        {}.tap do |map|
          Person.where(:person_id => ids).
            includes(MAPPING_ASSOCIATIONS).
            each { |p| map[p.person_id] = p }

          rows.each { |r| r.person = map[r.person_id] }
        end
      end
    end

    ##
    # For each row, find the first event label that matches an {Event}
    # belonging to that row's {Participant}, and sets the row's event
    # attribute to that Event.
    #
    # The semantics of the match are defined by {Person#matches_activity}.
    #
    # The row's event will be nil if no event label matches an event on the
    # Participant.
    def map_events
      run_callbacks :map_events do
        rows_with_events.each do |r|
          possible = r.participant.try(:events) || []
          expected = OpenStruct.new(:labels => r.event_label, :ideal_date => r.ideal_date)
          accepted = possible.detect { |event| event.matches_activity(expected) }

          r.event = accepted
        end
      end
    end

    def rows_with_events
      rows.select(&:event_label)
    end

    ##
    # For each row, finds or builds the first {Instrument} on the row's
    # {Event} that matches the instrument label for the row.
    #
    # This method also stores the {Survey} relating to the Instrument.
    #
    # The semantics of the match are defined by stripping the version from the
    # instrument label and using the remainder as the input to
    # {Survey.most_recent_for_access_code}.
    #
    # The row's instrument will be nil if any of the following are true:
    #
    # - a person cannot be found for the row
    # - a survey cannot be found for the row
    # - an event cannot be found for the row
    def map_instruments
      run_callbacks :map_instruments do
        {}.tap do |survey_map|
          targeted = rows_with_instruments

          targeted.map(&:survey_access_code).uniq.each do |sac|
            survey_map[sac] = Survey.most_recent_for_access_code(sac)
          end

          targeted.each do |r|
            r.survey = survey_map[r.survey_access_code]

            if r.person && r.survey && r.event
              r.instrument = Instrument.start(r.person, r.survey, r.event)
            end
          end
        end
      end
    end

    def rows_with_instruments
      rows.select(&:instrument_label)
    end

    ##
    # For each row, finds or builds a {Contact} for the row's {Event}.
    #
    # The set of possible contacts for a row is built by retrieving all
    # contacts for the row's event that have a blank end time.  From that set,
    # the first contact that has a contact date equal to the row's scheduled
    # date is selected.
    #
    # If no such contact exists, a contact matching those criteria is
    # instantiated, associated with the event and scheduled date, and re-used
    # for future occurrences of (event, scheduled_date).
    #
    # If the row's event is nil, then this method sets the row's contact to
    # nil.
    def map_contacts
      run_callbacks :map_contacts do
        new_cache = {}

        rows_with_contacts.each do |r|
          possible = r.event.contacts
          accepted = possible.detect { |c| c.contact_date == r.scheduled_date && c.contact_end_time.blank? }

          r.contact = if accepted
                        accepted
                      else
                        key = [r.event, r.scheduled_date]

                        unless new_cache.has_key?(key)
                          new_cache[key] = Contact.start(r.person, :contact_date => r.scheduled_date)
                        end

                        new_cache[key]
                      end
        end
      end
    end

    def rows_with_contacts
      rows.select(&:event)
    end

    ##
    # Wraps a report row with links back to Core entities such as the
    # referenced participant, event, and instrument.
    class Row
      attr_accessor :contact
      attr_accessor :event
      attr_accessor :instrument
      attr_accessor :person
      attr_accessor :survey

      attr_reader :row

      def initialize(row)
        @row = row
      end

      def ==(other)
        other.to_hash == row
      end

      def to_hash
        row
      end

      def participant
        person.try(:participant)
      end

      def ideal_date
        row['ideal_date']
      end

      def event_label
        row['labels'].detect { |l| l =~ /^event:/ }
      end

      def instrument_label
        row['labels'].detect { |l| l =~ /^instrument:/ }
      end

      def scheduled_date
        row['scheduled_date']
      end

      def survey_access_code
        instrument_label.match(/instrument:(.+)_v[\d\.]+/i)[1]
      end

      def person_id
        row['subject']['person_id']
      end
      
      def activity_name
        row['activity_name']
      end
    end
  end
end
