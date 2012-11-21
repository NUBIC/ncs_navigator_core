module Field
  ##
  # Generates event templates and associated objects: {InstrumentPlan}s and
  # {Survey}s.
  class EventTemplateGenerator
    attr_reader :logger

    ##
    # The scheduled activity report from which event templates are built.
    # Usually set by {#populate_from_psc}.
    attr_accessor :scheduled_activity_report

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
    # Retrieves schedule data from PSC and builds event templates from it.
    #
    # Recognized parameters:
    # 
    # @param [PatientStudyCalendar] psc
    # @param [String] date start date for the schedule
    # @param [Array<String>] templates Desired templates: usually the output
    #   of {#templates}, but can be varied if required.
    def populate_from_psc(psc, date, templates)
      data = psc.schedule_preview(date, templates)
    end
  end
end
