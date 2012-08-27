# -*- coding: utf-8 -*-
class SampleProcessesController < ApplicationController
  after_filter :clear_flash
  
  def clear_flash
    flash.discard
  end
  
  def index
    #RECEIVE
    @specimens = array_of_not_stored_specimens
    @samples = array_of_not_stored_samples
    #STORE
    @specimen_receipts_ids = array_of_selected_specs
    @specimen_receipts_hash = hash_of_spec_storages_by_container_id(@specimen_receipts_ids)
    
    @sample_receipt_stores = array_of_sample_receive_store
    
    @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
    @sample_receipt_stores_not_shipped = array_of_not_shipped_samples
    #SHIP
    @not_shipped_spec_storages = array_of_not_shipped_spec_storages
    @sample_shippings_not_received = hash_from_array_by_track_num(array_of_shipped_and_not_received_samples)
    @specimen_shippings_not_received = array_of_shipped_and_not_received_specimens
  end

  def array_of_not_stored_specimens
    Specimen.all.select{ |s| SpecimenReceipt.where(:specimen_id => s.id).blank?}
  end

  def array_of_not_stored_samples
    Sample.all.select{ |s| SampleReceiptStore.where(:sample_id => s.sample_id).blank?}
  end
  
  def array_of_selected_specs()
    SpecimenReceipt.all.select{ |s| SpecimenStorage.where(:specimen_storage_container_id => s.specimen_storage_container_id).blank?}
  end  
  
  def array_of_sample_receive_store()
    SampleReceiptStore.all.select{ |s| SampleShipping.where(:sample_id => s.sample_id).blank?}
  end
  
  def array_of_empty_spec_storages(arrayOfKeys)
    specimen_storages = []
    arrayOfKeys.each do |s|
      specimen_storages.push(SpecimenStorage.new(:specimen_storage_container_id => s))
    end
    return specimen_storages
  end  
  
  def array_of_not_shipped_samples
    SampleReceiptStore.all.select{ |sr| SampleShipping.where(:sample_id => sr.sample_id).blank?}
  end  
  
  def array_of_not_shipped_spec_storages
    SpecimenStorage.joins(:specimen_storage_container).where("specimen_storage_containers.specimen_shipping_id is NULL")
  end
  
  def array_of_shipped_and_not_received_samples
    SampleShipping.all.select{ |ss| SampleReceiptConfirmation.where(:sample_id => ss.sample_id).blank? }
  end
  
  # Array of specimen_shippings where some or all of the specimens are not confirmed.
  def array_of_shipped_and_not_received_specimens
    specimens_not_confirmed = Specimen.joins(:specimen_receipt => [ {:specimen_storage_container => :specimen_shipping}]).all.reject{ |sr| SpecimenReceiptConfirmation.where(:specimen_id => sr.id).any?}
    spec_shippings = []
    if not specimens_not_confirmed.blank?
      array_of_spec_shipping_ids = ActiveRecord::Base.connection.select_all("SELECT DISTINCT specimen_shipping_id FROM specimen_storage_containers ssc INNER JOIN specimen_receipts r ON ssc.id = r.specimen_storage_container_id INNER JOIN specimens s ON r.specimen_id = s.id WHERE s.id IN (#{specimens_not_confirmed.collect(&:to_param).map{|a| "'#{a}'"}.join(',')})")
      specimen_shipping_ids = array_of_spec_shipping_ids.map{|z| z["specimen_shipping_id"]}
      spec_shippings = SpecimenShipping.where(:id => specimen_shipping_ids)
    end
    return spec_shippings
  end  
  
  def hash_from_array_by_track_num(array_of_samples)
    spec_hash = {}
    array_of_samples.each do |s|
      spec_hash[s.shipment_tracking_number] ||= []
      spec_hash[s.shipment_tracking_number] << s
    end
    return spec_hash
  end 
  
  def hash_of_spec_storages_by_container_id(arrayOfSpecStorages)
    spec_hash = {}
    arrayOfSpecStorages.each do |s|
      storage_container_id = SpecimenStorageContainer.where(:id => s.specimen_storage_container_id).first
      specimen = Specimen.where(:id => s.specimen_id).first
      spec_hash[storage_container_id] ||= []
      spec_hash[storage_container_id] << specimen
    end
    return spec_hash
  end   
end
