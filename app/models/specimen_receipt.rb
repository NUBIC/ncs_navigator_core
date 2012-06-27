# == Schema Information
# Schema version: 20120626221317
#
# Table name: specimen_receipts
#
#  id                                     :integer         not null, primary key
#  psu_code                               :integer         not null
#  specimen_id                            :string(36)      not null
#  specimen_processing_shipping_center_id :integer
#  staff_id                               :string(36)      not null
#  receipt_comment_code                   :integer         not null
#  receipt_comment_other                  :string(255)
#  receipt_datetime                       :datetime        not null
#  cooler_temp                            :decimal(6, 2)
#  monitor_status_code                    :integer
#  upper_trigger_code                     :integer
#  upper_trigger_level_code               :integer
#  lower_trigger_cold_code                :integer
#  lower_trigger_ambient_code             :integer
#  storage_container_id                   :string(36)      not null
#  centrifuge_comment_code                :integer
#  centrifuge_comment_other               :string(255)
#  centrifuge_starttime                   :string(5)
#  centrifuge_endtime                     :string(5)
#  centrifuge_staff_id                    :string(36)
#  specimen_equipment_id                  :integer
#  transaction_type                       :string(36)
#  created_at                             :datetime
#  updated_at                             :datetime
#

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
