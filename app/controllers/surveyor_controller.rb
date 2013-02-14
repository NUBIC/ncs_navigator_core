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
  def surveyor_finish
    set_activity_plan_for_participant

    contact_link = @response_set.instrument.contact_link
    activity = @activity_plan.current_scheduled_activity(contact_link.event.to_s, @response_set)

    if @activity_plan.final_survey_part?(@response_set, @event) || params[:breakoff] || activity.instruments.empty?
      # mark all scheduled activities associated with survey as occurred
      @activity_plan.scheduled_activities_for_survey(@response_set.survey.title, @event).each do |a|
        psc.update_activity_state(a.activity_id, @participant, Psc::ScheduledActivity::OCCURRED)
      end

      # go to contact_link.edit_instrument
      update_participant_based_on_survey(@response_set)
      edit_instrument_contact_link_path(contact_link.id)

    else
      # go to next part of the survey
      access_code = Survey.to_normalized_string(activity.instrument)
      survey = Survey.most_recent_for_access_code(access_code)
      start_instrument_person_path(@response_set.person,
                                   :participant_id => activity.participant.id,
                                   :references_survey_access_code => activity.references.to_s,
                                   :survey_access_code => survey.access_code,
                                   :contact_link_id => contact_link.id)
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
      if core_participant.p_type_code == 6
        @participant = core_participant.mother.participant
      else
        @participant = core_participant
      end
    end
    @instrument           = @response_set.instrument
    @event                = @instrument.event
    @activities_for_event = []
    if @participant
      @activity_plan        = psc.build_activity_plan(@participant)
      @activities_for_event = @activity_plan.scheduled_activities_for_event(@event)
    end
  end

  ##
  # Create and return InstrumentContext object associated with the current user
  def build_instrument_context
    ctxt = NcsNavigator::Core::Mustache::InstrumentContext.new(@response_set)
    ctxt.current_user = current_user
    ctxt
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

  private

  # TODO: ensure that the state transitions are based on the responses in the response set
  #       and that the disposition of the instrument was completed
  def update_participant_based_on_survey(response_set)
    if participant = response_set.participant
      participant.update_state_after_survey(response_set, psc)
      if !participant.eligible? && response_set.survey.title =~ /PBSamplingScreen/
        SampledPersonsIneligibility.create_from_participant!(participant)
      end
    end
  end
end
