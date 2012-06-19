class SampleReceiptConfirmationsController < ApplicationController
  
  def index
    array_of_samples_per_tracking_number(params[:tracking_number])
    respond_to do |format|      
       format.js do
         render :layout => false
       end
     end
  end
  
  def array_of_samples_per_tracking_number(tracking_num)
    # have to only include the ones by trac_num and where sample_ids are not in sample_receipt_confirm
    @sample_shippings = SampleShipping.where(:shipment_tracking_number => tracking_num).all.select{ |ss| SampleReceiptConfirmation.where(:sample_id => ss.sample_id).blank? }
    @sample_receipt_confirmations_edit = SampleReceiptConfirmation.where(:shipment_tracking_number => tracking_num)
    @sample_receipt_confirmations_new = []
    @sample_shippings.each do |ss|
      @sample_receipt_confirmation = SampleReceiptConfirmation.new(:sample_receipt_shipping_center_id => ss.sample_receipt_shipping_center_id,
                                                                :sample_id => ss.sample_id, :shipper_id => ss.shipper_id, 
                                                                :shipment_tracking_number => ss.shipment_tracking_number)
      @sample_receipt_confirmations_new << @sample_receipt_confirmation
    end
    [@sample_receipt_confirmations_edit,@sample_receipt_confirmations_new]
  end

  def create
    @tracking_number = params[:tracking_number]
    @sample_receipt_confirmation = SampleReceiptConfirmation.new(params[:sample_receipt_confirmation])
    @sample_receipt_confirmation.psu_code = @psu_code

    respond_to do |format|
      if @sample_receipt_confirmation.save
        format.html { redirect_to(sample_receipt_confirmations_path(params[:tracking_number])) }
        format.json { render :json => @sample_receipt_confirmation }
        flash[:notice] = 'Sample Receipt Confirmation was successfully created.'
      else
        format.json { render :json => @sample_receipt_confirmation.errors, :status => :unprocessable_entity }
      end
    end    
    
  end
  
  def update
    @sample_receipt_confirmation = SampleReceiptConfirmation.find(params[:id])
    respond_to do |format|
      if @sample_receipt_confirmation.update_attributes(params[:sample_receipt_confirmation])
        format.html { redirect_to(sample_receipt_shipping_centers_path, :notice => 'Sample Receipt Shipping Center was successfully updated.') }
        format.json { render :json => @sample_receipt_confirmation }
      else
        format.json { render :json => @sample_receipt_confirmation.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  def show
    @sample_receipt_confirmation = SampleReceiptConfirmation.find(params[:id])
  end 
  
  def edit
    @sample_receipt_confirmation = SampleReceiptConfirmation.find(params[:id])
  end  
end