require 'aker'
require 'aker/cas_cli'
require 'set'

module Field
  ##
  # This is meant for use by {::Merge#run}.
  #
  # @private
  class PscSync
    attr_accessor :psc

    attr_accessor :superposition
    attr_accessor :logger

    attr_reader :logger
    attr_reader :events
    attr_reader :instruments
    attr_reader :psc_participants

    def initialize
      @psc_participants = {}
    end

    ##
    # Runs the sync.
    #
    # Returns truthy if sync completed without errors, false otherwise.
    def run
      return false unless prerequisites_satisfied?

      login_to_psc

      # Build {PscParticipant} objects that correspond to the participants in
      # the fieldwork.
      resolve_psc_participants

      # Resolve SAs that correspond to instruments and events in the
      # fieldwork.
      instrument_sa_groups, event_sa_groups =
        prioritize(grouped_instrument_sas, grouped_event_sas)

      # Remove instrument activities that don't need to be synced.
      instrument_sa_groups.each { |g| g.reject_unchanged }

      # Ditto for events.
      event_sa_groups.each { |g| g.reject_unchanged }

      # Update SAs.
      begin
        update(instrument_sa_groups)
        update(event_sa_groups)
      rescue PatientStudyCalendar::ResponseError => e
        logger.error { "PSC sync raised #{e.class}: #{e.message}" }
        false
      end
    end

    ##
    # The Aker configuration to use.
    #
    # This is intended as a testing convenience, but in the future it might
    # make sense to use a separate configuration for machine communication.
    def aker_configuration
      Aker.configuration
    end

    def prerequisites_satisfied?
      prereqs = Prerequisites.new(aker_configuration, logger)

      prereqs.satisfied?
    end

    def update(groups)
      groups.each(&:update)
    end

    def resolve_psc_participants
      @events = superposition.current_events
      @instruments = superposition.current_instruments

      build_psc_participants(events)
      build_psc_participants(instruments)
    end

    def login_to_psc(logger)
      cas_cli = Aker::CasCli.new(aker_configuration)
      username, password = NcsNavigatorCore.machine_account_credentials
      user = cas_cli.authenticate(username, password)

      raise "Authentication as #{username} failed" unless user

      @psc = PatientStudyCalendar.new(user)
    end

    ##
    # @private
    def build_psc_participants(list)
      list.each do |obj|
        p = obj.participant

        unless psc_participants.has_key?(p.id)
          psc_participants[p.id] = PscParticipant.new(psc, p)
        end
      end
    end

    ##
    # Retrieve open SAs for each event or instrument, and group them by the
    # {PscParticipant} matching the event or instrument.
    #
    # Returns an array of (object, SA array) pairs.
    def grouped_sas(collection)
      sa_groups = {}

      collection.each do |obj|
        pscp = psc_participants[obj.participant.id]
        activities = obj.scheduled_activities(pscp)

        sa_groups[pscp] ||= SAGroup.new(pscp, obj, [])
        sa_groups[pscp].add_activities(activities)
      end

      sa_groups.values
    end

    def grouped_event_sas
      grouped_sas(events)
    end

    def grouped_instrument_sas
      grouped_sas(instruments)
    end

    ##
    # SAs belonging to instruments will also belong to events.  They should,
    # however, be updated with a reason stating that the state change occurred
    # due to instrument completion.
    def prioritize(instrument_sa_groups, event_sa_groups)
      instrument_sas = Set.new

      instrument_sa_groups.each do |sa_group|
        instrument_sas += sa_group.sas
      end

      instrument_sa_array = instrument_sas.to_a

      event_sa_groups.each do |sa_group|
        sa_group.remove_activities(instrument_sa_array)
      end

      [instrument_sa_groups, event_sa_groups]
    end

    class SAGroup < Struct.new(:psc_participant, :object, :sas)
      def add_activities(sas)
        self.sas |= sas
      end

      def remove_activities(sas)
        self.sas -= sas
      end

      def reject_unchanged
        desired_sa_state = object.desired_sa_state

        sas.reject! { |sa| sa.current_state == desired_sa_state }
      end

      def update
        packet = {}
        desired_sa_state = object.desired_sa_state
        end_date = object.sa_end_date
        reason = object.sa_state_change_reason

        sas.each do |sa|
          packet[sa.id] = { 'date' => end_date, 'reason' => reason, 'state' => desired_sa_state }
        end

        psc_participant.update_scheduled_activity_states(packet)
      end
    end

    class Prerequisites
      include Aker::Cas::ConfigurationHelper

      attr_reader :configuration
      attr_reader :logger

      def initialize(configuration, logger)
        @configuration = configuration
        @logger = logger
      end

      def satisfied?
        cas_configured?.tap do |ok|
          logger.warn "Prerequisites for PSC sync failed; sync will not run" if !ok
        end
      end

      def cas_configured?
        ok = cas_url

        logger.warn "CAS URL not configured" if !cas_url

        ok
      end
    end
  end
end
