# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimen_storage_containers
#
#  created_at           :datetime
#  id                   :integer          not null, primary key
#  specimen_shipping_id :integer
#  storage_container_id :string(36)       not null
#  updated_at           :datetime
#

class SpecimenStorageContainer < ActiveRecord::Base
  has_many :specimen_receipts
  accepts_nested_attributes_for :specimen_receipts, :allow_destroy => true
  
  has_one :specimen_storage
  belongs_to :specimen_shipping
  
  validates_presence_of :storage_container_id
end
