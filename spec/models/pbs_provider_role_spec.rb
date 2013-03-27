# == Schema Information
#
# Table name: pbs_provider_roles
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  provider_id             :integer
#  provider_role_pbs_code  :integer          not null
#  provider_role_pbs_id    :string(36)       not null
#  provider_role_pbs_other :string(255)
#  psu_code                :integer          not null
#  transaction_type        :string(36)
#  updated_at              :datetime
#

require 'spec_helper'

describe PbsProviderRole do
  it "should create a new instance given valid attributes" do
    pbs_provider_role = Factory(:pbs_provider_role)
    pbs_provider_role.should_not be_nil
  end

  it { should belong_to(:provider) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pbs_provider_role = Factory(:pbs_provider_role)
      pbs_provider_role.public_id.should_not be_nil
      pbs_provider_role.provider_role_pbs_id.should == pbs_provider_role.public_id
      pbs_provider_role.provider_role_pbs_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      pbs_provider_role = PbsProviderRole.new
      pbs_provider_role.psu_code = 20000030
      pbs_provider_role.save!

      obj = PbsProviderRole.first
      obj.provider_role_pbs.local_code.should == -4
    end
  end
end
