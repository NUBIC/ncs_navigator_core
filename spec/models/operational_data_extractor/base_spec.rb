# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::Base do

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

  describe "determining the proper data extractor to use" do
    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }

    context "with a pregnancy screener instrument" do
      it "chooses the OperationalDataExtractor::PregnancyScreener" do
        survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::PregnancyScreener
      end
    end

    context "with a pregnancy probability instrument" do
      it "chooses the OperationalDataExtractor::PpgFollowUp" do
        survey = create_follow_up_survey_with_ppg_status_history_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::PpgFollowUp
      end
    end

    context "with a pre pregnancy instrument" do
      it "chooses the OperationalDataExtractor::PrePregnancy" do
        survey = create_pre_pregnancy_survey_with_person_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::PrePregnancy
      end
    end

    context "with a pregnancy visit instrument" do
      it "chooses the OperationalDataExtractor::PregnancyVisit" do
        survey = create_pregnancy_visit_1_survey_with_person_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::PregnancyVisit
      end
    end

    context "with a birth visit instrument" do
      it "chooses the OperationalDataExtractor::Birth" do
        survey = create_birth_survey_with_child_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::Birth
      end
    end

    context "with a lo i pregnancy screener instrument" do
      it "chooses the OperationalDataExtractor::LowIntensityPregnancyVisit" do
        survey = create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::LowIntensityPregnancyVisit
      end
    end

    context "with an adult blood instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_adult_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::Specimen
      end
    end

    context "with an adult urine instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_adult_urine_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::Specimen
      end
    end

    context "with a cord blood instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_cord_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::Specimen
      end
    end

    context "with a tap water instrument" do
      it "chooses the OperationalDataExtractor::Sample" do
        survey = create_tap_water_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::Sample
      end
    end

    context "with a vacuum bag dust instrument" do
      it "chooses the OperationalDataExtractor::Sample" do
        survey = create_vacuum_bag_dust_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.should == OperationalDataExtractor::Sample
      end
    end

  end

  context "processing the response set" do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      question = Factory(:question, :data_export_identifier => "PREG_SCREEN_HI_2.HOME_PHONE")
      answer = Factory(:answer, :response_class => "string")
      home_phone_response = Factory(:response, :string_value => "3125551212", :question => question, :answer => answer, :response_set => @response_set)

      @response_set.responses << home_phone_response
    end

    describe "#process" do

      before(:each) do
        OperationalDataExtractor::Base.process(@response_set)
      end

      it "creates only one data record for the extracted data" do
        person = Person.find(@person.id)
        phones = person.telephones
        phones.should_not be_empty
        phones.size.should == 1
        phones.first.phone_nbr.should == "3125551212"

        OperationalDataExtractor::Base.process(@response_set)
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

        OperationalDataExtractor::Base.process(@response_set)
        person = Person.find(@person.id)
        person.telephones.should == phones
        person.telephones.first.phone_nbr.should == "3125556789"
      end

    end

  end

end
