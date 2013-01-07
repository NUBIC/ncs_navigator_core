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

    ##
    # Response templates.
    #
    # Set by {#build_response_templates}.
    attr_reader :response_templates

    ##
    # Path to a master list of all response templates.
    RESPONSE_TEMPLATE_FILE = "#{Rails.root}/db/prepopulated_response_set_values.yml"

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
    # Derives event and response templates.
    #
    # Response templates are derived using the collection at
    # {RESPONSE_TEMPLATE_FILE}.
    def generate
      data = begin
               YAML.load(File.read(RESPONSE_TEMPLATE_FILE))
             rescue Errno::ENOENT
               logger.error "Response template file #{RESPONSE_TEMPLATE_FILE} not found; no templates will be generated"
               {}
             end

      derive_models
      build_response_templates(data)
      assign_response_templates
    end

    ##
    # Uses schedule data from PSC to derive event templates and related models:
    # events, instruments, instrument plans, and surveys.
    def derive_models
      filter_schedule
      scheduled_activity_report.derive_models
      build_event_templates
    end

    ##
    # Removes activities in accordance with Cases' configuration.
    def filter_schedule
      if !NcsNavigatorCore.configuration.with_specimens?
        scheduled_activity_report.without_collection!
      end
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
      @event_templates = events.map do |e|
        EventTemplate.new(e).tap { |et| add_instruments_to_template(et) }
      end
    end

    ##
    # Builds response templates for the events in this generator.
    #
    # The collection passed to this method must be a Hash of the form
    #
    #     { "event label" => {
    #         "survey title" => [
    #           { "qref" => "question reference identifier",
    #             "aref" => "answer reference identifier"
    #           },
    #           ...
    #         ],
    #         ...
    #       },
    #       ...
    #     }
    #
    # @param [Hash] collection the collection of response templates to use
    def build_response_templates(collection)
      # Collect survey titles for resolution.
      relevant = events.map { |e| [e.label, collection[e.label]] }.reject { |_, spec| !spec }.each

      titles = relevant.with_object([]) do |(_, spec), a|
        spec.each { |survey_title, _| a << survey_title }
      end

      # Resolve titles to public IDs.
      map = Survey.select([:title, :api_id]).where(:title => titles).each_with_object({}) { |s, h| h[s.title] = s.api_id }

      # Make a second pass at the relevant templates to build
      # {ResponseTemplate} objects.
      @response_templates = relevant.with_object({}) do |(event_label, spec), h|
        h[event_label] = []

        spec.each do |survey_title, refs|
          survey_id = map[survey_title]

          if !survey_id
            logger.warn "Cannot resolve public ID for survey #{survey_title}.  Its templates will not be provided to Field."
            next
          end

          refs.each do |ref|
            h[event_label] << ResponseTemplate.new(ref['aref'].to_s, ref['qref'].to_s, survey_id, ref['value'])
          end
        end
      end
    end

    def assign_response_templates
      event_templates.each do |et|
        et.response_templates = response_templates[et.event.label] || []
      end
    end

    def add_instruments_to_template(et)
      et.instruments += instruments.select { |i| i.event == et.event }
    end
  end
end
