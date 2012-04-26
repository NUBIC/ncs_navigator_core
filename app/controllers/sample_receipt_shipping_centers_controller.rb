class SampleReceiptShippingCentersController < ApplicationController
  def index
    @sample_receipt_shipping_centers = SampleReceiptShippingCenter.find(:all)

    respond_to do |format|
      format.html
      format.json { render :json => @sample_receipt_shipping_centers}
    end
  end

  def new
    @sample_receipt_shipping_center = SampleReceiptShippingCenter.new
    @sample_receipt_shipping_center.address = Address.new
  end
  
  def create
    @params = params[:sample_receipt_shipping_center]
    @params[:psu_code] = @psu_code
    @sample_receipt_shipping_center = SampleReceiptShippingCenter.new(params[:sample_receipt_shipping_center])
    respond_to do |format|
     if @sample_receipt_shipping_center.save
        format.html { redirect_to(sample_receipt_shipping_centers_path, :notice => 'Sample Receipt Shipping Center was successfully created.') }
        format.json { render :json => @sample_receipt_shipping_center}
      else
        format.html { render :action => "new"}
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
    respond_to do |format|
      if @sample_receipt_shipping_center.update_attributes(params[:sample_receipt_shipping_center])
        format.html { redirect_to(sample_receipt_shipping_centers_path, :notice => 'Sample Receipt Shipping Center was successfully updated.') }
        format.json { head :ok }
      else
        format.json { render :json => @sample_receipt_shipping_center.errors, :status => :unprocessable_entity }
      end
    end
  end
end