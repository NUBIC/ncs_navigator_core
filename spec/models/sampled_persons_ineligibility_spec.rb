# == Schema Information
#
# Table name: sampled_persons_ineligibilities
#
#  age_eligible_code         :integer
#  county_of_residence_code  :integer
#  created_at                :datetime
#  first_prenatal_visit_code :integer
#  id                        :integer          not null, primary key
#  ineligible_by_code        :integer
#  person_id                 :integer
#  pregnancy_eligible_code   :integer
#  provider_id               :integer
#  psu_code                  :string(36)       not null
#  sampled_persons_inelig_id :string(36)       not null
#  transaction_type          :string(36)
#  updated_at                :datetime
#

require 'spec_helper'

describe SampledPersonsIneligibility do
    
  it "should create a new instance given valid attributes" do
    sam_per_inelig = Factory(:sampled_persons_ineligibility)
    sam_per_inelig.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:person) }
  it { should belong_to(:provider) }
  

  context "as mdes record" do

	it "sets the public_id to a uuid" do
	  sam_per_inelig = Factory(:sampled_persons_ineligibility)
	  sam_per_inelig.public_id.should_not be_nil
	  sam_per_inelig.sampled_persons_inelig_id.should == sam_per_inelig.public_id
	  sam_per_inelig.sampled_persons_inelig_id.length.should == 36
	end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
	  sam_per_inelig = SampledPersonsIneligibility.new
	  sam_per_inelig.psu_code = 20000030
	  sam_per_inelig.person = Factory(:person)
	  sam_per_inelig.provider = Factory(:provider)
	  sam_per_inelig.save!

	  obj = SampledPersonsIneligibility.first
	  obj.age_eligible.local_code.should == -4
	  obj.county_of_residence.local_code.should == -4
	  obj.first_prenatal_visit.local_code.should == -4
	  obj.ineligible_by.local_code.should == -4
	end
  end
end  
