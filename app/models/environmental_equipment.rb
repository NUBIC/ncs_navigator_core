# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: environmental_equipments
#
#  created_at                        :datetime
#  equipment_id                      :string(36)       not null
#  equipment_type_code               :integer          not null
#  equipment_type_other              :string(255)
#  government_asset_tag_number       :string(36)
#  id                                :integer          not null, primary key
#  psu_code                          :integer          not null
#  retired_date                      :string(10)
#  retired_reason_code               :integer          not null
#  retired_reason_other              :string(255)
#  sample_receipt_shipping_center_id :integer
#  serial_number                     :string(50)       not null
#  transaction_type                  :string(36)
#  updated_at                        :datetime
#

class EnvironmentalEquipment < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :equipment_id

  belongs_to :sample_receipt_shipping_center
  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :equipment_type,        'EQUIPMENT_TYPE_CL2'
  ncs_coded_attribute :retired_reason,        'EQUIPMENT_ISSUES_CL1'

  validates_presence_of :psu
  validates_presence_of :equipment_id
  validates_presence_of :equipment_type
  validates_presence_of :serial_number
  validates_presence_of :retired_reason
end

