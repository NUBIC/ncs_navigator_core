# -*- coding: utf-8 -*-
class SampleShippingsController < ApplicationController
  before_filter do
    @in_edit_mode = params[:in_edit_mode] == 'true'
    flash.discard
  end
  
  def new
    @sample_receipt_stores = SampleReceiptStore.find_all_by_id(params[:sample_storage])
    @samples = []
    @sample_receipt_stores.each do |srs|
      @samples << srs.sample
    end
    @sample_shipping = SampleShipping.new(:sample_receipt_shipping_center_id => SampleReceiptShippingCenter.last)
    @sample_shipping.samples = @samples

    respond_to do |format|      
      format.html do
        render :layout => false
      end
    end
  end
  
  def create
    @params = params[:sample_shipping]
    @params.merge!(:sample_shipped_by_code => NcsCode.for_list_name_and_local_code("SAMPLES_SHIPPED_BY_CL1", "1"),
      :staff_id => current_staff_id,
      :staff_id_track => current_staff_id,
      :psu_code => @psu_code, 
      :sample_receipt_shipping_center_id => SampleReceiptShippingCenter.last.id)
    @sample_shipping = SampleShipping.new(@params)
    
    respond_to do |format|
      if @sample_shipping.save
        format.json { render :json => @sample_shipping}
      else
        format.json { render :json => @sample_shipping.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @sample_shipping = SampleShipping.find(params[:id])
    @in_edit_mode = params[:in_edit_mode] == 'true'
  end

  def edit
    @sample_shipping = SampleShipping.find(params[:id])
  end

  def send_email
    @sample_shipping = SampleShipping.find(params[:sample_shipping][:id])
    generate_email = SpecimenMailer.manifest_email(extract_params(@sample_shipping))
    generate_email.deliver
    respond_to do |format|
      # TODO - below works for the old path -- remove during cleaning up
      format.html do
        flash[:notice] = 'Email has been created and sent.'    
        render :action => "show", :layout => false
      end
    end
    
  end
  
  def extract_params(sample_shipping)
    params
    params[:from_email] = NcsNavigatorCore.configuration.sample_receipt_shipping_center_email
    params[:shipper_id] = sample_shipping.shipper_id
    params[:psu_code] = NcsCode.for_list_name_and_local_code("PSU_CL1", @psu_code) 
    params[:sample_receipt_shipping_center_id] = sample_shipping.sample_receipt_shipping_center.sample_receipt_shipping_center_id
    params[:contact_name] = sample_shipping.contact_name
    params[:contact_phone] = sample_shipping.contact_phone
    params[:carrier] = sample_shipping.carrier
    params[:shipment_tracking_number] = sample_shipping.shipment_tracking_number
    params[:shipment_date_and_time] = sample_shipping.shipment_date
    params[:shipper_dest] = NcsCode.for_list_name_and_local_code("SHIPPER_DESTINATION_CL1", sample_shipping.shipper_destination_code)
    params[:shipping_temperature_selected] = NcsCode.for_list_name_and_local_code("SHIPMENT_TEMPERATURE_CL2", sample_shipping.shipment_coolant_code)
    params[:total_number_of_containers] = sample_shipping.samples.size
    params[:total_number_of_samples] = sample_shipping.samples.size
    params[:kind] = "ENV"
    return params
  end
  
  def update
    @sample_shipping = SampleShipping.find(params[:id])
    @params = params[:sample_shipping]
      respond_to do |format|
        if @sample_shipping.update_attributes(@params)
          flash[:notice] = 'Manifest Log was successfully updated.'
          format.json { render :json => @sample_shipping }
        else
          format.json { render :json => @sample_shipping.errors, :status => :unprocessable_entity  }
        end
      end
  end
end
