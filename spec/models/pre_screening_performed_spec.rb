# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130813203232
#
# Table name: pre_screening_performeds
#
#  created_at                   :datetime         not null
#  id                           :integer          not null, primary key
#  pr_age_eligible_code         :integer          not null
#  pr_county_of_residence_code  :integer          not null
#  pr_first_provider_visit_code :integer          not null
#  pr_pregnancy_eligible_code   :integer          not null
#  pre_screening_performed_id   :string(36)       not null
#  provider_id                  :integer          not null
#  psu_code                     :integer          not null
#  transaction_type             :string(36)
#  updated_at                   :datetime         not null
#

require 'spec_helper'

describe PreScreeningPerformed do
  let(:psp) { Factory(:pre_screening_performed) }

  it "should create a new instance given valid attributes" do
    psp.should_not be_nil
  end

  it { should belong_to(:provider) }

  context "as mdes record" do
    it "sets the public_id to a uuid" do
      psp.public_id.should_not be_nil
      psp.pre_screening_performed_id.should == psp.public_id
      psp.pre_screening_performed_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      p = PreScreeningPerformed.new
      p.provider = Factory(:provider)
      p.save!

      obj = PreScreeningPerformed.first
      obj.pr_pregnancy_eligible.local_code.should == -4
      obj.pr_age_eligible.local_code.should == -4
      obj.pr_first_provider_visit.local_code.should == -4
      obj.pr_county_of_residence.local_code.should == -4
    end
  end

end
