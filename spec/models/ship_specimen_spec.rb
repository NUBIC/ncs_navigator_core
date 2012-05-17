# == Schema Information
# Schema version: 20120515181518
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

require 'spec_helper'

describe ShipSpecimen do

  it "creates a new instance given valid attributes" do
    ship_spec = Factory(:ship_specimen)
    ship_spec.should_not be_nil
  end

  it { should belong_to(:specimen) }
  it { should belong_to(:specimen_shipping) }
end
