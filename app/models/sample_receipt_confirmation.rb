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

