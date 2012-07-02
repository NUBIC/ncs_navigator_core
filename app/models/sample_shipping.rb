# -*- coding: utf-8 -*-
class SampleShipping < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :sample_id

  belongs_to :sample_receipt_shipping_center
  ncs_coded_attribute :psu,                         'PSU_CL1'
  ncs_coded_attribute :shipper_destination,         'SHIPPER_DESTINATION_CL1'
  ncs_coded_attribute :shipment_coolant,            'SHIPMENT_TEMPERATURE_CL2'
  ncs_coded_attribute :sample_shipped_by,           'SAMPLES_SHIPPED_BY_CL1'

  validates_presence_of :staff_id 
  validates_presence_of :shipper_id
  validates_presence_of :shipper_destination
  validates_presence_of :shipment_date 
  validates_presence_of :shipment_coolant
  validates_presence_of :shipment_tracking_number
  validates_presence_of :sample_shipped_by
end

