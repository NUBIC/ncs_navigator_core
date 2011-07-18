require 'spec_helper'

describe Telephone do
  it "should create a new instance given valid attributes" do
    phone = Factory(:telephone)
    phone.should_not be_nil
  end
  
  it { should belong_to(:person) }
  it { should belong_to(:psu) }
  it { should belong_to(:phone_info_source) }
  it { should belong_to(:phone_type) }
  it { should belong_to(:phone_rank) }
  it { should belong_to(:phone_share) }
  it { should belong_to(:phone_landline) }
  it { should belong_to(:cell_permission) }
  it { should belong_to(:text_permission) }
    
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      phone = Factory(:telephone)
      phone.public_id.should_not be_nil
      phone.phone_id.should == phone.public_id
      phone.phone_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Telephone)
      
      phone = Telephone.new
      phone.psu = Factory(:ncs_code)
      phone.person = Factory(:person)
      phone.save!
    
      obj = Telephone.first
      obj.phone_info_source.local_code.should == -4
      obj.phone_type.local_code.should == -4
      obj.phone_rank.local_code.should == -4
      obj.phone_landline.local_code.should == -4
      obj.cell_permission.local_code.should == -4
      obj.text_permission.local_code.should == -4
    end
  end
end
