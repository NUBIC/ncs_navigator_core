# == Schema Information
# Schema version: 20120626221317
#
# Table name: sample_receipt_confirmations
#
#  id                                :integer         not null, primary key
#  psu_code                          :integer         not null
#  sample_receipt_shipping_center_id :integer
#  shipment_receipt_confirmed_code   :integer         not null
#  shipper_id                        :string(255)     not null
#  shipment_tracking_number          :string(255)     not null
#  shipment_receipt_datetime         :datetime        not null
#  shipment_condition_code           :integer         not null
#  shipment_damaged_reason           :string(255)
#  sample_id                         :string(255)     not null
#  sample_receipt_temp               :decimal(6, 2)   not null
#  sample_condition_code             :integer         not null
#  shipment_received_by              :string(255)     not null
#  transaction_type                  :string(36)
#  created_at                        :datetime
#  updated_at                        :datetime
#

class SampleReceiptConfirmation < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :sample_id

  belongs_to :sample_receipt_shipping_center

  ncs_coded_attribute :psu,                             'PSU_CL1'
  ncs_coded_attribute :shipment_receipt_confirmed,      'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :shipment_condition,              'SHIPMENT_CONDITION_CL1'
  ncs_coded_attribute :sample_condition,                'SPECIMEN_STATUS_CL7'

  validates_presence_of :shipper_id
  validates_presence_of :shipment_tracking_number
  validates_presence_of :shipment_receipt_datetime
  validates_presence_of :sample_id
  validates_presence_of :shipment_received_by
  validates_presence_of :sample_receipt_temp
end
