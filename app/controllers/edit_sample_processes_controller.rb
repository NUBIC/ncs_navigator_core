class EditSampleProcessesController < ApplicationController
  before_filter [:in_edit_mode, :clear_flash]
  after_filter :clear_flash
  
  def clear_flash
    flash.discard
  end
    
  def in_edit_mode
    @edit = true
  end
  
  def index
  end

  
  def search_by_id
    search_id = params[:search_id].first.strip

    @specimens = get_specimen_receipts(search_id)
    @samples = SampleReceiptStore.joins(:sample).where("samples.sample_id = ?", search_id)

    @specimen_storages = get_specimen_storages(@specimens, search_id)
    
    @sample_shippings = get_sample_shippings(search_id)

    @sample_receipt_confirmation = SampleReceiptConfirmation.joins(:sample).where("samples.sample_id = ?", search_id).first

    @specimen_shippings = get_specimen_shippings(search_id)
    
    @specimen_receipt_confirmation = SpecimenReceiptConfirmation.joins(:specimen).where("specimens.specimen_id = ?", search_id).first

    respond_to do |format|      
       format.html do
         render :layout => false
       end
     end
  end
  
  def get_specimen_receipts(search_id)
    spec_receipts_from_container = SpecimenReceipt.joins(:specimen_storage_container).where("specimen_storage_containers.storage_container_id = ?", search_id)
    spec_receipts_from_specimen = SpecimenReceipt.joins(:specimen).where("specimens.specimen_id = ?", search_id)
    spec_receipts_from_container | spec_receipts_from_specimen
  end
  
  def get_specimen_storages(spec_receipts, search_id)
    spec_storages_from_container = SpecimenStorage.joins(:specimen_storage_container).where("specimen_storage_containers.storage_container_id = ?", search_id)
    spec_storages_from_receipts = spec_receipts.select{|sr| sr.specimen_storage_container.specimen_storage}.map{|ss| ss.specimen_storage_container.specimen_storage}
    spec_storages_from_container | spec_storages_from_receipts
  end
  
  def get_sample_shippings(search_id)
    sample_shippings = SampleShipping.find :all, :joins => [:samples], :conditions => ["samples.sample_id = ? or shipment_tracking_number = ?", search_id, search_id]
    sample_shippings_hash = {}
    sample_shippings.each do |ss|
      sample_shippings_hash[ss] ||= []
      sample_shippings_hash[ss] = ss.samples
    end
    return sample_shippings_hash
  end
  
  def get_specimen_shippings(search_id)                                                       
    array_of_specimen_shipping_ids = SpecimenShipping.find_id_by_tracking_number_or_specimen_or_storage_container(search_id)
    SpecimenShipping.includes(:specimen_storage_containers => {:specimen_receipts => :specimen}).where("specimen_shippings.id" => array_of_specimen_shipping_ids)
  end
  
  def hash_of_specs_by_container_id(specimen_storage)
    spec_hash = {}
    specimen_storage.each do |s|
      s.specimen_receipts.each do |sr|
        spec_hash[sr.storage_container_id] ||= []
        spec_hash[sr.storage_container_id] << sr.specimen_id
      end
    end
    return spec_hash
  end
  
  def hash_from_array(array_of_specs)
    spec_hash = {}
    array_of_specs.each do |s|
      spec_hash[s.storage_container_id] ||= []
      spec_hash[s.storage_container_id] << s
    end
    return spec_hash
  end
   
  def array_of_empty_spec_storages(arrayOfKeys)
      specimen_storages = []
      arrayOfKeys.each do |s|
        specimen_storages.push(SpecimenStorage.new(:storage_container_id => s))
      end
      return specimen_storages
  end

  def hash_from_array_by_track_num(array_of_samples)
    spec_hash = {}
    array_of_samples.each do |s|
      spec_hash[s.shipment_tracking_number] ||= []
      spec_hash[s.shipment_tracking_number] << s
    end
    return spec_hash
  end  
end