class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'
  
  def surveyor_finish
    OperationalDataExtractor.process(@response_set)
    update_participant_based_on_responses(@response_set)
    edit_contact_link_path(@response_set.contact_link_id)
  end
  
  
  private
  
    def update_participant_based_on_responses(response_set)
      
      participant = Participant.find(response_set.person.participant.id) if response_set.person.participant
      if participant
      
        if /_PregScreen_/ =~ response_set.survey.title
          resp = psc.update_subject(participant)
          participant.assign_to_pregnancy_probability_group!
        end
      
        if /_LIPregNotPreg_/ =~ response_set.survey.title && participant.can_follow_low_intensity?
          participant.follow_low_intensity!
        end
      
        if participant.known_to_be_pregnant? && participant.can_impregnate?
          participant.impregnate!
        end
      
        if participant.known_to_have_experienced_child_loss? && participant.can_lose_child?
          participant.lose_child!
        end
      
      # TODO: update participant state for each survey
      #       e.g. participant.assign_to_pregnancy_probability_group! after completing PregScreen
      end
    end
end