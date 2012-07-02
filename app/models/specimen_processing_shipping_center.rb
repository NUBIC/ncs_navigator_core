# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: specimen_processing_shipping_centers
#
#  address_id                             :integer
#  created_at                             :datetime
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
#  specimen_processing_shipping_center_id :string(36)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

class SpecimenProcessingShippingCenter < ActiveRecord::Base
  belongs_to :address
  accepts_nested_attributes_for :address, :allow_destroy => true
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  
  validates_presence_of :psu_code
  validates_presence_of :specimen_processing_shipping_center_id
end

