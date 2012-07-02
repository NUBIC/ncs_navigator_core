# -*- coding: utf-8 -*-
require 'spec_helper'

describe NonInterviewProvider do
  it "should create a new instance given valid attributes" do
    nir = Factory(:non_interview_provider)
    nir.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:contact) }
  it { should belong_to(:provider) }

  it { should belong_to(:nir_type_provider) }
  it { should belong_to(:nir_closed_info) }
  it { should belong_to(:who_refused) }
  it { should belong_to(:perm_closure) }
  it { should belong_to(:refuser_strength) }
  it { should belong_to(:ref_action_provider) }
  it { should belong_to(:who_confirm_noprenatal) }
  it { should belong_to(:nir_moved_info) }
  it { should belong_to(:perm_moved) }

  it { should have_many(:non_interview_provider_refusals) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      nir = Factory(:non_interview_provider)
      nir.public_id.should_not be_nil
      nir.non_interview_provider_id.should == nir.public_id
      nir.non_interview_provider_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      nir = NonInterviewProvider.new(:psu_code => '20000030')
      nir.save!

      obj = NonInterviewProvider.first
      obj.nir_type_provider.local_code.should == -4
      obj.nir_closed_info.local_code.should == -4
      obj.who_refused.local_code.should == -4
      obj.perm_closure.local_code.should == -4
      obj.refuser_strength.local_code.should == -4
      obj.ref_action_provider.local_code.should == -4
      obj.who_confirm_noprenatal.local_code.should == -4
      obj.nir_moved_info.local_code.should == -4
      obj.perm_moved.local_code.should == -4

    end
  end

end
