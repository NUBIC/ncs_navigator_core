# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: non_interview_providers
#
#  contact_id                   :integer
#  created_at                   :datetime
#  id                           :integer          not null, primary key
#  nir_closed_info_code         :integer          not null
#  nir_closed_info_other        :string(255)
#  nir_moved_info_code          :integer          not null
#  nir_moved_info_other         :string(255)
#  nir_pbs_comment              :text
#  nir_type_provider_code       :integer          not null
#  nir_type_provider_other      :string(255)
#  non_interview_provider_id    :string(36)       not null
#  perm_closure_code            :integer          not null
#  perm_moved_code              :integer          not null
#  provider_id                  :integer
#  psu_code                     :integer          not null
#  ref_action_provider_code     :integer          not null
#  refuser_strength_code        :integer          not null
#  transaction_type             :string(255)
#  updated_at                   :datetime
#  when_closure                 :date
#  when_moved                   :date
#  who_confirm_noprenatal_code  :integer          not null
#  who_confirm_noprenatal_other :string(255)
#  who_refused_code             :integer          not null
#  who_refused_other            :string(255)
#

require 'spec_helper'

describe NonInterviewProvider do
  it "should create a new instance given valid attributes" do
    nir = Factory(:non_interview_provider)
    nir.should_not be_nil
  end

  it { should belong_to(:contact) }
  it { should belong_to(:provider) }


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
