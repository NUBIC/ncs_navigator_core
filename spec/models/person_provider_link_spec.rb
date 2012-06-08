# == Schema Information
# Schema version: 20120607203203
#
# Table name: person_provider_links
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  person_provider_id           :string(36)      not null
#  provider_id                  :integer
#  person_id                    :integer
#  is_active_code               :integer         not null
#  provider_intro_outcome_code  :integer         not null
#  provider_intro_outcome_other :string(255)
#  transaction_type             :string(36)
#  created_at                   :datetime
#  updated_at                   :datetime
#

require 'spec_helper'

describe PersonProviderLink do
  it "should create a new instance given valid attributes" do
    ppl = Factory(:person_provider_link)
    ppl.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:provider) }
  it { should belong_to(:person) }
  it { should belong_to(:is_active) }
  it { should belong_to(:provider_intro_outcome) }

  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:provider) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      ppl = Factory(:person_provider_link)
      ppl.public_id.should_not be_nil
      ppl.person_provider_id.should == ppl.public_id
      ppl.person_provider_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      ppl = PersonProviderLink.new
      ppl.psu_code = 20000030
      ppl.person = Factory(:person)
      ppl.provider = Factory(:provider)
      ppl.save!

      obj = PersonProviderLink.first
      obj.is_active.local_code.should == -4
      obj.provider_intro_outcome.local_code.should == -4
    end
  end

end
