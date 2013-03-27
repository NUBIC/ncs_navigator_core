# -*- coding: utf-8 -*-


class WelcomeController < ApplicationController

  def index
    if scheduled_activities = get_scheduled_activities_report(:current_user => current_user.username)
      @events = join_scheduled_events_by_date(parse_scheduled_activities(scheduled_activities))
    end
  end

  def upcoming_activities
    @scheduled_activities = Psc::ScheduledActivityCollection.from_report(
        get_scheduled_activities_report).sort_by{ |sa| sa.activity_date }
    if params[:export] && @scheduled_activities
      csv_data = to_csv(@scheduled_activities)
      outfile = "scheduled_activities_" + Time.now.strftime("%m-%d-%Y") + ".csv"
      send_data csv_data,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{outfile}"
    end
  end

  def overdue_activities
    criteria = { :end_date => 1.day.ago.to_date.to_s }
    @scheduled_activities = Psc::ScheduledActivityCollection.from_report(
        psc.scheduled_activities_report(criteria)).sort_by{ |sa| sa.activity_date }
    if params[:export] && @scheduled_activities
      csv_data = to_csv(@scheduled_activities)
      outfile = "overdue_activities_" + Time.now.strftime("%m-%d-%Y") + ".csv"
      send_data csv_data,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{outfile}"
    end
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
      create_pregnancy_screener_event_record(participant)
      redirect_to new_person_contact_path(person)
    else
      destroy_participant_and_redirect(participant, resp)
    end
  end

  def start_pbs_eligibility_screener_instrument
    person = Person.find(params[:person_id])
    if person.sampled_ineligible?
      flash[:warning] = "Person is ineligible - cannot start eligibility screener"
      redirect_to request.referer
    else
      participant = Participant.create(:psu_code => @psu_code)
      participant.person = person
      participant.save!
      resp = psc.assign_subject(participant)
      if resp && resp.status.to_i < 299
        create_pbs_eligibility_screener_event_record(participant)
        redirect_to new_person_contact_path(person)
      else
        destroy_participant_and_redirect(participant, resp, false)
      end
    end
  end

  private

    def create_pbs_eligibility_screener_event_record(participant)
      create_screener_event_record(participant, NcsCode.pbs_eligibility_screener)
    end

    def create_pregnancy_screener_event_record(participant)
      create_screener_event_record(participant, NcsCode.pregnancy_screener)
    end

    def create_screener_event_record(participant, event_type)
      if activity_plan = psc.build_activity_plan(participant)
        dates = []
        # get dates for scheduled pbs_eligibility_screener activity for participant
        activity_plan.scheduled_activities.each do |a|
          code = NcsCode.find_event_by_lbl(a.event)
          dates << a.ideal_date if code == event_type
        end
        # create a placeholder event for each date
        dates.uniq.each do |dt|
          Event.create( :participant => participant, :psu_code => participant.psu_code,
                        :event_start_date => dt, :event_type => event_type)

        end
      end
    end



    def destroy_participant_and_redirect(participant, resp, destroy_person = true)
      ppl = participant.participant_person_links.where(:relationship_code => 1).first
      ppl.destroy if ppl
      participant.destroy
      person.destroy if destroy_person
      error_msg = resp.blank? ? "Unable to start eligibility screener instrument." : "#{resp.body}"
      flash[:warning] = error_msg
      redirect_to :controller => "welcome", :action => "index"
    end

    def get_scheduled_activities_report(options = {})
      @start_date = 1.day.ago.to_date.to_s
      @end_date   = params[:end_date] || 6.weeks.from_now.to_date.to_s
      criteria = { :start_date => @start_date, :end_date => @end_date, :current_user => nil }
      criteria.merge!(options) if options

      psc.scheduled_activities_report(criteria)
    end

    def parse_scheduled_activities(scheduled_activities)
      events = []
      if rows = scheduled_activities['rows']
        rows.each do |row|
          activity_time = row['activity_time'] if row && row['activity_time']
          if row && row['subject']
            person = Person.find_by_person_id(row['subject']['person_id'])
            if person
              event_label = Event.parse_label(row['labels'].first)
              events << ScheduledEvent.new(row['scheduled_date'], activity_time, person, event_label.titleize) if event_label
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

    def to_csv(scheduled_activities)
      Rails.application.csv_impl.generate do |csv|
        csv << [
          "Date",
          "Person",
          "PPG Status",
          "Activity"]
        scheduled_activities.each do |sa|
          person = Person.find_by_person_id(sa.person_id)
          if person
            ppg = person.participant.ppg_status.blank? ? "n/a" : "PPG #{person.participant.ppg_status.local_code}"
            csv << [
              sa.activity_date,
              person.to_s,
              ppg,
              sa.name
            ]
          end
        end
      end
    end

    ScheduledEvent = Struct.new(:date, :activity_time, :person, :event_type)

end
