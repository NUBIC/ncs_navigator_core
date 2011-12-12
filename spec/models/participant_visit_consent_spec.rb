# == Schema Information
# Schema version: 20111212224350
#
# Table name: participant_visit_consents
#
#  id                          :integer         not null, primary key
#  psu_code                    :integer         not null
#  pid_visit_consent_id        :string(36)      not null
#  participant_id              :integer
#  vis_consent_type_code       :integer         not null
#  vis_consent_response_code   :integer         not null
#  vis_language_code           :integer         not null
#  vis_language_other          :string(255)
#  vis_person_who_consented_id :integer
#  vis_who_consented_code      :integer         not null
#  vis_translate_code          :integer         not null
#  vis_comments                :text
#  contact_id                  :integer
#  transaction_type            :string(36)
#  created_at                  :datetime
#  updated_at                  :datetime
#

require 'spec_helper'

describe ParticipantVisitConsent do

  it "creates a new instance given valid attributes" do
    pvc = Factory(:participant_visit_consent)
    pvc.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:contact) }
  it { should belong_to(:vis_person_who_consented) }

  it { should belong_to(:vis_who_consented) }
  it { should belong_to(:vis_consent_type) }
  it { should belong_to(:vis_consent_response) }
  it { should belong_to(:vis_language) }
  it { should belong_to(:vis_translate) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pvc = Factory(:participant_visit_consent)
      pvc.public_id.should_not be_nil
      pvc.pid_visit_consent_id.should == pvc.public_id
      pvc.pid_visit_consent_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(ParticipantVisitConsent)

      pvc = ParticipantVisitConsent.new
      pvc.psu = Factory(:ncs_code)
      pvc.participant = Factory(:participant)
      pvc.vis_person_who_consented = Factory(:person)
      pvc.save!

      obj = ParticipantVisitConsent.find(pvc.id)
      obj.vis_consent_type.local_code.should == -4
      obj.vis_consent_response.local_code.should == -4
      obj.vis_language.local_code.should == -4
      obj.vis_who_consented.local_code.should == -4
      obj.vis_translate.local_code.should == -4
    end
  end

end
