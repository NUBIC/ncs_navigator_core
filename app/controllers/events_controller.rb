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
    if params[:contact_link_id]
      @contact_link = ContactLink.find(params[:contact_link_id])
      if @event.event_disposition.blank?
        @event.event_disposition = @contact_link.contact.contact_disposition
      end
    end
    @close = params[:close]
    set_disposition_group
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    if params[:contact_link_id]
      @contact_link = ContactLink.find(params[:contact_link_id])
    end
    @close = params[:close]
    respond_to do |format|
      if @event.update_attributes(params[:event])
        mark_activity_occurred

        notice = 'Event was successfully updated.'

        participant = @event.participant
        if participant.pending_events.blank?
          resp = Event.schedule_and_create_placeholder(psc, participant)
          notice += " Could not schedule next event [#{participant.next_study_segment}]" unless resp
        end

        format.html do
          if params[:commit] == "Continue" && @contact_link
            redirect_to(edit_contact_link_contact_path(@contact_link, @contact_link.contact, :next_event => true), :notice => notice)
          else
            redirect_to(redirect_path, :notice => notice)
          end
        end
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

      psc.schedule_pending_event(@event, Psc::ScheduledActivity::SCHEDULED, @date, reason)

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

    def redirect_path
      path = events_path
      if @event.provider_recruitment_event?
        provider = @event.contact_links.find { |cl| !cl.provider.nil? }.provider
        path = pbs_list_path(provider.pbs_list)
      elsif !@event.participant.nil?
        path = participant_path(@event.participant)
      end
      path
    end

    ##
    # Updates activities associated with this event
    # in PSC as 'occurred'
    def mark_activity_occurred
      if !@event.event_end_date.blank? && !@event.provider_recruitment_event?
  	    psc.activities_for_event(@event).each do |a|
  	      if @event.matches_activity(a)
            psc.update_activity_state(activity.activity_id,
                                      @event.participant,
                                      Psc::ScheduledActivity::OCCURRED)
          end
        end
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
        when "Provider-Based Recruitment"
          @disposition_group = DispositionMapper::PROVIDER_RECRUITMENT_EVENT
        when "PBS Participant Eligibility Screening"
          @disposition_group = DispositionMapper::PBS_ELIGIBILITY_EVENT
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
