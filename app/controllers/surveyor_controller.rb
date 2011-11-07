class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'
  
  def surveyor_finish
    OperationalDataExtractor.process(@response_set)
    update_participant_based_on_responses(@response_set)
    edit_contact_link_path(@response_set.contact_link_id)
  end
  
  
  private
  
  
    # TODO: ensure that the state transitions are based on the responses in the response set
    #       and that the disposition of the instrument was completed
    def update_participant_based_on_responses(response_set)
      
      participant = Participant.find(response_set.person.participant.id) if response_set.person.participant
      if participant
      
        if /_PregScreen_/ =~ response_set.survey.title
          resp = psc.update_subject(participant)
          participant.assign_to_pregnancy_probability_group! if participant.can_assign_to_pregnancy_probability_group?
        end
      
        if /_LIPregNotPreg_/ =~ response_set.survey.title && participant.can_follow_low_intensity?
          participant.follow_low_intensity!
        end
      
        # TODO: Hi-Lo Conversion !!
        if /_LIHIConversion_/ =~ response_set.survey.title && participant.can_enroll_in_high_intensity_arm?
          participant.enroll_in_high_intensity_arm!
          
          
          # TODO: update this information only when completing a Consent record - move to consent controller
          if participant.consented? && participant.can_high_intensity_consent?
            participant.high_intensity_consent!
            if participant.known_to_be_pregnant?
              participant.pregnant_informed_consent!
            else
              participant.non_pregnant_informed_consent!
            end
          end
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