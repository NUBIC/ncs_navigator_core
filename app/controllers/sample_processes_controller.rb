# -*- coding: utf-8 -*-
class SampleProcessesController < ApplicationController

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
    # @specimen_receipts_hash_not_shipped = hash_from_array(@specimen_receipts_not_shipped)

    @sample_shippings_not_received = hash_from_array_by_track_num(array_of_shipped_and_not_received_samples)
    @specimen_shippings_not_received = array_of_shipped_and_not_received_specimens
  end

  def array_of_not_shipped_spec_storages
    SpecimenStorage.joins(:specimen_storage_container).where("specimen_storage_containers.specimen_shipping_id is NULL")
  end

  def array_of_not_stored_specimens
    Specimen.all.select{ |s| SpecimenReceipt.where(:specimen_id => s.id).blank?}
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
    SpecimenReceipt.all.select{ |s| SpecimenStorage.where(:specimen_storage_container_id => s.specimen_storage_container_id).blank?}
  end

  def hash_of_specs_by_container_id(arrayOfSpecs)
    spec_hash = {}
    arrayOfSpecs.each do |s|
      spec_hash[s.specimen_storage_container_id] ||= []
      spec_hash[s.specimen_storage_container_id] << s.specimen_id
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
      specimen_storages.push(SpecimenStorage.new(:specimen_storage_container_id => s))
    end
    return specimen_storages
  end

  def array_of_sample_receive_store()
    SampleReceiptStore.all.select{ |s| SampleShipping.where(:sample_id => s.sample_id).blank?}
  end

  def array_of_shipped_and_not_received_samples
    SampleShipping.all.select{ |ss| SampleReceiptConfirmation.where(:sample_id => ss.sample_id).blank? }
  end

  def array_of_shipped_and_not_received_specimens
    SpecimenShipping.all.select{ |ss| SpecimenReceiptConfirmation.where(:shipment_tracking_number_id => ss.id).blank?}
    # SpecimenShipping.all.select{ |ss| SpecimenReceipt.where(:specimen_storage_container_id => ss.specimen_storage_container_id).all.reject{ |sr| SpecimenReceiptConfirmation.where(:specimen_id => sr.specimen_id).any?}.any? }
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
