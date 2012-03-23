# == Schema Information
# Schema version: 20120321181032
#
# Table name: participant_consent_samples
#
#  id                            :integer         not null, primary key
#  psu_code                      :integer         not null
#  participant_consent_sample_id :string(36)      not null
#  participant_id                :integer
#  participant_consent_id        :integer
#  sample_consent_type_code      :integer         not null
#  sample_consent_given_code     :integer         not null
#  transaction_type              :string(36)
#  created_at                    :datetime
#  updated_at                    :datetime
#

require 'spec_helper'

describe ParticipantConsentSample do
  it "creates a new instance given valid attributes" do
    pcs = Factory(:participant_consent_sample)
    pcs.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:participant_consent) }

  it { should belong_to(:sample_consent_type) }
  it { should belong_to(:sample_consent_given) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      paf = Factory(:participant_authorization_form)
      paf.public_id.should_not be_nil
      paf.auth_form_id.should == paf.public_id
      paf.auth_form_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(ParticipantConsentSample)

      pcs = ParticipantConsentSample.new
      pcs.psu = Factory(:ncs_code)
      pcs.participant = Factory(:participant)
      pcs.participant_consent = Factory(:participant_consent)
      pcs.save!

      obj = ParticipantConsentSample.find(pcs.id)
      obj.sample_consent_type.local_code.should == -4
      obj.sample_consent_given.local_code.should == -4
    end
  end
end
