class SampleReceiptShippingCentersController < ApplicationController
  def index
    @sample_receipt_shipping_centers = SampleReceiptShippingCenter.find(:all)
    if not @sample_receipt_shipping_centers.blank?
      flash[:notice] = 'If you need to make changes, please contact the help desk.'
    end
    respond_to do |format|
      format.html
      format.json { render :json => @sample_receipt_shipping_centers}
      
    end
  end
  
  def new
    @sample_receipt_shipping_center = SampleReceiptShippingCenter.last
    if @sample_receipt_shipping_center.blank?
      @sample_receipt_shipping_center = SampleReceiptShippingCenter.new
      @sample_receipt_shipping_center.address = Address.new
      flash[:notice] = 'Please be aware you only can create the Sample Receipt Shipping Center once.'
    else
      redirect_to sample_receipt_shipping_center_path(@sample_receipt_shipping_center)
    end
  end  
  
  def create
    @sample_receipt_shipping_center = SampleReceiptShippingCenter.new
    @sample_receipt_shipping_center.psu_code = @psu_code
    set_model_parameters
    @sample_receipt_shipping_center.build_address(@address_params)
    @sample_receipt_shipping_center.sample_receipt_shipping_center_id = @sample_receipt_shipping_center_id    
    respond_to do |format|
      if @sample_receipt_shipping_center.save && @address.update_attributes(@address_params)
        @sample_receipt_shipping_center.address = @address
        @sample_receipt_shipping_center.save!
        
        format.html { redirect_to(sample_receipt_shipping_centers_path)}
        flash[:notice] = 'Sample Receipt Shipping Center was successfully created.'
        format.json { render :json => @sample_receipt_shipping_center}
      else
        format.html { render :new}
        format.json { render :json => @sample_receipt_shipping_center.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  def show
    @sample_receipt_shipping_center = SampleReceiptShippingCenter.find(params[:id])
  end
  
  def edit
    @sample_receipt_shipping_center = SampleReceiptShippingCenter.find(params[:id])
  end
  
  def update
    @sample_receipt_shipping_center = SampleReceiptShippingCenter.find(params[:id])
    set_model_parameters
    respond_to do |format|
      if @address.update_attributes(@address_params)
        @sample_receipt_shipping_center.address = @address
        @sample_receipt_shipping_center.save!
        format.html { redirect_to(sample_receipt_shipping_centers_path, :notice => 'Sample Receipt Shipping Center was successfully updated.') }
        format.json { head :ok }
      else
        format.json { render :json => @sample_receipt_shipping_center.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def set_model_parameters
    @sample_receipt_shipping_center_id = params[:sample_receipt_shipping_center][:sample_receipt_shipping_center_id]
    @address_params = params[:sample_receipt_shipping_center][:address_attributes]
    @address = @sample_receipt_shipping_center.address.blank? ? Address.new : @sample_receipt_shipping_center.address
  end
end
