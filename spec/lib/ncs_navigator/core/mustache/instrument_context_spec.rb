# -*- coding: utf-8 -*-


require 'spec_helper'

module NcsNavigator::Core::Mustache
  describe InstrumentContext do
    include SurveyCompletion

    it "should be a child of Mustache" do
      InstrumentContext.ancestors.should include(Mustache)
    end

    let(:baby_fname) { "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_FNAME" }
    let(:baby_sex)   { "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_SEX" }
    let(:multiple)   { "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MULTIPLE" }

    let(:multiple_gestation) { "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.MULTIPLE_GESTATION" }
    let(:multiple_num)   { "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MULTIPLE_NUM" }

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

      describe ".institution" do
        it "returns the name of the institution involved in the study" do
          instrument_context.institution.should == sc_config["study_center_name"]
        end
        it "returns [INSTITUTION] if study_center is not configured" do
          sc_config["study_center_name"] = nil
          instrument_context.institution.should == '[INSTITUTION]'
        end
      end

      describe ".county" do
        it "returns the county without the wave number, if the raw county name contains text referring to a wave number" do
          unfiltered_county   = "Cook County, IL (Wave 1)"
          NcsCode.stub(:for_list_name_and_local_code).and_return(mock(NcsCode, :to_s => unfiltered_county))
          instrument_context.county.should == "Cook County, IL"
        end

        it "does not modify county names that do not contain a wave number" do
          unfiltered_county   = "Los Angeles County, CA"
          NcsCode.stub(:for_list_name_and_local_code).and_return(mock(NcsCode, :to_s => unfiltered_county))
          instrument_context.county.should == "Los Angeles County, CA"
        end

        it "displays an empty string when county name returns nil" do
          NcsCode.stub(:for_list_name_and_local_code).and_return(nil)
          instrument_context.county.should == ""
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

        it "formats the phone number" do
          actual   = "3125555656"
          expected = "312-555-5656"
          person = mock_model(Person, :primary_home_phone => actual, :primary_cell_phone => nil)
          rs = mock_model(ResponseSet, :person => person)
          InstrumentContext.new(rs).p_phone_number.should == expected
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
        it "returns OperationalDataExtractor::Birth::BIRTH_LI_PREFIX" do
          instrument_context.multiple_birth_prefix.should ==
            OperationalDataExtractor::Birth::BIRTH_LI_PREFIX
        end
      end

      describe ".multiple_identifier" do
        it "returns MULTIPLE" do
          instrument_context.multiple_identifier.should == "MULTIPLE"
        end
      end

      describe ".birth_baby_name_prefix" do
        it "returns OperationalDataExtractor::Birth::BABY_NAME_LI_PREFIX" do
          instrument_context.birth_baby_name_prefix.should ==
            OperationalDataExtractor::Birth::BABY_NAME_LI_PREFIX
        end
      end

    end

    context "for a birth instrument" do
      before(:each) do
        setup_survey_instrument(create_birth_survey_with_child_operational_data)
      end

      let(:instrument_context) { InstrumentContext.new(@response_set) }

      describe ".multiple_birth_prefix" do
        it "returns OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX" do
          instrument_context.multiple_birth_prefix.should ==
            OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX
        end
      end

      describe ".multiple_identifier" do
        it "returns MULTIPLE" do
          instrument_context.multiple_identifier.should == "MULTIPLE"
        end
      end

      describe ".birth_baby_name_prefix" do
        it "returns OperationalDataExtractor::Birth::BABY_NAME_PREFIX" do
          instrument_context.birth_baby_name_prefix.should ==
            OperationalDataExtractor::Birth::BABY_NAME_PREFIX
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

      describe ".he_she_upcase" do

        it "returns 'HE' if male" do
          create_male_response
          instrument_context.he_she_upcase.should == "HE"
        end

        it "returns 'SHE' if female" do
          create_female_response
          instrument_context.he_she_upcase.should == "SHE"
        end

        it "returns 'HE/SHE' if no sex response" do
          instrument_context.he_she_upcase.should == "HE/SHE"
        end

      end

      describe ".he_she_the_child" do

        it "returns 'he' if male" do
          create_male_response
          instrument_context.he_she_the_child.should == "he"
        end

        it "returns 'she' if female" do
          create_female_response
          instrument_context.he_she_the_child.should == "she"
        end

        it "returns 'the child' if no sex response" do
          instrument_context.he_she_the_child.should == "the child"
        end

      end


      describe ".child_children" do
        it "returns 'Child' if single birth" do
          create_single_birth
          instrument_context.child_children.should == "Child"
        end

        it "returns 'Children' if multiple birth" do
          create_multiple_birth
          instrument_context.child_children.should == "Children"
        end
      end

      describe ".child_children_downcast" do
        it "returns 'child' if single birth" do
          create_single_birth
          instrument_context.child_children_downcast.should == "child"
        end

        it "returns 'children' if multiple birth" do
          create_multiple_birth
          instrument_context.child_children_downcast.should == "children"
        end
      end


      describe ".birthing_place" do

        before(:each) do
          setup_survey_instrument(create_birth_3_0_with_release_and_birth_deliver_and_mulitiple)
          NcsNavigatorCore.mdes_version.stub(:number).and_return("3.0")
        end
        let(:birth_deliver) { "BIRTH_VISIT_3.BIRTH_DELIVER" }

        it "returns 'Hospital' as the most recent response for BIRTH_VISIT_3.BIRTH_DELIVER" do
          take_survey(@survey, @response_set) do |a|
            at_home = mock(NcsCode, :local_code => 1)
            a.choice birth_deliver, at_home
          end
          instrument_context.birthing_place.should == 'hospital'
        end

        it "returns 'Birthing center' as the most recent response for BIRTH_VISIT_3.BIRTH_DELIVER" do
          take_survey(@survey, @response_set) do |a|
            at_home = mock(NcsCode, :local_code => 2)
            a.choice birth_deliver, at_home
          end
          instrument_context.birthing_place.should == 'birthing center'
        end

        it "returns 'Other place' as the most recent response for BIRTH_VISIT_3.BIRTH_DELIVER" do
          take_survey(@survey, @response_set) do |a|
            at_home = mock(NcsCode, :local_code => -5)
            a.choice birth_deliver, at_home
          end
          instrument_context.birthing_place.should == 'other place'
        end

        it "return nil if no reponse for BIRTH_VISIT_3.BIRTH_DELIVER" do
          InstrumentContext.any_instance.stub(:response_for).and_return(nil)
          instrument_context.birthing_place.should be_nil
        end
      end

      describe ".stomach_back_side" do
        it "returns singular version if single pregnancy" do
          create_single_birth
          instrument_context.stomach_back_side.should == "stomach, back and side"
        end
        it "returns plural version if multiple pregnancy" do
          create_multiple_birth
          instrument_context.stomach_back_side.should == "stomachs, backs and sides"
        end
      end

      describe ".c_dob_through_participant" do
        it "returns 'child's date of birth' if first loop and more than 3 children" do
          create_multiple_birth

          mom = @response_set.person

          mom.person_dob = "05/06/1980"
          mom.participant.p_type_code = 1 # 1 age eligilble woman
          mom.participant.save!

          person_child = Factory(:person, :person_dob => "09/15/2012")
          person_child.save!

          Factory(:participant_person_link, :person => person_child, :participant => mom.participant, :relationship_code => 8) # 8 Child

          mom.participant_person_links.reload

          instrument_context.c_dob_through_participant.should == "09/15/2012"
        end


      end
      describe ".do_when_will_live_with_you" do

        before(:each) do
          setup_survey_instrument(create_birth_3_0_with_release_and_birth_deliver_and_mulitiple)
          NcsNavigatorCore.mdes_version.stub(:number).and_return("3.0")
        end

        let(:birth_deliver) { "BIRTH_VISIT_3.BIRTH_DELIVER" }
        let(:release) { "BIRTH_VISIT_3.RELEASE" }
        let(:multiple) {"BIRTH_VISIT_3.MULTIPLE"}

        it "returns generic sentence when no conditions met" do
          instrument_context.do_when_will_live_with_you == "[Does [C_FNAME/your baby]]/[Do your babies]/[When [C_FNAME/your babies] leave the]/[When your baby leaves the] [hospital/ birthing center/ other place] will [he/she/they] live with you?"
        end

        it "returns 'Does' and name or baby if single birth, released is 'yes' and delivered 'at home'"  do
          take_survey(@survey, @response_set) do |a|
            a.yes release
            at_home = mock(NcsCode, :local_code => 3)
            a.choice birth_deliver, at_home
          end
          mom = @response_set.person
          mom.participant.p_type_code = 1 # 1 age eligilble woman
          mom.participant.save!

          person_child = Factory(:person)
          person_child.save!

          Factory(:participant_person_link, :person => person_child, :participant => mom.participant, :relationship_code => 8) # 8 Child

          mom.participant_person_links.reload
          instrument_context.do_when_will_live_with_you.should == "Does " + instrument_context.child_first_name_your_baby + " live with you?"
        end
        it "returns 'When' and 'name or baby' if single birth, released is 'no'"  do
          take_survey(@survey, @response_set) do |a|
            a.no release
          end
          mom = @response_set.person

          mom.person_dob = "05/06/1980"
          mom.participant.p_type_code = 1 # 1 age eligilble woman
          mom.participant.save!

          person_child = Factory(:person, :person_dob => "09/15/2012")
          person_child.save!

          Factory(:participant_person_link, :person => person_child, :participant => mom.participant, :relationship_code => 8) # 8 Child

          mom.participant_person_links.reload
          instrument_context.do_when_will_live_with_you.should == "When " + instrument_context.child_first_name_your_baby + " leaves the " + instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
        end
        it "returns 'Do your babies' if multiple birth, released is 'yes' and delivered 'at home'"  do
          take_survey(@survey, @response_set) do |a|
            a.yes release
            at_home = mock(NcsCode, :local_code => 3)
            a.choice birth_deliver, at_home
          end
          create_multiple_birth
          instrument_context.do_when_will_live_with_you.should == "Do your babies live with you?"
        end
        it "returns 'When your babies leave the' if multiple birth, and released is 'no'"  do
          take_survey(@survey, @response_set) do |a|
            a.no release
          end
          create_multiple_birth
          instrument_context.do_when_will_live_with_you.should == "When your babies leave the "+ instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
        end

      end

      describe ".lets_talk_about_baby" do
        it "returns 'Let’s talk about your baby.' if single birth" do
          create_single_birth
          instrument_context.lets_talk_about_baby.should == "Let’s talk about your baby."
        end

        it "returns 'First, let’s talk about your first higher order birth.' if first loop and more than 3 children" do
          create_multiple_birth

          mom = @response_set.person
          child = @response_set.participant

          mom.participant.p_type_code = 1 # 1 age eligilble woman
          mom.participant.save!

          person_child = child.person
          child.p_type_code = 6
          child.save!

          Factory(:participant_person_link, :person => person_child, :participant => mom.participant, :relationship_code => 8) # 8 Child
          Factory(:participant_person_link, :person => mom, :participant => child, :relationship_code => 2)
          mom.participant_person_links.reload
          child.participant_person_links.reload

          instrument_context.lets_talk_about_baby.should == "First, let’s talk about your first higher order birth."
        end

        it "returns 'First let’s talk about your first twin birth.' if first loop and 2 children" do
          create_multiple_birth
          set_multiple_num("2")

          mom = @response_set.person
          child = @response_set.participant

          mom.participant.p_type_code = 1 # 1 age eligilble woman
          mom.participant.save!

          person_child = child.person
          child.p_type_code = 6
          child.save!

          Factory(:participant_person_link, :person => person_child, :participant => mom.participant, :relationship_code => 8) # 8 Child
          Factory(:participant_person_link, :person => mom, :participant => child, :relationship_code => 2)
          mom.participant_person_links.reload
          child.participant_person_links.reload

          instrument_context.lets_talk_about_baby.should == "First let’s talk about your first twin birth."
        end
        it "returns 'First let’s talk about your first triplet birth.' if first loop and 2 children" do
          create_multiple_birth
          set_multiple_num("3")

          mom = @response_set.person
          child = @response_set.participant

          mom.participant.p_type_code = 1 # 1 age eligilble woman
          mom.participant.save!

          person_child = child.person
          child.p_type_code = 6
          child.save!

          Factory(:participant_person_link, :person => person_child, :participant => mom.participant, :relationship_code => 8) # 8 Child
          Factory(:participant_person_link, :person => mom, :participant => child, :relationship_code => 2)
          mom.participant_person_links.reload
          child.participant_person_links.reload

          instrument_context.lets_talk_about_baby.should == "First let’s talk about your first triplet birth."
        end

        it "return 'Now let’s talk about your next baby.' if second loop" do
          pending
          create_multiple_birth
          # need to set second loop

          mom = @response_set.person
          child1 = @response_set.participant
          child2 = @response_set.participant

          mom.participant.p_type_code = 1 # 1 age eligilble woman
          mom.participant.save!

          person_child1 = child1.person
          child1.p_type_code = 6
          child1.save!

          Factory(:participant_person_link, :person => person_child1, :participant => mom.participant, :relationship_code => 8) # 8 Child
          Factory(:participant_person_link, :person => mom, :participant => child1, :relationship_code => 2)

          mom.participant_person_links.reload
          child1.participant_person_links.reload
          instrument_context.lets_talk_about_baby.should == "Now let’s talk about your next baby."

        end

      end

      describe ".date_of_preg_visit_2" do

        it "returns the most recent event end date for pv2" do
          date = Date.today
          @participant  = @response_set.participant
          @person = @participant.person
          @response_set.instrument.event = Factory(:event, :event_type_code => 15, :event_end_date => date, :participant => @participant)
          @participant.events.reload
          instrument_context.date_of_preg_visit_2.should == date
        end

        it "returns nil if there are no completed pv1 events" do
          instrument_context.date_of_preg_visit_2.should be_nil
        end

      end

      describe ".date_of_last_pv_visit" do

        it "returnt '[DATE OF PV1 VISIT/DATE OF PV2 VISIT]' if there are no completed events for pv1 and pv2" do
          @participant  = @response_set.participant
          @person = @participant.person
          instrument_context.date_of_last_pv_visit.should == "[DATE OF PV1 VISIT/DATE OF PV2 VISIT]"

        end

        it "returns the end date for pv1" do
          date = Date.today
          @participant  = @response_set.participant
          @person = @participant.person
          @response_set.instrument.event = Factory(:event, :event_type_code => 13, :event_end_date => date, :participant => @participant)
          @response_set.instrument.event = Factory(:event, :event_type_code => 15, :participant => @participant)
          @participant.events.reload
          instrument_context.date_of_last_pv_visit.should == date
        end

        it "returns the end date for pv2" do
          date = Date.today
          @participant  = @response_set.participant
          @person = @participant.person
          @response_set.instrument.event = Factory(:event, :event_type_code => 13, :participant => @participant)
          @response_set.instrument.event = Factory(:event, :event_type_code => 15, :event_end_date => date, :participant => @participant)
          @participant.events.reload
          instrument_context.date_of_last_pv_visit.should == date

        end

      end

      describe "overall sentence call for 'in the past', 'ever' and 'since'" do
        # Have you {ever} been told by a doctor or other health care provider that you had asthma {since
        #   {DATE OF FIRST PREGNANCY VISIT 1 INTERVIEW}}/{since {DATE OF MOST RECENT SUBSEQUENT PREGNANCY VISIT 1 INTERVIEW}}
        it "returns ever and in the past for new pv1" do
          str = "Have you " + instrument_context.ever + " been told by a doctor or other health care provider that you had asthma" + instrument_context.since + " " +
          instrument_context.date_of_preg_visit_1.to_s
          str.strip.should == "Have you ever been told by a doctor or other health care provider that you had asthma"
        end

        it "returns since and date when completed pv1" do
          date = Date.today
          @participant  = @response_set.participant
          @person = @participant.person
          @response_set.instrument.event = Factory(:event, :event_end_date => date, :event_type_code => 13, :participant => @participant)
          @participant.events.reload
          str = "Have you " + instrument_context.ever + "been told by a doctor or other health care provider that you had asthma " + instrument_context.since + " " +
          instrument_context.date_of_preg_visit_1.to_s
          str.should == "Have you been told by a doctor or other health care provider that you had asthma since "+ date.to_s
        end
      end

      describe ".in_the_past" do

        it "returns 'in the past' if no pv1 is ever complete" do
          instrument_context.in_the_past.should == "in the past"

        end

        it "returns empty string if pv1 was completed" do
          @participant  = @response_set.participant
          @person = @participant.person
          @response_set.instrument.event = Factory(:event, :event_end_date => Date.today, :event_type_code => 13, :participant => @participant)
          @participant.events.reload
          instrument_context.in_the_past.should == ""

        end

      end

      describe ".since" do

        it "returns empty string if no pv1 is ever complete" do
          instrument_context.since.should == ""
        end

        it "returns 'since' if pv1 was completed" do
          @participant  = @response_set.participant
          @person = @participant.person
          @response_set.instrument.event = Factory(:event, :event_end_date => Date.today, :event_type_code => 13, :participant => @participant)
          @participant.events.reload
          instrument_context.since.should == "since"

        end

      end

      describe ".ever" do

        it "returns 'ever' if no pv1 is ever complete" do
          instrument_context.ever.should == "ever"
        end

        it "returns empty string if pv1 was completed" do
          @participant  = @response_set.participant
          @person = @participant.person
          @response_set.instrument.event = Factory(:event, :event_end_date => Date.today, :event_type_code => 13, :participant => @participant)
          @participant.events.reload

          instrument_context.ever.should == ""

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
        it "returns OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX" do
          instrument_context.multiple_birth_prefix.should ==
            OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX
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
        it "returns 'HAS THE BABY' if unknown if single or multiple gestation" do
          instrument_context.has_baby_have_babies.should == 'HAS THE BABY'
        end

        it "returns 'HAS THE BABY' if singleton gestation" do
          create_singleton_gestation
          instrument_context.has_baby_have_babies.should == 'HAS THE BABY'
        end

        it "returns 'HAVE THE BABIES' if twin gestation" do
          create_twin_gestation
          instrument_context.has_baby_have_babies.should == 'HAVE THE BABIES'
        end

        it "returns 'HAVE THE BABIES' if triplet or higher gestation" do
          create_triplet_gestation
          instrument_context.has_baby_have_babies.should == 'HAVE THE BABIES'
        end
      end

      describe ".p_full_name" do
        it "returns the full name of the person taking the survey" do
          instrument_context.p_full_name.should == @person.full_name
        end

        it "returns '[UNKNOWN]' if the full_name is blank" do
          Person.any_instance.stub(:full_name).and_return('')
          instrument_context.p_full_name.should == '[UNKNOWN]'
        end
      end

      describe ".participant_parent_caregiver_name" do
        it "returns the full name of the person taking the survey" do
          instrument_context.participant_parent_caregiver_name.should == @person.full_name
        end

        it "returns [Participant/Parent/Caregiver Name] if person full_name is blank" do
          Person.any_instance.stub(:full_name).and_return('')
          instrument_context.participant_parent_caregiver_name.should == '[Participant/Parent/Caregiver Name]'
        end
      end

      describe ".p_dob" do
        it "returns the date of birth of the person taking the survey" do
          Person.any_instance.stub(:person_dob).and_return(20.years.ago)
          instrument_context.p_dob.should == @person.person_dob
        end

        it "returns '[UNKNOWN]' if the person_dob is nil" do
          Person.any_instance.stub(:person_dob).and_return(nil)
          instrument_context.p_dob.should == '[UNKNOWN]'
        end

      end

      describe ".work_address" do
        let(:person) { Factory(:person) }
        let(:participant) { Factory(:participant) }
        let(:rs) { Factory(:response_set, :person => person, :participant => participant) }
        let(:context) { InstrumentContext.new(rs) }

        before do
          participant.person = person; participant.save!
        end

        it "returns the [WORK ADDRESS] if primary_work_address is blank" do
          person.primary_work_address.to_s.should be_blank
          context.work_address.should eq "[WORK ADDRESS]"
        end

        it "returns the participant's workplace address" do
          primary = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 1)
          work_address = Factory(:address, :address_rank => primary, :address_type => Address.work_address_type, :person => person)
          person.primary_work_address.should_not be_nil
          context.work_address.should eq person.primary_work_address.to_s
        end
      end

      describe ".visit_today" do
        it "returns 'Is your visit today' if this visit is the first visit with provider" do
          pending
        end

        it "returns 'Was your visit today' if this visit is not the first visit with provider"  do
          pending
        end
      end

      describe ".practice_name" do
        let(:person) { Factory(:person) }
        let(:participant) { Factory(:participant) }

        let(:provider) {Factory(:provider, :name_practice => "Children's Practice")}
        let(:person_provider_link) {Factory(:person_provider_link, :provider => provider, :person => person)}
        let(:rs) { Factory(:response_set, :person => person, :participant => participant) }
        let(:context) { InstrumentContext.new(rs) }

        before do
          participant.person = person_provider_link.person
        end

        it "returns the practice associated with the study" do
          context.practice_name.should == "Children's Practice"
        end

        it "returns '[PRACTICE_NAME]' if person doesn't exist" do
          participant.person = nil
          context.practice_name.should == "[PRACTICE_NAME]"
        end

        it "returns '[PRACTICE_NAME]' if practice doesn't exist" do
          person =  Factory(:person)
          participant = Factory(:participant)
          rs = Factory(:response_set, :person => person, :participant => participant)
          context = InstrumentContext.new(rs)
          context.practice_name.should == "[PRACTICE_NAME]"
        end
      end

    end

    context "participant verification instrument" do

      let(:instrument_context) { InstrumentContext.new }

      describe ".child_primary_address" do
        it "returns '[CHILD'S PRIMARY ADDRESS]' if the child has no primary address" do
          person = mock_model(Person, :primary_address => nil)
          participant = mock_model(Participant, :person => person)
          rs = mock_model(ResponseSet, :participant => participant)
          InstrumentContext.new(rs).child_primary_address.should == "[CHILD'S PRIMARY ADDRESS]"
        end

        it "returns the primary address" do
           address = mock_model(Address, :to_s => "123 Easy Street")
           person = mock_model(Person, :primary_address => address)
           participant = mock_model(Participant, :person => person)
           rs = mock_model(ResponseSet, :participant => participant)
           InstrumentContext.new(rs).child_primary_address.should == "#{address.to_s}"
        end
      end

      describe ".child_secondary_address" do
        it "returns '[CHILD'S SECONDARY ADDRESS]' if the child has no secondary address" do
          person = mock_model(Person, :secondary_address => nil)
          participant = mock_model(Participant, :person => person)
          rs = mock_model(ResponseSet, :participant => participant)
          InstrumentContext.new(rs).child_secondary_address.should == "[CHILD'S SECONDARY ADDRESS]"
        end

        it "returns the secondary address" do
           address = mock_model(Address, :to_s => "123 Easy Street")
           person = mock_model(Person, :secondary_address => address)
           participant = mock_model(Participant, :person => person)
           rs = mock_model(ResponseSet, :participant => participant)
           InstrumentContext.new(rs).child_secondary_address.should == "#{address.to_s}"
        end
      end

      describe ".child_secondary_number" do
        it "returns '[SECONDARY PHONE NUMBER]' if the child has no secondary phone" do
          person = mock_model(Person, :secondary_phone => nil)
          participant = mock_model(Participant, :person => person)
          rs = mock_model(ResponseSet, :participant => participant)
          InstrumentContext.new(rs).child_secondary_number.should == "[SECONDARY PHONE NUMBER]"
        end

        it "returns the secondary number" do
           phone = mock_model(Telephone, :to_s => "555-555-5555")
           person = mock_model(Person, :secondary_phone => phone)
           participant = mock_model(Participant, :person => person)
           rs = mock_model(ResponseSet, :participant => participant)
           InstrumentContext.new(rs).child_secondary_number.should == "#{phone.to_s}"
        end
      end

    end

    context "for a work_place_name method" do
      describe ".work_place_name_for_pv2" do

        before(:each) do
          setup_survey_instrument(create_pv2_and_birth_with_work_name)
        end

        let(:instrument_context) { InstrumentContext.new(@response_set) }
        let(:work_name) { "PREG_VISIT_1_3.WORK_NAME" }

        it "returns work name as the most recent response for PREG_VISIT_1_3.WORK_NAME" do
          take_survey(@survey, @response_set) do |a|
            a.str work_name, 'NWU'
          end
          # @response_set.instrument.event = Factory(:event, :event_type_code => 15)
          instrument_context.work_place_name.should == 'NWU'
        end
      end

      describe ".work_place_name_for_birth" do

        before(:each) do
          setup_survey_instrument(create_pv2_and_birth_with_work_name)
        end

        let(:instrument_context) { InstrumentContext.new(@response_set) }
        let(:work_name) { "PREG_VISIT_2_3.WORK_NAME" }


        it "returns work name as the most recent response for PREG_VISIT_2_3.WORK_NAME" do
          take_survey(@survey, @response_set) do |a|
            a.str work_name, 'NUBIC'
          end
          # @response_set.instrument.event = Factory(:event, :event_type_code => 18)
          instrument_context.work_place_name.should == 'NUBIC'
        end

        it "return '[PARTICIPANTS WORKPLACE NAME]' if no reponse for WORK_NAME is provided" do
          @response_set.instrument.event = Factory(:event)
          instrument_context.work_place_name.should == '[PARTICIPANTS WORKPLACE NAME]'
        end
      end
    end

    describe ".child_first_name_the_child_the_children" do

      it "returns the child's first name"

      it "returns 'the child' if the child has no first name"

      it "returns 'the children' if a multiple birth"
    end

    describe ".child_first_name_your_child" do

      it "returns the child's first name"

      it "returns 'your child' if the child has no first name"

    end

    describe ".child_first_name_your_child_upcase" do

      it "returns the child's first name in uppercase"

      it "returns 'YOUR CHILD' if the child has no first name"

    end


    describe "c_fname_or_the_child" do
      before(:each) do
        setup_survey_instrument(create_pv2_and_birth_with_work_name)
      end
      let(:instrument_context) { InstrumentContext.new(@response_set) }

      it "returns child's first name " do

        @participant  = @response_set.participant
        @person = @participant.person
        @person.first_name = "Masha"
        instrument_context.c_fname_or_the_child.should == "Masha"
      end

      it "returns 'the Child' if no first name is provided" do
        @participant  = @response_set.participant
        @person = @participant.person
        @person.first_name = nil
        instrument_context.c_fname_or_the_child.should == "the Child"
      end

      it "returns 'the Child' if no participant exists" do
        @response_set.participant  = nil
        instrument_context.c_fname_or_the_child.should == "the Child"
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


    describe "age_of_child_in_months" do

      let(:instrument_context) { InstrumentContext.new }

      it "returns a default message if person is nil" do
        rs = Factory(:response_set, :person => nil)
        context = InstrumentContext.new(rs)
        context.about_person.should be_nil
        context.age_of_child_in_months.should == "[AGE OF CHILD IN MONTHS]"
      end

      it "returns a default message if person dob is blank" do
        today = Date.parse("2012-12-25")
        person =  Factory(:person, :person_dob => nil)
        participant = Factory(:participant)
        participant.person = person
        person.save!

        rs = Factory(:response_set, :participant => participant)
        context = InstrumentContext.new(rs)
        context.about_person.should_not be_nil
        context.age_of_child_in_months(today).should == "[AGE OF CHILD IN MONTHS]"
      end

      it "returns a default message if person dob is unparseable" do
        today = Date.parse("2012-12-25")
        person =  Factory(:person, :person_dob => "1234567890")
        participant = Factory(:participant)
        participant.person = person
        person.save!

        rs = Factory(:response_set, :participant => participant)
        context = InstrumentContext.new(rs)
        context.about_person.should_not be_nil
        context.age_of_child_in_months(today).should == "[AGE OF CHILD IN MONTHS]"
      end

      it "returns the child's age in months" do
        dob = Date.parse("2012-01-01")
        today = Date.parse("2012-12-25")

        person =  Factory(:person, :person_dob => dob)
        participant = Factory(:participant)
        participant.person = person
        person.save!

        rs = Factory(:response_set, :participant => participant)
        context = InstrumentContext.new(rs)
        context.about_person.should_not be_nil
        context.age_of_child_in_months(today).should == (today.year*12 + today.month) - (dob.year*12 + dob.month)
      end

      context "if dob is greater than today" do
        it "returns the child's age in months" do
          dob = Date.parse("2012-10-31")
          today = Date.parse("2012-12-25")

          person =  Factory(:person, :person_dob => dob)
          participant = Factory(:participant)
          participant.person = person
          person.save!

          rs = Factory(:response_set, :participant => participant)
          context = InstrumentContext.new(rs)
          context.about_person.should_not be_nil
          context.age_of_child_in_months(today).should == ((today.year*12 + today.month) - (dob.year*12 + dob.month)) -1
        end
      end

      context "different years" do
        it "returns the child's age in months" do
          dob = Date.parse("2012-10-31")
          today = Date.parse("2013-12-14")

          person =  Factory(:person, :person_dob => dob)
          participant = Factory(:participant)
          participant.person = person
          person.save!

          rs = Factory(:response_set, :participant => participant)
          context = InstrumentContext.new(rs)
          context.about_person.should_not be_nil
          context.age_of_child_in_months(today).should == ((today.year*12 + today.month) - (dob.year*12 + dob.month)) -1
        end
      end

    end

    describe ".c_dob" do
      before(:each) do
        setup_survey_instrument(create_participant_verification_survey)
      end
      let(:instrument_context) { InstrumentContext.new(@response_set) }

      it "returns a default message if person is nil" do
        @response_set.participant.person = nil
        instrument_context.c_dob.should == "[CHILD'S DATE OF BIRTH]"
      end

      it "returns a default message if child's dob is blank" do
        today = Date.parse("2012-12-25")
        @response_set.participant.person.person_dob = nil
        instrument_context.c_dob.should == "[CHILD'S DATE OF BIRTH]"
      end

      it "returns 2012-12-25 if child's dob is set through instrument" do
        dob = Date.parse("2012-12-25")
        take_survey(@survey, @response_set) do |a|
          a.date('PARTICIPANT_VERIF_CHILD.CHILD_DOB', "2012-12-25")
        end
        @response_set.completed_at = "2013-01-25"
        @response_set.save!
        instrument_context.c_dob.should == "2012-12-25"
      end
    end

    describe ".was_were" do

      # TODO: look at INS_QUE_6Month_INT_EHPBHIPBS_M3.1_V2.0_PART_TWO to determine logic for this
      it "returns 'was/were'" do
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

    def set_multiple_num mult_num
      take_survey(@survey, @response_set) do |a|
        a.str multiple_num, mult_num
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
