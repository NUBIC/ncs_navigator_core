class ParticipantsController < ApplicationController
  layout proc { |controller| controller.request.xhr? ? nil : 'application'  }

  ##
  # List all of the Participants in the application, paginated
  #
  # GET /participants
  # GET /participants.json
  def index
    params[:page] ||= 1

    params[:q] ||= {}
    params[:q][:participant_person_links_relationship_code_eq] = 1

    @q = Participant.search(params[:q])
    # @q.sorts = 'last_name asc' if @q.sorts.empty?
    result = @q.result(:distinct => true)
    @participants = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => result.all }
    end
  end

  ##
  # List all Participants in the application who belong to this Pregnancy Probability Group
  #
  # GET /participants/in_ppg_group?ppg_group=X
  def in_ppg_group
    params[:ppg_group] ||= 1
    @ppg_group = NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => params[:ppg_group]).first
    @participants = Participant.in_ppg_group(params[:ppg_group].to_i)
  end

  ##
  # GET /participants/:id
  def show
    @participant = Participant.find(params[:id])
    @person = @participant.person
    @scheduled_activities = psc.scheduled_activities(@participant)
    @scheduled_activities_grouped_by_date = {}
    @scheduled_activities.each do |a|
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
    @participant = Participant.find(params[:id])
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
    @participant = Participant.find(params[:id])

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
    @participant = Participant.find(params[:id])
    @subject_schedules = psc.schedules(@participant)
  end

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
    @participant = Participant.find(params[:id])
  end

  def update
    @participant = Participant.find(params[:id])

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
    @participant = Participant.find(params[:id])
  end

  def update_arm
    @participant = Participant.find(params[:id])

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
    @participant = Participant.find(params[:id])
  end

  def update_ppg_status
    @participant = Participant.find(params[:id])
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

  ##
  # Page to show participant in particular state and potentially update that
  # state in case of issues
  def correct_workflow
    @low_intensity_states = [["registered", "Registered"], ["in_pregnancy_probability_group", "In Pregnancy Probii"]]
    @participant = Participant.find(params[:id])
  end

  ##
  # Simple action to move participant from one state to the next
  # PUT /participants/1/process_update_state
  def process_update_state
    @participant = Participant.find(params[:id])
    @participant.state = params[:new_state]
    @participant.high_intensity = true if params[:new_state] == "moved_to_high_intensity_arm"
    @participant.save!
    flash[:notice] = "Participant was moved to #{params[:new_state].titleize}."
    redirect_to correct_workflow_participant_path(@participant)
  end

  ##
  # Show changes
  def versions
    @participant = Participant.find(params[:id])
    if params[:export]
      send_data(@participant.export_versions, :filename => "#{@participant.public_id}.csv")
    end
  end

  private

    def mark_pending_event_activities_canceled(participant)
      participant.pending_events.each do |e|

  	    activity = nil
  	    psc.activities_for_event(e).each do |a|
  	      activity = a if e.matches_activity(a)
        end

  	    if activity
  	      psc.update_activity_state(activity.activity_id, participant, PatientStudyCalendar::ACTIVITY_CANCELED)
  	    end
      end
    end

end
