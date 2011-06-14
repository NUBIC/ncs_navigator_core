# == Schema Information
# Schema version: 20110613210555
#
# Table name: dwelling_household_links
#
#  id                :integer         not null, primary key
#  psu_code          :integer
#  is_active_code    :integer
#  dwelling_unit_id  :integer
#  household_unit_id :integer
#  du_rank_code      :integer
#  du_rank_other     :string(255)
#  transaction_type  :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe DwellingHouseholdLink do
  
  it "should create a new instance given valid attributes" do
    link = Factory(:dwelling_household_link)
    link.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:is_active) }
  it { should belong_to(:du_rank) }
  
end
