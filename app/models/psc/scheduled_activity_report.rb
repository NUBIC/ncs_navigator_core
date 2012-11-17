# -*- coding: utf-8 -*-

module Psc
  ##
  # Wraps PSC's scheduled activities report.
  class ScheduledActivityReport
    include ModelDerivation

    ##
    # Logger.  Defaults to Rails.logger.
    attr_accessor :logger

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
    end

    def process
      derive_models
    end
  end
end
