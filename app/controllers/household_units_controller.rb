class HouseholdUnitsController < ApplicationController

  # GET /household_units
  # GET /household_units.json
  def index
    params[:page] ||= 1
    @household_units = HouseholdUnit.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json  { render :json => @household_units }
    end
  end
  
  # GET /household_units/new
  # GET /household_units/new.json
  def new
    @household_unit = HouseholdUnit.new
    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @household_unit }
    end
  end

  # POST /household_units
  # POST /household_units.json
  def create
    @household_unit = HouseholdUnit.new(params[:household_unit])

    respond_to do |format|
      if @household_unit.save
        format.html { redirect_to(household_units_path, :notice => 'Household was successfully created.') }
        format.json { render :json => @household_unit }
      else
        format.html { render :action => "new" }
        format.json { render :json => @household_unit.errors }
      end
    end
  end
  
  # GET /household_units/1/edit
  def edit
    @household_unit = HouseholdUnit.find(params[:id])
  end

  # PUT /household_units/1
  # PUT /household_units/1.json
  def update
    @household_unit = HouseholdUnit.find(params[:id])

    respond_to do |format|
      if @household_unit.update_attributes(params[:household_unit])
        format.html { redirect_to(household_units_path, :notice => 'Household was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @household_unit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end