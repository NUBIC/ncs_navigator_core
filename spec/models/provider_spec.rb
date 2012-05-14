require 'spec_helper'

describe Provider do
  it "should create a new instance given valid attributes" do
    provider = Factory(:provider)
    provider.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:provider_type) }
  it { should belong_to(:provider_ncs_role) }
  it { should belong_to(:practice_info) }
  it { should belong_to(:practice_patient_load) }
  it { should belong_to(:practice_size) }
  it { should belong_to(:public_practice) }
  it { should belong_to(:provider_info_source) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      provider = Factory(:provider)
      provider.public_id.should_not be_nil
      provider.provider_id.should == provider.public_id
      provider.provider_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      provider = Provider.new
      provider.psu_code = 20000030
      provider.save!

      obj = Provider.first
      obj.provider_type.local_code.should == -4
      obj.provider_ncs_role.local_code.should == -4
      obj.practice_info.local_code.should == -4
      obj.practice_patient_load.local_code.should == -4
      obj.practice_size.local_code.should == -4
      obj.public_practice.local_code.should == -4
      obj.provider_info_source.local_code.should == -4
    end
  end

end
