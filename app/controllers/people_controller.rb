# -*- coding: utf-8 -*-


class PeopleController < ApplicationController

  # GET /people
  # GET /people.json
  def index
    params[:page] ||= 1

    @q = Person.search(params[:q])
    result = @q.result(:distinct => true)
    @people = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => result.all }
    end
  end

  # GET /people/1
  def show
    @person = Person.find(params[:id])
    @participant = @person.participant
    redirect_to participant_path(@participant) if @participant
  end

  # GET /people/new
  # GET /people/new.json
  def new  
    unless params[:participant_id].blank?
      @participant = Participant.find(params[:participant_id])
    end
    @person = Person.new  

      respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @person }
    end
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save

        ## Create relationship to participant if participant_id is sent
        if !params[:participant_id].blank? && !params[:relationship_code].blank?
          @participant = Participant.find(params[:participant_id])
          ParticipantPersonLink.create(:participant => @participant, :person => @person, :relationship_code => params[:relationship_code])
        end


        format.html { redirect_to(people_path, :notice => 'Person was successfully created.') }
        format.json { render :json => @person }
      else
        format.html { render :action => "new" }
        format.json { render :json => @person.errors }
      end
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(people_path, :notice => 'Person was successfully updated.') }
        format.json { render :json => @person }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /people/1/start_instrument
  def start_instrument
    # get information from params
    person = Person.find(params[:id])
    participant = Participant.find(params[:participant_id])
    instrument_survey = Survey.most_recent_for_access_code(params[:references_survey_access_code])
    current_survey = Survey.most_recent_for_access_code(params[:survey_access_code])

    # determine event
    cl = person.contact_links.includes(:event, :contact).find(params[:contact_link_id])
    event = cl.event

    # start instrument
    instrument = Instrument.start(person, participant, instrument_survey, current_survey, event)
    instrument.save!

    # add instrument to contact link
    link = instrument.link_to(person, cl.contact, event, current_staff_id)
    link.save!

    # redirect
    rs_access_code = instrument.response_sets.where(:survey_id => current_survey.id).last.try(:access_code)
    redirect_to(edit_my_survey_path(:survey_code => params[:survey_access_code], :response_set_code => rs_access_code))
  end

  def responses_for
    @person = Person.find(params[:id])
    if request.put?
      @responses = []
      if params[:data_export_identifier]
        @responses = @person.responses_for(params[:data_export_identifier])
      end
    end
  end

  ##
  # Show changes
  def versions
    @person = Person.find(params[:id])
    if params[:export]
      send_data(@person.export_versions, :filename => "#{@person.public_id}.csv")
    end
  end

end