# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: sample_receipt_shipping_centers
#
#  address_id                        :integer
#  created_at                        :datetime
#  id                                :integer          not null, primary key
#  psu_code                          :integer          not null
#  sample_receipt_shipping_center_id :string(36)       not null
#  transaction_type                  :string(36)
#  updated_at                        :datetime
#

class SampleReceiptShippingCenter < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  belongs_to :address
  accepts_nested_attributes_for :address, :allow_destroy => true

  ncs_coded_attribute :psu,                        'PSU_CL1'
  
  validates_presence_of :psu_code
  validates_presence_of :sample_receipt_shipping_center_id
end

