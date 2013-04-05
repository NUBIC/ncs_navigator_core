# -*- coding: utf-8 -*-

require 'spec_helper'
require File.expand_path('../../../../../shared/custom_recruitment_strategy', __FILE__)

module NcsNavigator::Core::Mustache
  describe InstrumentContext do
    include SurveyCompletion

    let(:baby_fname) { "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_FNAME" }
    let(:baby_sex)   { "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_SEX" }
    let(:multiple)   { "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MULTIPLE" }

    let(:multiple_gestation) { "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.MULTIPLE_GESTATION" }
    let(:multiple_num) { "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MULTIPLE_NUM" }

    let(:instrument_context) { InstrumentContext.new(rs) }
    let(:rs) { ResponseSet.new }
    let(:survey) { nil }
    let(:person) { Person.new }

    let(:sc_config) { NcsNavigator.configuration.core }

    before do
      rs.person = person
      rs.survey = survey
    end

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

    describe ".interviewer_name" do
      it "returns '[INTERVIEWER NAME]'" do
        instrument_context.interviewer_name.should == "[INTERVIEWER NAME]"
      end
    end

    context "obtaining information from the person taking the survey" do
      describe ".p_primary_address" do
        it "returns \"[What is your street address?]\" if the person has no primary address" do
          person = mock_model(Person, :primary_address => nil)
          rs.person = person

          instrument_context.p_primary_address.should == "[What is your street address?]"
        end

        it "returns the primary address" do
          address = mock_model(Address, :to_s => "123 Easy Street")
          person = mock_model(Person, :primary_address => address)
          rs.person = person

          instrument_context.p_primary_address.should ==
            "Let me confirm your street address. I have it as #{address.to_s}."
        end
      end

      describe ".p_phone_number" do
        let(:home_phone) { "312-555-1234" }
        let(:cell_phone) { "312-555-9999" }

        it "returns nil if there is no person" do
          instrument_context.p_phone_number.should be_nil
        end

        it "returns nil if the person has no primary home phone or cell phone" do
          person = mock_model(Person, :primary_home_phone => nil, :primary_cell_phone => nil)
          rs.person = person

          instrument_context.p_phone_number.should be_nil
        end

        it "returns the primary home phone" do
          person = mock_model(Person, :primary_home_phone => home_phone, :primary_cell_phone => nil)
          rs.person = person

          instrument_context.p_phone_number.should == home_phone
        end

        it "returns the primary cell phone" do
          person = mock_model(Person, :primary_home_phone => nil, :primary_cell_phone => cell_phone)
          rs.person = person

          instrument_context.p_phone_number.should == cell_phone
        end

        it "prefers the primary home phone" do
          person = mock_model(Person, :primary_home_phone => home_phone, :primary_cell_phone => cell_phone)
          rs.person = person

          instrument_context.p_phone_number.should == home_phone
        end

        it "formats the phone number" do
          actual   = "3125555656"
          expected = "312-555-5656"
          person = mock_model(Person, :primary_home_phone => actual, :primary_cell_phone => nil)
          rs.person = person
          instrument_context.p_phone_number.should == expected
        end
      end
    end

    shared_context 'a saved response set' do
      before do
        rs.save!
      end
    end

    describe ".response_for" do
      include_context 'a saved response set'

      let(:survey) { create_birth_survey_with_child_operational_data }

      it "returns the value of the response for the given data_export_identifier" do
        take_survey(survey, rs) do |r|
          r.a baby_fname, 'Mary'
        end

        instrument_context.response_for(baby_fname).should == 'Mary'
      end
    end

    context "for a lo i birth instrument" do
      include_context 'a saved response set'

      let(:survey) { create_lo_i_birth_survey }

      describe ".multiple_release_birth_visit_prefix" do
        it "returns OperationalDataExtractor::Birth::BIRTH_LI_PREFIX" do
          instrument_context.multiple_release_birth_visit_prefix.should ==
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
      include_context 'a saved response set'

      let(:survey) { create_birth_survey_with_child_operational_data }

      describe ".multiple_release_birth_visit_prefix" do
        it "returns OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX" do
          instrument_context.multiple_release_birth_visit_prefix.should ==
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
        context "instrument prior to MDES 3.0" do
          before do
            NcsNavigatorCore.stub_chain("mdes.version.to_f").and_return(2.2)
          end

          it "returns the entered first name of the baby" do
            take_survey(survey, rs) do |r|
              r.a baby_fname, 'Mary'
            end

            instrument_context.b_fname.should == 'Mary'
          end

          it "returns the generic 'your baby' if there is no response for the BABY_FNAME" do
            instrument_context.b_fname.should == 'your baby'
          end
        end

        context "instrument at and after MDES 3.0" do
          before do
            NcsNavigatorCore.stub_chain("mdes.version.to_f").and_return(3.0)
            @part = Factory(:participant)
            @child = Factory(:person, :first_name => "Billy")
          end

          it "returns the childs first name if its a child participant" do
            @part.person = @child
            @part.stub(:child_participant? => true)
            rs.participant = @part
            instrument_context.b_fname.should == 'Billy'
          end

          it "returns the parents first child's first name if its not a child participant" do
            parent = Factory(:person)
            @part.person = parent
            child_link = Factory(:participant_person_link,
                                 :person => @child,
                                 :participant => @part,
                                 :relationship_code => 8)
            @part.participant_person_links <<  child_link
            rs.participant = @part
            instrument_context.b_fname.should == 'Billy'
          end

          it "returns the generic 'your baby' if there is no response for the BABY_FNAME" do
            instrument_context.b_fname.should == 'your baby'
          end
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

        it "returns true for event with no response for MULTIPLE and participant has one child" do
          rs.participant = Factory(:participant)
          person_child = Factory(:person, :person_dob => "09/15/2012")
          rs.participant.participant_person_links << Factory(:participant_person_link, :person => person_child, :relationship_code => 8) # 8 Child
          instrument_context.single_birth?.should be_true
        end

        it "returns false for event with no response for MULTIPLE and participant has more than one child" do
          rs.participant = Factory(:participant)
          person_child_1 = Factory(:person, :person_dob => "09/15/2012")
          rs.participant.participant_person_links << Factory(:participant_person_link, :person => person_child_1, :relationship_code => 8) # 8 Child
          person_child_2 = Factory(:person, :person_dob => "09/15/2012")
          rs.participant.participant_person_links << Factory(:participant_person_link, :person => person_child_2, :relationship_code => 8) # 8 Child

          instrument_context.single_birth?.should be_false
        end

        it "returns true for event with no response for MULTIPLE and no information on participant" do
          instrument_context.single_birth?.should be_true
        end

        it "returns true for event with no response for MULTIPLE and no information on participant's children" do
          rs.participant = Factory(:participant)
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
          NcsNavigatorCore.stub_chain("mdes.version.to_f").and_return(2.2)
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

      describe ".his_her_their_upcase" do
        it "returns 'THEIR' if multiple birth" do
          create_multiple_birth
          instrument_context.his_her_their_upcase.should == "THEIR"
        end

        it "returns 'HIS' if male and single birth" do
          create_single_birth
          create_male_response
          instrument_context.his_her_their_upcase.should == "HIS"
        end

        it "returns 'HER' if female and single birth" do
          create_single_birth
          create_female_response
          instrument_context.his_her_their_upcase.should == "HER"
        end

        it "returns 'HIS/HER' if no sex response and single birth" do
          create_single_birth
          instrument_context.his_her_their_upcase.should == "HIS/HER"
        end

        it "returns 'HIS/HER' if no sex response and unknown if single or multiple birth" do
          instrument_context.his_her_their_upcase.should == "HIS/HER"
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
        include_context 'a saved response set'

        let(:birth_deliver) { "BIRTH_VISIT_3.BIRTH_DELIVER" }
        let(:survey) { create_birth_3_0_with_release_and_birth_deliver_and_mulitiple }

        before do
          NcsNavigatorCore.mdes_version.stub(:number).and_return("3.0")
        end

        it "returns 'Hospital' as the most recent response for BIRTH_VISIT_3.BIRTH_DELIVER" do
          take_survey(survey, rs) do |r|
            at_home = mock(NcsCode, :local_code => 1)
            r.a birth_deliver, at_home
          end
          instrument_context.birthing_place.should == 'hospital'
        end

        it "returns 'Birthing center' as the most recent response for BIRTH_VISIT_3.BIRTH_DELIVER" do
          take_survey(survey, rs) do |r|
            at_home = mock(NcsCode, :local_code => 2)
            r.a birth_deliver, at_home
          end
          instrument_context.birthing_place.should == 'birthing center'
        end

        it "returns 'Other place' as the most recent response for BIRTH_VISIT_3.BIRTH_DELIVER" do
          take_survey(survey, rs) do |r|
            at_home = mock(NcsCode, :local_code => -5)
            r.a birth_deliver, at_home
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

      describe ".does_participants_children_have_date_of_birth" do
        it "returns true if child's dob is set" do
          create_multiple_birth

          rs.participant = Factory(:participant)
          person_child = Factory(:person, :person_dob => "09/15/2012")
          rs.participant.participant_person_links << Factory(:participant_person_link, :person => person_child, :relationship_code => 8) # 8 Child

          instrument_context.does_participants_children_have_date_of_birth?(rs.participant).should == true
        end

        it "returns false if child's dob is not set" do
          create_multiple_birth

          rs.participant = Factory(:participant, :p_type_code => 1)
          person_child = Factory(:person)
          rs.participant.participant_person_links << Factory(:participant_person_link, :person => person_child, :relationship_code => 8) # 8 Child

          instrument_context.does_participants_children_have_date_of_birth?(rs.participant).should == false
        end
      end

      describe ".c_dob_through_participant" do
        it "returns child's date of birth through mother" do
          create_multiple_birth

          rs.participant = Factory(:participant, :p_type_code => 1) # 1: age-eligible woman
          rs.participant.save!

          person_child = Factory(:person, :person_dob => "09/15/2012")
          person_child.save!

          Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

          instrument_context.c_dob_through_participant.should == "09/15/2012"
        end

        it "returns [CHILD'S DATE OF BIRTH] if child's dob is not set" do
          create_multiple_birth

          rs.participant = Factory(:participant, :p_type_code => 1)
          person_child = Factory(:person)

          Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

          instrument_context.c_dob_through_participant.should == "[CHILD'S DATE OF BIRTH]"
        end
      end

      describe ".do_when_will_live_with_you" do
        describe "with INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO survey" do
          let(:birth_deliver) { "BIRTH_VISIT_3.BIRTH_DELIVER" }
          let(:multiple) {"BIRTH_VISIT_3.MULTIPLE"}
          let(:release) { "BIRTH_VISIT_3.RELEASE" }
          let(:survey) { create_birth_3_0_with_release_and_birth_deliver_and_mulitiple }

          before do
            NcsNavigatorCore.mdes_version.stub(:number).and_return("3.0")
            survey.title = 'INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0'
          end

          it "returns generic sentence when no conditions met" do
            instrument_context.do_when_will_live_with_you == "[Does [C_FNAME/your baby]]/[Do your babies]/[When [C_FNAME/your babies] leave the]/[When your baby leaves the] [hospital/ birthing center/ other place] will [he/she/they] live with you?"
          end

          it "returns 'Does' and name or baby if single birth, released is 'yes' and delivered 'at home'"  do
            take_survey(survey, rs) do |r|
              r.yes release
              at_home = mock(NcsCode, :local_code => 3)
              r.a birth_deliver, at_home
            end

            rs.participant = Factory(:participant, :p_type_code => 1)
            person_child = Factory(:person)

            Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

            instrument_context.do_when_will_live_with_you.should == "Does " + instrument_context.child_first_name_your_baby + " live with you?"
          end

          it "returns 'When' and 'name or baby' if single birth, released is 'no'"  do
            take_survey(survey, rs) do |r|
              r.no release
            end

            rs.participant = Factory(:participant, :p_type_code => 1)
            person_child = Factory(:person, :person_dob => "09/15/2012")

            Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

            instrument_context.do_when_will_live_with_you.should == "When " + instrument_context.child_first_name_your_baby + " leaves the " + instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
          end

          it "returns 'Do your babies' if multiple birth, released is 'yes' and delivered 'at home'"  do
            take_survey(survey, rs) do |r|
              r.yes release
              at_home = mock(NcsCode, :local_code => 3)
              r.a birth_deliver, at_home
            end

            create_multiple_birth
            instrument_context.do_when_will_live_with_you.should == "Do your babies live with you?"
          end

          it "returns 'When your babies leave the' if multiple birth, and released is 'no'"  do
            take_survey(survey, rs) do |r|
              r.no release
            end

            create_multiple_birth
            instrument_context.do_when_will_live_with_you.should == "When your babies leave the "+ instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
          end
        end

        describe "with INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO survey" do
          before(:each) do
            NcsNavigatorCore.mdes_version.stub(:number).and_return("3.0")
            survey.title = 'INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO'
          end

          let(:survey) { create_birth_3_0_with_release_and_birth_deliver_and_mulitiple('BIRTH_VISIT_4') }
          let(:birth_deliver) { "BIRTH_VISIT_4.BIRTH_DELIVER" }
          let(:release) { "BIRTH_VISIT_4.RELEASE" }
          let(:multiple) {"BIRTH_VISIT_4.MULTIPLE"}

          it "returns generic sentence when no conditions met" do
            instrument_context.do_when_will_live_with_you == "[Does [C_FNAME/your baby]]/[Do your babies]/[When [C_FNAME/your babies] leave the]/[When your baby leaves the] [hospital/ birthing center/ other place] will [he/she/they] live with you?"
          end

          it "returns 'Does' and name or baby if single birth, released is 'yes' and delivered 'at home'"  do
            take_survey(survey, rs) do |r|
              r.yes release
              at_home = mock(NcsCode, :local_code => 3)
              r.a birth_deliver, at_home
            end

            rs.participant = Factory(:participant, :p_type_code => 1)
            person_child = Factory(:person)

            Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

            instrument_context.do_when_will_live_with_you.should == "Does " + instrument_context.child_first_name_your_baby + " live with you?"
          end

          it "returns 'When' and 'name or baby' if single birth, released is 'no'"  do
            take_survey(survey, rs) do |r|
              r.no release
            end

            rs.participant = Factory(:participant, :p_type_code => 1)
            person_child = Factory(:person)

            Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

            instrument_context.do_when_will_live_with_you.should == "When " + instrument_context.child_first_name_your_baby + " leaves the " + instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
          end

          it "returns 'Do your babies' if multiple birth, released is 'yes' and delivered 'at home'"  do
            take_survey(survey, rs) do |r|
              r.yes release
              at_home = mock(NcsCode, :local_code => 3)
              r.a birth_deliver, at_home
            end

            create_multiple_birth
            instrument_context.do_when_will_live_with_you.should == "Do your babies live with you?"
          end

          it "returns 'When your babies leave the' if multiple birth, and released is 'no'"  do
            take_survey(survey, rs) do |r|
              r.no release
            end

            create_multiple_birth
            instrument_context.do_when_will_live_with_you.should == "When your babies leave the "+ instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
          end
        end

        describe "with INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO survey" do
          before(:each) do
            NcsNavigatorCore.mdes_version.stub(:number).and_return("3.0")
            survey.title = "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO"
          end

          let(:survey) { create_birth_3_0_with_release_and_birth_deliver_and_mulitiple('BIRTH_VISIT_LI_2') }
          let(:birth_deliver) { "BIRTH_VISIT_LI_2.BIRTH_DELIVER" }
          let(:release) { "BIRTH_VISIT_LI_2.RELEASE" }
          let(:multiple) {"BIRTH_VISIT_LI_2.MULTIPLE" }

          it "returns generic sentence when no conditions met" do
            instrument_context.do_when_will_live_with_you == "[Does [C_FNAME/your baby]]/[Do your babies]/[When [C_FNAME/your babies] leave the]/[When your baby leaves the] [hospital/ birthing center/ other place] will [he/she/they] live with you?"
          end

          it "returns 'Does' and name or baby if single birth, released is 'yes' and delivered 'at home'"  do
            take_survey(survey, rs) do |r|
              r.yes release
              at_home = mock(NcsCode, :local_code => 3)
              r.a birth_deliver, at_home
            end

            rs.participant = Factory(:participant, :p_type_code => 1)
            person_child = Factory(:person)

            Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

            instrument_context.do_when_will_live_with_you.should == "Does " + instrument_context.child_first_name_your_baby + " live with you?"
          end

          it "returns 'When' and 'name or baby' if single birth, released is 'no'"  do
            take_survey(survey, rs) do |r|
              r.no release
            end

            rs.participant = Factory(:participant, :p_type_code => 1)
            person_child = Factory(:person, :person_dob => "09/15/2012")

            Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

            instrument_context.do_when_will_live_with_you.should == "When " + instrument_context.child_first_name_your_baby + " leaves the " + instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
          end

          it "returns 'Do your babies' if multiple birth, released is 'yes' and delivered 'at home'"  do
            take_survey(survey, rs) do |r|
              r.yes release
              at_home = mock(NcsCode, :local_code => 3)
              r.a birth_deliver, at_home
            end

            create_multiple_birth
            instrument_context.do_when_will_live_with_you.should == "Do your babies live with you?"
          end

          it "returns 'When your babies leave the' if multiple birth, and released is 'no'"  do
            take_survey(survey, rs) do |r|
              r.no release
            end

            create_multiple_birth
            instrument_context.do_when_will_live_with_you.should == "When your babies leave the "+ instrument_context.birthing_place + " will " + instrument_context.he_she_they + " live with you?"
          end
        end
      end

      describe ".child_first_name through the .child_first_name_the_child method" do
        it "returns default ('the child') if participant is mother and no children" do
          instrument_context.child_first_name_the_child.should == "the child"
        end

        it "returns child's name if participant is child" do
          rs.participant = Factory(:participant, :p_type_code => 6)
          child = Factory(:person)
          rs.participant.person = child

          instrument_context.child_first_name_the_child.should == child.first_name
        end

        it "returns the child's name through the mother's name" do
          rs.participant = Factory(:participant, :p_type_code => 1)

          person_child = Factory(:person, :first_name => "Child's Name")
          person_child.save!

          Factory(:participant_person_link, :person => person_child, :participant => rs.participant, :relationship_code => 8) # 8 Child

          instrument_context.child_first_name_the_child.should == "Child's Name"
        end
      end

      describe ".lets_talk_about_baby" do
        def create_mother_child_graph
          mother = Factory(:person)
          child = Factory(:person)
          mother_p = Factory(:participant, :p_type_code => 1)
          child_p = Factory(:participant, :p_type_code => 6)

          # Self-links.
          Factory(:participant_person_link, :person => mother, :participant => mother_p, :relationship_code => 1)
          Factory(:participant_person_link, :person => child, :participant => child_p, :relationship_code => 1)

          # Mother -> child.  (Relationship code 8: "child")
          Factory(:participant_person_link, :person => child, :participant => mother_p, :relationship_code => 8)

          # Child -> mother. (Relationship code 2: "biological mother")
          Factory(:participant_person_link, :person => mother, :participant => child_p, :relationship_code => 2)

          [mother, child, mother_p, child_p]
        end

        before do
          mother, _, _, child_p = create_mother_child_graph
          rs.person = mother
          rs.participant = child_p
        end

        it "returns 'Let’s talk about your baby.' if single birth" do
          create_single_birth
          instrument_context.lets_talk_about_baby.should == "Let’s talk about your baby."
        end

        it "returns 'First, let’s talk about your first higher order birth.' if first loop and more than 3 children" do
          create_multiple_birth
          instrument_context.lets_talk_about_baby.should == "First, let’s talk about your first higher order birth."
        end

        it "returns 'First let’s talk about your first twin birth.' if first loop and 2 children" do
          create_multiple_birth
          set_multiple_num("2")
          instrument_context.lets_talk_about_baby.should == "First let’s talk about your first twin birth."
        end

        it "returns 'First let’s talk about your first triplet birth.' if first loop and 2 children" do
          create_multiple_birth
          set_multiple_num("3")
          instrument_context.lets_talk_about_baby.should == "First let’s talk about your first triplet birth."
        end

        it "return 'Now let’s talk about your next baby.' if second loop" do
          pending
          create_multiple_birth
          # need to set second loop

          mom = rs.person
          child1 = rs.participant
          child2 = rs.participant

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
        before do
          rs.participant = Factory(:participant)
        end

        it "returns the most recent event end date for pv2" do
          end_date = Date.parse('2000-01-01')
          rs.participant.events << Factory(:event, :event_type_code => 15, :event_end_date => end_date)

          instrument_context.date_of_preg_visit_2.should == end_date
        end

        it "returns nil if there are no completed pv1 events" do
          instrument_context.date_of_preg_visit_2.should be_nil
        end
      end

      describe ".date_of_last_pv_visit" do
        before do
          rs.participant = Factory(:participant)
        end

        it "returns '[DATE OF PV1 VISIT/DATE OF PV2 VISIT]' if there are no events for participant" do
          instrument_context.date_of_last_pv_visit.should == "[DATE OF PV1 VISIT/DATE OF PV2 VISIT]"
        end

        it "returns '[DATE OF PV1 VISIT/DATE OF PV2 VISIT]' if there are no pv1 and pv2 events" do
          rs.participant.events << Factory(:event, :event_type_code => 18, :event_end_date => "2013-11-21")

          instrument_context.date_of_last_pv_visit.should == "[DATE OF PV1 VISIT/DATE OF PV2 VISIT]"
        end

        it "returns the end date for pv1" do
          date = Date.parse('2000-01-01')

          rs.participant.events << Factory(:event, :event_type_code => 13, :event_end_date => date)
          rs.participant.events << Factory(:event, :event_type_code => 15)

          instrument_context.date_of_last_pv_visit.should == date
        end

        it "returns the end date for pv2" do
          date = Date.parse('2000-01-01')

          rs.participant.events << Factory(:event, :event_type_code => 13)
          rs.participant.events << Factory(:event, :event_type_code => 15, :event_end_date => date)

          instrument_context.date_of_last_pv_visit.should == date
        end

        it "returns the end date of pv2 when both pv1 and pv2 have event_end_date" do
          date = Date.parse('2000-01-01')

          rs.participant.events << Factory(:event, :event_type_code => 13, :event_end_date => date, :participant => @participant)
          rs.participant.events << Factory(:event, :event_type_code => 15, :event_end_date => date, :participant => @participant)

          instrument_context.date_of_last_pv_visit.should == date
        end
      end

      describe "overall sentence call for 'in the past', 'ever' and 'since'" do
        before do
          rs.participant = Factory(:participant)
        end

        # Have you {ever} been told by a doctor or other health care provider that you had asthma {since
        #   {DATE OF FIRST PREGNANCY VISIT 1 INTERVIEW}}/{since {DATE OF MOST RECENT SUBSEQUENT PREGNANCY VISIT 1 INTERVIEW}}
        it "returns ever and in the past for new pv1" do
          str = "Have you " + instrument_context.ever + " been told by a doctor or other health care provider that you had asthma" + instrument_context.since + " " + instrument_context.date_of_preg_visit_1.to_s

          str.strip.should == "Have you ever been told by a doctor or other health care provider that you had asthma"
        end

        it "returns since and date when completed pv1" do
          date = Date.parse('2000-01-01')
          rs.participant.events << Factory(:event, :event_end_date => date, :event_type_code => 13)

          str = "Have you " + instrument_context.ever + "been told by a doctor or other health care provider that you had asthma " + instrument_context.since + " " + instrument_context.date_of_preg_visit_1.to_s
          str.should == "Have you been told by a doctor or other health care provider that you had asthma since "+ date.to_s
        end
      end

      describe ".in_the_past" do
        before do
          rs.participant = Factory(:participant)
        end

        it "returns 'in the past' if no pv1 is ever complete" do
          instrument_context.in_the_past.should == "in the past"
        end

        it "returns empty string if pv1 was completed" do
          rs.participant.events << Factory(:event, :event_end_date => Date.parse('2000-01-01'), :event_type_code => 13)

          instrument_context.in_the_past.should == ""
        end
      end

      describe ".since" do
        before do
          rs.participant = Factory(:participant)
        end

        it "returns empty string if no pv1 is ever complete" do
          instrument_context.since.should == ""
        end

        it "returns 'since' if pv1 was completed" do
          rs.participant.events << Factory(:event, :event_end_date => Date.today, :event_type_code => 13)

          instrument_context.since.should == "since"
        end
      end

      describe ".ever" do
        before do
          rs.participant = Factory(:participant)
        end

        it "returns 'ever' if no pv1 is ever complete" do
          instrument_context.ever.should == "ever"
        end

        it "returns empty string if pv1 was completed" do
          rs.participant.events << Factory(:event, :event_end_date => Date.today, :event_type_code => 13)

          instrument_context.ever.should == ""
        end
      end
    end

    context "for a pregnancy visit one saq" do
      let(:survey) { create_pregnancy_visit_1_saq_with_father_data }

      describe ".f_fname" do
        it "returns the entered father's first name" do
          take_survey(survey, rs) do |r|
            r.a "PREG_VISIT_1_SAQ_2.FATHER_NAME", 'Fred Sanford'
          end
          instrument_context.f_fname.should == "Fred"
        end

        it "returns 'the father' if no name entered" do
          instrument_context.f_fname.should == "the father"
        end
      end
    end

    context "for a pregnancy visit one instrument" do
      let(:survey) { create_pregnancy_visit_1_survey_with_person_operational_data }
      let(:person) { Factory(:person) }

      describe ".multiple_release_birth_visit_prefix" do
        it "returns OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX" do
          instrument_context.multiple_release_birth_visit_prefix.should ==
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
          instrument_context.p_full_name.should == person.full_name
        end

        it "returns '[UNKNOWN]' if the full_name is blank" do
          Person.any_instance.stub(:full_name).and_return('')
          instrument_context.p_full_name.should == '[UNKNOWN]'
        end
      end

      describe ".participant_parent_caregiver_name" do
        it "returns the full name of the person taking the survey" do
          instrument_context.participant_parent_caregiver_name.should == person.full_name
        end

        it "returns [Participant/Parent/Caregiver Name] if person full_name is blank" do
          Person.any_instance.stub(:full_name).and_return('')
          instrument_context.participant_parent_caregiver_name.should == '[Participant/Parent/Caregiver Name]'
        end
      end

      describe ".p_dob" do
        it "returns the date of birth of the person taking the survey" do
          Person.any_instance.stub(:person_dob).and_return(20.years.ago)
          instrument_context.p_dob.should == person.person_dob
        end

        it "returns '[UNKNOWN]' if the person_dob is nil" do
          Person.any_instance.stub(:person_dob).and_return(nil)
          instrument_context.p_dob.should == '[UNKNOWN]'
        end
      end

      describe ".work_address" do
        let(:person) { Factory(:person) }
        let(:participant) { Factory(:participant) }
        let(:context) { instrument_context }

        before do
          rs.participant = participant
          participant.person = person
          participant.save!
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
        let(:context) { instrument_context }

        before do
          rs.participant = participant
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
          participant.person = Factory(:person)

          context.practice_name.should == "[PRACTICE_NAME]"
        end
      end
    end

    context "participant verification instrument" do
      let(:participant) { Factory(:participant) }
      let(:child) { Factory(:person) }

      before do
        Factory(:participant_person_link, :participant => participant, :person => child, :relationship_code => 1)

        rs.participant = participant
      end

      describe ".child_primary_address" do
        it "returns '[CHILD'S PRIMARY ADDRESS]' if the child has no primary address" do
          instrument_context.child_primary_address.should == "[CHILD'S PRIMARY ADDRESS]"
        end

        it "returns the primary address" do
          participant.person.stub!(:primary_address => mock_model(Address, :to_s => '123 Easy Street'))

          instrument_context.child_primary_address.should == "123 Easy Street"
        end
      end

      describe ".child_secondary_address" do
        it "returns '[CHILD'S SECONDARY ADDRESS]' if the child has no secondary address" do
          instrument_context.child_secondary_address.should == "[CHILD'S SECONDARY ADDRESS]"
        end

        it "returns the secondary address" do
          participant.person.stub!(:secondary_address => mock_model(Address, :to_s => "123 Easy Street"))

          instrument_context.child_secondary_address.should == "123 Easy Street"
        end
      end

      describe ".child_secondary_number" do
        it "returns '[SECONDARY PHONE NUMBER]' if the child has no secondary phone" do
          instrument_context.child_secondary_number.should == "[SECONDARY PHONE NUMBER]"
        end

        it "returns the secondary number" do
          participant.person.stub!(:secondary_phone => mock_model(Telephone, :to_s => '555-555-5555'))

          instrument_context.child_secondary_number.should == "555-555-5555"
        end
      end
    end

    context "for a work_place_name method" do
      describe ".work_place_name_for_pv2" do
        let(:survey) { create_pv2_and_birth_with_work_name }
        let(:work_name) { "PREG_VISIT_1_3.WORK_NAME" }

        it "returns work name as the most recent response for PREG_VISIT_1_3.WORK_NAME" do
          take_survey(survey, rs) do |r|
            r.a work_name, 'work_name', :value => 'NWU'
          end

          # rs.instrument.event = Factory(:event, :event_type_code => 15)
          instrument_context.work_place_name.should == 'NWU'
        end
      end

      describe ".work_place_name_for_birth" do
        let(:survey) { create_pv2_and_birth_with_work_name }
        let(:work_name) { "PREG_VISIT_2_3.WORK_NAME" }

        it "returns work name as the most recent response for PREG_VISIT_2_3.WORK_NAME" do
          take_survey(survey, rs) do |r|
            r.a work_name, 'work_name', :value => 'NUBIC'
          end
          # rs.instrument.event = Factory(:event, :event_type_code => 18)
          instrument_context.work_place_name.should == 'NUBIC'
        end

        it "return '[PARTICIPANTS WORKPLACE NAME]' if no reponse for WORK_NAME is provided" do
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
      let(:survey) { create_pv2_and_birth_with_work_name }
      let(:participant) { Factory(:participant) }
      let(:child) { Factory(:person) }

      before do
        Factory(:participant_person_link, :participant => participant, :person => child, :relationship_code => 1)

        rs.participant = participant
      end

      it "returns child's first name " do
        participant.person.first_name = "Masha"
        instrument_context.c_fname_or_the_child.should == "Masha"
      end

      it "returns 'the Child' if no first name is provided" do
        participant.person.first_name = nil
        instrument_context.c_fname_or_the_child.should == "the Child"
      end

      it "returns 'the Child' if no participant exists" do
        rs.participant  = nil
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

    describe "c_full_name" do
      let(:participant) { Factory(:participant) }

      it "returns a default message if person is nil" do
        rs.person = nil

        instrument_context.c_full_name.should == "[CHILD'S FULL NAME]"
      end

      it "returns a default message if full_name is nil" do
        person = Factory(:person, :first_name => nil, :last_name => nil)
        Factory(:participant_person_link, :participant => participant, :person => person, :relationship_code => 1)

        rs.participant = participant

        instrument_context.c_full_name.should == "[CHILD'S FULL NAME]"
      end

      it "returns the c_full_name if the full_name exists" do
        person = Factory(:person, :first_name => "The", :last_name => "King")
        Factory(:participant_person_link, :participant => participant, :person => person, :relationship_code => 1)

        rs.participant = participant

        instrument_context.c_full_name.should == "The King"
      end
    end

    describe "age_of_child_in_months" do
      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person) }

      before do
        Factory(:participant_person_link, :person => person, :participant => participant, :relationship_code => 1)

        rs.participant = participant
      end

      it "returns a default message if the participant doesn't have a person" do
        ParticipantPersonLink.delete_all

        instrument_context.age_of_child_in_months.should == "[AGE OF CHILD IN MONTHS]"
      end

      it "returns a default message if person dob is blank" do
        date = Date.parse("2012-12-25")
        person.update_attribute(:person_dob, nil)

        instrument_context.age_of_child_in_months(date).should == "[AGE OF CHILD IN MONTHS]"
      end

      it "returns a default message if person dob is unparseable" do
        date = Date.parse("2012-12-25")
        person.update_attribute(:person_dob, '1234567890')

        instrument_context.age_of_child_in_months(date).should == "[AGE OF CHILD IN MONTHS]"
      end

      it "returns the child's age in months" do
        dob = Date.parse("2012-01-01")
        date = Date.parse("2012-12-25")

        person.update_attribute(:person_dob, dob)

        # date               dob
        # (2012 * 12 + 12) - (2012 * 12 + 1)
        instrument_context.age_of_child_in_months(date).should == 11
      end

      it "rounds down" do
        dob = Date.parse("2012-10-31")
        date = Date.parse("2012-12-25")

        person.update_attribute(:person_dob, dob)

        # There's one month and three weeks between 2012-10-31 and 2012-12-25.
        instrument_context.age_of_child_in_months(date).should == 1
      end

      it "rounds down across years" do
        dob = Date.parse("2012-10-31")
        date = Date.parse("2013-12-14")

        person.update_attribute(:person_dob, dob)

        # There's thirteen months and one week between 2012-10-13 and 2013-12-14.
        instrument_context.age_of_child_in_months(date).should == 13
      end
    end

    describe ".c_dob" do
      let(:survey) { create_participant_verification_survey }
      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person) }

      before do
        Factory(:participant_person_link, :person => person, :participant => participant, :relationship_code => 1)

        rs.participant = participant
      end

      it "returns a default message if person is nil" do
        ParticipantPersonLink.delete_all

        instrument_context.c_dob.should == "[CHILD'S DATE OF BIRTH]"
      end

      it "returns a default message if child's dob is blank" do
        person.update_attribute(:person_dob, nil)

        instrument_context.c_dob.should == "[CHILD'S DATE OF BIRTH]"
      end

      it "returns the DOB of the participant's person" do
        person.update_attribute(:person_dob, '2012-12-25')

        instrument_context.c_dob.should == "2012-12-25"
      end
    end

    describe ".was_were" do

      # TODO: look at INS_QUE_6Month_INT_EHPBHIPBS_M3.1_V2.0_PART_TWO to determine logic for this
      it "returns 'was/were'" do
        pending
      end

    end

    context "for multi_mode_visit_info approximate_visit_time" do
      let(:survey) { Factory(:survey, :title => "Stub Survey") }
      let(:participant) { Factory(:participant) }
      let(:instrument) { Instrument.new }

      before do
        rs.instrument = instrument
        rs.participant = participant
      end

      def set_high_intensity()
        participant.high_intensity = true
        participant.save!
      end

      def set_low_intensity()
        participant.high_intensity = false
        participant.save!
      end

      def add_event(event_type_code)
        rs.instrument.event = Factory(:event,
                                      :event_type_code => event_type_code,
                                      :participant => participant)
        participant.events.reload
      end

      describe ".approximate_visit_time" do
        context "for 'EnhancedHousehold'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { EnhancedHousehold.new }

          it "returns '1.5 hours' for Twenty Four Month Visit" do
            add_event(Event::twenty_four_month_visit_code)
            instrument_context.approximate_visit_time.should == "1.5 hours"
          end
        end

        context "for 'ProviderBased'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { ProviderBased.new }

          it "returns '45 minutes' for 'Provider-Based Recruitment', Eighteen Month Visit" do
            add_event(Event::eighteen_month_visit_code)
            instrument_context.approximate_visit_time.should == "45 minutes"
          end
        end

        context "for 'TwoTier'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { TwoTier.new }

          it "returns '2 hours' for 'High Intensity', Twelve Month Visit" do
            set_high_intensity
            add_event(Event::twelve_month_visit_code)
            instrument_context.approximate_visit_time.should == "2 hours"
          end

          it "returns '1 hour' for 'Low Intensity', Pregnancy Visit 1" do
            set_low_intensity
            add_event(Event::pregnancy_visit_1_code)
            instrument_context.approximate_visit_time.should == "1 hour"
          end

          it "returns 'unknown amount of time' if valid recruitment time but event_code is not set" do
            set_high_intensity
            instrument_context.approximate_visit_time.should ==
                                                      "unknown amount of time"
          end
        end

        context "for 'ProviderBasedSubsample'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { ProviderBasedSubsample.new }

          it "returns '1.5 hours' for 'Provider Based Subsample', Six Month Visit" do
            add_event(Event::six_month_visit_code)
            instrument_context.approximate_visit_time.should == "1.5 hours"
          end
        end

        context "for 'OriginalVanguard'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { OriginalVanguard.new }

          it "returns 'unknown amount of time' if recruitment center is set to 'OVC' and event_code is valid" do
            add_event(Event::pregnancy_visit_2_code)
            instrument_context.approximate_visit_time.should ==
                                                    "unknown amount of time"
          end
        end
      end

    end

    context "for a 30 month visit" do
      let(:survey) { create_participant_verif_child_sex_survey_for_30m }

      describe ".boys_girls" do
        it "returns 'boys' if CHILD_SEX set to MALE (1)" do
          take_survey(survey, rs) do |r|
            male = mock(NcsCode, :local_code => 1)
            r.a("PARTICIPANT_VERIF_CHILD.CHILD_SEX", male)
          end
          instrument_context.boys_girls.should == "boys"
        end

        it "returns 'girls' if CHILD_SEX set to FEMALE (2)" do
          take_survey(survey, rs) do |r|
            female = mock(NcsCode, :local_code => 2)
            r.a("PARTICIPANT_VERIF_CHILD.CHILD_SEX", female)
          end
          instrument_context.boys_girls.should == "girls"
        end

        it "returns 'boys/girls' if CHILD_SEX set to REFUSED" do
          take_survey(survey, rs) do |r|
            r.refused("PARTICIPANT_VERIF_CHILD.CHILD_SEX")
          end
          instrument_context.boys_girls.should == "boys/girls"
        end

        it "returns 'boys/girls' if CHILD_SEX set to DON'T KNOW" do
          take_survey(survey, rs) do |r|
            could_not_obtain= mock(NcsCode, :local_code => "neg_2")
            r.a("PARTICIPANT_VERIF_CHILD.CHILD_SEX", could_not_obtain)
          end
          instrument_context.boys_girls.should == "boys/girls"
        end

        it "returns 'boys/girls' if CHILD_SEX is not set" do
          instrument_context.boys_girls.should == "boys/girls"
        end

      end
    end

    def create_single_birth
      take_survey(survey, rs) do |r|
        r.no multiple
      end
    end

    def create_multiple_birth
      take_survey(survey, rs) do |r|
        r.yes multiple
      end
    end

    def create_singleton_gestation
      @singleton = NcsCode.for_list_name_and_local_code("GESTATION_TYPE_CL1", 1)
      take_survey(survey, rs) do |r|
        r.a(multiple_gestation, @singleton)
      end
    end

    def create_twin_gestation
      @twin = NcsCode.for_list_name_and_local_code("GESTATION_TYPE_CL1", 2)
      take_survey(survey, rs) do |r|
        r.a(multiple_gestation, @twin)
      end
    end

    def set_multiple_num mult_num
      take_survey(survey, rs) do |r|
        r.a multiple_num, mult_num
      end
    end

    def create_triplet_gestation
      @triplet = NcsCode.for_list_name_and_local_code("GESTATION_TYPE_CL1", 3)
      take_survey(survey, rs) do |r|
        r.a(multiple_gestation, @triplet)
      end
    end

    def create_male_response
      male = NcsCode.for_list_name_and_local_code("GENDER_CL1", 1)

      take_survey(survey, rs) do |r|
        r.a(baby_sex, male)
      end
    end

    def create_female_response
      female = NcsCode.for_list_name_and_local_code("GENDER_CL1", 2)

      take_survey(survey, rs) do |r|
        r.a baby_sex, female
      end
    end

    def set_first_name first_name
      take_survey(survey, rs) do |r|
        r.a baby_fname, first_name
      end
    end
  end
end
