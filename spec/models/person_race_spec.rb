# == Schema Information
# Schema version: 20110624163825
#
# Table name: person_races
#
#  id               :integer         not null, primary key
#  psu_code         :string(36)      not null
#  person_id        :integer         not null
#  race_code        :integer         not null
#  race_other       :string(255)
#  transaction_type :string(36)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe PersonRace do
  
  it "should create a new instance given valid attributes" do
    pr = Factory(:person_race)
    pr.should_not be_nil
  end
  
  it { should belong_to(:person) }
  it { should belong_to(:psu) }
  it { should belong_to(:race) }
  
  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:psu) }
  it { should validate_presence_of(:race) }
  
end
