# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::InformedConsent do
  include SurveyCompletion

  let(:person) { Factory(:person) }
  let(:participant) { Factory(:participant, :enroll_status_code => -4, :enroll_date => nil) }
  let(:survey) { Survey.last }
  let(:contact) { Factory(:contact) }

  let(:consent_form_type) { NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL3", 1) }
  let(:yes) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 1) }
  let(:no) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 2) }
  let(:no2) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL21", 2) }
  let(:date) { "2525-12-12" }
  let(:who) { NcsCode.for_list_name_and_local_code("AGE_STATUS_CL1", 2) }
  let(:en) { NcsCode.for_list_name_and_local_code("LANGUAGE_CL2", 1) }
  let(:no_trans) { NcsCode.for_list_name_and_local_code("TRANSLATION_METHOD_CL1", 1) }

  context "with an InformedConsent survey" do

    before do
      f = "#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb"
      Surveyor::Parser.parse File.read(f)
    end

    describe "a response set without an associated consent" do
      it "should raise an InvalidSurveyException" do
        consent = prepare_consent(person, participant, survey, contact)
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "PARTICIPANT_CONSENT.CONSENT_GIVEN_CODE", yes
        end
        response_set.participant_consent = nil
        response_set.save!
        response_set.responses.reload
        response_set.responses.size.should == 1

        expect {
          OperationalDataExtractor::InformedConsent.new(response_set).extract_data
        }.to raise_error(OperationalDataExtractor::InvalidSurveyException)
      end
    end

    describe "extracting ParticipantConsent data" do

      it "sets the ParticipantConsent attributes to the Response values" do
        consent = prepare_consent(person, participant, survey, contact)
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "PARTICIPANT_CONSENT.CONSENT_FORM_TYPE_CODE", consent_form_type
          r.a "PARTICIPANT_CONSENT.CONSENT_GIVEN_CODE", yes
          r.a "PARTICIPANT_CONSENT.CONSENT_DATE", "consent_date", :value => date
          r.a "PARTICIPANT_CONSENT.CONSENT_VERSION", "consent_version", :value => "version"
          r.a "PARTICIPANT_CONSENT.WHO_CONSENTED_CODE", who
          r.a "PARTICIPANT_CONSENT.CONSENT_LANGUAGE_CODE", en
          r.a "PARTICIPANT_CONSENT.CONSENT_TRANSLATE_CODE", no_trans
          r.a "PARTICIPANT_CONSENT.RECONSIDERATION_SCRIPT_USE_CODE", no2
          r.a "PARTICIPANT_CONSENT.CONSENT_COMMENTS", "consent_comments", :value => "comments"
        end

        response_set.responses.reload
        response_set.responses.size.should == 9

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent.id)
        consent.consent_form_type.should == consent_form_type
        consent.consent_given.should == yes
        consent.consent_date.should == Date.parse(date)
        consent.consent_version.should == "version"
        consent.consent_expiration.should be_nil
        consent.who_consented.should == who
        consent.consent_language.should == en
        consent.consent_translate.should == no_trans
        consent.reconsideration_script_use.should == no2
        consent.consent_comments.should == "comments"
      end

      it "sets the ParticipantConsentSample attributes to the Response values" do
        consent = prepare_consent(person, participant, survey, contact)
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_1", yes
          r.a "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_2", no
          r.a "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_3", yes
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent.id)
        [ [1, yes], [2, no], [3, yes] ].each do |code, val|
          consent.participant_consent_samples.where(:sample_consent_type_code => code).all.each do |s|
            s.sample_consent_given.should == val
          end
        end
      end

      context "when consent given" do
        it "updates the enrollment status on the participant to true" do
          participant.should_not be_enrolled

          consent = prepare_consent(person, participant, survey, contact)
          response_set = consent.response_set

          take_survey(survey, response_set) do |r|
            r.a "PARTICIPANT_CONSENT.CONSENT_GIVEN_CODE", yes
            r.a "PARTICIPANT_CONSENT.CONSENT_DATE", "consent_date", :value => date
          end

          response_set.responses.reload
          response_set.responses.size.should == 2

          OperationalDataExtractor::InformedConsent.new(response_set).extract_data

          consent = ParticipantConsent.find(consent.id)
          consent.consent_given.should == yes

          consent.participant.should be_enrolled
          consent.participant.enroll_date.should == Date.parse(date)
        end
      end

      context "when consent is not given" do
        it "updates the enrollment status on the participant to false" do
          participant.should_not be_enrolled

          consent = prepare_consent(person, participant, survey, contact)
          response_set = consent.response_set

          take_survey(survey, response_set) do |r|
            r.a "PARTICIPANT_CONSENT.CONSENT_GIVEN_CODE", no
            r.a "PARTICIPANT_CONSENT.CONSENT_DATE", "consent_date", :value => date
          end

          response_set.responses.reload
          response_set.responses.size.should == 2

          OperationalDataExtractor::InformedConsent.new(response_set).extract_data

          consent = ParticipantConsent.find(consent.id)
          consent.consent_given.should == no

          consent.participant.should be_unenrolled
          consent.participant.enroll_date.should be_nil
        end
      end

    end
  end

  context "with a Withdrawal survey" do

    let(:wdraw1) { NcsCode.for_list_name_and_local_code("CONSENT_WITHDRAW_REASON_CL1", 1) }
    let(:wdraw2) { NcsCode.for_list_name_and_local_code("CONSENT_WITHDRAW_REASON_CL2", 7) }
    let(:who) { NcsCode.for_list_name_and_local_code("AGE_STATUS_CL3", 2) }

    before do
      f = "#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb"
      Surveyor::Parser.parse File.read(f)
    end

    describe "extracting ParticipantConsent data" do
      let!(:consent) { prepare_consent(person, participant, survey, contact) }
      let(:response_set) { consent.response_set }

      before do
        take_survey(survey, response_set) do |r|
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_CODE", yes
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_TYPE_CODE", wdraw1
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_REASON_CODE", wdraw2
          r.a "PARTICIPANT_CONSENT.WHO_WITHDREW_CONSENT", who
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_DATE", "consent_withdraw_date", :value => date
        end
        response_set.responses.reload
        response_set.responses.size.should == 5
        OperationalDataExtractor::InformedConsent.new(response_set).extract_data
      end

      it "sets the ParticipantConsent attributes to the Response values" do
        c = ParticipantConsent.find(consent.id)
        c.consent_withdraw.should == yes
        c.consent_withdraw_type.should == wdraw1
        c.consent_withdraw_reason.should == wdraw2
        c.consent_withdraw_date.should == Date.parse(date)
        c.who_wthdrw_consent.should == who
      end

      it "updates the enrollment status" do
        c = ParticipantConsent.find(consent.id)
        c.participant.should be_unenrolled
        c.participant.enroll_date.should be_nil
      end

      it "creates a withdrawn ppg status history record" do
        pt = Participant.find consent.participant.id
        pt.ppg_status_histories.last.ppg_status_code.should == PpgStatusHistory::WITHDRAWN
      end

    end
  end

  context "with a Reconsent survey" do

    let(:reason) { NcsCode.for_list_name_and_local_code("CONSENT_RECONSENT_REASON_CL1", 9) }

    before do
      f = "#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb"
      Surveyor::Parser.parse File.read(f)
    end

    describe "extracting ParticipantConsent data" do

      it "sets the ParticipantConsent attributes to the Response values" do
        consent = prepare_consent(person, participant, survey, contact)
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "PARTICIPANT_CONSENT.CONSENT_RECONSENT_CODE", yes
          r.a "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_CODE", reason
          r.a "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_OTHER", "consent_reconsent_reason_other", :value => "other"
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent.id)
        consent.consent_reconsent.should == yes
        consent.consent_reconsent_reason.should == reason
        consent.consent_reconsent_reason_other.should == "other"
      end

      describe "not giving consent" do
        let!(:consent) { prepare_consent(person, participant, survey, contact) }
        let(:response_set) { consent.response_set }

        before do
          take_survey(survey, response_set) do |r|
            r.a "PARTICIPANT_CONSENT.CONSENT_GIVEN_CODE", no
            r.a "PARTICIPANT_CONSENT.CONSENT_RECONSENT_CODE", yes
            r.a "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_CODE", reason
            r.a "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_OTHER", "consent_reconsent_reason_other", :value => "other"
          end

          response_set.responses.reload
          response_set.responses.size.should == 4

          OperationalDataExtractor::InformedConsent.new(response_set).extract_data
        end

        it "updates the enrollment status" do
          c = ParticipantConsent.find(consent.id)
          c.participant.should be_unenrolled
          c.participant.enroll_date.should be_nil
        end

        it "creates a withdrawn ppg status history record" do
          pt = Participant.find consent.participant.id
          pt.ppg_status_histories.last.ppg_status_code.should == PpgStatusHistory::WITHDRAWN
        end

      end

    end
  end

end
