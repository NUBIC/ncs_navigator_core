# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: ship_specimens
#
#  created_at           :datetime
#  id                   :integer          not null, primary key
#  specimen_id          :integer
#  specimen_shipping_id :integer
#  updated_at           :datetime
#  volume_amount        :decimal(6, 2)
#  volume_unit          :string(36)
#

class ShipSpecimen < ActiveRecord::Base
  belongs_to :specimen
  belongs_to :specimen_shipping  
end

