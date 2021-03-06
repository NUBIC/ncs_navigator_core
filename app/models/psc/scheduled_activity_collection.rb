require 'forwardable'

module Psc
  ##
  # An orderable collection of {ScheduledActivity} objects.
  #
  # ScheduledActivityCollection may be initialized with:
  #
  # * nothing (.new)
  # * a PSC participant schedule (.from_schedule)
  # * a PSC scheduled activity report (.from_report)
  #
  # Sorting
  # =======
  #
  # By default, a ScheduledActivityCollection's activities are ordered as they
  # were received from PSC.  ScheduledActivityCollection is an enumerable
  # object, so you may define other orderings via #sort_by or #sort.  (Note,
  # however, that {ScheduledActivity} objects have no natural order, so you
  # MUST supply a block to #sort.)
  class ScheduledActivityCollection
    extend Forwardable
    include Enumerable

    def_delegators :@arr, :length, :each

    ##
    # Instantiates a collection from a scheduled activity report.
    # If given nil, returns an empty collection.
    #
    # @see PatientStudyCalendar#scheduled_activities_report
    def self.from_report(report)
      new.tap do |c|
        break c if report.nil?

        report['rows'].each { |r| c.add_from_report(r) }
      end
    end

    ##
    # Instantiates a collection from a participant schedule.
    # If given nil, returns an empty collection.
    #
    # @see PatientStudyCalendar#schedules
    def self.from_schedule(schedule)
      new.tap do |c|
        break c if schedule.nil?

        schedule['days'].values.each do |d|
          d['activities'].each { |a| c.add_from_schedule(a) }
        end
      end
    end

    def initialize
      @arr = []
    end

    def add_from_report(row)
      @arr << ScheduledActivity.from_report(row)
    end

    def add_from_schedule(row)
      @arr << ScheduledActivity.from_schedule(row)
    end

    def reject!(&block)
      @arr.reject!(&block)
    end
  end
end
