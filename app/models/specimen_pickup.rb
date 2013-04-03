# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: specimen_pickups
#
#  created_at                             :datetime
#  event_id                               :integer
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
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

  belongs_to :specimen_processing_shipping_center
  belongs_to :event
  belongs_to :specimen_pickup_comment

  has_many :specimens
  accepts_nested_attributes_for :specimens, :allow_destroy => true

  ncs_coded_attribute :psu,                        'PSU_CL1'

  validates_presence_of :psu_code
  validates_presence_of :staff_id
  validates_presence_of :specimen_pickup_datetime

  validate :specimen_exists
  
  def specimen_exists
    self.specimens.count > 0
  end
end

