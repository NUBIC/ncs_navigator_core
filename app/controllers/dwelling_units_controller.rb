# -*- coding: utf-8 -*-


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

  ##
  # Creates a household_unit record and associates it with this
  # DwellingUnit and all People at this address
  #
  # TODO: This is really only to be used in development !!!
  def create_household_unit
    @dwelling_unit = DwellingUnit.find(params[:id])
    url = edit_dwelling_unit_path(@dwelling_unit)
    url = params[:redirect_to] unless params[:redirect_to].blank?

    hh = HouseholdUnit.create(:psu_code => @dwelling_unit.psu_code)
    DwellingHouseholdLink.create(:psu_code => @dwelling_unit.psu_code, :dwelling_unit => @dwelling_unit, :household_unit => hh)
    if @dwelling_unit.address.person
      HouseholdPersonLink.create(:psu_code => @dwelling_unit.psu_code, :person => @dwelling_unit.address.person, :household_unit => hh)
    end

    respond_to do |format|
      format.html do
        redirect_to(url, :notice => "Household was successfully created!")
      end
      format.json do
        render :json => { :id => @dwelling_unit.id, :errors => [] }, :status => :ok
      end
    end

  end

end