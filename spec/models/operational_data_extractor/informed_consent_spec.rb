# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::InformedConsent do
  include SurveyCompletion

  let(:person) { Factory(:person) }
  let(:participant) { Factory(:participant, :enroll_status_code => -4, :enroll_date => nil) }
  let(:survey) do
    Surveyor::Parser.parse File.read("#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb")
    Survey.last
  end
  let(:contact) { Factory(:contact) }
  let(:event) { Factory(:event, :event_type_code => 10) } # informed consent event
  let(:contact_link) { Factory(:contact_link, :contact => contact, :person => person, :event => event) }

  let!(:consent) { prepare_consent(person, participant, survey, contact, contact_link) }
  let(:consent_id) { consent.id }

  let(:consent_form_type) { NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL3", 1) }
  let(:yes) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 1) }
  let(:no) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 2) }
  let(:yes21) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL21", 1) }
  let(:no21) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL21", 2) }
  let(:date) { "2525-12-12" }
  let(:who) { NcsCode.for_list_name_and_local_code("AGE_STATUS_CL1", 2) }
  let(:en) { NcsCode.for_list_name_and_local_code("LANGUAGE_CL2", 1) }
  let(:no_trans) { NcsCode.for_list_name_and_local_code("TRANSLATION_METHOD_CL1", 1) }

  context "with an InformedConsent survey" do

    describe "a response set without an associated consent" do
      it "should raise an InvalidSurveyException" do
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "consent_given_code", yes
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
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "consent_form_type_code", consent_form_type
          r.a "consent_given_code", yes
          r.a "consent_date", "consent_date", :value => date
          r.a "consent_version", "consent_version", :value => "version"
          r.a "who_consented_code", who
          r.a "consent_language_code", en
          r.a "consent_translate_code", no_trans
          r.a "reconsideration_script_use_code", no21
          r.a "consent_comments", "consent_comments", :value => "comments"
        end

        response_set.responses.reload
        response_set.responses.size.should == 9

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent_id)
        consent.consent_form_type.should == consent_form_type
        consent.consent_given.should == yes
        consent.consent_date.should == Date.parse(date)
        consent.consent_version.should == "version"
        consent.consent_expiration.should be_nil
        consent.who_consented.should == who
        consent.consent_language.should == en
        consent.consent_translate.should == no_trans
        consent.reconsideration_script_use.should == no21
        consent.consent_comments.should == "comments"
      end

      it "does not create ParticipantConsentSample records by default" do
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|

          r.a "sample_consent_given_code_1", yes21
          r.a "sample_consent_given_code_2", no21
          r.a "sample_consent_given_code_3", yes21
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent_id)
        consent.participant_consent_samples.should be_empty
      end

      it "sets the ParticipantConsentSample attributes to the Response values
          if collect_specimen_consent was answered in the affirmative" do
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "collect_specimen_consent", yes
          r.a "sample_consent_given_code_1", yes21
          r.a "sample_consent_given_code_2", no21
          r.a "sample_consent_given_code_3", yes21
        end

        response_set.responses.reload
        response_set.responses.size.should == 4

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent_id)
        consent.participant_consent_samples.size.should == 3
        [ [1, yes21], [2, no21], [3, yes21] ].each do |code, val|
          consent.participant_consent_samples.where(:sample_consent_type_code => code).all.each do |s|
            s.sample_consent_given.should == val
          end
        end
      end

      context "when consent given" do
        it "updates the enrollment status on the participant to true" do
          participant.should_not be_enrolled

          response_set = consent.response_set

          take_survey(survey, response_set) do |r|
            r.a "consent_given_code", yes
            r.a "consent_date", "consent_date", :value => date
          end

          response_set.responses.reload
          response_set.responses.size.should == 2

          OperationalDataExtractor::InformedConsent.new(response_set).extract_data

          consent = ParticipantConsent.find(consent_id)
          consent.consent_given.should == yes

          consent.participant.should be_enrolled
          consent.participant.enroll_date.should == Date.parse(date)
        end
      end

      context "when consent is not given" do
        it "updates the enrollment status on the participant to false" do
          participant.should_not be_enrolled

          response_set = consent.response_set

          take_survey(survey, response_set) do |r|
            r.a "consent_given_code", no
            r.a "consent_date", "consent_date", :value => date
          end

          response_set.responses.reload
          response_set.responses.size.should == 2

          OperationalDataExtractor::InformedConsent.new(response_set).extract_data

          consent = ParticipantConsent.find(consent_id)
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
      let(:response_set) { consent.response_set }
      before do
        take_survey(survey, response_set) do |r|
          r.a "consent_withdraw_code", yes
          r.a "consent_withdraw_type_code", wdraw1
          r.a "consent_withdraw_reason_code", wdraw2
          r.a "who_wthdrw_consent_code", who
          r.a "consent_withdraw_date", "consent_withdraw_date", :value => date
        end
        response_set.responses.reload
        response_set.responses.size.should == 5
        OperationalDataExtractor::InformedConsent.new(response_set).extract_data
      end

      it "sets the ParticipantConsent attributes to the Response values" do
        c = ParticipantConsent.find(consent_id)
        c.consent_withdraw.should == yes
        c.consent_withdraw_type.should == wdraw1
        c.consent_withdraw_reason.should == wdraw2
        c.consent_withdraw_date.should == Date.parse(date)
        c.who_wthdrw_consent.should == who
        c.person_wthdrw_consent.should == response_set.person
      end

      it "updates the enrollment status" do
        c = ParticipantConsent.find(consent_id)
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
        response_set = consent.response_set

        take_survey(survey, response_set) do |r|
          r.a "consent_reconsent_code", yes
          r.a "consent_reconsent_reason_code", reason
          r.a "consent_reconsent_reason_other", "consent_reconsent_reason_other", :value => "other"
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        OperationalDataExtractor::InformedConsent.new(response_set).extract_data

        consent = ParticipantConsent.find(consent_id)
        consent.consent_reconsent.should == yes
        consent.consent_reconsent_reason.should == reason
        consent.consent_reconsent_reason_other.should == "other"
      end

      describe "not giving consent" do
        let(:response_set) { consent.response_set }

        before do
          take_survey(survey, response_set) do |r|
            r.a "consent_given_code", no
            r.a "consent_reconsent_code", yes
            r.a "consent_reconsent_reason_code", reason
            r.a "consent_reconsent_reason_other", "consent_reconsent_reason_other", :value => "other"
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
