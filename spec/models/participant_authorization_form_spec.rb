# == Schema Information
# Schema version: 20120321181032
#
# Table name: participant_authorization_forms
#
#  id                  :integer         not null, primary key
#  psu_code            :integer         not null
#  auth_form_id        :string(36)      not null
#  participant_id      :integer
#  contact_id          :integer
#  provider_id         :integer
#  auth_form_type_code :integer         not null
#  auth_type_other     :string(255)
#  auth_status_code    :integer         not null
#  auth_status_other   :string(255)
#  transaction_type    :string(36)
#  created_at          :datetime
#  updated_at          :datetime
#

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
      create_missing_in_error_ncs_codes(ParticipantAuthorizationForm)

      paf = ParticipantAuthorizationForm.new
      paf.psu = Factory(:ncs_code)
      paf.participant = Factory(:participant)
      paf.save!

      obj = ParticipantAuthorizationForm.find(paf.id)
      obj.auth_form_type.local_code.should == -4
      obj.auth_status.local_code.should == -4
    end
  end
end
