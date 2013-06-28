# -*- coding: utf-8 -*-
#
#

class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'

  ##
  # Overridden from Surveyor::SurveyorControllerMethods
  # to handle Operational Data Extraction and to determine
  # whether or not this is a part of a multi-part survey
  # if no participant, person url is specified for redirect
  def surveyor_finish
    if @response_set.participant
      finish_off_participant
    else
      @response_set.person
    end
  end

  def finish_off_participant
    # sets @event and @participant
    set_activity_plan_for_participant

    activity = @activity_plan.current_scheduled_activity(@event, @response_set)

    if @activity_plan.final_survey_part?(@response_set, @event) || params[:breakoff] || activity.instruments.empty?
      # mark all scheduled activities associated with survey for this @event as occurred
      @activity_plan.scheduled_activities_for_survey(@response_set.survey.title, @event).each do |a|
        psc.update_activity_state(a.activity_id, @participant, Psc::ScheduledActivity::OCCURRED)
      end

      determine_redirect(@response_set, @event)
    else
      # go to next part of the survey
      access_code = Survey.to_normalized_string(activity.instrument)
      survey = Survey.most_recent_for_access_code(access_code)
      start_instrument_person_path(@response_set.person,
                                   :participant_id => activity.participant.id,
                                   :references_survey_access_code => activity.references.to_s,
                                   :survey_access_code => survey.access_code,
                                   :contact_link_id => most_recent_contact_link.id)
    end
  end

  ##
  # Determine where to go next if this is the final survey part
  # or a breakoff or there are no more instruments associated with the activity
  #
  # If the is an instrument associated with the response set go to the
  # edit instrument page
  # If the current event is closed, assume that we are editing a previous
  # response set and return to the participant page
  # Otherwise just go to the decision page for the most recent contact link.
  def determine_redirect(response_set, event)
    if response_set.instrument_associated?
      edit_instrument_contact_link_path(most_recent_contact_link)
    elsif event.closed?
      participant_path(response_set.participant)
    else
      decision_page_contact_link_path(most_recent_contact_link)
    end
  end

  ##
  # Update method copied from Surveyor {https://github.com/NUBIC/surveyor}
  # gem and modified with code ideas borrowed from
  # internal NUBIC project Registar {http://projects.nubic.northwestern.edu/}
  # to handle mandatory questions.
  def update
    question_ids_for_dependencies = (params[:r] || []).map{|k,v| v["question_id"] }.compact.uniq
    saved = load_and_update_response_set_with_retries

    return redirect_with_message(surveyor_finish, :notice, t('surveyor.completed_survey')) if saved && params[:finish]

    respond_to do |format|
      format.html do
        if @response_set.nil?
          return redirect_with_message(available_surveys_path, :notice, t('surveyor.unable_to_find_your_responses'))
        # This section taken from internal NUBIC project Registar
        elsif !@response_set.mandatory_questions_complete?
          flash[:notice] = "Please Complete ALL required questions"
          redirect_to surveyor.edit_my_survey_path(
            :section => @response_set.first_incomplete_section.id, :review => true)
        else
          flash[:notice] = t('surveyor.unable_to_update_survey') unless saved
          redirect_to surveyor.edit_my_survey_path(:anchor => anchor_from(params[:section]), :section => section_id_from(params))
        end
      end
      format.js do
        if @response_set
          render :json => @response_set.reload.all_dependencies(question_ids_for_dependencies)
        else
          render :text => "No response set #{params[:response_set_code]}",
            :status => 404
        end
      end
    end
  end

  def load_and_update_response_set
    ResponseSet.transaction do
      @response_set = ResponseSet.
        find_by_access_code(params[:response_set_code], :include => {:responses => :answer})
      if @response_set
        saved = true
        if params[:r]
          @response_set.update_from_ui_hash(params[:r])
        end
        if params[:finish]
          saved &= @response_set.complete!
        end
        saved
      else
        false
      end
    end
  end

  def render_context
    set_activity_plan_for_participant
    build_instrument_context
  end

  ##
  # Piggy-back on the render_context callback from SurveyorControllerMethods
  # to ensure that we have the response_set object for this
  def set_activity_plan_for_participant
    core_participant = @response_set.participant
    if core_participant
      if core_participant.child_participant?
        @participant = core_participant.mother.participant
      else
        @participant = core_participant
      end
    end
    @event = determine_current_event(@response_set.event)
    @activities_for_event = []
    if @participant
      @activity_plan        = psc.build_activity_plan(@participant)
      @activities_for_event = @activity_plan.scheduled_activities_for_event(@event)
    end
  end

  ##
  # For the given event determine if this event is a standalone event
  # or done with another event at the same time. If in consort with
  # another event get the most recent event associated with that contact
  # filtering out the informed consent events.
  # @see Event#chronological to see how ordering is determined
  def determine_current_event(event)
    contact_ids = event.contact_links.map(&:contact_id).uniq
    events = Event.joins(:contact_links).where("contact_links.contact_id in (?)", contact_ids).chronological
    if events.size > 1
      events = events.select { |e| e.event_type_code != Event.informed_consent_code }
    end

    events.blank? ? event : events.last
  end

  ##
  # The most recently updated contact link for the event
  # Used only to redirect user after surveyor_finish
  # @see #surveyor_finish
  # @see #determine_redirect
  # @return [ContactLink]
  def most_recent_contact_link
    @event.contact_links.order('updated_at DESC').first
  end
  private :most_recent_contact_link

  def build_instrument_context
    @response_set.to_mustache
  end

  ##
  # Overrides the parent version to add retrying for optimistic locking errors.
  def load_and_update_response_set_with_retries(remaining=2)
    begin
      super
    rescue ActiveRecord::StaleObjectError => e
      if remaining > 0
        load_and_update_response_set_with_retries(remaining - 1)
      else
        raise e
      end
    end
  end
end
