class DwellingUnitsController < ApplicationController

  # GET /dwelling_units
  # GET /dwelling_units.json
  def index
    params[:page] ||= 1
    @dwelling_units = DwellingUnit.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.json { render :json => @dwelling_units }
    end
  end

  # GET /dwelling_units/new
  # GET /dwelling_units/new.json
  def new
    @dwelling_unit = DwellingUnit.new
    @dwelling_unit.address = Address.new
    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @dwelling_unit }
    end
  end

  # POST /dwelling_units
  # POST /dwelling_units.json
  def create
    @dwelling_unit = DwellingUnit.new(params[:dwelling_unit])

    respond_to do |format|
      if @dwelling_unit.save
        format.html { redirect_to(dwelling_units_path, :notice => 'Dwelling was successfully created.') }
        format.json { render :json => @dwelling_unit }
      else
        format.html { render :action => "new" }
        format.json { render :json => @dwelling_unit.errors }
      end
    end
  end

  # GET /dwelling_units/1/edit
  def edit
    @dwelling_unit = DwellingUnit.find(params[:id])
  end

  # PUT /dwelling_units/1
  # PUT /dwelling_units/1.json
  def update
    @dwelling_unit = DwellingUnit.find(params[:id])

    respond_to do |format|
      if @dwelling_unit.update_attributes(params[:dwelling_unit])
        format.html { redirect_to(dwelling_units_path, :notice => 'Dwelling was successfully updated.') }
        format.json { render :json => @dwelling_unit }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @dwelling_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

end