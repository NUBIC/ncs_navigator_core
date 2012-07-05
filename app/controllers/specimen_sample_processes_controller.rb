# -*- coding: utf-8 -*-
class SpecimenSampleProcessesController < ApplicationController

  def index
    @specimens = array_of_not_stored_specimens
    @samples = array_of_not_stored_samples
  end
  
  def receive
    @specimens = params[:specimen_id]
    @samples = params[:sample_id]
    # if not @specimens.blank?
    #   @specimens = array_of_not_received_specs(@specimens)
    # end
    # if not @samples.blank?
    #   @samples = array_of_not_received_samples(@samples)
    # end
  end

  # def array_of_not_received_specs(arrayOfSpecs)
  #   return arrayOfSpecs.select{ |a| SpecimenReceipt.where( :specimen_id => a).blank?}
  # end
  # 
  # def array_of_not_received_samples(arrayOfSamples)
  #   return arrayOfSamples.select{ |a| SampleReceiptStore.where( :sample_id => a).blank?}
  # end  
  # 
  def show
    @specimens = params[:specimen_id]
    @samples = params[:sample_id]
    if @specimens.blank? and @samples.blank?
      index
      respond_to do |format|      
        format.html do
          flash[:notice] = 'Please select specimens or samples you are receiving.'    
          render :action => "index"
        end
      end
    end
  end
  
  def store
    @specimen_receipts_ids = array_of_selected_specs(params[:specimen_id])
    @specimen_receipts_hash = hash_of_specs_by_container_id(@specimen_receipts_ids)
    @sample_receipt_stores = array_of_sample_receive_store(params[:sample_id])
    @specimen_storages = array_of_empty_spec_storages(@specimen_receipts_hash.keys)
  end
  
  def array_of_not_stored_specimens
    Specimen.all.select{ |s| SpecimenReceipt.where(:specimen_id => s.specimen_id).blank?}    
  end
  
  def array_of_not_stored_samples
    Sample.all.select{ |s| SampleReceiptStore.where(:sample_id => s.sample_id).blank?}
  end
  
  def array_of_selected_specs(arrayOfParams)
    SpecimenReceipt.find(:all, :conditions => { :specimen_id => arrayOfParams})
  end
  
  def hash_of_specs_by_container_id(arrayOfSpecs)
    spec_hash = {}
    arrayOfSpecs.each do |s|
      spec_hash[s.storage_container_id] ||= []
      spec_hash[s.storage_container_id] << s.specimen_id
    end
    return spec_hash
  end
  
  def array_of_empty_spec_storages(arrayOfKeys)
    @temp = SpecimenStorage.new(:storage_container_id => "1")
    specimen_storages = []
    arrayOfKeys.each do |s|
      specimen_storages.push(SpecimenStorage.new(:storage_container_id => s))
    end
    return specimen_storages
  end
  
  def array_of_sample_receive_store(arrayOfSamples)
    SampleReceiptStore.find(:all, :conditions => { :sample_id => arrayOfSamples})
  end  
end