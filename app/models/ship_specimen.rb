# == Schema Information
# Schema version: 20120507183332
#
# Table name: ship_specimens
#
#  id                   :integer         not null, primary key
#  specimen_id          :integer
#  specimen_shipping_id :integer
#  volume_amount        :decimal(6, 2)
#  volume_unit          :string(36)
#  created_at           :datetime
#  updated_at           :datetime
#

class ShipSpecimen < ActiveRecord::Base
  belongs_to :specimen
  belongs_to :specimen_shipping  
end
