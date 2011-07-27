# == Schema Information
# Schema version: 20110726214159
#
# Table name: household_person_links
#
#  id                :integer         not null, primary key
#  psu_code          :string(36)      not null
#  person_hh_id      :binary          not null
#  person_id         :integer         not null
#  household_unit_id :integer         not null
#  is_active_code    :integer         not null
#  hh_rank_code      :integer         not null
#  hh_rank_other     :string(255)
#  transaction_type  :string(36)
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe HouseholdPersonLink do
  
  it "should create a new instance given valid attributes" do
    hh_pers_link = Factory(:household_person_link)
    hh_pers_link.should_not be_nil
  end
  
  it { should belong_to(:person) }
  it { should belong_to(:psu) }
  it { should belong_to(:household_unit) }
  it { should belong_to(:hh_rank) }
  it { should belong_to(:is_active) }
  
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      hpl = Factory(:household_person_link)
      hpl.public_id.should_not be_nil
      hpl.person_hh_id.should == hpl.public_id
      hpl.person_hh_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(HouseholdPersonLink)
      
      hpl = HouseholdPersonLink.new
      hpl.psu = Factory(:ncs_code)
      hpl.person = Factory(:person)
      hpl.household_unit = Factory(:household_unit)
      hpl.save!
    
      obj = HouseholdPersonLink.first
      obj.hh_rank.local_code.should == -4
      obj.is_active.local_code.should == -4
    end
  end
  
end
