# -*- coding: utf-8 -*-

module Psc
  ##
  # Wraps PSC's scheduled activities report.
  class ScheduledActivityReport
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
    # Logger.  Defaults to Rails.logger.
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

      from_json(data)
    end

    ##
    # Builds a ScheduledActivityReport from parsed JSON data.
    def self.from_json(data)
      new.tap do |r|
        r.filters = data['filters']
        r.rows = data['rows']
        r.process
      end
    end

    def initialize
      self.rows = []
      self.logger = Rails.logger
    end

    ##
    # A no-op by default.  Subclasses can redefine this method to process the
    # PSC report data.
    def process
    end
  end
end
