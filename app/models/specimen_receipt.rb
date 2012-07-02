# -*- coding: utf-8 -*-
class SpecimenReceipt < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :specimen_id
  
  belongs_to :specimen_processing_shipping_center
  belongs_to :specimen_equipment
  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :receipt_comment,       'SPECIMEN_STATUS_CL3'
  ncs_coded_attribute :monitor_status,        'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :upper_trigger,         'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :upper_trigger_level,   'TRIGGER_STATUS_CL2'
  ncs_coded_attribute :lower_trigger_cold,    'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :lower_trigger_ambient, 'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :centrifuge_comment,    'SPECIMEN_STATUS_CL4'
  
  validates_presence_of :staff_id
  validates_presence_of :specimen_processing_shipping_center_id
  validates_presence_of :storage_container_id
  validates_presence_of :receipt_datetime  
end

