class ParticipantsController < ApplicationController
  
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
  
  def in_ppg_group
    params[:ppg_group] ||= 1
    @ppg_group = NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => params[:ppg_group]).first
    @participants = Participant.in_ppg_group(params[:ppg_group].to_i)
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
  
  def edit_arm
    @participant = Participant.find(params[:id])
  end
  
  def update_arm
    @participant = Participant.find(params[:id])
    
    @notice = "Successfully added #{@participant.person} to High Intensity Arm"
    @notice = "Successfully added #{@participant.person} to Low Intensity Arm" if @participant.high_intensity
    
    @participant.high_intensity = !@participant.high_intensity
    
    if @participant.save
      
      url = edit_participant_path(@participant)
      url = params[:redirect_to] unless params[:redirect_to].blank?
      redirect_to(url, :notice => @notice)
    else
      render :action => "edit_arm"
    end
  end
  
end