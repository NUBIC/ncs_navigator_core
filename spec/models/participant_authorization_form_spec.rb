# -*- coding: utf-8 -*-


require 'spec_helper'

describe ParticipantAuthorizationForm do
  it "creates a new instance given valid attributes" do
    paf = Factory(:participant_authorization_form)
    paf.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:contact) }
  # it { should belong_to(:provider) }

  it { should belong_to(:auth_form_type) }
  it { should belong_to(:auth_status) }

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

