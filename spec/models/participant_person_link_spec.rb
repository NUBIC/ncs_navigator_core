# == Schema Information
# Schema version: 20110714212419
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
#  person_pid_id      :binary          not null
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
  
  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:participant) }
  
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      ppl = Factory(:participant_person_link)
      ppl.public_id.should_not be_nil
      ppl.person_pid_id.should == ppl.public_id
      ppl.person_pid_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(ParticipantPersonLink)
      
      ppl = ParticipantPersonLink.new
      ppl.psu = Factory(:ncs_code)
      ppl.participant = Factory(:participant)
      ppl.person = Factory(:person)
      ppl.save!
    
      obj = ParticipantPersonLink.first
      obj.relationship.local_code.should == -4
      obj.is_active.local_code.should == -4
    end
  end
  
end
