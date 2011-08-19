class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'
  
  def surveyor_finish
    edit_contact_link_path(@response_set.contact_link_id)
  end  
end