# -*- coding: utf-8 -*-
class SampleShippingConfirmationsController < ApplicationController
  def index
    @sample_shippings_not_received = hash_from_array(array_of_shipped_and_not_received_samples)
    @sample_shippings_confirmed = hash_from_array(array_of_shipped_and_confirmed_samples)
    
    # exclude the ones that are not fully processed and add to confirmed hash
    @sample_shippings_not_received.each do |k, v|
      if @sample_shippings_confirmed.has_key? k
        v << @sample_shippings_confirmed.values_at(k)
        @sample_shippings_confirmed.delete(k)
      end
    end
  end
  
  def array_of_shipped_and_not_received_samples
    SampleShipping.all.select{ |ss| SampleReceiptConfirmation.where(:sample_id => ss.sample_id).blank? }
  end  
  
  def array_of_shipped_and_confirmed_samples()
    SampleShipping.all.select{ |ss| SampleReceiptConfirmation.where(:sample_id => ss.sample_id).any?}
  end
  
  def hash_from_array(array_of_samples)
    spec_hash = {}
    array_of_samples.each do |s|
      spec_hash[s.shipment_tracking_number] ||= []
      spec_hash[s.shipment_tracking_number] << s
    end
    return spec_hash
  end  
end