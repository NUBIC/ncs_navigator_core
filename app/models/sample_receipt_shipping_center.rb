# -*- coding: utf-8 -*-
class SampleReceiptShippingCenter < ActiveRecord::Base
  belongs_to :address
  accepts_nested_attributes_for :address, :allow_destroy => true
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  
  validates_presence_of :psu_code
  validates_presence_of :sample_receipt_shipping_center_id
end

