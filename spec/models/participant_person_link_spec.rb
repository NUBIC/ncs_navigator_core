# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130502152819
#
# Table name: participant_person_links
#
#  created_at                  :datetime
#  id                          :integer          not null, primary key
#  is_active_code              :integer          not null
#  multi_birth_id              :string(36)
#  participant_id              :integer          not null
#  person_id                   :integer          not null
#  person_pid_id               :string(36)       not null
#  primary_caregiver_flag_code :integer          default(-4), not null
#  psu_code                    :integer          not null
#  relationship_code           :integer          not null
#  relationship_other          :string(255)
#  response_set_id             :integer
#  transaction_type            :string(36)
#  updated_at                  :datetime
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

  it { should belong_to(:person) }
  it { should belong_to(:participant) }

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

      ppl = ParticipantPersonLink.new
      ppl.participant = Factory(:participant)
      ppl.person = Factory(:person)
      ppl.save!

      obj = ParticipantPersonLink.first
      obj.relationship.local_code.should == -4
      obj.is_active.local_code.should == 1
    end
  end

  describe "#active?" do
    let(:ppl) { Factory(:participant_person_link, :relationship_code => is_active_code) }
    describe "when is_active_code is 1" do
      let(:is_active_code) { 1 }
      it "is true" do
        ppl.should be_self_relationship
      end
    end

    describe "when is_active_code is not 1" do
      let(:is_active_code) { -4 }
      it "is false" do
        ppl.should_not be_self_relationship
      end
    end
  end

  describe "#self_relationship?" do
    let(:ppl) { Factory(:participant_person_link, :relationship_code => relationship_code) }
    describe "when relationship_code is 1" do
      let(:relationship_code) { 1 }
      it "is true" do
        ppl.should be_self_relationship
      end
    end

    describe "when relationship_code is not 1" do
      let(:relationship_code) { -4 }
      it "is false" do
        ppl.should_not be_self_relationship
      end
    end
  end

end

