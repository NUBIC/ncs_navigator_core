require 'forwardable'

module Field
  ##
  # Generates event templates and associated objects: {InstrumentPlan}s and
  # {Survey}s.
  class EventTemplateGenerator
    extend Forwardable

    attr_reader :logger

    ##
    # The scheduled activity report from which event templates are built.
    #
    # This is set by {#populate_from_psc}.
    attr_reader :scheduled_activity_report

    ##
    # Instrument plans and surveys built in the report.
    #
    # Plans are referenced by event templates; surveys are referenced by plans.
    def_delegators :scheduled_activity_report, :instrument_plans, :surveys

    ##
    # Conveniences for {#build_event_templates},
    def_delegators :scheduled_activity_report, :events, :instruments

    ##
    # Event templates.
    #
    # This is set by {#derive_models}.
    attr_reader :event_templates

    def initialize(logger)
      @logger = logger
    end

    ##
    # Returns names of event templates for a given recruitment strategy.
    #
    # Currently, study segment names are used to identify event templates.
    # See {RecruitmentStrategy#field_event_templates} for more information.
    def templates
      NcsNavigatorCore.recruitment_strategy.field_event_templates
    end

    ##
    # Retrieves schedule data from PSC.
    #
    # Recognized parameters:
    #
    # @param [PatientStudyCalendar] psc
    # @param [String] date start date for the schedule
    # @param [Array<String>] templates Desired templates: usually the output
    #   of {#templates}, but can be varied if required.
    def populate_from_psc(psc, date, templates)
      data = psc.schedule_preview(date, templates)

      @scheduled_activity_report = Field::ScheduledActivityReport.new(logger)
      @scheduled_activity_report.populate_from_schedule(data)
    end

    ##
    # Uses schedule data from PSC to derive event templates and related models:
    # events, instruments, instrument plans, and surveys.
    def derive_models
      scheduled_activity_report.derive_models

      build_event_templates
    end

    ##
    # For activities that are associated with instruments, assigns each
    # instrument to its event template.
    #
    # Some activities (i.e. Informed Consent) are currently associated with
    # events but not instruments; this method handles those cases by
    # instantiating instrumentless templates.
    #
    # @private
    def build_event_templates
      tmap = {}

      events.each { |ev| tmap[ev] = EventTemplate.new(ev) }

      instruments.each do |inst|
        ev = inst.event

        # If this happens, something went very wrong -- likely a bug in the
        # scheduled activity report code.  The only sane thing to do here is to
        # bug out.
        if !tmap.has_key?(ev)
          raise "Instrument has event #{ev.inspect} which doesn't occur in event collection"
        end

        tmap[ev].instruments << inst
      end

      @event_templates = tmap.values
    end
  end
end
