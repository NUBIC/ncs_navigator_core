class Specimen < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :specimen_pickup
  
  has_one :ship_specimen
  validates_presence_of :instrument_id
end

