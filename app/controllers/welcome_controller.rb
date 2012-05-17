# -*- coding: utf-8 -*-

class WelcomeController < ApplicationController

  def index
    if scheduled_activities = get_upcoming_activities
      @events = join_scheduled_events_by_date(parse_scheduled_activities(scheduled_activities))
    end
  end

  def upcoming_activities
    @scheduled_activities = get_upcoming_activities
  end

  def overdue_activities
    criteria = { :current_user => current_username,
                 :end_date => 1.day.ago.to_date.to_s }
    @scheduled_activities = psc.scheduled_activities_report(criteria)
  end

  def summary
    @dwellings    = DwellingUnit.next_to_process
    @participants = Participant.all
  end

  def pending_events
    @pending_events = Event.where("event_end_date is null").
                            order("event_start_date").
                            paginate(:page => params[:page], :per_page => 20)
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
      redirect_to :controller => "welcome", :action => "index"
    end

  end

  private

    def get_upcoming_activities
      @start_date = 1.day.ago.to_date.to_s
      @end_date   = params[:end_date] || 6.weeks.from_now.to_date.to_s
      criteria = { :current_user => current_username,
                   :start_date => @start_date,
                   :end_date => @end_date }
      psc.scheduled_activities_report(criteria)
    end

    def parse_scheduled_activities(scheduled_activities)
      events = []
      if rows = scheduled_activities['rows']
        rows.each do |row|
          if row && row['subject']
            person = Person.find_by_person_id(row['subject']['person_id'])
            if person
              event_label = Event.parse_label(row['labels'].first)
              events << ScheduledEvent.new(row['scheduled_date'], person, event_label.titleize) if event_label
            end
          end
        end
      end
      events
    end

    def join_scheduled_events_by_date(events)
      result = {}
      events.uniq.each do |e|
        date = e.date
        if result.has_key?(date)
          result[date] << e
        else
          result[date] = [e]
        end
      end
      result
    end

    ScheduledEvent = Struct.new(:date, :person, :event_type)

end