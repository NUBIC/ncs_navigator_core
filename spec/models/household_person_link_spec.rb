# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: household_person_links
#
#  created_at        :datetime
#  hh_rank_code      :integer          not null
#  hh_rank_other     :string(255)
#  household_unit_id :integer          not null
#  id                :integer          not null, primary key
#  is_active_code    :integer          not null
#  person_hh_id      :string(36)       not null
#  person_id         :integer          not null
#  psu_code          :integer          not null
#  transaction_type  :string(36)
#  updated_at        :datetime
#



require 'spec_helper'

describe HouseholdPersonLink do

  it "should create a new instance given valid attributes" do
    hh_pers_link = Factory(:household_person_link)
    hh_pers_link.should_not be_nil
  end

  it { should belong_to(:person) }
  it { should belong_to(:household_unit) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      hpl = Factory(:household_person_link)
      hpl.public_id.should_not be_nil
      hpl.person_hh_id.should == hpl.public_id
      hpl.person_hh_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      hpl = HouseholdPersonLink.new
      hpl.person = Factory(:person)
      hpl.household_unit = Factory(:household_unit)
      hpl.save!

      obj = HouseholdPersonLink.first
      obj.hh_rank.local_code.should == -4
      obj.is_active.local_code.should == -4
    end
  end

  describe "#order_by_rank" do
    let(:primary)   { Factory(:household_person_link, :hh_rank => NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 1))  }
    let(:secondary) { Factory(:household_person_link, :hh_rank => NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2))  }
    let(:other)     { Factory(:household_person_link, :hh_rank => NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', -5)) }
    let(:unordered) { [other, primary, secondary] }

    it "should have primary first" do
      HouseholdPersonLink.order_by_rank(unordered).should == [primary, secondary, other]
    end
  end

end

