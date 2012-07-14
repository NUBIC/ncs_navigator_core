class InstrumentPlan

  attr_accessor :scheduled_activities

  ##
  # Creates a new instance of the InstrumentPlan
  def initialize(schedule)
    raise "No parameter supplied to build plan" if schedule.blank?
    @scheduled_activities = []
    parse_schedule(schedule)
    # associate_scheduled_activity_with_participant
  end

  ##
  # Takes the PSC schedule and creates several ScheduledActivity
  # objects from the data
  # @param [Hash]
  def parse_schedule(schedule)
    activities(schedule).each do |activity|
      @scheduled_activities << ScheduledActivity.new(
        scheduled_activity_attrs_from_activity(activity))
    end
  end

  ##
  # Take PSC scheduled activities and creates array
  # from activities node
  # @param [Hash]
  def activities(schedule)
    result = []
    if schedule && schedule["days"]
      schedule["days"].values.each do |date|
        date["activities"].each do |activity|
          result << activity
        end
      end
    end
    result
  end

  ##
  # Build hash from PSC activity node
  # @param [Hash]
  # @return [Hash]
  def scheduled_activity_attrs_from_activity(activity)
    result = Hash.new
    result[:study_segment] = activity['study_segment'].to_s
    result[:activity_id]   = activity['id']
    result[:ideal_date]    = activity['ideal_date']
    result[:labels]        = activity['labels']
    result[:activity_name] = activity['activity']['name'] if activity['activity']
    result[:activity_type] = activity['activity']['type'] if activity['activity']
    result[:current_state] = activity['current_state']['name'] if activity['current_state']
    result[:date]          = activity['current_state']['date'] if activity['current_state']
    result[:person_id]     = activity['assignment']['id'] if activity['assignment']
    result
  end

  ##
  # Returns the unique events from the
  # @scheduled_activities attribute ordered by ideal_date
  # @return [Array<String>]
  def events
    @scheduled_activities.sort_by{ |a| a.ideal_date }.map(&:event).uniq
  end

  ##
  # Returns all the instruments from the
  # @scheduled_activities attribute
  # @return [Array<String>]
  def instruments(event = nil)
    sas = event.nil? ? @scheduled_activities : @scheduled_activities.select{ |sa| sa.event == event }
    sas.sort_by{ |a| [a.ideal_date, a.order.to_s] }.map(&:instrument).compact
  end

  ##
  # Returns the next instrument for the event based on the
  # given current instrument
  # @param [String] - the event context
  # @param [String] - the current_instrument or nil
  # @return [String] - the instrument following the given current_instrument
  def next_instrument(event, current_instrument = nil)
    ins = self.instruments(event)
    current_instrument.blank? ? ins.first : ins[ins.index(current_instrument) + 1]
  end

end