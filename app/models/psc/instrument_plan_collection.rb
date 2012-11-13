require 'forwardable'

module Psc
  ##
  # Given a collection of {ScheduledActivity} objects, groups them by event
  # label and activity ID, and generates a corresponding set of
  # {Psc::InstrumentPlan} objects.
  class InstrumentPlanCollection
    extend Forwardable
    include Enumerable

    def_delegators :@plans, :each

    attr_reader :activities
    attr_reader :groups

    ##
    # Generate a collection for a list of {Psc::ScheduledActivity} objects.
    def self.for(activities)
      new(activities).tap(&:calculate)
    end

    def initialize(activities = nil)
      @activities = activities || []
      @plans = []
    end

    ##
    # Add a {Psc::ScheduledActivity} to the collection.
    def add_activity(a)
      activities << a
    end

    ##
    # Group activities by their contact and event labels.
    def group
      @groups = {}

      activities.each do |a|
        group = [a.contact, a.event]
        @groups[group] ||= []
        @groups[group] << a
      end
    end

    ##
    # For each group calculated by {#group}, generates a {Psc::InstrumentPlan}
    # for the activities in that group.
    #
    # This method also orders instruments in each of the resulting plans, using
    # {Psc::InstrumentPlan#order}.
    def calculate
      @plans = []

      group

      groups.values.each do |activities|
        @plans += plans_for_group(activities)
      end

      @plans.each(&:order)
    end

    ##
    # Given a list of activities, creates a {Psc::InstrumentPlan} for the
    # instruments implied by each activity.
    #
    # Embedded in this method is a distinction between activities that define
    # _root instruments_ and those that do not: a root instrument is an
    # instrument that does not reference any other instruments.  This method
    # returns one plan per root.
    #
    # @private
    def plans_for_group(activities)
      plans = {}

      roots, children = activities.partition(&:instrument)

      roots.each do |activity|
        root = activity.instrument

        plans[activity.survey.access_code] = InstrumentPlan.new(root, [activity.survey])
      end

      children.select(&:referenced_survey).each do |activity|
        referenced_code = activity.referenced_survey.access_code

        unless plans.has_key?(referenced_code)
          raise "Activity #{activity.activity_id} references unknown survey #{referenced_code}"
        end

        plans[referenced_code].surveys << activity.survey
      end

      plans.values
    end
  end
end
