# == Schema Information
# Schema version: 20120420163434
#
# Table name: specimen_equipments
#
#  id                                     :integer         not null, primary key
#  psu_code                               :integer         not null
#  specimen_processing_shipping_center_id :integer
#  equipment_id                           :string(36)      not null
#  equipment_type_code                    :integer         not null
#  equipment_type_other                   :string(255)
#  serial_number                          :string(50)      not null
#  government_asset_tag_number            :string(36)
#  retired_date                           :string(10)
#  retired_reason_code                    :integer         not null
#  retired_reason_other                   :string(255)
#  transaction_type                       :string(36)
#  created_at                             :datetime
#  updated_at                             :datetime
#


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
      puts (se.inspect)
      se.public_id.should_not be_nil
      se.equipment_id.should == se.public_id
      se.equipment_id.to_s.should == "4567"
    end
  end
end
