# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130108204723
#
# Table name: participant_consents
#
#  consent_comments                :text
#  consent_date                    :date
#  consent_expiration              :date
#  consent_form_type_code          :integer          not null
#  consent_given_code              :integer          not null
#  consent_language_code           :integer          not null
#  consent_language_other          :string(255)
#  consent_reconsent_code          :integer          default(-4), not null
#  consent_reconsent_reason_code   :integer          default(-4), not null
#  consent_reconsent_reason_other  :string(255)
#  consent_translate_code          :integer          not null
#  consent_type_code               :integer          not null
#  consent_version                 :string(9)
#  consent_withdraw_code           :integer          not null
#  consent_withdraw_date           :date
#  consent_withdraw_reason_code    :integer          not null
#  consent_withdraw_type_code      :integer          not null
#  contact_id                      :integer
#  created_at                      :datetime
#  id                              :integer          not null, primary key
#  participant_consent_id          :string(36)       not null
#  participant_id                  :integer
#  person_who_consented_id         :integer
#  person_wthdrw_consent_id        :integer
#  psu_code                        :integer          not null
#  reconsideration_script_use_code :integer          not null
#  transaction_type                :string(36)
#  updated_at                      :datetime
#  who_consented_code              :integer          not null
#  who_wthdrw_consent_code         :integer          not null
#



require 'spec_helper'

