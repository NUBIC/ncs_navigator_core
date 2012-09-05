# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: samples
#
#  created_at             :datetime
#  data_export_identifier :string(255)
#  id                     :integer          not null, primary key
#  instrument_id          :integer
#  response_set_id        :integer
#  sample_id              :string(36)       not null
#  sample_shipping_id     :integer
#  updated_at             :datetime
#  volume_amount          :decimal(6, 2)
#  volume_unit            :string(36)
#

class Sample < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :response_set
  has_one :sample_receipt_store
  has_one :sample_receipt_confirmation
  belongs_to :sample_shipping
  
  validates_presence_of :sample_id
end

