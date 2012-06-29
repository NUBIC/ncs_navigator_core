class SamplesController < ApplicationController
  before_filter :process_params, :except => [:index]
  after_filter :clear_flash

  def clear_flash
    flash.discard
  end

  def index
    @sample_receipt_stores = array_of_not_shipped_samples
  end
  
  def verify
    array_of_samples = params[:sample_id]    
    if (array_of_samples.nil?)
      flash[:error] = 'Please select sample to ship'
      @sample_receipt_stores = array_of_not_shipped_samples
      render :action => "index"
    else
      @sample_receipt_stores      = array_of_selected_samples(array_of_samples)
      populate_samples_size(@sample_receipt_stores) 
      respond_to do |format|      
        format.js do
          render :layout => false
        end
      end
    end
  end
  
  def generate
    array_of_spec_shipping_records = []
    saved = true
    problem = nil
    
    @sample_receipt_stores = array_of_selected_samples(params[:sample_id])
    populate_samples_size(@sample_receipt_stores)
    
    @shipment_date = (@shipment_date_and_time != nil) ? @shipment_date_and_time.split.first : nil
    @sample_shipped_by = NcsCode.for_list_name_and_local_code("SAMPLES_SHIPPED_BY_CL1", "1")
    @sample_receipt_stores.each do |srs|
      sh = SampleShipping.new(
        :sample_id                         => srs.sample_id, 
        :staff_id                          => @staff_id, 
        :shipper_id                        => @shipper_id, 
        :shipper_destination_code          => @send_to_site_selected, 
        :shipment_date                     => @shipment_date, 
        :shipment_coolant_code             => @shipping_temperature_selected,
        :shipment_tracking_number          => @shipment_tracking_number, 
        :psu_code                          => @psu_code,
        :sample_shipped_by                 => @sample_shipped_by,
        :sample_receipt_shipping_center_id => srs.sample_receipt_shipping_center_id, 
        :volume_amount                     => @volume_amt[srs.sample_id], 
        :volume_unit                       => @volume_unit[srs.sample_id])

      array_of_spec_shipping_records << sh
      SampleShipping.transaction do
        array_of_spec_shipping_records.each do |sh|
          unless sh.save
            saved = false
            problem = sh
            raise ActiveRecord::Rollback             
          end
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
    @sample_receipt_stores = array_of_selected_samples(params[:sample_id])
    populate_samples_size(@sample_receipt_stores)
    
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
  
  def populate_samples_size(samples)
    @total_number_of_containers = samples.size
    @total_number_of_samples =  samples.size
  end 
  
  def process_params
    @psu_id                            = @psu_code
    @sample_receipt_shipping_center_id = SampleReceiptShippingCenter.last.sample_receipt_shipping_center_id
    @shipper_id                        = params[:shipper_id]
    @staff_id                          = current_staff_id
    @shipment_date_and_time            = params[:shipment_date_and_time]
    @shipment_tracking_number          = params[:shipment_tracking_number]
    @contact_name                      = params[:contact_name]
    @contact_phone                     = params[:contact_phone]
    @carrier                           = params[:carrier]
    @volume_amt = params[:volume_amt]
    @volume_unit = params[:volume_unit]
    
    @shipping_temperature =  NcsCode.ncs_code_lookup(:sample_shipment_temperature_code)
    @shipment_temperature_id = params[:temp]
    if not @shipment_temperature_id.blank?
      @shipment_temperature_id = @shipment_temperature_id.first
    end
    @shipping_temperature_selected = params[:shipping_temperature_selected] || NcsCode.for_list_name_and_local_code("SHIPMENT_TEMPERATURE_CL2", @shipment_temperature_id)    
    
    @send_to_site = NcsCode.ncs_code_lookup(:sample_shipper_destination_code)
    @send_to_site_id = params[:dest]
    if not @send_to_site_id.blank?
      @send_to_site_id = @send_to_site_id.first
    end
    @send_to_site_selected = params[:send_to_site_selected] || NcsCode.for_list_name_and_local_code("SHIPPER_DESTINATION_CL1", @send_to_site_id)
  end  
  
  def array_of_not_shipped_samples
    SampleReceiptStore.all.select{ |sr| SampleShipping.where(:sample_id => sr.sample_id).blank?}
  end
  
  def array_of_selected_samples(arrayOfIds)
    SampleReceiptStore.find(:all, :conditions => { :sample_id => arrayOfIds})
  end 
  
end