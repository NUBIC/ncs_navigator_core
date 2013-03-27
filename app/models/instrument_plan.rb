class InstrumentPlan

  attr_accessor :all_activities, :scheduled_activities, :occurred_activities

  def self.from_schedule(schedule = nil)
    raise "No parameter supplied to build plan" if schedule.blank?

    new.tap { |p| p.populate_from_schedule(schedule) }
  end

  ##
  # Creates a new instance of the InstrumentPlan
  def initialize(activities = [])
    @scheduled_activities = activities
    @all_activities = []
    @occurred_activities = []
  end

  def populate_from_schedule(schedule)
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
      sa = ScheduledActivity.new(scheduled_activity_attrs_from_activity(activity))
      @all_activities << sa
      @scheduled_activities << sa if (sa.scheduled? || sa.conditional?)
      @occurred_activities << sa if sa.occurred?
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
    result[:activity_time] = activity['current_state']['time'] if activity['current_state']['time']
    result[:person_id]     = activity['assignment']['id'] if activity['assignment']
    result
  end

  ##
  # Sets the participant attribute on the ScheduledActivity
  # based on the participant_type.
  # If the participant_type is 'child', ensure that there is an activity
  # for each child.
  def associate_scheduled_activity_with_participant
    [@scheduled_activities, @all_activities].each do |coll|
      child_activities = []
      coll.each do |sa|
        if participant = Person.where(:person_id => sa.person_id).first.try(:participant)
          case sa.participant_type
          when 'mother'
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
      child_activities.each { |ca| coll << ca } unless child_activities.blank?
      coll.sort!
    end
  end

  ##
  # Returns the unique event labels from the
  # @scheduled_activities attribute ordered by ideal_date
  #
  # @return [Array<String>]
  def events
    @scheduled_activities.sort_by{ |a| a.ideal_date }.map(&:event).uniq
  end

  ##
  # Returns all ScheduledActivities for the given event
  #
  # TODO: revert check for nil after #3341 is complete
  #
  # @param [Event] - the event
  # @return [Array<ScheduledActivity>]
  def scheduled_activities_for_event(event)
    return @scheduled_activities if event.nil?
    @scheduled_activities.select{ |sa| event.matches_activity(sa) }
  end

  ##
  # Returns all Activities for the given event
  #
  # TODO: revert check for nil after #3341 is complete
  #
  # @param [Event]
  # @return [Array<ScheduledActivity>]
  def activities_for_event(event)
    return @all_activities if event.nil?
    @all_activities.select{ |sa| event.matches_activity(sa) }
  end

  ##
  # Returns all OccurredActivities for the given event
  #
  # TODO: revert check for nil after #3341 is complete
  #
  # @param [Event]
  # @return [Array<ScheduledActivity>]
  def occurred_activities_for_event(event)
    return @occurred_activities if event.nil?
    @occurred_activities.select{ |oa| event.matches_activity(oa) }
  end

  ##
  # Given a response_set, determine if this is the final
  # part of a multi-part survey.
  # This should be true if there are as many (or more) response_sets
  # for this survey as there are scheduled survey parts.
  # If this is a Informed Consent survey - there is only one part.
  #
  # @param[ResponseSet]
  # @param [Event]
  # @return Boolean
  def final_survey_part?(response_set, event)
    return true if response_set.participant_consent || response_set.non_interview_report
    expected = scheduled_activities_for_survey(response_set.survey.title, event).size
    actual   = response_set.instrument.response_sets.size
    expected <= actual
  end

  ##
  # Given an event and a response set, return the current scheduled activity that
  # should be acted upon. The current activity would be the next scheduled activity
  # for the event that has not been touched.
  #
  # @param [Event]
  # @param [ResponseSet]
  # @return ScheduledActivity
  def current_scheduled_activity(event, response_set)
    remaining_activities(event, response_set).first
  end

  ##
  # This method determines the remaining activities
  # given an event and response_set. The response set
  # comes from an associated instrument which may or
  # may not exist, thus the response set parameter here
  # could be nil, in which case we return all scheduled
  # activities for the event.
  # If the response set exists, this method filters
  # the activities already associated with the surveys
  # for the response set's instrument.
  #
  # @param [Event]
  # @param [ResponseSet]
  # @return Array<ScheduledActivity>
  def remaining_activities(event, response_set)
    sas = scheduled_activities_for_event(event)
    return sas if response_set.blank?

    sas_hsh = keyed_scheduled_activities(sas)
    # determine if a scheduled activity survey has occurred
    # and remove it from the list of scheduled activities
    # this convoluted approach is used in order to handle
    # multiple births
    already_touched_survey_titles(response_set).each do |t|
      val = sas_hsh[t]
      val.delete_at(0) if val
      sas_hsh[t] = val
    end

    sas_hsh.values.flatten.compact.sort
  end
  private :remaining_activities

  ##
  # The given scheduled activities keyed by subject title
  # @param Array<ScheduledActivity>
  # @return Hash[<String>,<Array>]
  def keyed_scheduled_activities(sas)
    result = {}
    sas.each do |sa|
      result[sa.survey_title] ||= []
      result[sa.survey_title] << sa unless sa.has_non_matching_mdes_version_instrument?
    end
    result
  end

  ##
  # All the survey titles for the response_set.instrument
  # @return [Array<String>]
  def already_touched_survey_titles(response_set)
    response_set.associated_response_sets.collect { |rs| rs.survey.title.downcase }
  end
  private :already_touched_survey_titles

  ##
  # Finds the scheduled activity for the given title and matches it to
  # other scheduled activities (the other survey parts) associated to the found
  # scheduled activity.
  # If there are no matching activities an empty array is returned.
  #
  # @param survey_title [String]
  # @param [Event] - the event, defaults to nil
  # @return [Array<ScheduledActivities>]
  def scheduled_activities_for_survey(survey_title, event)
    result = []
    if a = scheduled_activity_for_survey(survey_title, event)
      result = scheduled_activities_for_event(event).select do |sa|
        sa.survey_identifier == a.survey_root || sa.references == a.survey_root
      end.sort
    end
    result
  end

  ##
  # Find the scheduled_activity for the given survey_title
  # The survey title should uniquely identify a scheduled activity in the instrument plan
  #
  # @param survey_title [String]
  # @param [Event] - the event, defaults to nil
  # @return [ScheduledActivity]
  def scheduled_activity_for_survey(survey_title, event)
    survey_title = survey_title.to_s.downcase
    scheduled_activities_for_event(event).select { |sa| sa.survey_identifier == survey_title }.first
  end

end
