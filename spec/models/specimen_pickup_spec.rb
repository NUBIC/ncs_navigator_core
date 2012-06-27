# == Schema Information
# Schema version: 20120626221317
#
# Table name: specimen_pickups
#
#  id                                     :integer         not null, primary key
#  psu_code                               :integer         not null
#  specimen_processing_shipping_center_id :integer
#  event_id                               :integer
#  staff_id                               :string(50)      not null
#  specimen_pickup_datetime               :datetime        not null
#  specimen_pickup_comment_code           :integer         not null
#  specimen_pickup_comment_other          :string(255)
#  specimen_transport_temperature         :decimal(6, 2)
#  transaction_type                       :string(36)
#  created_at                             :datetime
#  updated_at                             :datetime
#

require 'spec_helper'

describe SpecimenPickup do
  it "should create a new instance given valid attributes" do
    specimen_pickup = Factory(:specimen_pickup)
    specimen_pickup.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:event) }
  it { should belong_to(:specimen_processing_shipping_center) } 
end
