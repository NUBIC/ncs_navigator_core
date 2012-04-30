# == Schema Information
# Schema version: 20120420163434
#
# Table name: environmental_equipments
#
#  id                                :integer         not null, primary key
#  psu_code                          :integer         not null
#  sample_receipt_shipping_center_id :integer
#  equipment_id                      :string(36)      not null
#  equipment_type_code               :integer         not null
#  equipment_type_other              :string(255)
#  serial_number                     :string(50)      not null
#  government_asset_tag_number       :string(36)
#  retired_date                      :string(10)
#  retired_reason_code               :integer         not null
#  retired_reason_other              :string(255)
#  transaction_type                  :string(36)
#  created_at                        :datetime
#  updated_at                        :datetime
#

require 'spec_helper'

describe EnvironmentalEquipment do
  it "should create a new instance given valid attributes" do
    environmental_equipments = Factory(:environmental_equipment)
    environmental_equipments.should_not be_nil
  end
  
  it { should belong_to(:sample_receipt_shipping_center) }
  it { should belong_to(:psu) }  
  it { should belong_to(:equipment_type) }
  it { should belong_to(:retired_reason) }
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      ee = Factory(:environmental_equipment)
      ee.public_id.should_not be_nil
      ee.equipment_id.should == ee.public_id
      ee.equipment_id.to_s.should == "4567"
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      ee = EnvironmentalEquipment.create(:equipment_id => "equipment_id", :serial_number => "123SerialNumber")
      ee.save!
 
      obj = EnvironmentalEquipment.find(ee.id)
      obj.psu.local_code.should == -4      
      obj.equipment_type.local_code.should == -4
      obj.retired_reason.local_code.should == -4
    end
  end    
end
