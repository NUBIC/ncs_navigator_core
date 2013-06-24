# encoding: utf-8

module Reports
  class EventReport
    attr_reader :data_collectors
    attr_reader :date_range
    attr_reader :type_codes
    attr_reader :psc
    attr_reader :logger

    attr_reader :start_date
    attr_reader :end_date

    attr_reader :rows

    def initialize(type_codes, data_collectors, date_range, psc, logger = Rails.logger)
      @data_collectors = data_collectors
      @date_range = date_range
      @type_codes = type_codes
      @psc = psc
      @logger = logger

      parse_dates

      if date_range.blank?
        raise ScopeTooBroadError, 'a date range must be specified'
      end
    end

    # Runs the report.  The report result is accessible via {#rows}.
    #
    # The report is run as follows:
    #
    #     ┌────────────────────┐
    #     │ SAR for date range │
    #     └─────────┬──────────┘
    #               │
    #            ┌──┴───┐ N
    #            │ DCs? ├──────────────┐
    #            └──┬───┘              │
    #               │ Y                │
    #       ┌───────┴────────┐         │
    #       │  Filter by DC  │         │
    #       └───────┬────────┘         │
    #               │                  │
    #    ┌──────────┴───────────┐      │
    #    │ Events by ideal date ├──────┘
    #    └──────────┬───────────┘
    #               │
    #        ┌──────┴───────┐ N
    #        │ Event types? ├──────────┐
    #        └──────┬───────┘          │
    #               │ Y                │
    #    ┌──────────┴─────────────┐    │
    #    │ Reject undesired codes │    │
    #    └──────────┬─────────────┘    │
    #               │                  │
    #            ┌──┴───┐              │
    #            │ Done ├──────────────┘
    #            └──────┘
    #
    # Returns nothing.
    def run
      begin
        start = Time.now.to_i

        report = Psc::ScheduledActivityReport.new(logger)
        report.populate_from_psc(psc, date_range_as_report_filter)

        set = resolve_events(report.activities)

        if data_collectors?
          select_targeted_data_collectors!(set)
        end

        if type_codes?
          select_targeted_event_types!(set)
        end

        @rows = set
      ensure
        finish = Time.now.to_i
        logger.info "Report run took #{finish - start} seconds."
      end
    end

    private

    def date_range?
      [start_date, end_date].any?
    end

    def type_codes?
      !type_codes.blank?
    end

    def data_collectors?
      !data_collectors.blank?
    end

    def parse_dates
      matches = date_range.to_s.match /\[([^,]*),([^,]*)\]/
      return unless matches

      @start_date = matches[1]
      @end_date = matches[2]
    end

    def resolve_events(activities)
      ideal_dates = activities.map(&:ideal_date).uniq

      Event.with_person.where(:psc_ideal_date => ideal_dates).each_with_object([]) do |e, arr|
        matches = activities.select { |a| e.implied_by?(a) }

        unless matches.empty?
          e.scheduled_activities = matches
          arr << e
        end
      end
    end

    def select_targeted_event_types!(rows)
      ets = Hash[*type_codes.zip([true].cycle).flatten]

      rows.select! { |e| ets[e.event_type_code] }
    end

    def select_targeted_data_collectors!(rows)
      dct = Hash[*data_collectors.zip([true].cycle).flatten]

      rows.select! { |e| e.data_collectors.any? { |u| dct[u] } }
    end

    def date_range_as_report_filter
      { :start_date => start_date, :end_date => end_date }.reject { |_, v| v.blank? }
    end
  end
end
