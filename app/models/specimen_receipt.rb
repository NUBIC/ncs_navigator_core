# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimen_receipts
#
#  centrifuge_comment_code                :integer
#  centrifuge_comment_other               :string(255)
#  centrifuge_endtime                     :string(5)
#  centrifuge_staff_id                    :string(36)
#  centrifuge_starttime                   :string(5)
#  centrifuge_temp                        :decimal(6, 2)
#  cooler_temp                            :decimal(6, 2)
#  created_at                             :datetime
#  id                                     :integer          not null, primary key
#  lower_trigger_ambient_code             :integer
#  lower_trigger_cold_code                :integer
#  monitor_status_code                    :integer
#  psu_code                               :integer          not null
#  receipt_comment_code                   :integer          not null
#  receipt_comment_other                  :string(255)
#  receipt_datetime                       :datetime         not null
#  specimen_equipment_id                  :integer
#  specimen_id                            :integer          not null
#  specimen_processing_shipping_center_id :integer
#  specimen_storage_container_id          :integer          not null
#  staff_id                               :string(36)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#  upper_trigger_code                     :integer
#  upper_trigger_level_code               :integer
#

class SpecimenReceipt < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :specimen_id

  belongs_to :specimen_processing_shipping_center
  belongs_to :specimen_equipment
  belongs_to :specimen

  belongs_to :specimen_storage_container

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :receipt_comment,
    :list_name => { 'SPECIMEN_STATUS_CL3' => '<= 3.0', 'SPECIMEN_STATUS_CL10' => '>= 3.1' }
  ncs_coded_attribute :monitor_status,        'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :upper_trigger,         'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :upper_trigger_level,   'TRIGGER_STATUS_CL2'
  ncs_coded_attribute :lower_trigger_cold,    'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :lower_trigger_ambient, 'TRIGGER_STATUS_CL1'
  ncs_coded_attribute :centrifuge_comment,    'SPECIMEN_STATUS_CL4'

  validates_presence_of :staff_id
  validates_presence_of :specimen_processing_shipping_center_id
  # validates_presence_of :specimen_storage_container_id
  validates_presence_of :receipt_datetime
end

