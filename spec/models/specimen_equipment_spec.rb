
require 'spec_helper'

describe SpecimenEquipment do
  it "should create a new instance given valid attributes" do
    specimen_equipment = Factory(:specimen_equipment)
    specimen_equipment.should_not be_nil
  end

  it { should belong_to(:specimen_processing_shipping_center) }
  it { should belong_to(:psu) }
  it { should belong_to(:equipment_type) }
  it { should belong_to(:retired_reason) }

  context "as mdes record" do
    it "sets the public_id to a uuid" do
      se = Factory(:specimen_equipment)
      se.public_id.should_not be_nil
      se.equipment_id.should == se.public_id
      se.equipment_id.to_s.should == "4567"
    end
  end
end

