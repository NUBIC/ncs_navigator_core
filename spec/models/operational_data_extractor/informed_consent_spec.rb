# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::InformedConsent do
  include SurveyCompletion

  let(:person) { Factory(:person) }
  let(:participant) { Factory(:participant) }
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
    end
  end

  context "with a Withdrawal survey" do

    let(:wdraw1) { NcsCode.for_list_name_and_local_code("CONSENT_WITHDRAW_REASON_CL1", 1) }
    let(:wdraw2) { NcsCode.for_list_name_and_local_code("CONSENT_WITHDRAW_REASON_CL2", 7) }

    before do
      f = "#{Rails.root}/internal_surveys/IRB_CON_Withdrawal.rb"
      Surveyor::Parser.parse File.read(f)
    end

    describe "extracting ParticipantConsent data" do

      it "sets the ParticipantConsent attributes to the Response values" do
        consent = prepare_consent(person, participant, survey, contact)
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_CODE", yes
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_TYPE_CODE", wdraw1
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_REASON_CODE", wdraw2
          r.a "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_DATE", "consent_date", :value => date
        end

        response_set.responses.reload
        response_set.responses.size.should == 4

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent.id)
        consent.consent_withdraw.should == yes
        consent.consent_withdraw_type.should == wdraw1
        consent.consent_withdraw_reason.should == wdraw2
        consent.consent_withdraw_date.should == Date.parse(date)
      end
    end
  end

  context "with a Reconsent survey" do

    let(:reason) { NcsCode.for_list_name_and_local_code("CONSENT_RECONSENT_REASON_CL1", 9) }

    before do
      f = "#{Rails.root}/internal_surveys/IRB_CON_Reconsent.rb"
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
    end
  end

end
