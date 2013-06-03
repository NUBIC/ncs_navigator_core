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

      if [data_collectors?, type_codes?, date_range?].none?
        raise ScopeTooBroadError, 'at least one criterion must be specified'
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

        @rows = if type_codes?
                  start_with_event_types
                elsif date_range?
                  start_with_date_range
                elsif data_collectors?
                  start_with_data_collectors
                end
      ensure
        finish = Time.now.to_i
        logger.info "Report run took #{finish - start} seconds."
      end
    end

    private

    def start_with_event_types
      set = Event.where(:event_type_code => type_codes)
      set = set.with_psc_data(psc)

      if date_range?
        set.select! { |e| e.scheduled_date.try(:between?, start_date, end_date) }
      end

      if data_collectors?
        select_targeted_data_collectors!(set)
      end

      set
    end

    def start_with_date_range
      report = Psc::ScheduledActivityReport.new(logger)
      report.populate_from_psc(psc, date_range_as_report_filter)

      set = implied_events(report.activities)

      if data_collectors?
        select_targeted_data_collectors!(set)
      end

      set
    end

    def start_with_data_collectors
      reports = data_collectors.map do |dc|
        Psc::ScheduledActivityReport.new(logger).tap do |r|
          r.populate_from_psc(psc, :current_user => dc)
        end
      end

      all_activities = reports.map { |r| r.activities.to_a }.flatten

      implied_events(all_activities)
    end

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

    def implied_events(activities)
      ideal_dates = activities.map(&:ideal_date).uniq

      Event.where(:psc_ideal_date => ideal_dates).each_with_object([]) do |e, arr|
        matches = activities.select { |a| e.implied_by?(a) }

        unless matches.empty?
          e.scheduled_activities = matches
          arr << e
        end
      end
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
