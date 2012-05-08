# == Schema Information
# Schema version: 20120507183332
#
# Table name: specimens
#
#  id                 :integer         not null, primary key
#  specimen_id        :string(36)      not null
#  specimen_pickup_id :integer
#  instrument_id      :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Specimen < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :specimen_pickup
  
  has_one :ship_specimen
  validates_presence_of :instrument_id
end
