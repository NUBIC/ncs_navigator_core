class WelcomeController < ApplicationController

  def index
    criteria = { :current_user => current_staff,
                 :start_date => 14.days.ago.to_date.to_s }
    @scheduled_activities = psc.scheduled_activities_report(criteria)
  end

  def overdue_activities
    criteria = { :current_user => current_staff,
                 :end_date => 1.day.ago.to_date.to_s }
    @scheduled_activities = psc.scheduled_activities_report(criteria)
  end

  def summary
    @dwellings    = DwellingUnit.next_to_process
    @participants = Participant.all
  end

  def faq
  end

  def start_pregnancy_screener_instrument
    person = Person.create(:psu_code => @psu_code)
    participant = Participant.create(:psu_code => @psu_code)
    participant.person = person
    participant.save!

    resp = psc.assign_subject(participant)
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