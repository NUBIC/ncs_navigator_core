class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'
  
  def surveyor_finish
    OperationalDataExtractor.process(@response_set)
    PatientStudyCalendar.update_subject(@response_set.person.participant) if @response_set.person.participant && /_PregScreen_/ =~ @response_set.survey.title
    edit_contact_link_path(@response_set.contact_link_id)
  end  
end