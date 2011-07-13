class PeopleController < ApplicationController

  # GET /people
  # GET /people.json
  def index
    params[:page] ||= 1
    @people = Person.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json  { render :json => @people }
    end
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
  
end