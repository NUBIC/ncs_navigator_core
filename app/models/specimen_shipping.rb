# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: specimen_shippings
#
#  contact_name                           :string(255)
#  contact_phone                          :string(30)
#  created_at                             :datetime
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
#  shipment_date                          :string(10)       not null
#  shipment_issues_code                   :integer          not null
#  shipment_issues_other                  :string(255)
#  shipment_receipt_confirmed_code        :integer          not null
#  shipment_receipt_datetime              :datetime
#  shipment_temperature_code              :integer          not null
#  shipment_tracking_number               :string(36)       not null
#  shipper_destination                    :string(3)        not null
#  shipper_id                             :string(36)       not null
#  specimen_processing_shipping_center_id :integer
#  staff_id                               :string(36)       not null
#  storage_container_id                   :string(36)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

class SpecimenShipping < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
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

