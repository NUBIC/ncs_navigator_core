# -*- coding: utf-8 -*-
class SpecimenShippingsController < ApplicationController
  def new
    @specimen_storages = SpecimenStorage.find_all_by_id(params[:specimen_storage])
    ncs_location = ShipperDestination::SPECIMEN_LOCATIONS.first
    @specimen_shipping = SpecimenShipping.new(:specimen_processing_shipping_center => SpecimenProcessingShippingCenter.last, :shipper_destination => ncs_location.first)
    
    @specimen_storages.each do |ss| 
      ss.specimen_storage_container.specimen_receipts.each do |sr|
        @specimen_shipping.ship_specimens.build(:specimen_id => sr.specimen.id)
      end
    end

    respond_to do |format|      
      format.html do
        render :layout => false
      end
    end
  end
  
  def create
    @params = params[:specimen_shipping]
    @params.merge!(:shipment_receipt_confirmed_code => NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", "2"), 
      :shipment_issues_code => NcsCode.for_list_name_and_local_code("SHIPMENT_ISSUES_CL1", "-7"), 
      :staff_id => current_staff_id, :shipper_destination => ShipperDestination::SPECIMEN_LOCATIONS.first.last,
      :psu_code => @psu_code, 
      :specimen_processing_shipping_center_id => SpecimenProcessingShippingCenter.last.id)
    @specimen_shipping = SpecimenShipping.new(@params)
    specimen_storage_containers = params[:specimen_storage_container_id]
    specimen_storage_containers.each do |ssc| 
      @specimen_shipping.specimen_storage_containers << SpecimenStorageContainer.find_by_storage_container_id(ssc)
    end
    
    respond_to do |format|
      if @specimen_shipping.save
        format.json { render :json => @specimen_shipping}
      else
        format.json { render :json => @specimen_shipping.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    ncs_location = ShipperDestination::SPECIMEN_LOCATIONS.first
    @send_to_site = ncs_location.first
    @specimen_shipping = SpecimenShipping.find(params[:id])
  end

  def edit
    @specimen_shipping = SpecimenShipping.find(params[:id])
  end

  def send_email
    @specimen_shipping = SpecimenShipping.find(params[:specimen_shipping][:id])    
    generate_email = Emailer.manifest_email(extract_params(@specimen_shipping))
    generate_email.deliver
    respond_to do |format|
      # TODO - below works for the old path -- remove during cleaning up
      format.html do
        flash[:notice] = 'Email has been created and sent.'    
        render :action => "show", :layout => false
      end
    end
    
  end
  
  def extract_params(specimen_shipping)
    params
    params[:shipper_id] = specimen_shipping.shipper_id
    params[:specimen_processing_shipping_center_id] = specimen_shipping.specimen_processing_shipping_center.specimen_processing_shipping_center_id
    params[:sample_receipt_shipping_center_id] = ""
    params[:contact_name] = specimen_shipping.contact_name
    params[:contact_phone] = specimen_shipping.contact_phone
    params[:carrier] = specimen_shipping.carrier
    params[:shipment_tracking_number] = specimen_shipping.shipment_tracking_number
    params[:shipment_date_and_time] = specimen_shipping.shipment_date
    params[:shipper_dest] = ShipperDestination::SPECIMEN_LOCATIONS.first.first
    params[:shipping_temperature_selected] = specimen_shipping.shipment_temperature_code
    params[:total_number_of_containers] = 1
    params[:total_number_of_samples] = specimen_shipping.ship_specimens.size
    params[:kind] = "BIO"
    return params
  end
  
  def update
    @specimen_shipping = SpecimenShipping.find(params[:id])
    @params = params[:specimen_shipping]
      respond_to do |format|
        if @specimen_shipping.update_attributes(@params)
          flash[:notice] = 'Manifest Log was successfully updated.'
          format.json { render :json => @specimen_shipping }
        else
          format.json { render :json => @specimen_shipping.errors, :status => :unprocessable_entity  }
        end
      end
  end
end