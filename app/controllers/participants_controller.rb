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
  # If the Participant is not known to PSC, register the participant
  #
  # POST /participant/:id/register_with_psc
  # POST /participant:id/register_with_psc.json
  def register_with_psc
    @participant = Participant.find(params[:id])
    @participant.register! if @participant.can_register? # move state so that the participant can tell PSC what is the next study segment to schedule
    
    resp = PatientStudyCalendar.assign_subject(@participant)

    url = edit_participant_path(@participant)
    url = params[:redirect_to] unless params[:redirect_to].blank?

    Rails.logger.info(resp.inspect)
    Rails.logger.info(resp.headers.inspect)

    if resp.status.to_i < 299
      respond_to do |format|
        format.html do
          redirect_to(url, :notice => "#{@participant.person.to_s} registered with PSC")
        end
        format.json do
          render :json => { :id => @participant.id, :errors => [] }, :status => :ok
        end
      end
    else
      @participant.update_attribute(:state, 'pending') if @participant.registered? # reset to initial state if failed to register with PSC
      respond_to do |format|
        format.html do
          redirect_to(url, :error => "#{resp.body}")
        end
        format.json do
          render :json => { :id => @participant.id, :errors => "#{resp.body}" }, :status => :error
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
    @subject_schedules = PatientStudyCalendar.schedules(@participant)
  end
  
  # GET /participants/new
  # GET /participants/new.json
  def new
    if params[:person_id].blank?
      redirect_to(people_path, :notice => 'Cannot create a Participant without a reference to a Person')
    elsif @participant = Participant.where(:person_id => params[:person_id]).first
      redirect_to(edit_participant_path(@participant), :notice => 'Participant already exists')
    else
      @participant = Participant.new(:person_id => params[:person_id])

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
  
end