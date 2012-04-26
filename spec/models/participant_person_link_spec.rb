# -*- coding: utf-8 -*-

# == Schema Information
# Schema version: 20120426034324
#
# Table name: participant_person_links
#
#  id                 :integer         not null, primary key
#  psu_code           :integer         not null
#  person_id          :integer         not null
#  participant_id     :integer         not null
#  relationship_code  :integer         not null
#  relationship_other :string(255)
#  is_active_code     :integer         not null
#  transaction_type   :string(36)
#  person_pid_id      :string(36)      not null
#  created_at         :datetime
#  updated_at         :datetime
#  response_set_id    :integer
#

require 'spec_helper'

describe ParticipantPersonLink do

  it "should create a new instance given valid attributes" do
    link = Factory(:participant_person_link)
    link.should_not be_nil
  end

  it "should be active when first created" do
    person = Factory(:person)
    participant = Factory(:participant)
    link = ParticipantPersonLink.new(:person => person, :participant => participant)
    link.should be_active
  end

  it { should belong_to(:psu) }
  it { should belong_to(:person) }
  it { should belong_to(:participant) }
  it { should belong_to(:relationship) }
  it { should belong_to(:is_active) }

  it { should validate_presence_of(:person_id) }
  it { should validate_presence_of(:participant_id) }
  it { should belong_to(:response_set) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      ppl = Factory(:participant_person_link)
      ppl.public_id.should_not be_nil
      ppl.person_pid_id.should == ppl.public_id
      ppl.person_pid_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(ParticipantPersonLink)

      ppl = ParticipantPersonLink.new
      ppl.psu = Factory(:ncs_code)
      ppl.participant = Factory(:participant)
      ppl.person = Factory(:person)
      ppl.save!

      obj = ParticipantPersonLink.first
      obj.relationship.local_code.should == -4
      obj.is_active.local_code.should == 1
    end
  end

end
