# -*- coding: utf-8 -*-

class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'

  def surveyor_finish
    set_activity_plan_for_participant

    OperationalDataExtractor.process(@response_set)
    contact_link = @response_set.instrument.contact_link

    if @activity_plan.final_survey_part?(@response_set)
      # go to contact_link.edit_instrument
      update_participant_based_on_survey(@response_set)
      edit_instrument_contact_link_path(contact_link.id)
    else
      # go to next part of the survey
      activity = @activity_plan.scheduled_activity_for_survey(
                    @activity_plan.next_survey(contact_link.event.to_s, @response_set.survey.title))
      survey = Survey.most_recent_for_access_code(Survey.to_normalized_string(activity.instrument))
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
    @participant          = @response_set.person.participant
    @instrument           = @response_set.instrument
    @event                = @instrument.event
    @activity_plan        = psc.build_activity_plan(@participant)
    @activities_for_event = @activity_plan.activities_for_event(@event.to_s)
  end

  ##
  # Create and return InstrumentContext object associated with the current user
  def build_instrument_context
    ctxt = NcsNavigator::Core::Mustache::InstrumentContext.new(@response_set)
    ctxt.current_user = current_user
    ctxt
  end

  private

    # TODO: ensure that the state transitions are based on the responses in the response set
    #       and that the disposition of the instrument was completed
    def update_participant_based_on_survey(response_set)
      participant = Participant.find(response_set.person.participant.id) if response_set.person.participant
      if participant
        participant.update_state_after_survey(response_set, psc)
      end
    end
end