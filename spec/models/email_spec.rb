require 'spec_helper'

describe Email do
  it "should create a new instance given valid attributes" do
    email = Factory(:email)
    email.should_not be_nil
  end
  
  it { should belong_to(:person) }
  it { should belong_to(:psu) }
  it { should belong_to(:email_info_source) }
  it { should belong_to(:email_type) }
  it { should belong_to(:email_rank) }
  it { should belong_to(:email_share) }
  it { should belong_to(:email_active) }    
    
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      email = Factory(:email)
      email.public_id.should_not be_nil
      email.email_id.should == email.public_id
      email.email_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Email)
      
      email = Email.new
      email.psu = Factory(:ncs_code)
      email.person = Factory(:person)
      email.save!
    
      obj = Email.first
      obj.email_info_source.local_code.should == -4
      obj.email_type.local_code.should == -4
      obj.email_rank.local_code.should == -4
      obj.email_share.local_code.should == -4
      obj.email_active.local_code.should == -4
    end
  end
end
