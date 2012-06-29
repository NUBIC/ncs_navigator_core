class SpecimensController < ApplicationController
  before_filter :process_params, :except => [:index]
  after_filter :clear_flash
  
  def clear_flash
    flash.discard
  end

  def index
    @specimen_receipts = array_of_not_shipped_specs
    @specimen_receipts_hash = hash_from_array(@specimen_receipts)
  end
  
  def verify
    array_of_storage_container_ids = params[:storage_container_id]
    if (array_of_storage_container_ids.nil?)
      flash[:notice] = 'Please select specimen to ship'
      @specimen_receipts = array_of_not_shipped_specs
      @specimen_receipts_hash = hash_from_array(@specimen_receipts)      
      render :action => "index"
    else
      populate_specimen_receipts
      respond_to do |format|      
        format.js do
          render :layout => false
        end
      end
    end
  end
  
  def generate
    array_of_spec_shipping_records = []
    saved                          = true
    problem                        = nil
    populate_specimen_receipts
    
    @shipment_receipt_confirmed    = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", "2") # Yes
    @shipment_issues               = NcsCode.for_list_name_and_local_code("SHIPMENT_ISSUES_CL1", "-7") # Not applicable
    @shipment_date                 = (@shipment_date_and_time != nil) ? @shipment_date_and_time.split.first : nil

    @specimen_receipts_hash.each do |key, value|
      sh = SpecimenShipping.new(
            :storage_container_id                   => key, 
            :staff_id                               => current_staff_id, 
            :shipper_id                             => @shipper_id, 
            :shipper_destination                    => @send_to_site_selected_id.first, 
            :shipment_date                          => @shipment_date, 
            :shipment_tracking_number               => @shipment_tracking_number, 
            :psu_code                               => @psu_code, 
            :specimen_processing_shipping_center_id => value[0].specimen_processing_shipping_center_id, 
            :shipment_temperature_code              => @shipping_temperature_selected, 
            :shipment_receipt_confirmed             => @shipment_receipt_confirmed,
            :shipment_issues                        => @shipment_issues)      
      value.each do |sr|
        ship_specimen = sh.ship_specimens.build(      
            :specimen_shipping  => sh,
            :specimen_id        => Specimen.where(:specimen_id => sr.specimen_id).first.id, 
            :volume_amount      => @volume_amt[sr.specimen_id],
            :volume_unit        => @volume_unit[sr.specimen_id])
      end
      array_of_spec_shipping_records << sh
    end
    
    SpecimenShipping.transaction do
      array_of_spec_shipping_records.each do |sh|
        unless sh.save
          saved = false
          problem = sh
          raise ActiveRecord::Rollback             
        end
      end
    end

    respond_to do |format|
      format.js do
        if saved
          flash[:notice] = 'Manifest Log was successfully created.'
          render :action => "show", :layout => false
        else
          render :action => "verify", :locals => { :errors => problem.errors }, :layout => false
        end
      end
      # TODO - below works for the old path -- remove during cleaning up
      format.html do
        if saved
          flash[:notice] = 'Manifest Log was successfully created.'
          render :action => "show"
        else
          render :action => "verify", :locals => { :errors => problem.errors }
        end
      end      
    end

  end
  
  def send_email
    populate_specimen_receipts
    generate_email = Emailer.manifest_email(params)
    generate_email.deliver
    respond_to do |format|
      format.js do
        flash[:notice] = 'Email has been created and sent.'
        render :action => "show", :layout => false
      end
      # TODO - below works for the old path -- remove during cleaning up
      format.html do
        flash[:notice] = 'Email has been created and sent.'    
        render :action => "show"
      end
    end
  end
  
  def process_params
    arrayOfStorageContainerIds = params[:storage_container_id]
    
    @psu_id                                 = @psu_code
    @specimen_processing_shipping_center_id = SpecimenProcessingShippingCenter.last.specimen_processing_shipping_center_id
    @shipper_id                             = params[:shipper_id]
    @staff_id                               = params[:contact_name]
    @shipper_dest                           = params[:shipper_dest]
    @shipment_date_and_time                 = params[:shipment_date_and_time]
    @shipping_temperature                   = NcsCode.ncs_code_lookup(:spec_shipment_temperature_code)
    @shipment_tracking_number               = params[:shipment_tracking_number]
    @contact_name                           = params[:contact_name]
    @contact_phone                          = params[:contact_phone]
    @carrier                                = params[:carrier]
    
    @shipment_temperature_id       = params[:temp]
    if not @shipment_temperature_id.blank?
      @shipment_temperature_id = @shipment_temperature_id.first
    end
    @shipping_temperature_selected = params[:shipping_temperature_selected] || NcsCode.for_list_name_and_local_code("SHIPMENT_TEMPERATURE_CL1", @shipment_temperature_id)

    @send_to_site             = ShipperDestination::LOCATIONS
    @send_to_site_selected_id = params[:dest]
    @send_to_site_selected    = params[:send_to_site_selected]

    if not @send_to_site_id.blank?
      @send_to_site.each do |txt, val| 
        @send_to_site_selected = txt if val.eql? @send_to_site_selected_id.to_s
      end
    end
    @volume_amt = params[:volume_amt]
    @volume_unit = params[:volume_unit]
  end
  
  def array_of_not_shipped_specs
    SpecimenReceipt.all.select{ |sr| SpecimenShipping.where(:storage_container_id => sr.storage_container_id).blank? }
  end
  
  def array_of_selected_spec_receipts(array_of_ids)
    SpecimenReceipt.find(:all, :conditions => { :storage_container_id => array_of_ids})
  end
  
  def array_of_selected_specs (array_of_spec_ids)
    Specimen.find(:all, :conditions => { :specimen_id => array_of_spec_ids})
  end
  
  def hash_from_array(array_of_specs)
    spec_hash = {}
    array_of_specs.each do |s|
      spec_hash[s.storage_container_id] ||= []
      spec_hash[s.storage_container_id] << s
    end
    return spec_hash
  end

  def populate_specimen_receipts
    @specimen_receipts = array_of_selected_spec_receipts(params[:storage_container_id])
    @specimen_receipts_hash = hash_from_array(@specimen_receipts)
  end
end

