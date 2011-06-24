# == Schema Information
# Schema version: 20110624163825
#
# Table name: participant_person_links
#
#  id                 :integer         not null, primary key
#  psu_code           :string(36)      not null
#  person_id          :integer         not null
#  participant_id     :integer         not null
#  relationship_code  :integer         not null
#  relationship_other :string(255)
#  is_active_code     :integer         not null
#  transaction_type   :string(36)
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe ParticipantPersonLink do
  
  it "should create a new instance given valid attributes" do
    par = Factory(:participant)
    par.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:person) }
  it { should belong_to(:participant) }
  it { should belong_to(:relationship) }
  it { should belong_to(:is_active) }
  
  it { should validate_presence_of(:psu) }
  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:participant) }
  it { should validate_presence_of(:relationship) }
  it { should validate_presence_of(:is_active) }
  
end
