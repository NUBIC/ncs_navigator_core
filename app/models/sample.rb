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
  
  validates_presence_of :sample_id
  validates_presence_of :instrument_id
  
end

