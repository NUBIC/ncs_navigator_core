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
  
end