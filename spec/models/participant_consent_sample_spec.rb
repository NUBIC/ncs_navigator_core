# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130514215040
#
# Table name: participant_consent_samples
#
#  created_at                    :datetime
#  id                            :integer          not null, primary key
#  participant_consent_id        :integer
#  participant_consent_sample_id :string(36)       not null
#  psu_code                      :integer          not null
#  sample_consent_given_code     :integer          not null
#  sample_consent_type_code      :integer          not null
#  transaction_type              :string(36)
#  updated_at                    :datetime
#



require 'spec_helper'

describe ParticipantConsentSample do
  it "creates a new instance given valid attributes" do
    pcs = Factory(:participant_consent_sample)
    pcs.should_not be_nil
  end

  it { should belong_to(:participant_consent) }


  context "as mdes record" do

    it "sets the public_id to a uuid" do
      paf = Factory(:participant_authorization_form)
      paf.public_id.should_not be_nil
      paf.auth_form_id.should == paf.public_id
      paf.auth_form_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      pcs = ParticipantConsentSample.new
      pcs.participant_consent = Factory(:participant_consent)
      pcs.save!

      obj = ParticipantConsentSample.find(pcs.id)
      obj.sample_consent_type.local_code.should == -4
      obj.sample_consent_given.local_code.should == -4
    end
  end

  context "consent type code lists" do

    it "knows all of the consent types" do
      consent_types = ParticipantConsentSample.consent_types
      consent_types.size.should == 3
      consent_types[0].should == ["1", "Consent to collect environmental samples"]
      consent_types[1].should == ["2", "Consent to collect biospecimens"]
      consent_types[2].should == ["3", "Consent to collect genetic material"]
    end

    it "knows the environmental consent" do
      ParticipantConsentSample.environmental_consent_type_code.should ==
        NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL2", 1)
    end

    it "knows the biospecimen consent" do
      ParticipantConsentSample.biospecimen_consent_type_code.should ==
        NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL2", 2)
    end

    it "knows the genetic consent" do
      ParticipantConsentSample.genetic_consent_type_code.should ==
        NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL2", 3)
    end

  end

end