describe ParticipantConsent do

  it "creates a new instance given valid attributes" do
    pc = Factory(:participant_consent)
    pc.should_not be_nil
  end

  it { should belong_to(:participant) }
  it { should belong_to(:contact) }
  it { should belong_to(:person_who_consented) }
  it { should belong_to(:person_wthdrw_consent) }


  it { should ensure_length_of(:consent_version).is_at_most(9) }

  it { should have_many(:participant_consent_samples) }
  it { should have_one(:response_set) }

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
      obj.consent_reconsent.local_code.should == -4
      obj.consent_reconsent_reason.local_code.should == -4
    end
  end

  describe "withdrawn?" do
    it "returns true if the consent_withdraw_code is Yes (1)" do
      Factory(:participant_consent, :consent_withdraw_code => NcsCode::YES).should be_withdrawn
    end

    it "returns false if the consent_withdraw_code is No (2)" do
      Factory(:participant_consent, :consent_withdraw_code => NcsCode::NO).should_not be_withdrawn
    end
  end

  describe "reconsent?" do
    it "returns true if the consent_reconsent_code is Yes (1)" do
      Factory(:participant_consent, :consent_reconsent_code => NcsCode::YES).should be_reconsent
    end

    it "returns false if the consent_reconsent_code is No (2)" do
      Factory(:participant_consent, :consent_reconsent_code => NcsCode::NO).should_not be_reconsent
    end

    it "returns false if the consent_reconsent_code is nil" do
      Factory(:participant_consent, :consent_reconsent_code => nil).should_not be_reconsent
    end
  end

  describe "reconsented?" do
    it "returns true if the consent_reconsent_code is Yes (1) and consent_given_code is Yes" do
      Factory(:participant_consent, :consent_reconsent_code => NcsCode::YES, :consent_given_code => NcsCode::YES).should be_reconsented
    end

    it "returns false if the consent_reconsent_code is Yes (1) and consent_given_code is No" do
      Factory(:participant_consent, :consent_reconsent_code => NcsCode::YES, :consent_given_code => NcsCode::NO).should_not be_reconsented
    end
  end

  context "for a participant" do

    before(:each) do
      @yes = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 1)
      @no  = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 2)
    end

    it "cannot have consented without a participant_consent record" do
      participant = Factory(:participant)
      participant.participant_consents.should be_empty
      participant.should_not be_consented
    end

    context "phase one consent" do
      before do
        @general       = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 1)
        @biospecimens  = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 2)
        @environmental = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 3)
        @genetic       = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 4)
        @birth         = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 5)
        @child         = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 6)
        @low_intensity = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 7)
      end

      let(:date) { Date.parse('2525-12-25') }

      it "knows if the participant has consented" do
        pc = Factory(:participant_consent, :consent_given => @yes, :consent_withdraw => @no,
                     :consent_type => @low_intensity, :consent_form_type_code => -4, :consent_date => date)
        pt = Participant.find(pc.participant_id)
        pt.participant_consents.should == [pc]
        pt.should be_consented
        pt.should_not be_withdrawn
      end

      it "knows if the participant has withdrawn consented" do
        pc = Factory(:participant_consent, :consent_given => @no, :consent_withdraw => @yes,
                     :consent_type => @low_intensity, :consent_form_type_code => -4, :consent_date => date)
        pt = Participant.find(pc.participant_id)
        pt.should be_withdrawn
      end
    end

    context "phase two consent" do
      before do
        @general       = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL3", 1)
        @low_intensity = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL3", 7)
      end

      let(:date) { Date.parse('2525-12-25') }

      it "knows if the participant has consented" do
        pc = Factory(:participant_consent, :consent_given => @yes, :consent_withdraw => @no,
                     :consent_form_type => @low_intensity, :consent_type_code => -4, :consent_date => date)
        pt = Participant.find(pc.participant_id)
        pt.should be_consented
        pt.should_not be_withdrawn
      end

      it "knows if the participant has withdrawn consented" do
        pc = Factory(:participant_consent, :consent_given => @no, :consent_withdraw => @yes,
                     :consent_form_type => @low_intensity, :consent_type_code => -4, :consent_date => date)
        pt = Participant.find(pc.participant_id)
        pt.should be_withdrawn
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

  describe '#high_intensity?' do
    it 'is true when the consent is for a phase one high consent' do
      ParticipantConsent.new(:consent_type_code => 1).should be_high_intensity
    end

    it 'is not true for phase one low intensity consents' do
      ParticipantConsent.new(:consent_type_code => 7).should_not be_high_intensity
    end

    [1, 2, 6].each do |cft|
      it "is true when the consent is for a phase two high consent form type #{cft}" do
        ParticipantConsent.new(:consent_form_type_code => cft).should be_high_intensity
      end
    end

    it "is not true when the consent is for a phase two low consent form type" do
      ParticipantConsent.new(:consent_form_type_code => 7).should_not be_high_intensity
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

  describe "#consent_event" do
    let(:participant_consent) { Factory(:participant_consent, :contact => contact) }

    context "without a contact" do
      let(:contact) { nil }
      it "returns nil" do
        participant_consent.consent_event.should be_nil
      end
    end

    context "with a contact" do
      let(:contact) { Factory(:contact) }

      context "not associated with an Event" do
        let!(:contact_link) { Factory(:contact_link, :event => nil, :contact => contact) }
        it "returns nil" do
          participant_consent.consent_event.should be_nil
        end
      end

      context "associated with Events through ContactLink" do
        describe "with only one event" do
          let(:event) { Factory(:event, :event_type_code => Event.pregnancy_screener_code) }
          let!(:contact_link) { Factory(:contact_link, :event => event, :contact => contact) }

          it "returns that event" do
            participant_consent.consent_event.should == event
          end
        end

        describe "with more than one event" do
          let(:ic_event) { Factory(:event, :event_type_code => Event.informed_consent_code) }
          let(:ps_event) { Factory(:event, :event_type_code => Event.pregnancy_screener_code) }
          before do
            Factory(:contact_link, :event => ic_event, :contact => contact)
            Factory(:contact_link, :event => ps_event, :contact => contact)
          end

          it "returns the InformedConsent event" do
            participant_consent.consent_event.should == ic_event
          end
        end

        describe "with more than one InformedConsent event" do
          # This should not happen but is being seen in some SC data
          # There is one contact for two IC events that happen on different dates
          let(:event1) { Factory(:event, :event_type_code => Event.informed_consent_code, :event_start_date => Date.parse("2012-01-01")) }
          let(:event2) { Factory(:event, :event_type_code => Event.informed_consent_code, :event_start_date => Date.parse("2012-10-10")) }
          before do
            Factory(:contact_link, :event => event1, :contact => contact)
            Factory(:contact_link, :event => event2, :contact => contact)
          end

          it "returns the first chronological event" do
            participant_consent.consent_event.should == event1
          end

          describe "and one of those events has a nil event start date" do
            let(:event3) { Factory(:event, :event_type_code => Event.informed_consent_code, :event_start_date => nil) }
            before do
              Factory(:contact_link, :event => event3, :contact => contact)
            end

            it "returns the first chronological event" do
              participant_consent.consent_event.should == event1
            end
          end

        end
      end
    end
  end

  describe ".start!" do
    let(:contact) { Factory(:contact) }
    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }
    let(:event) { Factory(:event, :participant => participant) }
    let(:survey) { Survey.last }
    let(:contact_link) { Factory(:contact_link, :contact => contact, :event => event) }

    describe "for a new ParticipantConsent record" do

      before do
        f = "#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb"
        Surveyor::Parser.parse File.read(f)

        ParticipantConsent.count.should == 0
        ParticipantConsent.start!(person, participant, survey, contact, contact_link)
      end

      it "creates a new ParticipantConsent record" do
        ParticipantConsent.count.should == 1
        pc = ParticipantConsent.first
        pc.contact.should == contact
        pc.response_set.survey.should == survey
        pc.response_set.participant.should == participant
        pc.response_set.person.should == person
        pc.participant.should == participant
      end

      it "creates an associated informed consent event" do
        pc = ParticipantConsent.first
        e = Event.last
        e.should be_informed_consent
        pc.contact.should == e.contact_links.last.contact
      end

      it "creates an associated ResponseSet" do
        ParticipantConsent.first.response_set.should_not be_nil
      end

    end

    describe "for a existing ParticipantConsent record" do

      before do
        f = "#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb"
        Surveyor::Parser.parse File.read(f)
      end

      it "returns the ParticipantConsent associated with the survey, person, and contact" do
        2.times do |i|
          ParticipantConsent.count.should == i
          ParticipantConsent.start!(person, participant, survey, contact, contact_link)
          ParticipantConsent.count.should == 1
        end

        pc = ParticipantConsent.last
        pc.contact.should == contact
        pc.response_set.survey.should == survey
        pc.response_set.participant.should == participant
        pc.response_set.person.should == person
        pc.participant.should == participant
      end

    end
  end

  describe "#associate_response_set" do

    context "when a response_set already is associated" do
      let(:rs) { Factory(:response_set) }
      let(:pc) { Factory(:participant_consent, :response_set => rs) }

      before do
        pc.associate_response_set
      end

      it "does nothing" do
        ParticipantConsent.find(pc.id).response_set == rs
      end
    end

    context "when response_set is nil" do
      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person) }
      let(:pc) { Factory(:participant_consent, :response_set => nil, :participant => participant) }

      before do
        participant.person = person
        participant.save!
        f = "#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb"
        Surveyor::Parser.parse File.read(f)
        pc.associate_response_set
      end

      it "creates an associated response_set" do
        rs = ParticipantConsent.find(pc.id).response_set
        rs.should_not be_nil
      end

      it "builds responses based on the participant_consent data" do
        rs = ParticipantConsent.find(pc.id).response_set
        rs.responses.should_not be_blank
      end

    end

  end

end
