# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: non_interview_provider_refusals
#
#  created_at                :datetime
#  id                        :integer          not null, primary key
#  nir_provider_refusal_id   :string(36)       not null
#  non_interview_provider_id :integer
#  psu_code                  :integer          not null
#  refusal_reason_pbs_code   :integer          not null
#  refusal_reason_pbs_other  :string(255)
#  transaction_type          :string(255)
#  updated_at                :datetime
#

require 'spec_helper'

describe NonInterviewProviderRefusal do
  it "should create a new instance given valid attributes" do
    nipr = Factory(:non_interview_provider_refusal)
    nipr.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:non_interview_provider) }
  it { should belong_to(:refusal_reason_pbs) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      nipr = Factory(:non_interview_provider_refusal)
      nipr.public_id.should_not be_nil
      nipr.nir_provider_refusal_id.should == nipr.public_id
      nipr.nir_provider_refusal_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      nipr = NonInterviewProviderRefusal.new(:psu_code => 20000030)
      nipr.save!

      obj = NonInterviewProviderRefusal.first
      obj.refusal_reason_pbs.local_code.should == -4

    end
  end

end
