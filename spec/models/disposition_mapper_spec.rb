# -*- coding: utf-8 -*-


require 'spec_helper'

describe DispositionMapper do

  it "gets all the disposition options grouped by event" do
    grouped_options = DispositionMapper.get_grouped_options

    grouped_options.keys.each {|k| DispositionMapper::EVENTS.should include(k) }
  end

  it "returns only the disposition options for the given event" do
    grouped_options = DispositionMapper.get_grouped_options("General Study Visit Event")
    grouped_options.keys.size.should == 1
    grouped_options.keys.should == ["General Study Visit Event"]
  end

  it "returns the category by for_event_disposition_category_code" do
    [
      [1, DispositionMapper::HOUSEHOLD_ENUMERATION_EVENT],
      [2, DispositionMapper::PREGNANCY_SCREENER_EVENT],
      [3, DispositionMapper::GENERAL_STUDY_VISIT_EVENT],
      [4, DispositionMapper::MAILED_BACK_SAQ_EVENT],
      [5, DispositionMapper::TELEPHONE_INTERVIEW_EVENT],
      [6, DispositionMapper::INTERNET_SURVEY_EVENT],
      [7, DispositionMapper::PROVIDER_RECRUITMENT_EVENT],
      [8, DispositionMapper::PBS_ELIGIBILITY_EVENT],
      [0, DispositionMapper::GENERAL_STUDY_VISIT_EVENT]
    ].each do |code, expected|
      DispositionMapper.for_event_disposition_category_code(code).should == expected
    end

  end

  describe "#determine_event" do

    describe "when given 'INS_QUE_PregScreen_'" do
      it "returns PREGNANCY_SCREENER_EVENT" do
        DispositionMapper.determine_event('INS_QUE_PregScreen_').should ==
          DispositionMapper::PREGNANCY_SCREENER_EVENT
      end
    end

    describe "when given 'Telephone'" do
      it "returns TELEPHONE_INTERVIEW_EVENT" do
        DispositionMapper.determine_event('Telephone').should ==
          DispositionMapper::TELEPHONE_INTERVIEW_EVENT
      end
    end

    describe "when given 'Text Message'" do
      it "returns TELEPHONE_INTERVIEW_EVENT" do
        DispositionMapper.determine_event('Text Message').should ==
          DispositionMapper::TELEPHONE_INTERVIEW_EVENT
      end
    end

    describe "when given 'Mail'" do
      it "returns MAILED_BACK_SAQ_EVENT" do
        DispositionMapper.determine_event('Mail').should ==
          DispositionMapper::MAILED_BACK_SAQ_EVENT
      end
    end

    describe "when given 'Some_SAQ_'" do
      it "returns MAILED_BACK_SAQ_EVENT" do
        DispositionMapper.determine_event('Some_SAQ_').should ==
          DispositionMapper::MAILED_BACK_SAQ_EVENT
      end
    end

    describe "when given 'Some_HHEnum_'" do
      it "returns HOUSEHOLD_ENUMERATION_EVENT" do
        DispositionMapper.determine_event('Some_HHEnum_').should ==
          DispositionMapper::HOUSEHOLD_ENUMERATION_EVENT
      end
    end

    describe "when given 'anything else'" do
      it "returns GENERAL_STUDY_VISIT_EVENT" do
        DispositionMapper.determine_event('anything else').should ==
          DispositionMapper::GENERAL_STUDY_VISIT_EVENT
      end
    end

  end

  context "determining the event given a contact type" do
    it "handles Telephone" do
      grouped_options = DispositionMapper.get_grouped_options("Telephone")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Telephone Interview Event"]
    end

    it "handles Mail" do
      grouped_options = DispositionMapper.get_grouped_options("Mail")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Mailed Back SAQ Event"]
    end
  end

  context "determining the event given a survey title" do
    it "handles Household Enumeration Surveys" do
      grouped_options = DispositionMapper.get_grouped_options("INS_QUE_HHEnum_INT_EH_P2_V1.2")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Household Enumeration Event"]
    end

    it "handles Pregnancy Screener Surveys" do
      grouped_options = DispositionMapper.get_grouped_options("INS_QUE_PregScreen_INT_HILI_P2_V2.0")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Pregnancy Screener Event"]
    end
  end

  context "determining disposition for an event" do

    before(:each) do
      @general_study = NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 3)
      @pregnancy_screen = NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 2)
    end

    describe "#get_key_from_event_disposition_category" do

      it "finds GENERAL_STUDY_VISIT_EVENT" do
        DispositionMapper.get_key_from_event_disposition_category(@general_study).should == DispositionMapper::GENERAL_STUDY_VISIT_EVENT
      end

      it "finds PREGNANCY_SCREENER_EVENT" do
        DispositionMapper.get_key_from_event_disposition_category(@pregnancy_screen).should == DispositionMapper::PREGNANCY_SCREENER_EVENT
      end
    end

    describe "#disposition_text" do

      it "returns the given disposition code if no event disposition category given" do
        DispositionMapper.disposition_text(nil, 55).should == 55
      end

      it "returns the disposition text for a matching event disposition category and code" do
        DispositionMapper.disposition_text(@general_study, 55).should == "Eligible Non-response- Other"
        DispositionMapper.disposition_text(@general_study, 16).should == "Participant incarcerated"
      end

    end

  end


  context "determining disposition for a contact" do

    describe "#disposition_text_for_contact" do

      describe "when no event is provided" do

        let(:contact_disposition) { 55 }

        describe "for a mailing contact" do
          it "returns the disposition text for the contact type" do
            contact = Factory(:contact, :contact_type_code => Contact::MAILING_CONTACT_CODE, :contact_disposition => contact_disposition)
            DispositionMapper.disposition_text_for_contact(contact).should == "Partial with sufficient information in Other Language"
          end
        end

        describe "for a telephone contact" do
          it "returns the disposition text for the contact type" do
            contact = Factory(:contact, :contact_type_code => Contact::TELEPHONE_CONTACT_CODE, :contact_disposition => contact_disposition)
            DispositionMapper.disposition_text_for_contact(contact).should == "Unknown if participant is a household resident"
          end
        end

        describe "for an in person contact" do
          it "returns the disposition text for the contact type" do
            contact = Factory(:contact, :contact_type_code => Contact::IN_PERSON_CONTACT_CODE, :contact_disposition => contact_disposition)
            DispositionMapper.disposition_text_for_contact(contact).should == "Eligible Non-response- Other"
          end
        end

        it "returns the raw disposition if contact type is missing" do
          contact = Factory(:contact, :contact_type_code => nil, :contact_disposition => 55)
          DispositionMapper.disposition_text_for_contact(contact).should == 55
        end
      end

      describe "when event /is/ provided" do

        let(:contact_disposition) { 11 }

        it "returns the disposition text if the event type determines the disposition category" do
          event = Factory(:event, :event_type_code => Event::pbs_eligibility_screener_code)
          contact = Factory(:contact, :contact_type_code => Contact::IN_PERSON_CONTACT_CODE, :contact_disposition => contact_disposition)
          DispositionMapper.disposition_text_for_contact(contact, event).should == "Patient does not meet one or more of the eligibility criteria"
        end

        it "returns the disposition text based on contact type" do
          event = Factory(:event, :event_type_code => Event::pregnancy_visit_1_code)
          contact = Factory(:contact, :contact_type_code => Contact::IN_PERSON_CONTACT_CODE, :contact_disposition => contact_disposition)
          DispositionMapper.disposition_text_for_contact(contact, event).should == "Participant deceased"
        end

      end

    end

  end


  describe "#determine_category_from_event_type(event_type)" do

    it "returns nil if given nil" do
      DispositionMapper.determine_category_from_event_type(nil).should be_nil
    end

    it "returns NcsCode EVENT_DSPSTN_CAT_CL1 1 for a Household Enumeration Event" do
      ncs_code = DispositionMapper.determine_category_from_event_type(
        Event.household_enumeration_code)
      ncs_code.list_name.should == 'EVENT_DSPSTN_CAT_CL1'
      ncs_code.local_code.should == 1
    end

    it "returns NcsCode EVENT_DSPSTN_CAT_CL1 2 for a Pregnancy Screener Event" do
      DispositionMapper.determine_category_from_event_type(
        Event.pregnancy_screener_code).local_code.should == 2
    end

    it "returns NcsCode EVENT_DSPSTN_CAT_CL1 7 for a Provider Recruitment Event" do
      DispositionMapper.determine_category_from_event_type(
        Event.provider_recruitment_code).local_code.should == 7
    end

    it "returns NcsCode EVENT_DSPSTN_CAT_CL1 8 for a PBS Eligibility Screener Event" do
      DispositionMapper.determine_category_from_event_type(
        Event.pbs_eligibility_screener_code).local_code.should == 8
    end

    it "returns nil for post-natal events" do
      DispositionMapper.determine_category_from_event_type(
        Event.birth_code).should be_nil
    end

    it "returns nil for Participant focused events" do
      DispositionMapper.determine_category_from_event_type(
        Event.pregnancy_visit_1_code).should be_nil
    end

    it "returns nil for a invalid event type code" do
      DispositionMapper.determine_category_from_event_type(
        666).should be_nil
    end

  end


end
