# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimen_shippings
#
#  carrier                                :string(255)
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
#  shipment_time                          :string(5)
#  shipment_tracking_number               :string(36)       not null
#  shipper_destination                    :string(3)        not null
#  shipper_id                             :string(36)       not null
#  specimen_processing_shipping_center_id :integer
#  staff_id                               :string(36)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

class SpecimenShipping < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :shipment_tracking_number

  belongs_to :specimen_processing_shipping_center
  has_many :specimen_storage_containers
  has_many :ship_specimens
  
  has_many :specimen_receipt_confirmations
  
  accepts_nested_attributes_for :ship_specimens, :allow_destroy => true
  
  # has_many :specimen_receipts, :primary_key => :storage_container_id, :foreign_key => :storage_container_id

  ncs_coded_attribute :psu,                        'PSU_CL1'
  ncs_coded_attribute :shipment_temperature,       'SHIPMENT_TEMPERATURE_CL1'
  ncs_coded_attribute :shipment_receipt_confirmed, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :shipment_issues,            'SHIPMENT_ISSUES_CL1'

  # validates_presence_of :storage_container_id
  validates_presence_of :staff_id 
  validates_presence_of :shipper_id
  validates_presence_of :shipper_destination
  validates_presence_of :shipment_date 
  validates_presence_of :shipment_tracking_number
  validates_presence_of :shipment_temperature
  
  def self.find_by_tracking_number(criteria)
    SpecimenShipping.where(:shipment_tracking_number => criteria)
  end
  
  def self.find_id_by_tracking_number_or_specimen_or_storage_container(criteria)
    specimen_shipping_ids = ActiveRecord::Base.connection.select_all("SELECT DISTINCT specimen_shipping_id FROM specimen_shippings ss INNER JOIN specimen_storage_containers ssc on ssc.specimen_shipping_id = ss.id INNER JOIN specimen_receipts r ON ssc.id = r.specimen_storage_container_id INNER JOIN specimens s ON r.specimen_id = s.id WHERE s.specimen_id = '#{criteria}' OR ss.shipment_tracking_number = '#{criteria}' OR ssc.storage_container_id = '#{criteria}'").map{|ss| ss["specimen_shipping_id"]}
    # SpecimenShipping.where(:id => specimen_shipping_ids)
  end
end

