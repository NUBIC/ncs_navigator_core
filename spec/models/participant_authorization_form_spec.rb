# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: participant_authorization_forms
#
#  auth_form_id        :string(36)       not null
#  auth_form_type_code :integer          not null
#  auth_status_code    :integer          not null
#  auth_status_other   :string(255)
#  auth_type_other     :string(255)
#  contact_id          :integer
#  created_at          :datetime
#  id                  :integer          not null, primary key
#  participant_id      :integer
#  provider_id         :integer
#  psu_code            :integer          not null
#  transaction_type    :string(36)
#  updated_at          :datetime
#



require 'spec_helper'

describe ParticipantAuthorizationForm do
  it "creates a new instance given valid attributes" do
    paf = Factory(:participant_authorization_form)
    paf.should_not be_nil
  end

  it { should belong_to(:participant) }
  it { should belong_to(:contact) }
  # it { should belong_to(:provider) }


  context "as mdes record" do

    it "sets the public_id to a uuid" do
      paf = Factory(:participant_authorization_form)
      paf.public_id.should_not be_nil
      paf.auth_form_id.should == paf.public_id
      paf.auth_form_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      paf = ParticipantAuthorizationForm.new
      paf.participant = Factory(:participant)
      paf.save!

      obj = ParticipantAuthorizationForm.find(paf.id)
      obj.auth_form_type.local_code.should == -4
      obj.auth_status.local_code.should == -4
    end
  end
end

