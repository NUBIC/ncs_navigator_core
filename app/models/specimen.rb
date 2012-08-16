# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: specimens
#
#  created_at         :datetime
#  id                 :integer          not null, primary key
#  instrument_id      :integer
#  specimen_id        :string(36)       not null
#  specimen_pickup_id :integer
#  updated_at         :datetime
#

class Specimen < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :specimen_pickup
  belongs_to :response_set
  has_one :specimen_receipt
  has_one :ship_specimen
  validates_presence_of :instrument_id
end

