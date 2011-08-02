# == Schema Information
# Schema version: 20110727185512
#
# Table name: person_races
#
#  id               :integer         not null, primary key
#  psu_code         :string(36)      not null
#  person_race_id   :binary          not null
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
  
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      pr = Factory(:person_race)
      pr.public_id.should_not be_nil
      pr.person_race_id.should == pr.public_id
      pr.person_race_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(PersonRace)
      
      pr = PersonRace.new
      pr.psu = Factory(:ncs_code)
      pr.person = Factory(:person)
      pr.save!
    
      PersonRace.first.race.local_code.should == -4
    end
  end
  
end
