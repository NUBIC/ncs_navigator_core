# == Schema Information
# Schema version: 20120626221317
#
# Table name: household_units
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  hh_status_code               :integer         not null
#  hh_eligibility_code          :integer         not null
#  hh_structure_code            :integer         not null
#  hh_structure_other           :string(255)
#  hh_comment                   :text
#  number_of_age_eligible_women :integer
#  number_of_pregnant_women     :integer
#  number_of_pregnant_minors    :integer
#  number_of_pregnant_adults    :integer
#  number_of_pregnant_over49    :integer
#  transaction_type             :string(36)
#  hh_id                        :string(36)      not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  being_processed              :boolean
#

# -*- coding: utf-8 -*-

require 'spec_helper'

describe HouseholdUnit do

  it "should create a new instance given valid attributes" do
    hh = Factory(:household_unit)
    hh.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:hh_status) }
  it { should belong_to(:hh_eligibility) }
  it { should belong_to(:hh_structure) }

  it { should have_many(:dwelling_household_links) }
  it { should have_many(:dwelling_units).through(:dwelling_household_links) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      hu = Factory(:household_unit)
      hu.public_id.should_not be_nil
      hu.hh_id.should == hu.public_id
      hu.hh_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      hu = HouseholdUnit.new
      hu.save!

      obj = HouseholdUnit.first
      obj.hh_status.local_code.should == -4
      obj.hh_eligibility.local_code.should == -4
      obj.hh_structure.local_code.should == -4
    end
  end

end
