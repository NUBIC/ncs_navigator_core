# -*- coding: utf-8 -*-
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
    @sample_shipping = SampleShipping.where(:shipment_tracking_number => tracking_num).first
    @samples = @sample_shipping.samples.select{ |s| s.sample_receipt_confirmation.blank?}
    @sample_receipt_confirmations_edit = SampleReceiptConfirmation.where(:sample_shipping_id => @sample_shipping.id)
    @sample_receipt_confirmations_new = []
    @samples.each do |s|
      @sample_receipt_confirmation = SampleReceiptConfirmation.new(:sample_receipt_shipping_center_id => @sample_shipping.sample_receipt_shipping_center_id,
                                                                :sample_id => s.id, :shipper_id => @sample_shipping.shipper_id,
                                                                :sample_shipping_id => @sample_shipping.id)
      @sample_receipt_confirmations_new << @sample_receipt_confirmation
    end
    [@sample_receipt_confirmations_edit,@sample_receipt_confirmations_new]
  end

  def create
    @tracking_number = params[:tracking_number]
    @sample_receipt_confirmation = SampleReceiptConfirmation.new(params[:sample_receipt_confirmation])
    @sample_receipt_confirmation.psu_code = @psu_code
    @sample_receipt_confirmation.staff_id = current_staff_id

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