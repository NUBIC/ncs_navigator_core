class SpecimenProcessingShippingCentersController < ApplicationController
  def index
    @specimen_processing_shipping_centers = SpecimenProcessingShippingCenter.find(:all)
    if not @specimen_processing_shipping_centers.blank?
      flash[:notice] = 'If you need to make changes, please contact the help desk.'
    end

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
      flash[:notice] = 'Please be aware you only can create the Specimen Processing Shipping Center once.'
    else
      redirect_to specimen_processing_shipping_center_path(@specimen_processing_shipping_center)
    end
  end
  
  def create
    @specimen_processing_shipping_center = SpecimenProcessingShippingCenter.new
    @specimen_processing_shipping_center.psu_code = @psu_code
    set_model_parameters
    @specimen_processing_shipping_center.build_address(@address_params)
    @specimen_processing_shipping_center.specimen_processing_shipping_center_id = @specimen_processing_shipping_center_id
    respond_to do |format|
      if @specimen_processing_shipping_center.save && @address.update_attributes(@address_params)
        @specimen_processing_shipping_center.address = @address
        @specimen_processing_shipping_center.save!
        format.html { redirect_to(specimen_processing_shipping_centers_path) }
        flash[:notice] = 'Specime Processing Shipping Center was successfully created.'
        format.json { render :json => @specimen_processing_shipping_center}
      else
        format.html { render :new}
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
    set_model_parameters
    respond_to do |format|
      if @address.update_attributes(@address_params)
        @specimen_processing_shipping_center.address = @address
        @specimen_processing_shipping_center.save!
        format.html { redirect_to(specimen_processing_shipping_centers_path, :notice => 'Specimen Processing Shipping Center was successfully updated.') }
        format.json { head :ok }
      else
        format.json { render :json => @specimen_processing_shipping_center.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def set_model_parameters
    @specimen_processing_shipping_center_id = params[:specimen_processing_shipping_center][:specimen_processing_shipping_center_id]    
    @address_params = params[:specimen_processing_shipping_center][:address_attributes]
    @address = @specimen_processing_shipping_center.address.blank? ? Address.new : @specimen_processing_shipping_center.address
  end
end