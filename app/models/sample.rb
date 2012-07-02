# -*- coding: utf-8 -*-
class Sample < ActiveRecord::Base
  belongs_to :instrument
  
  validates_presence_of :sample_id
  validates_presence_of :instrument_id
  
end

