##
# Shorthand for working with {Psc::ScheduledActivity} objects.
module ScheduledActivities
  def sa(attrs)
    Psc::ScheduledActivity.new(attrs)
  end
end
