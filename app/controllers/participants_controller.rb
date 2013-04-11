# -*- coding: utf-8 -*-


class ParticipantsController < ApplicationController
  layout proc { |controller| controller.request.xhr? ? nil : 'application'  }

  permit Role::SYSTEM_ADMINISTRATOR, Role::USER_ADMINISTRATOR, Role::ADMINISTRATIVE_STAFF, Role::STAFF_SUPERVISOR ,
         :only => [:edit_ppg_status, :update_ppg_status, :enroll, :unenroll, :remove_from_active_followup, :current_workflow]

  before_filter :load_participant, :except => [:index, :in_ppg_group, :new, :create]
  ##
  # List all of the Participants in the application, paginated
  #
  # GET /participants
  # GET /participants.json
  def index
    params[:page] ||= 1

    params[:q] ||= {}
    params[:q][:participant_person_links_relationship_code_eq] = 1
    params[:q][:being_followed_true] ||= 1

    @q, @participants = ransack_paginate(Participant)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => @q.result.all }
      format.csv { render :csv => @q.result.all, :force_quotes => true, :filename => 'participants' }
    end
  end

  ##
  # List all Participants in the application who belong to this Pregnancy Probability Group
  #
  # GET /participants/in_ppg_group?ppg_group=X
  def in_ppg_group
    params[:ppg_group] ||= 1
    @ppg_group = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", params[:ppg_group])
    @participants = Participant.in_ppg_group(params[:ppg_group].to_i)
  end

  ##
  # GET /participants/:id
  def show
    @person = @participant.person
    @participant_activity_plan = psc.build_activity_plan(@participant)

    @scheduled_activities_grouped_by_date = {}
    @participant_activity_plan.scheduled_activities.each do |a|
      date = a.date
      if @scheduled_activities_grouped_by_date.has_key?(date)
        @scheduled_activities_grouped_by_date[date] << a
      else
        @scheduled_activities_grouped_by_date[date] = [a]
      end
    end
  end

  ##
  # If the Participant is not known to PSC, register the participant
  #
  # POST /participant/:id/register_with_psc
  # POST /participant:id/register_with_psc.json
  def register_with_psc
    resp = psc.assign_subject(@participant)

    url = edit_participant_path(@participant)
    url = params[:redirect_to] unless params[:redirect_to].blank?

    if resp && resp.status.to_i < 299
      respond_to do |format|
        format.html do
          redirect_to(url, :notice => "#{@participant.person.to_s} registered with PSC")
        end
        format.json do
          render :json => { :id => @participant.id, :errors => [] }, :status => :ok
        end
      end
    else
      @participant.unregister if @participant.registered? # reset to initial state if failed to register with PSC
      error_msg = resp.blank? ? "Unable to send request to PSC" : "#{resp.body}"
      respond_to do |format|
        format.html do
          flash[:warning] = error_msg
          redirect_to(url, :error => error_msg)
        end
        format.json do
          render :json => { :id => @participant.id, :errors => error_msg }, :status => :error
        end
      end
    end

  end

  ##
  # If the Participant is known to PSC, schedule the next event for the participant
  #
  # POST /participant/:id/schedule_next_event_with_psc
  # POST /participant:id/schedule_next_event_with_psc.json
  def schedule_next_event_with_psc
    url = edit_participant_path(@participant)
    url = params[:redirect_to] unless params[:redirect_to].blank?

    if @participant.pending_events.blank?
      resp = Event.schedule_and_create_placeholder(psc, @participant, params[:date])

      if resp && resp.success?
        respond_to do |format|
          format.html do
            redirect_to(url, :notice => "Scheduled event for #{@participant.person.to_s} in PSC")
          end
          format.json do
            render :json => { :id => @participant.id, :errors => [] }, :status => :ok
          end
        end
      else
        @participant.unregister if @participant.registered? # reset to initial state if failed to register with PSC
        error_msg = resp.blank? ? "Unable to send request to PSC" : "#{resp.body}"
        respond_to do |format|
          format.html do
            flash[:warning] = error_msg
            redirect_to(url, :error => error_msg)
          end
          format.json do
            render :json => { :id => @participant.id, :errors => error_msg }, :status => :error
          end
        end
      end
    else
      # sanity check - should not get here
      redirect_to(url, :warning => "#{@participant.person.to_s} has pending events. Cannot schedule another event until the previous event has been completed.")
    end
  end

  ##
  # Retrieve the schedule from PSC for the registered Participant
  #
  # GET /participants/:id/schedule
  def schedule
    @subject_schedules = psc.schedules(@participant)
  end

  ##
  # Schedule an Informed Consent segment in PSC
  def schedule_informed_consent_event
    schedule_consent_event('Informed Consent', :schedule_general_informed_consent, params[:date])
  end

  ##
  # Schedule a Reconsent segment in PSC
  def schedule_reconsent_event
    schedule_consent_event('Re-Consent', :schedule_reconsent, params[:date])
  end

  ##
  # Schedule a Withdrawal segment in PSC
  def schedule_withdrawal_event
    schedule_consent_event('Withdrawal', :schedule_withdrawal, params[:date])
  end

  ##
  # Schedule a Child Consent Birth to 6 month segment in PSC
  def schedule_child_consent_birth_to_six_months_event
    schedule_consent_event('Child Consent', :schedule_child_consent_birth_to_six_months, params[:date])
  end

  ##
  # Schedule a Child Consent 6 month to Age of Majority segment in PSC
  def schedule_child_consent_six_month_to_age_of_majority_event
    schedule_consent_event('Child Consent', :schedule_child_consent_six_month_to_age_of_majority, params[:date])
  end

  def schedule_consent_event(typ, method, date)
    if date_available_for_informed_consent_event?(date)
      resp = Event.send(method, psc, @participant, date)
      msg = resp.success? ? "#{typ} event scheduled for Participant." : 'Could not schedule informed consent'
      redirect_to(participant_path(@participant), :notice => msg)
    else
      msg = "Informed Consent Event already scheduled for that date. Please choose another date."
      redirect_to(participant_path(@participant), :flash => { :warning => msg } )
    end
  end
  private :schedule_consent_event

  ##
  # Check if an informed consent event exists on the given date.
  # Return false if an event is already scheduled on that date.
  # @param date [String]
  # @return [Boolean]
  def date_available_for_informed_consent_event?(date)
    begin
      dt = Date.parse(date)
      ics = @participant.events.where(:event_type_code => Event.informed_consent_code)
      ics_dates = ics.map(&:psc_ideal_date)
      !ics_dates.include?(dt)
    rescue ArgumentError
      # if date cannot be parsed do not allow user to schedule the informed consent event
      false
    end
  end
  private :date_available_for_informed_consent_event?

  # GET /participants/new
  # GET /participants/new.json
  def new
    @person_id = params[:person_id]
    if params[:person_id].blank?
      redirect_to(people_path, :notice => 'Cannot create a Participant without a reference to a Person')
    elsif @participant = Participant.for_person(params[:person_id])
      redirect_to(edit_participant_path(@participant), :notice => 'Participant already exists')
    else
      @participant = Participant.new(:person => Person.find(params[:person_id]))

      respond_to do |format|
        format.html # new.html.haml
        format.json  { render :json => @participant }
      end
    end
  end

  # POST /participants
  # POST /participants.json
  def create
    @participant = Participant.new(params[:participant])
    person = Person.find(params[:person_id])

    respond_to do |format|
      if @participant.save
        @participant.person = person
        @participant.save!
        format.html { redirect_to(participants_path, :notice => 'Participant was successfully created.') }
        format.json { render :json => @participant }
      else
        format.html { render :action => "new" }
        format.json { render :json => @participant.errors }
      end
    end
  end

  # GET /participants/1/edit
  def edit
  end

  def update
    respond_to do |format|
      if @participant.update_attributes(params[:participant])
        format.html { redirect_to(participants_path, :notice => 'Participant was successfully updated.') }
        format.json { render :json => @participant }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @participant.errors }
      end
    end
  end

  def edit_arm
  end

  def update_arm
    mark_pending_event_activities_canceled(@participant)
    if @participant.switch_arm

      resp = Event.schedule_and_create_placeholder(psc, @participant)
      if resp && resp.success?
        if @participant.high_intensity
          @notice = "Successfully added #{@participant.person} to High Intensity Arm"
        else
          @notice = "Successfully added #{@participant.person} to Low Intensity Arm"
        end
      else
        @notice = "Switched arm but could not schedule next event [#{@participant.next_study_segment.inspect}]"
      end

      url = edit_participant_path(@participant)
      url = params[:redirect_to] unless params[:redirect_to].blank?
      redirect_to(url, :notice => @notice)
    else
      render :action => "edit_arm"
    end
  end

  def edit_ppg_status
  end

  def update_ppg_status
    respond_to do |format|
      if @participant.update_attributes(params[:participant])
        format.html { redirect_to(participant_path(@participant), :notice => 'Participant PPG Status was successfully updated.') }
        format.json { render :json => @participant }
      else
        format.html { render :action => "edit_ppg_status" }
        format.json { render :json => @participant.errors }
      end
    end
  end

  def mark_event_out_of_window
    @person = @participant.person
  end

  def process_mark_event_out_of_window
    event = Event.find(params[:event_id])
    resp = @participant.mark_event_out_of_window(psc, event)
    if resp && resp.success?
      flash[:notice] = "#{event.to_s} for Participant was marked 'Out of Window'."
    else
      flash[:warning] = "Could not scheduled next event after marking #{event.to_s} 'Out of Window'."
    end
    redirect_to participant_path(@participant)
  end

  def remove_from_active_followup
    @participant.unenroll!(psc, params[:enrollment_status_comment])

    url = participant_path(@participant)
    url = params[:redirect_to] unless params[:redirect_to].blank?

    redirect_to(url, :notice => "Participant is no longer being actively followed in the study.")
  end

  ##
  # Page to show participant in particular state and potentially update that
  # state in case of issues
  def correct_workflow
    @low_intensity_states = [["registered", "Registered"], ["in_pregnancy_probability_group", "In Pregnancy Probibility"]]
  end

  ##
  # Simple action to move participant from one state to the next
  # PUT /participants/1/process_update_state
  def process_update_state
    @participant.state = params[:new_state]
    @participant.high_intensity = true if params[:new_state] == "moved_to_high_intensity_arm"
    @participant.save!
    flash[:notice] = "Participant was moved to #{params[:new_state].titleize}."
    redirect_to correct_workflow_participant_path(@participant)
  end

  ##
  # Show changes
  def versions
    if params[:export]
      send_data(@participant.export_versions, :filename => "#{@participant.public_id}.csv")
    end
  end

  def update_psc
    psc.update_subject(@participant)
    flash[:notice] = "Participant information was sent to PSC."
    redirect_to participant_path(@participant)
  end

  private

    def mark_pending_event_activities_canceled(participant)
      participant.pending_events.each do |e|
        e.cancel_activities(psc)
      end
    end

    def load_participant
      return unless params[:id]
      @participant =
        Participant.find_by_id(params[:id]) ||
        Participant.find_by_p_id(params[:id]) ||
        Person.includes(:participant_person_links => :participant).where(:person_id => params[:id]).first.try(:participant) ||
        raise(ActiveRecord::RecordNotFound, "Couldn't find Participant with id=#{params[:id]} or p_id=#{params[:id]} or self person_id=#{params[:id]}")
    end

end
