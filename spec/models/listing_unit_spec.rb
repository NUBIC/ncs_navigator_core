# == Schema Information
# Schema version: 20110726214159
#
# Table name: listing_units
#
#  id               :integer         not null, primary key
#  psu_code         :integer         not null
#  list_id          :binary          not null
#  list_line        :integer
#  list_source_code :integer         not null
#  list_comment     :text
#  transaction_type :string(36)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe ListingUnit do
  it "should create a new instance given valid attributes" do
    lu = Factory(:listing_unit)
    lu.should_not be_nil
  end
  
  it "should create a uuid" do
    lu = Factory(:listing_unit)
    lu.list_id.should_not be_nil
    lu.list_id.length.should == 36
    lu.list_id.should == lu.public_id
    lu.public_id.should == lu.uuid
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:list_source) }
  it { should have_one(:dwelling_unit) }

  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      lu = Factory(:listing_unit)
      lu.public_id.should_not be_nil
      lu.list_id.should == lu.public_id
      lu.list_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(ListingUnit)
      
      lu = ListingUnit.new
      lu.psu = Factory(:ncs_code)
      lu.save!
    
      ListingUnit.first.list_source.local_code.should == -4
    end
  end

end
