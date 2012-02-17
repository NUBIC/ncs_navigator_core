class WelcomeController < ApplicationController

  def index
    @start_date = 1.day.ago.to_date.to_s
    @end_date = 2.weeks.from_now.to_date.to_s
    criteria = { :current_user => current_staff,
                 :start_date => @start_date,
                 :end_date => @end_date }

    if scheduled_activities = psc.scheduled_activities_report(criteria)
      scheduled_study_segment_ids = []
      if rows = scheduled_activities['rows']
        Rails.logger.info("~~~ scheduled_activities['rows'] = #{rows.size}")
        rows.each do |row|
          if row['scheduled_study_segment']
            Rails.logger.info("~~~ adding #{row['scheduled_study_segment']['grid_id']} to ids")
            scheduled_study_segment_ids << row['scheduled_study_segment']['grid_id']
          end
        end
      end

      events = Event.where("event_end_date is null").
                     where("scheduled_study_segment_identifier in (?)", scheduled_study_segment_ids.uniq.compact).
                     order("event_start_date").all
      @events = {}
      events.each do |e|
        if @events.has_key?(e.event_start_date)
          @events[e.event_start_date] << e
        else
          @events[e.event_start_date] = [e]
        end
      end
    end

  end

  def upcoming_activities
    @start_date = 1.day.ago.to_date.to_s
    @end_date = 2.weeks.from_now.to_date.to_s
    criteria = { :current_user => current_staff,
                 :start_date => @start_date,
                 :end_date => @end_date }
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