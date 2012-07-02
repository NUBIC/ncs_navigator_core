# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: personnel_provider_links
#
#  created_at      :datetime
#  id              :integer          not null, primary key
#  person_id       :integer
#  primary_contact :boolean
#  provider_id     :integer
#  updated_at      :datetime
#

require 'spec_helper'

describe PersonnelProviderLink do
  it "should create a new instance given valid attributes" do
    ppl = Factory(:personnel_provider_link)
    ppl.should_not be_nil
  end

  it { should belong_to(:provider) }
  it { should belong_to(:person) }

  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:provider) }

  context "ensuring only one primary contact" do

    let(:ppl) { Factory(:personnel_provider_link, :primary_contact => true) }

    it "updates all other records to not be primary if this record is the primary contact" do
      ppl.primary_contact.should be_true
      ppl2 = Factory(:personnel_provider_link, :primary_contact => true)
      PersonnelProviderLink.find(ppl).primary_contact.should_not be_true
    end

    it "does not update any records if this record is not primary" do
      ppl.primary_contact.should be_true
      ppl2 = Factory(:personnel_provider_link, :primary_contact => false)
      PersonnelProviderLink.find(ppl).primary_contact.should be_true
    end

  end

end

