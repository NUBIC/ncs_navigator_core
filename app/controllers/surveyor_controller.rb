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
      
      if response_set.person.participant  && /_PregScreen_/ =~ response_set.survey.title
        participant = Participant.find(response_set.person.participant.id)
        Rails.logger.info("~~~ surveyor_finish for #{response_set.survey.title} and #{response_set.person} - updating psc")
        resp = psc.update_subject(participant)
        Rails.logger.info("~~~ #{resp}")
        participant.assign_to_pregnancy_probability_group!
        participant.impregnate! if participant.ppg_status.local_code == 1        
      end
      
      # TODO: update participant state
      #       e.g. participant.assign_to_pregnancy_probability_group! after completing PregScreen
    end
end