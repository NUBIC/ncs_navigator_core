# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimens
#
#  created_at             :datetime
#  data_export_identifier :string(255)
#  id                     :integer          not null, primary key
#  instrument_id          :integer
#  response_set_id        :integer
#  specimen_id            :string(36)       not null
#  specimen_pickup_id     :integer
#  updated_at             :datetime
#

class Specimen < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :specimen_pickup
  belongs_to :response_set
  has_one :specimen_receipt
  has_one :ship_specimen
  validates_presence_of :instrument_id
  has_one :specimen_receipt_confirmation
end

