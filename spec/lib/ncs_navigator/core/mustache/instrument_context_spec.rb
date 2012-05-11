# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Mustache
  describe InstrumentContext do
    include SurveyCompletion

    it "should be a child of Mustache" do
      InstrumentContext.ancestors.should include(Mustache)
    end

    let(:baby_fname) { "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_FNAME" }
    let(:baby_sex)   { "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_SEX" }
    let(:multiple)   { "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MULTIPLE" }

    context "with a response set" do
      before(:each) do
        @person = Factory(:person)
        @survey = create_birth_survey_with_child_operational_data
        @response_set, @instrument = prepare_instrument(@person, @survey)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }

      describe ".initialize" do
        it "sets the response_set on the context" do
          instrument_context.response_set.should == @response_set
        end
      end

      describe ".response_for" do
        it "returns the value of the response for the given data_export_identifier" do
          take_survey(@survey, @response_set) do |a|
            a.str baby_fname, 'Mary'
          end
          instrument_context.response_for(baby_fname).should == 'Mary'
        end
      end

    end

    context "for a lo i birth instrument" do
      before(:each) do
        @person = Factory(:person)
        @survey = create_lo_i_birth_survey
        @response_set, @instrument = prepare_instrument(@person, @survey)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }

      describe ".birth_instrument_multiple_prefix" do
        it "returns BirthOperationalDataExtractor::BIRTH_LI_PREFIX" do
          instrument_context.birth_instrument_multiple_prefix.should ==
            BirthOperationalDataExtractor::BIRTH_LI_PREFIX
        end
      end

      describe ".birth_baby_name_prefix" do
        it "returns BirthOperationalDataExtractor::BABY_NAME_LI_PREFIX" do
          instrument_context.birth_baby_name_prefix.should ==
            BirthOperationalDataExtractor::BABY_NAME_LI_PREFIX
        end
      end

    end

    context "for a birth instrument" do
      before(:each) do
        @person = Factory(:person)
        @survey = create_birth_survey_with_child_operational_data
        @response_set, @instrument = prepare_instrument(@person, @survey)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }

      describe ".birth_instrument_multiple_prefix" do
        it "returns BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX" do
          instrument_context.birth_instrument_multiple_prefix.should ==
            BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX
        end
      end

      describe ".birth_baby_name_prefix" do
        it "returns BirthOperationalDataExtractor::BABY_NAME_PREFIX" do
          instrument_context.birth_baby_name_prefix.should ==
            BirthOperationalDataExtractor::BABY_NAME_PREFIX
        end
      end

      describe ".b_fname" do
        it "returns the entered first name of the baby" do
          set_first_name 'Mary'
          instrument_context.b_fname.should == 'Mary'
        end

        it "returns the generic 'your baby' if there is no response for the BABY_FNAME" do
          instrument_context.b_fname.should == 'your baby'
        end
      end

      describe ".single_birth" do
        it "returns true if mulitple is no" do
          create_single_birth
          instrument_context.single_birth?.should be_true
        end

        it "returns false if multiple is yes" do
          create_multiple_birth
          instrument_context.single_birth?.should be_false
        end

        it "returns true if there is no response for MULTIPLE" do
          instrument_context.single_birth?.should be_true
        end
      end

      describe ".baby_sex_response" do
        it "returns 'female' if BABY_SEX is 'Female'" do
          create_female_response
          instrument_context.baby_sex_response.should == 'female'
        end

        it "returns 'male' if BABY_SEX is 'Male'" do
          create_male_response
          instrument_context.baby_sex_response.should == 'male'
        end

        it "returns '' if there is no response for BABY_SEX" do
          instrument_context.baby_sex_response.should be_blank
        end
      end

      describe ".baby_babies" do
        it "returns 'baby' if unknown if single or multiple birth" do
          instrument_context.baby_babies.should == 'baby'
        end

        it "returns 'baby' if single birth" do
          create_single_birth
          instrument_context.baby_babies.should == 'baby'
        end

        it "returns 'babies' if multiple birth" do
          create_multiple_birth
          instrument_context.baby_babies.should == 'babies'
        end
      end

      describe ".babys_babies" do
        it "returns 'baby's' if unknown if single or multiple birth" do
          instrument_context.babys_babies.should == "baby's"
        end

        it "returns 'baby's' if single birth" do
          create_single_birth
          instrument_context.babys_babies.should == "baby's"
        end

        it "returns 'babies'' if multiple birth" do
          create_multiple_birth
          instrument_context.babys_babies.should == "babies'"
        end
      end

      describe ".b_fname_or_babies" do
        it "returns 'your baby' if unknown if single or multiple birth" do
          instrument_context.b_fname_or_babies.should == "your baby"
        end

        it "returns entered first name if single birth" do
          create_single_birth
          set_first_name 'Mary'
          instrument_context.b_fname_or_babies.should == "Mary"
        end

        it "returns 'your babies' if multiple birth" do
          create_multiple_birth
          instrument_context.b_fname_or_babies.should == "your babies"
        end
      end

      describe ".do_does" do
        it "returns 'Does' if unknown if single or multiple birth" do
          instrument_context.do_does.should == "Does"
        end

        it "returns 'Does if single birth" do
          create_single_birth
          instrument_context.do_does.should == "Does"
        end

        it "returns 'Do' if multiple birth" do
          create_multiple_birth
          instrument_context.do_does.should == "Do"
        end
      end

      describe ".do_does_downcase" do
        it "returns 'does' if unknown if single or multiple birth" do
          instrument_context.do_does_downcase.should == "does"
        end

        it "returns 'does if single birth" do
          create_single_birth
          instrument_context.do_does_downcase.should == "does"
        end

        it "returns 'do' if multiple birth" do
          create_multiple_birth
          instrument_context.do_does_downcase.should == "do"
        end
      end

      describe ".he_she_they" do

        it "returns 'they' if multiple birth" do
          create_multiple_birth
          instrument_context.he_she_they.should == "they"
        end

        it "returns 'he' if male and single birth" do
          create_single_birth
          create_male_response
          instrument_context.he_she_they.should == "he"
        end

        it "returns 'she' if female and single birth" do
          create_single_birth
          create_female_response
          instrument_context.he_she_they.should == "she"
        end

        it "returns 'he/she' if no sex response and single birth" do
          create_single_birth
          instrument_context.he_she_they.should == "he/she"
        end

        it "returns 'he/she' if no sex response and unknown if single or multiple birth" do
          instrument_context.he_she_they.should == "he/she"
        end

      end

      describe ".his_her_their" do

        it "returns 'their' if multiple birth" do
          create_multiple_birth
          instrument_context.his_her_their.should == "their"
        end

        it "returns 'his' if male and single birth" do
          create_single_birth
          create_male_response
          instrument_context.his_her_their.should == "his"
        end

        it "returns 'her' if female and single birth" do
          create_single_birth
          create_female_response
          instrument_context.his_her_their.should == "her"
        end

        it "returns 'his/her' if no sex response and single birth" do
          create_single_birth
          instrument_context.his_her_their.should == "his/her"
        end

        it "returns 'his/her' if no sex response and unknown if single or multiple birth" do
          instrument_context.his_her_their.should == "his/her"
        end

      end

      describe ".he_she" do

        it "returns 'he' if male" do
          create_male_response
          instrument_context.he_she.should == "he"
        end

        it "returns 'she' if female" do
          create_female_response
          instrument_context.he_she.should == "she"
        end

        it "returns 'he/she' if no sex response" do
          instrument_context.he_she.should == "he/she"
        end

      end

    end

    def create_single_birth
      take_survey(@survey, @response_set) do |a|
        a.no multiple
      end
    end

    def create_multiple_birth
      take_survey(@survey, @response_set) do |a|
        a.yes multiple
      end
    end

    def create_male_response
      @male = NcsCode.for_list_name_and_local_code("GENDER_CL1", 1)
      take_survey(@survey, @response_set) do |a|
        a.choice(baby_sex, @male)
      end
    end

    def create_female_response
      @female = NcsCode.for_list_name_and_local_code("GENDER_CL1", 2)
      take_survey(@survey, @response_set) do |a|
        a.choice(baby_sex, @female)
      end
    end

    def set_first_name first_name
      take_survey(@survey, @response_set) do |a|
        a.str baby_fname, first_name
      end
    end
  end
end