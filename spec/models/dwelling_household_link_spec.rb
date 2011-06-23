# == Schema Information
# Schema version: 20110623215337
#
# Table name: dwelling_household_links
#
#  id                :integer         not null, primary key
#  psu_code          :integer         not null
#  is_active_code    :integer         not null
#  dwelling_unit_id  :integer         not null
#  household_unit_id :integer         not null
#  du_rank_code      :integer         not null
#  du_rank_other     :string(255)
#  transaction_type  :string(36)
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
  
  it { should validate_presence_of(:psu) }
  it { should validate_presence_of(:is_active) }
  it { should validate_presence_of(:du_rank) }
  
end
