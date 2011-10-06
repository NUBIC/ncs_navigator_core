class WelcomeController < ApplicationController
  
  def index
    @scheduled_activities = psc.scheduled_activities_report({ :current_user => current_staff, :start_date => 1.month.ago.to_date.strftime("%Y-%m-%d") })
  end
  
  def summary
    @dwellings    = DwellingUnit.next_to_process
    @participants = Participant.all
  end
  
  def start_pregnancy_screener_instrument
    person = Person.create(:psu_code => @psu_code)
    participant = Participant.create(:psu_code => @psu_code, :person => person)
    participant.register!
    subject = psc.new(current_user)
    resp = subject.assign_subject(participant)
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