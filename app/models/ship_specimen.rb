# -*- coding: utf-8 -*-
class ShipSpecimen < ActiveRecord::Base
  belongs_to :specimen
  belongs_to :specimen_shipping  
end

