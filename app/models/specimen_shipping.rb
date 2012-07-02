# -*- coding: utf-8 -*-
class SpecimenShipping < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :storage_container_id 

  belongs_to :specimen_processing_shipping_center
  ncs_coded_attribute :psu,                        'PSU_CL1'
  ncs_coded_attribute :shipment_temperature,       'SHIPMENT_TEMPERATURE_CL1'
  ncs_coded_attribute :shipment_receipt_confirmed, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :shipment_issues,            'SHIPMENT_ISSUES_CL1'

  has_many :ship_specimens

  validates_presence_of :storage_container_id
  validates_presence_of :staff_id 
  validates_presence_of :shipper_id
  validates_presence_of :shipper_destination
  validates_presence_of :shipment_date 
  validates_presence_of :shipment_tracking_number
  validates_presence_of :shipment_temperature
end

