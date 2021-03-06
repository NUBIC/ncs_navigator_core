# -*- coding: utf-8 -*-
class SpecimenReceiptConfirmationsController < ApplicationController
  
  def index
    array_of_specimens_per_tracking_number(params[:tracking_number])
    @specimen_shipping = SpecimenShipping.where(:shipment_tracking_number => params[:tracking_number]).first
    respond_to do |format|      
       format.js do
         render :layout => false
       end
     end
  end
  
  def array_of_specimens_per_tracking_number(tracking_num)
    # have to only include the ones by trac_num and where spec_ids are not in spec_receipt_confirm
    @specimen_shipping = SpecimenShipping.where(:shipment_tracking_number => tracking_num).first
    @specimen_receipt_confirmations_edit = SpecimenReceiptConfirmation.where(:specimen_shipping_id => @specimen_shipping.id)
    @specimen_receipt_confirmations_new = []

    @specimen_receipts = SpecimenReceipt.where(:specimen_storage_container_id => @specimen_shipping.specimen_storage_containers).all.reject{ |sr| SpecimenReceiptConfirmation.where(:specimen_id => sr.specimen_id).any?}
    @specimen_receipts.each do |sr| 
      
      @specimen_receipt_confirmation = SpecimenReceiptConfirmation.new(:specimen_processing_shipping_center_id => @specimen_shipping.specimen_processing_shipping_center_id,
                                                              :specimen_id => sr.specimen_id, :shipper_id => @specimen_shipping.shipper_id, 
                                                              :specimen_shipping_id => @specimen_shipping.id)
      @specimen_receipt_confirmations_new << @specimen_receipt_confirmation
    end
    [@specimen_receipt_confirmations_edit,@specimen_receipt_confirmations_new]
  end

  def create
    @tracking_number = params[:tracking_number]
    @specimen_receipt_confirmation = SpecimenReceiptConfirmation.new(params[:specimen_receipt_confirmation])
    @specimen_receipt_confirmation.psu_code = @psu_code
    @specimen_receipt_confirmation.staff_id = current_staff_id
    respond_to do |format|
      if @specimen_receipt_confirmation.save
        format.html { redirect_to(specimen_receipt_confirmations_path(params[:tracking_number])) }
        format.json { render :json => @specimen_receipt_confirmation }
        flash[:notice] = 'Specimen Receipt Confirmation was successfully created.'
      else
        format.json { render :json => @specimen_receipt_confirmation.errors, :status => :unprocessable_entity }
      end
    end    
    
  end
  
  def update
    @specimen_receipt_confirmation = SpecimenReceiptConfirmation.find(params[:id])
    respond_to do |format|
      if @specimen_receipt_confirmation.update_attributes(params[:specimen_receipt_confirmation])
        format.html { redirect_to(specimen_receipt_confirmations_path, :notice => 'Specimen Receipt Shipping Center was successfully updated.') }
        format.json { render :json => @specimen_receipt_confirmation}
      else
        format.json { render :json => @specimen_receipt_confirmation.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  def show
    @specimen_receipt_confirmation = SpecimenReceiptConfirmation.find(params[:id])
  end 
  
  def edit
    @specimen_receipt_confirmation = SpecimenReceiptConfirmation.find(params[:id])
  end
  
end