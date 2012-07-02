# == Schema Information
# Schema version: 20120626221317
#
# Table name: participant_consents
#
#  id                              :integer         not null, primary key
#  psu_code                        :integer         not null
#  participant_consent_id          :string(36)      not null
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

  it { should have_many(:participant_consent_samples) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pc = Factory(:participant_consent)
      pc.public_id.should_not be_nil
      pc.participant_consent_id.should == pc.public_id
      pc.participant_consent_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      pc = ParticipantConsent.new
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

  context "for a participant" do

    before(:each) do
      @yes = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 1)
      @no  = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 2)

      @general       = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 1)
      @biospecimens  = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 2)
      @environmental = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 3)
      @genetic       = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 4)
      @birth         = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 5)
      @child         = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 6)
      @low_intensity = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 7)
    end

    it "cannot have consented without a participant_consent record" do
      participant = Factory(:participant)
      participant.participant_consents.should be_empty
      participant.should_not be_consented
    end

    context "phase one consent" do
      it "knows if the participant has consented" do
        pc = Factory(:participant_consent, :consent_given => @yes, :consent_withdraw => @no,
                     :consent_type => @low_intensity, :consent_form_type_code => -4)
        pc.participant.should be_consented
        pc.participant.consented?(@low_intensity).should be_true
        pc.participant.consented?(@general).should be_false
        pc.participant.should_not be_withdrawn
      end

      it "knows if the participant has withdrawn consented" do
        pc = Factory(:participant_consent, :consent_given => @yes, :consent_withdraw => @yes,
                     :consent_type => @low_intensity, :consent_form_type_code => -4)
        pc.participant.should be_withdrawn
        pc.participant.withdrawn?(@low_intensity).should be_true
        pc.participant.withdrawn?(@general).should be_false
      end
    end

    context "phase two consent" do
      it "knows if the participant has consented" do
        pc = Factory(:participant_consent, :consent_given => @yes, :consent_withdraw => @no,
                     :consent_form_type => @low_intensity, :consent_type_code => -4)
        pc.participant.should be_consented
        pc.participant.consented?(@low_intensity).should be_true
        pc.participant.consented?(@general).should be_false
        pc.participant.should_not be_withdrawn
      end

      it "knows if the participant has withdrawn consented" do
        pc = Factory(:participant_consent, :consent_given => @yes, :consent_withdraw => @yes,
                     :consent_form_type => @low_intensity, :consent_type_code => -4)
        pc.participant.should be_withdrawn
        pc.participant.withdrawn?(@low_intensity).should be_true
        pc.participant.withdrawn?(@general).should be_false
      end
    end
  end

  context "consent type code lists" do

    it "knows all of the consent types" do
      consent_types = ParticipantConsent.consent_types
      consent_types.size.should == 8
      consent_types[0].should == ["1", "General consent"]
      consent_types[6].should == ["7", "Low Intensity Consent"]
    end

    it "knows all of the li consent types" do
      lict = ParticipantConsent.low_intensity_consent_types
      lict.size.should == 1
      lict[0].should == ["7", "Low Intensity Consent"]
    end

    it "knows all of the hi consent types" do
      hict = ParticipantConsent.high_intensity_consent_types
      hict.size.should == 1
      hict[0].should == ["1", "General consent"]
    end

    it "knows the general consent" do
      ParticipantConsent.general_consent_type_code.should ==
        NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 1)
    end

    it "knows the child consent" do
      ParticipantConsent.child_consent_type_code.should ==
        NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 6)
    end

    it "knows the low_intensity consent" do
      ParticipantConsent.low_intensity_consent_type_code.should ==
        NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 7)
    end

  end

  context "phase 1 versus phase 2 consents" do

    describe ".phase_one?" do

      describe "should be phase 1" do
        it "if there is a valid consent_type_code and no consent_form_type_code" do
          participant_consent = Factory(:participant_consent, :consent_type_code => 1, :consent_form_type_code => -4)
          participant_consent.should be_phase_one
        end

        it "if there is a valid consent_type_code and a consent_form_type_code" do
          participant_consent = Factory(:participant_consent, :consent_type_code => 1, :consent_form_type_code => 1)
          participant_consent.should be_phase_one
        end
      end

      describe "should not be phase 1" do
        it "if there is not a valid consent_type_code" do
          participant_consent = Factory(:participant_consent, :consent_type_code => -4)
          participant_consent.should_not be_phase_one
        end
      end
    end

    describe ".phase_two?" do
      describe "should be phase 2" do
        it "if there is a valid consent_form_type_code and no consent_type_code" do
          participant_consent = Factory(:participant_consent, :consent_type_code => -4, :consent_form_type_code => 1)
          participant_consent.should be_phase_two
        end
      end

      describe "should not be phase 2" do
        it "if there is a valid consent_type_code" do
          participant_consent = Factory(:participant_consent, :consent_type_code => 1)
          participant_consent.should_not be_phase_two
        end
      end

    end
  end

end
