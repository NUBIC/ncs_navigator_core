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
  end

  # GET /people/new
  # GET /people/new.json
  def new
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
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def start_instrument
    @person = Person.find(params[:id])
    @contact_link = find_or_create_contact_link
    survey = Survey.most_recent_for_access_code(params[:survey_access_code])
    rs = ResponseSet.where("survey_id = ? and user_id = ?", survey.id, @person.id).first
    if rs.nil? or rs.complete?
      rs, instrument = @person.start_instrument(survey)
    else
      instrument = rs.instrument
    end

    if instrument && instrument.event.nil?
      instrument.event = @contact_link.event
      instrument.save!
    end

    @contact_link.instrument = instrument
    @contact_link.save!
    redirect_to(edit_my_survey_path(:survey_code => params[:survey_access_code], :response_set_code => rs.access_code))
  end

  def responses_for
    @person = Person.find(params[:id])
    @responses = []
    if params[:data_export_identifier]
      @responses = @person.responses_for(params[:data_export_identifier])
    end
  end

  private

    ##
    # An instrument can be associated with an existing ContactLink record
    # or associated with the same contact/event for the given ContactLink
    # If the pata
    def find_or_create_contact_link
      link = ContactLink.find(params[:contact_link_id])
      if params[:initial_instrument_for_contact] == true
        @contact = link.contact
        @event = link.event
        link = ContactLink.create(:contact => @contact, :person => @person, :event => @event, :staff_id => current_staff, :psu_code => NcsNavigatorCore.psu_code)
      end
      link
    end

end