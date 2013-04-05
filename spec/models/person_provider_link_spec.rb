# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130326184001
#
# Table name: person_provider_links
#
#  created_at                     :datetime
#  date_first_visit               :string(255)
#  date_first_visit_date          :date
#  id                             :integer          not null, primary key
#  ineligibility_batch_identifier :string(36)
#  is_active_code                 :integer          not null
#  person_id                      :integer
#  person_provider_id             :string(36)       not null
#  pre_screening_status_code      :integer          not null
#  provider_id                    :integer
#  provider_intro_outcome_code    :integer          not null
#  provider_intro_outcome_other   :string(255)
#  psu_code                       :integer          not null
#  sampled_person_code            :integer          not null
#  transaction_type               :string(36)
#  updated_at                     :datetime
#

require 'spec_helper'

describe PersonProviderLink do
  it "should create a new instance given valid attributes" do
    ppl = Factory(:person_provider_link)
    ppl.should_not be_nil
  end

  it { should belong_to(:provider) }
  it { should belong_to(:person) }

  # it { should validate_presence_of(:person) }
  it { should validate_presence_of(:provider) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      ppl = Factory(:person_provider_link)
      ppl.public_id.should_not be_nil
      ppl.person_provider_id.should == ppl.public_id
      ppl.person_provider_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      ppl = PersonProviderLink.new
      ppl.psu_code = 20000030
      ppl.person = Factory(:person)
      ppl.provider = Factory(:provider)
      ppl.save!

      obj = PersonProviderLink.first
      obj.is_active.local_code.should == -4
      obj.provider_intro_outcome.local_code.should == -4

      obj.sampled_person.local_code.should == -4
      obj.pre_screening_status.local_code.should == -4
    end
  end

end

