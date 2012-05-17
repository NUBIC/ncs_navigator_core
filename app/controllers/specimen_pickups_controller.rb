# SpecimenPickupsController
class SpecimenPickupsController < ApplicationController

  def new
    @specimen_pickup = SpecimenPickup.new()
    @specimen_pickup.specimens.build(:instrument_id => "associated instrument")
  end
  
  def create
    #TODO - have to hard-code params below. should get those from config page later
    @params = params[:specimen_pickup]
    @params[:psu_code] = @psu_code
    @params[:staff_id] = current_staff_id
    @params[:event_id] = "associated event"
    @params[:specimen_processing_shipping_center_id] = SpecimenProcessingShippingCenter.last.specimen_processing_shipping_center_id
    @specimen_pickup = SpecimenPickup.new(@params)
    respond_to do |format|
      if @specimen_pickup.save
        format.html { redirect_to(specimen_pickup_path(@specimen_pickup), :notice => 'Specimen Form was successfully created.') }
        format.json { render :json => @specimen_pickup }
      else
        format.html { render :action => "new"}
        format.json { render :json => @specimen_pickup.errors }
      end
    end    
  end
  
  def show
    @specimen_pickup = SpecimenPickup.find(params[:id])
  end
end