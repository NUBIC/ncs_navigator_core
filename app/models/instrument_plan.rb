class InstrumentPlan

  attr_accessor :scheduled_activities

  ##
  # Creates a new instance of the InstrumentPlan
  def initialize(schedule)
    raise "No parameter supplied to build plan" if schedule.blank?
    @scheduled_activities = []
    parse_schedule(schedule)
    associate_scheduled_activity_with_participant
  end

  ##
  # Takes the PSC schedule and creates several ScheduledActivity
  # objects from the data
  #
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
  #
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
  #
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
  # Sets the participant attribute on the ScheduledActivity
  # based on the participant_type.
  # If the participant_type is 'child', ensure that there is an activity
  # for each child.
  def associate_scheduled_activity_with_participant
    child_activities = []
    @scheduled_activities.each do |sa|
      if participant = Person.where(:person_id => sa.person_id).first.try(:participant)
        case sa.participant_type
        when 'self'
          sa.participant = participant
        when 'child'
          children = participant.children
          if children.size == 1
            sa.participant = children.first.participant
          else
            children.each_with_index do |child, ind|
              cp = children[ind].participant
              if ind == 0
                sa.participant = cp
              else
                copy = sa.copy
                copy.participant = cp
                child_activities << copy
              end
            end
          end
        end
      end
    end
    child_activities.each { |ca| @scheduled_activities << ca } unless child_activities.blank?
    @scheduled_activities.sort!
  end

  ##
  # Returns the unique events from the
  # @scheduled_activities attribute ordered by ideal_date
  #
  # @return [Array<String>]
  def events
    @scheduled_activities.sort_by{ |a| a.ideal_date }.map(&:event).uniq
  end

  ##
  # Returns all the instruments from the
  # @scheduled_activities attribute
  #
  # @return [Array<String>]
  def instruments(event = nil)
    activities_for_event(event).sort_by{ |a| [a.ideal_date, a.order.to_s] }.map(&:instrument).compact
  end

  ##
  # Returns all ScheduledActivities for the given event
  #
  # @param [String] - the event
  # @return [Array<ScheduledActivity>]
  def activities_for_event(event = nil)
   event.nil? ? @scheduled_activities : @scheduled_activities.select{ |sa| sa.event == event }
  end

  ##
  # Returns the next instrument for the event based on the
  # given current instrument
  #
  # @param [String] - the event context
  # @param [String] - the current_instrument or nil
  # @return [String] - the instrument following the given current_instrument
  def next_instrument(event, current_instrument = nil)
    ins = self.instruments(event)
    current_instrument.blank? ? ins.first : ins[ins.index(current_instrument) + 1]
  end

  ##
  # Returns the Instrument record for this survey_title and
  # person
  #
  # @param [String] - the survey title
  # @return Instrument record or nil
  def instrument_record_for(survey_title)
    sa  = scheduled_activity_for_instrument(survey_title)
    per = sa.person

    title = sa.references.blank? ? survey_title : sa.references
    sur = Survey.most_recent_for_title(title)

    if per && sur
      Instrument.where("person_id = ? AND survey_id = ? AND
                        (instrument_end_date IS NULL AND instrument_end_time IS NULL AND instrument_status_code <> 4)",
                        per.id, sur.id).first
    end
  end

  ##
  # Find the scheduled_activity for the given survey_title
  # The survey title should uniquely identify a scheduled activity in the instrument plan
  #
  # @param [String] - survey title
  # @return [ScheduledActivity]
  def scheduled_activity_for_instrument(survey_title)
    @scheduled_activities.select { |sa| sa.instrument == survey_title }.first
  end

end