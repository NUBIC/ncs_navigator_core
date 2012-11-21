# -*- coding: utf-8 -*-

module Psc
  ##
  # Wraps PSC's scheduled activities report.
  class ScheduledActivityReport
    ##
    # The logger.
    attr_reader :logger

    ##
    # Filters used in generating the report, if any.  Usually set by
    # {#populate_from_report}.
    #
    # @return Hash
    attr_reader :filters

    ##
    # The backing ScheduledActivityCollection.
    attr_reader :activities

    def initialize(logger)
      @logger = logger
    end

    ##
    # Builds a ScheduledActivityReport from PSC data.
    #
    # See {PatientStudyCalendar#scheduled_activities_report} for available
    # filters.
    #
    # @param [#scheduled_activities_report] psc a PSC client
    # @param Hash filters report filters
    def populate_from_psc(psc, filters)
      data = psc.scheduled_activities_report(filters)

      populate_from_report(data)
    end

    ##
    # Populates this report from scheduled activity report data.
    def populate_from_report(data)
      @activities = ScheduledActivityCollection.from_report(data)
      @filters = data['filters']
    end

    ##
    # Populates this report from participant schedule data.
    #
    # This also includes data such as schedule previews; see i.e.
    # {Field::EventTemplateGenerator} for an example use.
    def populate_from_schedule(data)
      @activities = ScheduledActivityCollection.from_schedule(data)
    end
  end
end
