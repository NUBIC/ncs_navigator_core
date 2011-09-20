# == Schema Information
# Schema version: 20110920210459
#
# Table name: participant_consents
#
#  id                              :integer         not null, primary key
#  psu_code                        :string(36)      not null
#  participant_consent_id          :binary          not null
#  participant_id                  :integer
#  consent_version                 :string(9)
#  consent_expiration              :date
#  consent_type_code               :integer         not null
#  consent_form_type_code          :integer         not null
#  consent_given_code              :integer         not null
#  consent_date                    :date
#  consent_withdraw_code           :integer         not null
#  consent_withdraw_type_code      :integer         not null
#  consent_withdraw_reason_code    :integer         not null
#  consent_withdraw_date           :date
#  consent_language_code           :integer         not null
#  consent_language_other          :string(255)
#  person_who_consented_id         :integer
#  who_consented_code              :integer         not null
#  person_wthdrw_consent_id        :integer
#  who_wthdrw_consent_code         :integer         not null
#  consent_translate_code          :integer         not null
#  consent_comments                :text
#  contact_id                      :integer
#  reconsideration_script_use_code :integer         not null
#  transaction_type                :string(36)
#  created_at                      :datetime
#  updated_at                      :datetime
#

require 'spec_helper'

describe ParticipantConsent do

  it "creates a new instance given valid attributes" do
    pc = Factory(:participant_consent)
    pc.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:contact) }
  it { should belong_to(:person_who_consented) }
  it { should belong_to(:person_wthdrw_consent) }
  it { should belong_to(:consent_type) }
  it { should belong_to(:consent_form_type) }
  it { should belong_to(:consent_given) }
  
  it { should belong_to(:consent_withdraw) }
  it { should belong_to(:consent_withdraw_type) }
  it { should belong_to(:consent_withdraw_reason) }
  it { should belong_to(:consent_language) }
  it { should belong_to(:who_consented) }
  it { should belong_to(:who_wthdrw_consent) }
  it { should belong_to(:consent_translate) }
  it { should belong_to(:reconsideration_script_use) }

  it { should ensure_length_of(:consent_version).is_at_most(9) }
  
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      pc = Factory(:participant_consent)
      pc.public_id.should_not be_nil
      pc.participant_consent_id.should == pc.public_id
      pc.participant_consent_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(ParticipantConsent)
      
      pc = ParticipantConsent.new
      pc.psu = Factory(:ncs_code)
      pc.participant = Factory(:participant)
      pc.consent_version = "asdf"
      pc.save!
    
      obj = ParticipantConsent.find(pc.id)
      obj.consent_type.local_code.should == -4
      obj.consent_form_type.local_code.should == -4
      obj.consent_given.local_code.should == -4
      obj.consent_withdraw.local_code.should == -4
      obj.consent_withdraw_type.local_code.should == -4
      obj.consent_withdraw_reason.local_code.should == -4
      obj.consent_language.local_code.should == -4
      obj.who_consented.local_code.should == -4
      obj.who_wthdrw_consent.local_code.should == -4
      obj.consent_translate.local_code.should == -4
      obj.reconsideration_script_use.local_code.should == -4
    end
  end

end
