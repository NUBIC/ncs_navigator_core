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
      
      if participant && /_PregScreen_/ =~ response_set.survey.title
        Rails.logger.info("~~~ surveyor_finish for #{response_set.survey.title} and #{response_set.person} - updating psc")
        resp = psc.update_subject(participant)
        Rails.logger.info("~~~ #{resp}")
        participant.assign_to_pregnancy_probability_group!
      end
      
      if participant && participant.known_to_be_pregnant? && participant.can_impregnate?
        participant.impregnate!
      end
      
      # TODO: update participant state for each survey
      #       e.g. participant.assign_to_pregnancy_probability_group! after completing PregScreen
    end
end