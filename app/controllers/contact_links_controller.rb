# -*- coding: utf-8 -*-


class ContactLinksController < ApplicationController

  # GET /contact_links
  # GET /contact_links.json
  def index
    params[:page] ||= 1

    @q, @contact_links = ransack_paginate(ContactLink)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => @q.result.all }
      format.csv { render :csv => @q.result.all, :force_quotes => true, :filename => 'contact_links' }
    end
  end

  # GET /contact_links/1/edit
  def edit
    @contact_link = ContactLink.find(params[:id])
    @event        = @contact_link.event
    @instrument   = @contact_link.instrument
    @response_sets= @instrument.response_sets if @instrument

    @person  = @contact_link.person
    @contact = @contact_link.contact
    @surveys  = @response_sets.collect { |resp_set| resp_set.survey } if @response_sets

    # Some events (e.g. provider recruitment do not have a participant)
    if @event.participant
      @event.populate_post_survey_attributes(@contact, @response_sets) if @response_sets
      @event.event_repeat_key = @event.determine_repeat_key
      @event_activities = psc.activities_for_event(@event)
    end

    set_time_and_dates
    set_disposition_group
  end

  # PUT /contact_links/1
  # PUT /contact_links/1.json
  def update
    @contact_link = ContactLink.find(params[:id])

    respond_to do |format|

      if @contact_link.update_attributes(params[:contact_link]) &&
         @contact_link.event.update_attributes(params[:event]) &&
         @contact_link.contact.update_attributes(params[:contact])

        notice = 'Contact was successfully updated.'

        if @contact_link.event.participant.pending_events.blank?
          resp = Event.schedule_and_create_placeholder(psc, @contact_link.event.participant)
          notice += " Could not schedule next event [#{@contact_link.event.participant.next_study_segment}]" unless resp
        end

        format.html {
          if params[:commit] == "Continue"
            redirect_to(edit_contact_link_contact_path(@contact_link, @contact_link.contact, :next_event => true), :notice => notice)
          else
            path = @contact_link.person.participant ? participant_path(@contact_link.person.participant) : person_path(@contact_link.person)
            redirect_to(path, :notice => notice)
          end
        }
        format.json { head :ok }
      else
        @event        = @contact_link.event
        @instrument   = @contact_link.instrument
        @response_sets = @instrument.response_sets if @instrument
        format.html { render :action => "edit" }
        format.json { render :json => @contact_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  def select_instrument
    @contact_link = ContactLink.find(params[:id])
    @contact      = @contact_link.contact
    @person       = @contact_link.person
    @participant  = @person.participant if @person
    @event        = @contact_link.event
    if @participant && @event
      @activity_plan        = psc.build_activity_plan(@participant)
      @activities_for_event = @activity_plan.activities_for_event(@event)
      @current_activity     = @activities_for_event.detect { |a| a.scheduled? }
      @scheduled_activities = @activity_plan.scheduled_activities_for_event(@event)
      @saq_activities       = @activities_for_event.find_all { |activity| activity.activity_name =~ /SAQ$/ }
    end
  end

  def decision_page
    @contact_link  = ContactLink.find(params[:id])
    @person        = @contact_link.person
    @instrument    = @contact_link.instrument
    @event         = @contact_link.event
    @participant   = @event.participant if @event
    @response_sets = @instrument.response_sets.includes(:survey) if @instrument
    @surveys       = @response_sets.collect { |resp_set| resp_set.survey } if @response_sets
    @contact_links = ContactLink.where(:contact_id => @contact_link.contact_id)

    if @participant && @event
      @activity_plan = psc.build_activity_plan(@participant)
      @activities_for_event = @activity_plan.activities_for_event(@event)
      @scheduled_activities = @activity_plan.scheduled_activities_for_event(@event)
      @current_activity = @activity_plan.current_scheduled_activity(@event, @response_sets.try(:first))
    end
  end

  ##
  # Displays the form for the Instrument record associated with the given ContactLink
  # Posts the form to the finalize_instrument path
  def edit_instrument
    setup_instrument_variables
  end

  ##
  # Updates the Instrument record for the given ContactLink
  # Afterwards redirects the user to the /contact_links/:id/decision_page
  def finalize_instrument
    setup_instrument_variables
    respond_to do |format|
      if @contact_link.instrument.update_attributes(params[:instrument])

        mark_activity_occurred if @contact_link.instrument.complete?

        format.html { redirect_to(decision_page_contact_link_path(@contact_link), :notice => 'Instrument was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @contact_link.errors, :status => :unprocessable_entity }
      end
    end

  end

  def setup_instrument_variables
    @contact_link  = ContactLink.find(params[:id])
    @person        = @contact_link.person
    @instrument    = @contact_link.instrument
    @response_sets = @instrument.response_sets.includes(:survey)
    @surveys       = @response_sets.collect { |resp_set| resp_set.survey }

    set_instrument_time_and_date(@contact_link.contact)
    @instrument.set_instrument_repeat_key(@person)
    @instrument.set_instrument_type(@surveys)
    @instrument.set_instrument_breakoff
  end

  def saq_instrument
    @contact_link = ContactLink.find(params[:id])
    person       = @contact_link.person
    participant  = person.participant if person
    event        = @contact_link.event
    if event && participant
      activity_plan        = psc.build_activity_plan(participant)
      occurred_activities  = activity_plan.occurred_activities_for_event(event)
      saq_activity         = occurred_activities.find_all{|activity| activity.activity_name =~ /SAQ$/}.first
      if saq_activity
        survey = Survey.most_recent_for_access_code(Survey.to_normalized_string(saq_activity.instrument))
        if survey
          rescheduled_activity(saq_activity)
          redirect_to start_instrument_person_path(person, :participant_id => participant.id,
                                                     :references_survey_access_code => saq_activity.references.to_s,
                                                     :survey_access_code => survey.access_code,
                                                     :contact_link_id => @contact_link.id)
        else
          Rails.logger.error "saq_instrument precondition failed: survey for #{saq_activity.activity_name} not found."
          redirect_to(decision_page_contact_link_path(@contact_link))
        end
      else
        Rails.logger.error "saq_instrument precondition failed: SAQ activity for the #{event} for contact link #{@contact_link.id} is nil."
        redirect_to(decision_page_contact_link_path(@contact_link))
      end
    else
      Rails.logger.error "saq_instrument precondition failed: participant or event for contact link #{@contact_link.id} is nil."
      redirect_to(decision_page_contact_link_path(@contact_link))
    end
  end

  def update_psc_for_activity
    @contact_link = ContactLink.find(params[:contact_link_id])
    resp = psc.update_activity_state(params[:activity_id],
      @contact_link.event.participant,
      params[:new_state],
      @contact_link.contact.contact_date,
      "Updated by #{current_username} through UI")

    Rails.logger.info("~~~ update_psc_for_activity - #{resp.env[:url]}")

    redirect_to request.referrer
  end

  private

    def set_time_and_dates(include_instrument = false)
      contact = @contact_link.contact
      contact.set_default_end_time

      set_event_time_and_date(contact)
      set_instrument_time_and_date(contact) if include_instrument
    end

    def set_event_time_and_date(contact)
      event = @contact_link.event
      if event
        start_date = contact.contact_date_date.nil? ? Date.today : contact.contact_date_date
        event.event_start_date = start_date if event.event_start_date.blank?
        event.event_start_time = contact.contact_start_time
        # TODO: determine if this should be prepopulated
        #       might depend on the response set
        # event.event_end_date = Date.today
        # event.event_end_time = contact.contact_end_time
      end
    end

    def set_instrument_time_and_date(contact)
      instrument = @contact_link.instrument
      if instrument
        default_date = contact.contact_date_date.nil? ? Date.today : contact.contact_date_date
        instrument.instrument_start_date = default_date
        instrument.instrument_end_date   = default_date
        instrument.instrument_start_time = instrument.created_at.strftime("%H:%M")
        instrument.instrument_end_time   = Time.now.strftime("%H:%M")
      end
    end

    ##
    # Determine the disposition group to be used from the contact type or instrument taken
    def set_disposition_group
      @disposition_group = nil
      if @event
        set_disposition_group_for_event
      else
        set_disposition_group_for_contact_link
      end
    end

    def rescheduled_activity(activity)
      if activity
        reason = "Re-scheduled activity for closed event"
        psc.update_activity_state(activity.activity_id, @contact_link.person.participant,
                                  Psc::ScheduledActivity::SCHEDULED, @contact_link.contact.contact_date_date, reason)
      end
    end

    def mark_activity_occurred
      psc.activities_for_event(@contact_link.event).each do |a|
        if @contact_link.instrument.survey.access_code == Instrument.surveyor_access_code(a.labels)
          psc.update_activity_state(a.activity_id, @contact_link.event.participant, Psc::ScheduledActivity::OCCURRED)
        end
      end
    end

end
