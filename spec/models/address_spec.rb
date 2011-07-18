require 'spec_helper'

describe Address do
  it "should create a new instance given valid attributes" do
    addr = Factory(:address)
    addr.should_not be_nil
  end
  
  it { should belong_to(:person) }
  it { should belong_to(:dwelling_unit) }
  it { should belong_to(:psu) }
  it { should belong_to(:address_rank) }
  it { should belong_to(:address_info_source) }
  it { should belong_to(:address_info_mode) }
  it { should belong_to(:address_type) }
  it { should belong_to(:address_description) }
  it { should belong_to(:state) }
    
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      addr = Factory(:address)
      addr.public_id.should_not be_nil
      addr.address_id.should == addr.public_id
      addr.address_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Address)
      
      addr = Address.new
      addr.psu = Factory(:ncs_code)
      addr.person = Factory(:person)
      addr.dwelling_unit = Factory(:dwelling_unit)
      addr.save!
    
      obj = Address.first
      obj.address_rank.local_code.should == -4
      obj.address_info_source.local_code.should == -4
      obj.address_info_mode.local_code.should == -4
      obj.address_type.local_code.should == -4
      obj.address_description.local_code.should == -4
      obj.state.local_code.should == -4
    end
  end
end
