class WelcomeController < ApplicationController
  
  def index
    @scheduled_activities = PatientStudyCalendar.scheduled_activities_report({ :current_user => current_staff })
  end
  
  def summary
    @dwellings    = DwellingUnit.next_to_process
    @participants = Participant.all
  end
  
  def start_pregnancy_screener_instrument
    person = Person.create(:psu_code => @psu_code)
    participant = Participant.create(:psu_code => @psu_code, :person => person)
    participant.register!
    resp = PatientStudyCalendar.assign_subject(participant)
    if resp && resp.status.to_i < 299
      redirect_to new_person_contact_path(person)
    else
      participant.destroy
      person.destroy
      error_msg = resp.blank? ? "Unable to start pregnancy screener instrument." : "#{resp.body}"
      flash[:warning] = error_msg
      redirect_to :controller => "welcome", :action => "summary"
    end
    
  end
  
end