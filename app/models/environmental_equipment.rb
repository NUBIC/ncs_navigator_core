class EnvironmentalEquipment < ActiveRecord::Base
  include MdesRecord
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

