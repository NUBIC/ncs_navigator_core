class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'
  
  def surveyor_finish
    OperationalDataExtractor.process(@response_set)
    update_participant_based_on_survey(@response_set)
    edit_instrument_contact_link_path(@response_set.contact_link_id)
  end

  private

    # TODO: ensure that the state transitions are based on the responses in the response set
    #       and that the disposition of the instrument was completed
    def update_participant_based_on_survey(response_set)
      participant = Participant.find(response_set.person.participant.id) if response_set.person.participant
      participant.update_state_after_survey(response_set, psc) if participant
    end
end