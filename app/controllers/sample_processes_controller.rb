class SampleProcessesController < ApplicationController

  def index
    @specimens = array_of_not_stored_specimens
    @samples = array_of_not_stored_samples
    
    
    @specimen_receipts_ids = array_of_selected_specs
    @specimen_receipts_hash = hash_of_specs_by_container_id(@specimen_receipts_ids)
    @sample_receipt_stores = array_of_sample_receive_store
    @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
    @sample_receipt_stores_not_shipped = array_of_not_shipped_samples
    @specimen_receipts_not_shipped = array_of_not_shipped_specs
    @specimen_receipts_hash_not_shipped = hash_from_array(@specimen_receipts_not_shipped)
  end
  
  def array_of_not_shipped_specs
    SpecimenStorage.all.select{ |sr| SpecimenShipping.where(:storage_container_id => sr.storage_container_id).blank? }
  end
  
  def array_of_not_stored_specimens
    Specimen.all.select{ |s| SpecimenReceipt.where(:specimen_id => s.specimen_id).blank?}    
  end
  
  def array_of_not_stored_samples
    Sample.all.select{ |s| SampleReceiptStore.where(:sample_id => s.sample_id).blank?}
  end

  def array_of_not_shipped_samples
    SampleReceiptStore.all.select{ |sr| SampleShipping.where(:sample_id => sr.sample_id).blank?}
  end

  def store
    @specimen_receipts_ids = array_of_selected_specs
    @specimen_receipts_hash = hash_of_specs_by_container_id(@specimen_receipts_ids)
    @sample_receipt_stores = array_of_sample_receive_store
    @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
  end
  
  def array_of_selected_specs()
    # SpecimenReceipt.find(:all, :conditions => { :specimen_id => arrayOfParams})
    # SpecimenReceipt.all
    SpecimenReceipt.all.select{ |s| SpecimenStorage.where(:storage_container_id => s.storage_container_id).blank?}    
  end
  
  def hash_of_specs_by_container_id(arrayOfSpecs)
    spec_hash = {}
    arrayOfSpecs.each do |s|
      spec_hash[s.storage_container_id] ||= []
      spec_hash[s.storage_container_id] << s.specimen_id
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
  
  def array_of_sample_receive_store()
    SampleReceiptStore.all.select{ |s| SampleShipping.where(:sample_id => s.sample_id).blank?}
    # SampleReceiptStore.find(:all, :conditions => { :sample_id => arrayOfSamples})
  end  
end
