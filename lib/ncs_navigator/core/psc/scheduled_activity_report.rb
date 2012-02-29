require 'logger'
require 'ncs_navigator/core'

module NcsNavigator::Core::Psc
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
    # This report's logger.
    #
    # By default, the logger logs to #{Rails.root}/log/psc.log.
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
        r.rows = data['rows']
      end
    end

    def initialize
      io = File.open("#{Rails.root}/log/psc.log", "a")

      self.logger = ::Logger.new(io)
    end
  end
end
