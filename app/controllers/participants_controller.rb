class ParticipantsController < ApplicationController
  layout proc { |controller| controller.request.xhr? ? nil : 'application'  } 
  
  ##
  # List all of the Participants in the application, paginated
  # 
  # GET /participants
  # GET /participants.json
  def index
    params[:page] ||= 1
    @participants = Participant.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => @participants }
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
    resp = psc.schedule_next_segment(@participant, params[:date])

    url = edit_participant_path(@participant)
    url = params[:redirect_to] unless params[:redirect_to].blank?

    if resp && resp.status.to_i < 299
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
    @participant.person = Person.find(params[:person_id])

    respond_to do |format|
      if @participant.save
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
        format.html { redirect_to(participants_path, :notice => 'Participant was successfully created.') }
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
    
    @notice = "Successfully added #{@participant.person} to High Intensity Arm"
    @notice = "Successfully added #{@participant.person} to Low Intensity Arm" if @participant.high_intensity
    
    if @participant.switch_arm
      
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
        path = @participant.current_contact_link.blank? ? participants_path : edit_contact_link_path(@participant.current_contact_link)
        format.html { redirect_to(path, :notice => 'Participant was successfully updated.') }
        format.json { render :json => @participant }
      else
        format.html { render :action => "edit_ppg_status" }
        format.json { render :json => @participant.errors }
      end
    end
  end
  
  ##
  # Developer view to show participant in particular state and the instruments in that state
  def development_workflow
    @participant = Participant.find(params[:id])
  end

  ##
  # Simple action to move participant from one state to the next
  # PUT /participants/1/development_update_state
  def development_update_state
    @participant = Participant.find(params[:id])
    @participant.state = params[:new_state]
    @participant.high_intensity = true if params[:new_state] == "moved_to_high_intensity_arm"
    @participant.save!
    flash[:notice] = "Participant was moved to #{params[:new_state].titleize}."
    redirect_to development_workflow_participant_path(@participant)
  end
  
end