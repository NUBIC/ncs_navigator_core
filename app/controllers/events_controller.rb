# -*- coding: utf-8 -*-


class EventsController < ApplicationController

  # GET /events
  # GET /events.json
  def index
    params[:page] ||= 1

    @q = Event.search(params[:q])
    result = @q.result(:distinct => true)
    @events = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => result.all }
      format.csv { render :csv => result.all, :force_quotes => true, :filename => 'events' }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    set_disposition_group
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])

        mark_activity_occurred unless @event.event_end_date.blank?

        path = @event.participant.nil? ? events_path : path = participant_path(@event.participant)

        format.html { redirect_to(path, :notice => 'Event was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def reschedule
    @event = Event.find(params[:id])
    @date = @event.event_start_date

    if request.put?
      reason = params[:reason]
      @date = params[:date]

      psc.schedule_pending_event(@event, PatientStudyCalendar::ACTIVITY_SCHEDULED, @date, reason)

      path = @event.participant.nil? ? events_path : path = participant_path(@event.participant)

      redirect_to(path, :notice => 'Event was successfully rescheduled.')
    end
  end

  ##
  # Show changes
  def versions
    @event = Event.find(params[:id])
    if params[:export]
      send_data(@event.export_versions, :filename => "#{@event.public_id}.csv")
    end
  end

  private

    def mark_activity_occurred
      activities = psc.activities_for_event(@event)

	    activity = nil
	    activities.each do |a|
	      activity = a if @event.matches_activity(a)
      end

	    if activity
	      psc.update_activity_state(activity.activity_id, @event.participant, PatientStudyCalendar::ACTIVITY_OCCURRED)
	    end
    end

    ##
	  # Determine the disposition group to be used from the contact type or instrument taken
	  def set_disposition_group
	    @disposition_group = nil
	    if @event.event_disposition_category_code.to_i > 0
	      @disposition_group =
	        DispositionMapper.for_event_disposition_category_code(@event.event_disposition_category_code)
	    else
  	    case @event.event_type.to_s
  	    when "Pregnancy Screener"
          @disposition_group = DispositionMapper::PREGNANCY_SCREENER_EVENT
        when "Informed Consent"
          if @event.try(:participant).low_intensity?
            @disposition_group = DispositionMapper::TELEPHONE_INTERVIEW_EVENT
          else
            @disposition_group = DispositionMapper::GENERAL_STUDY_VISIT_EVENT
          end
        else
          contact = @event.contact_links.last.contact unless @event.contact_links.blank?
          if contact && contact.contact_type
    	      @disposition_group = contact.contact_type.to_s
    	    else
    	      @disposition_group = DispositionMapper::GENERAL_STUDY_VISIT_EVENT
          end
        end
      end
	  end

end