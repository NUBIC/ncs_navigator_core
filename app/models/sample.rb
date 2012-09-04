# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: samples
#
#  created_at    :datetime
#  id            :integer          not null, primary key
#  instrument_id :integer
#  sample_id     :string(36)       not null
#  updated_at    :datetime
#

class Sample < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :response_set
  has_one :sample_receipt_store
  has_one :sample_receipt_confirmation
  belongs_to :sample_shipping
  
  validates_presence_of :sample_id
end

