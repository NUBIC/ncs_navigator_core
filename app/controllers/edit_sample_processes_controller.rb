class EditSampleProcessesController < ApplicationController
  def index
  end
  
  def search_by_id
    search_id = params[:search_id]

    @specimens = get_specimen_receipts(search_id)
    @samples = SampleReceiptStore.where(:sample_id => search_id)

    # TODO = uncomment once fixed
    # @specimen_storage_ids = SpecimenStorage.where(:storage_container_id => search_id)
    # @specimen_receipts_hash = hash_of_specs_by_container_id(@specimen_storage_ids)
    # 
    # @sample_receipt_stores = SampleReceiptStore.where(:sample_id => search_id)
    # @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
    # @sample_receipt_stores_not_shipped = SampleReceiptStore.where(:sample_id => search_id)
    # 
    # @specimen_receipts_not_shipped = SpecimenStorage.where(:storage_container_id => search_id)
    # @specimen_receipts_hash_not_shipped = hash_from_array(@specimen_receipts_not_shipped)
    # 
    # @sample_shippings_not_received = hash_from_array_by_track_num(SampleShipping.where("sample_id = ? or shipment_tracking_number =?", search_id, search_id))
    # @specimen_shippings_not_received = SpecimenShipping.where(:storage_container_id => search_id)
    respond_to do |format|      
       format.js do
         render :layout => false
       end
     end
  end
  
  def get_specimen_receipts(search_id)
    spec_receipts_from_container = SpecimenReceipt.joins(:specimen_storage_container).where("specimen_storage_containers.storage_container_id = ?", search_id)
    spec_receipts_from_specimen = SpecimenReceipt.joins(:specimen).where("specimens.specimen_id = ?", search_id)
    spec_receipts_from_specimen.each do |s|
      if not spec_receipts_from_container.include? s
        spec_receipts_from_container << s
      end
    end
    spec_receipts_from_container
  end
  
  def search_by_date
  end
  
  # def get_fields
  #   search_id = params[:search_id]
  #   @specimens = Specimen.where(:specimen_id => search_id)
  #   @samples = Sample.where(:sample_id => search_id)
  # 
  #   @specimen_receipts_ids = SpecimenReceipt.where(:storage_container_id => search_id)
  #   @specimen_receipts_hash = hash_of_specs_by_container_id(@specimen_receipts_ids)
  #   @sample_receipt_stores = SampleReceiptStore.where(:sample_id => search_id)
  #   @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
  #   @sample_receipt_stores_not_shipped = SampleReceiptStore.where(:sample_id => search_id)
  #   @specimen_receipts_not_shipped = SpecimenStorage.where(:storage_container_id => search_id)
  #   @specimen_receipts_hash_not_shipped = hash_from_array(@specimen_receipts_not_shipped)
  #   @smth = SampleShipping.where("sample_id = ? or shipment_tracking_number =?", search_id, search_id)
  #   puts("--something-- #{@smth.inspect}")
  #   @sample_shippings_not_received = hash_from_array_by_track_num(SampleShipping.where("sample_id = ? or shipment_tracking_number =?", search_id, search_id))
  #   @specimen_shippings_not_received = SpecimenShipping.where(:storage_container_id => search_id)
  #   respond_to do |format|      
  #      format.js do
  #        render :layout => false
  #      end
  #    end
  # 
  #   # @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
  # end
  
  # def store
  #   @specimen_receipts_ids = array_of_selected_specs
  #   @specimen_receipts_hash = hash_of_specs_by_container_id(@specimen_receipts_ids)
  #   @sample_receipt_stores = array_of_sample_receive_store
  #   @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
  # end
  # 
  # def array_of_selected_specs()
  #   # SpecimenReceipt.find(:all, :conditions => { :specimen_id => arrayOfParams})
  #   # SpecimenReceipt.all
  #   SpecimenReceipt.all.select{ |s| SpecimenStorage.where(:storage_container_id => s.storage_container_id).blank?}
  # end
  # 
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