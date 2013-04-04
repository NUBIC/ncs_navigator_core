# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130403145616
#
# Table name: specimen_pickups
#
#  created_at                             :datetime
#  event_id                               :integer
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
#  specimen_id                            :string(36)       not null
#  specimen_pickup_comment_code           :integer          not null
#  specimen_pickup_comment_other          :string(255)
#  specimen_pickup_datetime               :datetime         not null
#  specimen_processing_shipping_center_id :integer
#  specimen_transport_temperature         :decimal(6, 2)
#  staff_id                               :string(50)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

class SpecimenPickup < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :specimen_id
  belongs_to :specimen_processing_shipping_center
  belongs_to :event

  ncs_coded_attribute :psu,                        'PSU_CL1'
  ncs_coded_attribute :specimen_pickup_comment,    'SPECIMEN_STATUS_CL5'

  validates_presence_of :psu_code
  validates_presence_of :staff_id
  validates_presence_of :specimen_pickup_datetime

end

