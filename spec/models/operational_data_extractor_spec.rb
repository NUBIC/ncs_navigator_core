# encoding: utf-8

require 'spec_helper'

describe OperationalDataExtractor do

  before(:each) do
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Address)
    create_missing_in_error_ncs_codes(DwellingUnit)
    create_missing_in_error_ncs_codes(Telephone)
    create_missing_in_error_ncs_codes(Email)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(PpgDetail)
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  end

  it "sets up the test properly" do

    person = Factory(:person)
    survey = create_pregnancy_screener_survey_with_person_operational_data

    survey.sections.size.should == 1
    survey.sections.first.questions.size.should == 9

    survey.sections.first.questions.each do |q|
      case q.reference_identifier
      when "R_FNAME", "R_LNAME", "AGE", "PERSON_DOB"
        q.answers.size.should == 3
      when "AGE_RANGE"
        q.answers.size.should == 9
      when "ETHNICITY"
        q.answers.size.should == 2
      when "PERSON_LANG"
        q.answers.size.should == 3
      when "PERSON_LANG_OTH"
        q.answers.size.should == 1
      end
    end

  end

  it "determines the proper data extractor to use" do
    person = Factory(:person)
    survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    handler = OperationalDataExtractor.extractor_for(response_set)
    handler.should == PregnancyScreenerOperationalDataExtractor

    survey = create_follow_up_survey_with_ppg_status_history_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    handler = OperationalDataExtractor.extractor_for(response_set)
    handler.should == PpgFollowUpOperationalDataExtractor

    survey = create_pre_pregnancy_survey_with_person_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    handler = OperationalDataExtractor.extractor_for(response_set)
    handler.should == PrePregnancyOperationalDataExtractor

    survey = create_pregnancy_visit_1_survey_with_person_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    handler = OperationalDataExtractor.extractor_for(response_set)
    handler.should == PregnancyVisitOperationalDataExtractor

    survey = create_birth_survey_with_child_operational_data
    response_set, instrument = person.start_instrument(survey)
    handler = OperationalDataExtractor.extractor_for(response_set)
    handler.should == BirthOperationalDataExtractor

    survey = create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data
    response_set, instrument = person.start_instrument(survey)
    handler = OperationalDataExtractor.extractor_for(response_set)
    handler.should == LowIntensityPregnancyVisitOperationalDataExtractor

  end

  context "processing the response set" do

    before(:each) do
      @person = Factory(:person)
      @survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
      @response_set, @instrument = prepare_instrument(@person, @survey)
      question = Factory(:question, :data_export_identifier => "PREG_SCREEN_HI_2.HOME_PHONE")
      answer = Factory(:answer, :response_class => "string")
      home_phone_response = Factory(:response, :string_value => "3125551212", :question => question, :answer => answer, :response_set => @response_set)

      Factory(:ncs_code, :list_name => "ADDRESS_CATEGORY_CL1", :local_code => 1, :display_text => "Home")
      Factory(:ncs_code, :list_name => "ADDRESS_CATEGORY_CL1", :local_code => 4, :display_text => "Mail")

      Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :local_code => 1, :display_text => "Home")
      Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :local_code => 3, :display_text => "Cell")

      @response_set.responses << home_phone_response
    end

    describe "#process" do

      before(:each) do
        OperationalDataExtractor.process(@response_set)
      end

      it "creates only one data record for the extracted data" do
        person = Person.find(@person.id)
        phones = person.telephones
        phones.should_not be_empty
        phones.size.should == 1
        phones.first.phone_nbr.should == "3125551212"

        OperationalDataExtractor.process(@response_set)
        person = Person.find(@person.id)
        person.telephones.should == phones
        person.telephones.first.phone_nbr.should == "3125551212"
      end

      it "updates one data record if re-processed" do
        person = Person.find(@person.id)
        phones = person.telephones
        phones.should_not be_empty
        phones.size.should == 1
        phones.first.phone_nbr.should == "3125551212"

        @response_set.responses.first.string_value = "3125556789"

        OperationalDataExtractor.process(@response_set)
        person = Person.find(@person.id)
        person.telephones.should == phones
        person.telephones.first.phone_nbr.should == "3125556789"
      end

    end

  end

end