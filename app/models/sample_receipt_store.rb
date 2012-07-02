# -*- coding: utf-8 -*-
class SampleReceiptStore < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :sample_id

  belongs_to :sample_receipt_shipping_center
  belongs_to :environmental_equipment  
  ncs_coded_attribute :psu,                       'PSU_CL1'
  ncs_coded_attribute :sample_condition,          'SPECIMEN_STATUS_CL7'
  ncs_coded_attribute :cooler_temp_condition,     'COOLER_TEMP_CL1'
  ncs_coded_attribute :storage_compartment_area,  'STORAGE_AREA_CL2'
  ncs_coded_attribute :temp_event_occurred,       'CONFIRM_TYPE_CL20'
  ncs_coded_attribute :temp_event_action,         'SPECIMEN_STATUS_CL6'
  
  validates_presence_of :staff_id
  validates_presence_of :receipt_datetime
  validates_presence_of :placed_in_storage_datetime
end

