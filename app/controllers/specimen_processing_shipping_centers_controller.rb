class SpecimenProcessingShippingCentersController < ApplicationController
  before_filter :define_spsc_id
  
  def define_spsc_id
    @specimen_processing_shipping_center_id = NcsNavigatorCore.spsc_id
  end
  
  def index
    @specimen_processing_shipping_centers = SpecimenProcessingShippingCenter.find(:all)

    respond_to do |format|
      format.html
      format.json { render :json => @specimen_processing_shipping_centers}
    end
  end
  
  def new
    @specimen_processing_shipping_center = SpecimenProcessingShippingCenter.last
    if @specimen_processing_shipping_center.blank?
      @specimen_processing_shipping_center = SpecimenProcessingShippingCenter.new
      @specimen_processing_shipping_center.address = Address.new
    else
      render :edit, :notice => 'Specimen Processing Shipping Center already exists'
    end
  end  
  
  def create
    @params = params[:specimen_processing_shipping_center]
    @params[:psu_code] = @psu_code
    @params[:specimen_processing_shipping_center_id] = @specimen_processing_shipping_center_id
    @specimen_processing_shipping_center = SpecimenProcessingShippingCenter.new(@params)
    respond_to do |format|
     if @specimen_processing_shipping_center.save
        format.html { redirect_to(specimen_processing_shipping_centers_path, :notice => 'Specimen Processing Shipping Center was successfully created.') }
        format.json { render :json => @specimen_processing_shipping_center}
      else
        format.html { render :action => "new"}
        format.json { render :json => @specimen_processing_shipping_center.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  def show
    @specimen_processing_shipping_center = SpecimenProcessingShippingCenter.find(params[:id])
  end
  
  def edit
    @specimen_processing_shipping_center = SpecimenProcessingShippingCenter.find(params[:id])
  end
  
  def update
    @specimen_processing_shipping_center = SpecimenProcessingShippingCenter.find(params[:id])
    respond_to do |format|
      if @specimen_processing_shipping_center.update_attributes(params[:specimen_processing_shipping_center])
        format.html { redirect_to(specimen_processing_shipping_centers_path, :notice => 'Specimen Processing Shipping Center was successfully updated.') }
        format.json { head :ok }
      else
        format.json { render :json => @specimen_processing_shipping_center.errors, :status => :unprocessable_entity }
      end
    end
  end
end