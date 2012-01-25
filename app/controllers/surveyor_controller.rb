class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'

  def surveyor_finish
    OperationalDataExtractor.process(@response_set)
    update_participant_based_on_survey(@response_set)
    psc.update_activity_state_by_name(InstrumentEventMap.name_of_instrument(@response_set.survey.title), @response_set.person.participant, PatientStudyCalendar::ACTIVITY_OCCURRED) if @response_set.survey
    contact_link = ContactLink.where(:instrument_id => @response_set.instrument_id).first
    edit_instrument_contact_link_path(contact_link.id)
  end

  private

    # TODO: ensure that the state transitions are based on the responses in the response set
    #       and that the disposition of the instrument was completed
    def update_participant_based_on_survey(response_set)
      participant = Participant.find(response_set.person.participant.id) if response_set.person.participant
      if participant
        participant.update_state_after_survey(response_set, psc)
        Event.schedule_and_create_placeholder(psc, participant)
      end
    end
end