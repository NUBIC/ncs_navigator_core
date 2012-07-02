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

