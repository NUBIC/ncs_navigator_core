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

    let(:multiple_gestation) { "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.MULTIPLE_GESTATION" }

    context "without a response set" do

      let(:instrument_context) { InstrumentContext.new }

      describe ".last_year" do
        it "returns the last_year as a string" do
          instrument_context.last_year.should == (Time.now.year - 1).to_s
        end
      end

      describe ".thirty_days_ago" do
        it "returns 30 days ago in format MM/DD/YYYY" do
          instrument_context.thirty_days_ago.should == 30.days.ago.strftime("%m/%d/%Y")
        end
      end

    end

    context "configured information" do

      let(:instrument_context) { InstrumentContext.new }
      let(:sc_config) { NcsNavigator.configuration.core }

      describe ".local_study_affiliate" do
        it "returns the configured study center name" do
          instrument_context.local_study_affiliate.should == sc_config["study_center_name"]
        end
      end

      describe ".toll_free_number" do
        it "returns the configured toll free number" do
          instrument_context.toll_free_number.should == sc_config["toll_free_number"]
        end
      end

      describe ".local_age_of_majority" do
        it "returns the configured local_age_of_majority" do
          instrument_context.local_age_of_majority.should == sc_config["local_age_of_majority"]
        end
      end

    end

    context "setting the current_user" do

      let(:instrument_context) { InstrumentContext.new }
      let(:usr) { usr = mock(Aker::User, :full_name => "Fred Sanford", :username => "fgs") }

      describe ".current_user" do
        it "sets the current_user" do
          instrument_context.current_user = usr
          instrument_context.current_user.should == usr
        end
      end

      describe ".interviewer_name" do

        it "returns the current_user.full_name if current_user is set" do
          instrument_context.current_user = usr
          instrument_context.interviewer_name.should == usr.full_name
        end

        it "returns '[INTERVIEWER NAME]' if current_user is not set" do
          instrument_context.interviewer_name.should == "[INTERVIEWER NAME]"
        end
      end

    end

    context "obtaining information from the person taking the survey" do

      describe ".p_primary_address" do

        it "returns \"[What is your street address?]\" if the person has no primary address" do
          person = mock_model(Person, :primary_address => nil)
          rs = mock_model(ResponseSet, :person => person)
          InstrumentContext.new(rs).p_primary_address.should == "[What is your street address?]"
        end

        it "returns the primary address" do
          address = mock_model(Address, :to_s => "123 Easy Street")
          person = mock_model(Person, :primary_address => address)
          rs = mock_model(ResponseSet, :person => person)
          InstrumentContext.new(rs).p_primary_address.should ==
            "Let me confirm your street address. I have it as #{address.to_s}."
        end
      end

      describe ".p_phone_number" do

        let(:home_phone) { "312-555-1234" }
        let(:cell_phone) { "312-555-9999" }

        it "returns nil if there is no person" do
          InstrumentContext.new.p_phone_number.should be_nil
        end

        it "returns nil if the person has no primary home phone or cell phone" do
          person = mock_model(Person, :primary_home_phone => nil, :primary_cell_phone => nil)
          rs = mock_model(ResponseSet, :person => person)
          InstrumentContext.new(rs).p_phone_number.should be_nil
        end

        it "returns the primary home phone" do
          person = mock_model(Person, :primary_home_phone => home_phone, :primary_cell_phone => nil)
          rs = mock_model(ResponseSet, :person => person)
          InstrumentContext.new(rs).p_phone_number.should == home_phone
        end

        it "returns the primary cell phone" do
          person = mock_model(Person, :primary_home_phone => nil, :primary_cell_phone => cell_phone)
          rs = mock_model(ResponseSet, :person => person)
          InstrumentContext.new(rs).p_phone_number.should == cell_phone
        end

        it "prefers the primary home phone" do
          person = mock_model(Person, :primary_home_phone => home_phone, :primary_cell_phone => cell_phone)
          rs = mock_model(ResponseSet, :person => person)
          InstrumentContext.new(rs).p_phone_number.should == home_phone
        end
      end

    end

    context "with a response set" do
      before(:each) do
        setup_survey_instrument(create_birth_survey_with_child_operational_data)
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
        setup_survey_instrument(create_lo_i_birth_survey)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }

      describe ".multiple_birth_prefix" do
        it "returns BirthOperationalDataExtractor::BIRTH_LI_PREFIX" do
          instrument_context.multiple_birth_prefix.should ==
            BirthOperationalDataExtractor::BIRTH_LI_PREFIX
        end
      end

      describe ".multiple_identifier" do
        it "returns MULTIPLE" do
          instrument_context.multiple_identifier.should == "MULTIPLE"
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
        setup_survey_instrument(create_birth_survey_with_child_operational_data)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }

      describe ".multiple_birth_prefix" do
        it "returns BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX" do
          instrument_context.multiple_birth_prefix.should ==
            BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX
        end
      end

      describe ".multiple_identifier" do
        it "returns MULTIPLE" do
          instrument_context.multiple_identifier.should == "MULTIPLE"
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

    context "for a pregnancy visit one saq" do
      before(:each) do
        setup_survey_instrument(create_pregnancy_visit_1_saq_with_father_data)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }


      describe ".f_fname" do
        it "returns the entered father's first name" do
          take_survey(@survey, @response_set) do |a|
            a.str "PREG_VISIT_1_SAQ_2.FATHER_NAME", 'Fred Sanford'
          end
          instrument_context.f_fname.should == "Fred"
        end

        it "returns 'the father' if no name entered" do
          instrument_context.f_fname.should == "the father"
        end

      end

    end

    context "for a pregnancy visit one instrument" do
      before(:each) do
        setup_survey_instrument(create_pregnancy_visit_1_survey_with_person_operational_data)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }

      describe ".multiple_birth_prefix" do
        it "returns PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX" do
          instrument_context.multiple_birth_prefix.should ==
            PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX
        end
      end

      describe ".multiple_identifier" do
        it "returns MULTIPLE_GESTATION" do
          instrument_context.multiple_identifier.should == "MULTIPLE_GESTATION"
        end
      end

      describe ".baby_babies" do
        it "returns 'baby' if unknown if single or multiple gestation" do
          instrument_context.baby_babies.should == 'baby'
        end

        it "returns 'baby' if singleton gestation" do
          create_singleton_gestation
          instrument_context.baby_babies.should == 'baby'
        end

        it "returns 'babies' if twin gestation" do
          create_twin_gestation
          instrument_context.baby_babies.should == 'babies'
        end

        it "returns 'babies' if triplet or higher gestation" do
          create_triplet_gestation
          instrument_context.baby_babies.should == 'babies'
        end
      end

      describe ".has_baby_have_babies" do
        it "returns 'Has the baby' if unknown if single or multiple gestation" do
          instrument_context.has_baby_have_babies.should == 'Has the baby'
        end

        it "returns 'Has the baby' if singleton gestation" do
          create_singleton_gestation
          instrument_context.has_baby_have_babies.should == 'Has the baby'
        end

        it "returns 'Have the babies' if twin gestation" do
          create_twin_gestation
          instrument_context.has_baby_have_babies.should == 'Have the babies'
        end

        it "returns 'Have the babies' if triplet or higher gestation" do
          create_triplet_gestation
          instrument_context.has_baby_have_babies.should == 'Have the babies'
        end
      end

      describe ".p_full_name" do
        it "returns the full name of the person taking the survey" do
          instrument_context.p_full_name.should == @person.full_name
        end
      end

      describe ".p_dob" do
        it "returns the date of birth of the person taking the survey" do
          instrument_context.p_dob.should == @person.person_dob
        end
      end

      describe ".at_this_visit_or_at" do
        it "returns \"at_this_visit_or_at\"" do
          instrument_context.at_this_visit_or_at.should == "at_this_visit_or_at"
        end
      end

      describe ".work_place_name" do
        it "returns the name of the participant's workplace" do
          pending
        end
      end

      describe ".work_address" do
        it "returns the participant's workplace address" do
          pending
        end
      end

      describe ".visit_today" do
        it "returns 'Is your visit today' if MODE = CAPI or PAPI" do
          pending
        end

        it "returns 'Was your visit today' if MODE = CATI"  do
          pending
        end
      end

      describe ".institution" do
        it "returned the name of the institution involved in the study" do
          pending
        end
      end

      describe ".practice_name" do
        it "returns the practice associated with the study" do
          pending
        end
      end

      describe ".county" do
        it "returns the county associated with the study" do
          pending
        end
      end

      describe ".birthing_place" do
        it "returns the type of facility where the child was birthed" do
          pending
        end
      end

      describe ".stomach_back_side" do
        it "returns singular version if single pregnancy" do
          pending
        end
        it "returns plural version if multiple pregnancy" do
          pending
        end
      end

      describe ".date_of_preg_visit_1" do
        it "returns the date the PregVisit1 instrument was last administered" do
          pending
        end
      end

      describe ".date_of_preg_visit_2" do
        it "returns the date the PregVisit2 instrument was last administered" do
          pending
        end
      end
    end

    describe "choose_date_range_for_birth_instrument" do
      it "returns proper range depending on whether PregVisit1 or 2 have been administered" do
        pending
      end
    end

    describe "choose_date_range_for_birth_instrument_variation_1" do
      it "returns proper range statement depending on whether PregVisit1 or 2 have been administered" do
        pending
      end
    end

    describe "c_fname_or_the_child" do
      it "returns child's first name or 'the child" do
        pending
      end
    end

    describe "are_you_or_is_guardian_name" do
      it "returns 'are you' if respondent name = guardian name" do
        pending
      end
      it "returns 'is [GUARDIAN_NAME]' if respondent name != guardian name" do
        pending
      end
    end

    describe "still" do
      it "returns 'still' if CHILD_TIME = 1, -1 or -2" do
        pending
      end
      it "returns nothing if CHILD_TIME = 2 or does not exist" do
        pending
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

    def create_singleton_gestation
      @singleton = NcsCode.for_list_name_and_local_code("GESTATION_TYPE_CL1", 1)
      take_survey(@survey, @response_set) do |a|
        a.choice(multiple_gestation, @singleton)
      end
    end

    def create_twin_gestation
      @twin = NcsCode.for_list_name_and_local_code("GESTATION_TYPE_CL1", 2)
      take_survey(@survey, @response_set) do |a|
        a.choice(multiple_gestation, @twin)
      end
    end

    def create_triplet_gestation
      @triplet = NcsCode.for_list_name_and_local_code("GESTATION_TYPE_CL1", 3)
      take_survey(@survey, @response_set) do |a|
        a.choice(multiple_gestation, @triplet)
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

    def setup_survey_instrument(survey)
      @survey = survey
      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.save!
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
    end

  end
end
