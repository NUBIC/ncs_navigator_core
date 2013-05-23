# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: dwelling_household_links
#
#  created_at        :datetime
#  du_rank_code      :integer          not null
#  du_rank_other     :string(255)
#  dwelling_unit_id  :integer          not null
#  hh_du_id          :string(36)       not null
#  household_unit_id :integer          not null
#  id                :integer          not null, primary key
#  is_active_code    :integer          not null
#  psu_code          :integer          not null
#  transaction_type  :string(36)
#  updated_at        :datetime
#



require 'spec_helper'

describe DwellingHouseholdLink do

  it "should create a new instance given valid attributes" do
    link = Factory(:dwelling_household_link)
    link.should_not be_nil
  end


  context "as mdes record" do

    it "sets the public_id to a uuid" do
      dhl = Factory(:dwelling_household_link)
      dhl.public_id.should_not be_nil
      dhl.hh_du_id.should == dhl.public_id
      dhl.hh_du_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      dhl = DwellingHouseholdLink.new
      dhl.dwelling_unit = Factory(:dwelling_unit)
      dhl.household_unit = Factory(:household_unit)
      dhl.save!

      obj = DwellingHouseholdLink.first
      obj.is_active.local_code.should == -4
      obj.du_rank.local_code.should == -4
    end
  end

  describe "#order_by_rank" do
    let(:primary)   { Factory(:dwelling_household_link, :du_rank => NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 1))  }
    let(:secondary) { Factory(:dwelling_household_link, :du_rank => NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2))  }
    let(:other)     { Factory(:dwelling_household_link, :du_rank => NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', -5)) }
    let(:unordered) { [other, primary, secondary] }

    it "should be ordered" do
      DwellingHouseholdLink.order_by_rank(unordered).should == [primary, secondary, other]
    end
  end


end

