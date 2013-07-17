# -*- coding: utf-8 -*-


class EventsController < ApplicationController

  # GET /events
  # GET /events.json
  def index
    params[:page] ||= 1

    @q, @events = ransack_paginate(Event)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => @q.result.all }
      format.csv { render :csv => @q.result.all, :force_quotes => true, :filename => 'events' }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    if params[:contact_link_id]
      @contact_link = ContactLink.find(params[:contact_link_id])
      set_suggested_values_for_event
    end
    @close = params[:close]
    @disposition_group = nil
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    if params[:contact_link_id]
      @contact_link = ContactLink.find(params[:contact_link_id])
    end
    @close = params[:close]

    if @event.open_contacts? && !@event.continuable?
      if (!params[:event][:event_end_date].nil? || !params[:event][:event_end_date].nil?)
        flash[:warning] = "Event cannot be closed. Please close all contacts associated with this event before setting the event end date."
      end
      params[:event][:event_end_date] = nil
      params[:event][:event_end_time] = nil
    end

    respond_to do |format|
      if @event.update_attributes(params[:event])

        # TODO: remove some of the coupling between post_update_event_actions
        #       and redirect_path as the event type and participant eligibility
        #       are affecting the latter of the two methods.
        participant = post_update_event_actions(@event, @event.participant)

        format.html do
          if params[:commit] == "Continue" && @contact_link
            redirect_to(edit_contact_link_contact_path(@contact_link, @contact_link.contact, :next_event => true), :notice => notice)
          else
            redirect_to(redirect_path(@event, participant), :notice => notice)
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

    if request.put?
      reason = params[:reason]
      @date = params[:date]
      time = params[:time]

      psc.reschedule_pending_event(@event, @date, reason, time)

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

  def set_suggested_values_for_event
    @event.set_suggested_event_disposition(@contact_link)
    @event.set_suggested_event_disposition_category(@contact_link)
    @event.set_suggested_event_repeat_key
    @event.set_suggested_event_breakoff(@contact_link)
  end
  private :set_suggested_values_for_event

  def redirect_path(event, participant)
    if event.provider_recruitment_event?
      provider_recruitment_event_redirect_path
    else
      participant.nil? ? events_path : participant_path(participant)
    end
  end
  private :redirect_path

  def provider_recruitment_event_redirect_path
    provider = @event.contact_links.find { |cl| !cl.provider.nil? }.try(:provider)
    provider.nil? ? pbs_lists_path : pbs_list_path(provider.pbs_list)
  end
  private :provider_recruitment_event_redirect_path

  ##
  # After an event has been updated do the following:
  # 1) Mark Activity Occurred
  # 2) Cancel previously scheduled consent activities
  #    if the participant consented during this event
  # 3) Update associated events with data from this event
  # 4) Update the state of the Participant
  #
  # #update_participant_state alters the participant record
  # and therefore is returned from this method
  # Provider Recruitment Events also return nil
  #
  # @see #update_participant_state
  # @return [Participant]
  def post_update_event_actions(event, participant)
    # Update PSC activities
    mark_activity_occurred(event, participant)

    # For a consent event if the participant has consented, cancel all upcoming consent activities in PSC.
    if event.consent_event? && participant.try(:consented?)
      cancel_scheduled_consents_for_consented_participant(participant)
    end

    # If necessary, update associated event information
    event.update_associated_informed_consent_event

    # Update Participant state
    if event.provider_recruitment_event?
      nil
    else
      update_participant_state(event, participant)
    end
  end
  private :post_update_event_actions

  ##
  # Upon completion of an Event we advance the Participant to the
  # next state. However in the case of a screened Participant found to
  # be ineligible we adjudicate the Participant and act accordingly or if
  # the Participant has withdrawn from the study we unenroll the Participant.
  #
  # If the participant is determined ineligible during a screener event
  # this method will return nil
  #
  # @see Participant#advance
  # @see Participant#adjudicate_eligibility_and_disqualify_ineligible
  # @see Participant#unenroll
  # @param [Event]
  # @param [Participant]
  # @return [Participant]
  def update_participant_state(event, participant)
    if participant
      if participant.ineligible?
        if event.screener_event?
          Participant.adjudicate_eligibility_and_disqualify_ineligible(participant)
          return nil
        end
      elsif event.informed_consent? && participant.withdrawn?
        participant.unenroll!(psc, "Participant has withdrawn from the study.")
      else
        participant.advance(psc)
      end
    end
    participant
  end
  private :update_participant_state

  ##
  # Updates activities associated with this event
  # in PSC as 'occurred'
  def mark_activity_occurred(event, participant)
    if participant && event.closed? && !event.provider_recruitment_event?
      mark_event_activities_occurred(event, participant)
    end
  end
  private :mark_activity_occurred

  ##
  # For the given event, find the scheduled activities that match this event
  # and mark those activities as occurred.
  # @param [Event]
  # @param [Participant]
  def mark_event_activities_occurred(event, participant)
    psc.activities_for_event(event).each do |a|
      if event.matches_activity(a)
        psc.update_activity_state(a.activity_id, participant, Psc::ScheduledActivity::OCCURRED)
      end
    end
  end
  private :mark_event_activities_occurred

  ##
  # For all scheduled activities for the given participant,
  # cancel those that are consent activities
  # @param [Participant]
  def cancel_scheduled_consents_for_consented_participant(participant)
    psc.scheduled_activities(participant).each do |a|
      if a.cancelable_consent_activity?
        psc.update_activity_state(a.activity_id, participant, Psc::ScheduledActivity::CANCELED, Date.parse(a.ideal_date),
          "Consent activity cancelled as the Participant [#{participant.p_id}] has already consented.")
      end
    end
  end
  private :cancel_scheduled_consents_for_consented_participant

end
