# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimen_receipt_confirmations
#
#  created_at                             :datetime
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
#  shipment_condition_code                :integer          not null
#  shipment_damaged_reason                :string(255)
#  shipment_receipt_confirmed_code        :integer          not null
#  shipment_receipt_datetime              :datetime         not null
#  shipment_received_by                   :string(255)      not null
#  shipper_id                             :string(255)      not null
#  specimen_condition                     :string(255)
#  specimen_id                            :integer          not null
#  specimen_processing_shipping_center_id :integer
#  specimen_receipt_temp                  :decimal(6, 2)    not null
#  specimen_shipping_id                   :integer          not null
#  staff_id                               :string(255)      not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

class SpecimenReceiptConfirmation < ActiveRecord::Base
  belongs_to :specimen_processing_shipping_center
  belongs_to :specimen
  
  belongs_to :specimen_shipping

  # ncs_coded_attribute :specimen_condition,                'SPECIMEN_STATUS_CL7'

  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :shipment_receipt_confirmed, :conditions => "list_name = 'CONFIRM_TYPE_CL21'", :foreign_key => "shipment_receipt_confirmed_code", :class_name => 'NcsCode', :primary_key => :local_code  
  belongs_to :shipment_condition, :conditions => "list_name = 'SHIPMENT_CONDITION_CL1'", :foreign_key => "shipment_condition_code", :class_name => 'NcsCode', :primary_key => :local_code  
  
  validates_presence_of :shipper_id
  # validates_presence_of :shipment_tracking_number
  validates_presence_of :shipment_receipt_datetime
  validates_presence_of :specimen_id
  validates_presence_of :shipment_received_by
  validates_presence_of :specimen_receipt_temp
  validates_presence_of :shipment_receipt_confirmed
  validates_presence_of :shipment_condition
end

