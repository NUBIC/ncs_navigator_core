# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130329150304
#
# Table name: sample_shippings
#
#  carrier                           :string(255)
#  contact_name                      :string(255)
#  contact_phone                     :string(30)
#  created_at                        :datetime
#  id                                :integer          not null, primary key
#  psu_code                          :integer          not null
#  sample_receipt_shipping_center_id :integer
#  sample_shipped_by_code            :integer          not null
#  shipment_coolant_code             :integer          not null
#  shipment_date                     :string(10)       not null
#  shipment_issues_other             :string(255)
#  shipment_time                     :string(5)
#  shipment_tracking_number          :string(36)       not null
#  shipper_destination_code          :integer          not null
#  shipper_id                        :string(36)       not null
#  staff_id                          :string(36)       not null
#  staff_id_track                    :string(36)       not null
#  transaction_type                  :string(36)
#  updated_at                        :datetime
#

class SampleShipping < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :shipment_tracking_number
  
  has_many :samples
  accepts_nested_attributes_for :samples

  belongs_to :sample_receipt_shipping_center
  has_many :sample_receipt_confirmations
  
  ncs_coded_attribute :psu,                         'PSU_CL1'
  ncs_coded_attribute :shipper_destination,         'SHIPPER_DESTINATION_CL1'
  ncs_coded_attribute :shipment_coolant,            'SHIPMENT_TEMPERATURE_CL2'
  ncs_coded_attribute :sample_shipped_by,           'SAMPLES_SHIPPED_BY_CL1'

  validates_presence_of :staff_id
  validates_presence_of :staff_id_track
  validates_presence_of :shipper_id
  validates_presence_of :shipper_destination
  validates_presence_of :shipment_date 
  validates_presence_of :shipment_coolant
  validates_presence_of :shipment_tracking_number
  validates_presence_of :sample_shipped_by
end

