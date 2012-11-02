# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::ParticipantVerification do
    include SurveyCompletion

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.detect { |r| r.question.reference_identifier == reference_identifier }
      response.should_not be_nil
      response.to_s.should == value
    end

    context "with participant verification instrument pt one" do

      let(:person) { Factory(:person) }
      let(:survey_pt1) { create_participant_verification_part_one_survey_with_prepopulated_fields }

      before(:each) do
        participant = Factory(:participant)
        participant.person = person
        participant.save!

        @response_set_pt1, @instrument_pt1 = prepare_instrument(person, participant, survey_pt1)
        @response_set_pt1.responses.should be_empty
      end

      describe "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification" do

        it "is TRUE if this is the pv1 event" do
          event = Factory(:event, :event_type_code => 13) # PV1
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "TRUE")
        end

        it "is TRUE if this is the pv2 event" do
          event = Factory(:event, :event_type_code => 15) # PV2
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "TRUE")
        end

        it "is TRUE if this is the father event" do
          event = Factory(:event, :event_type_code => 19) # Father
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "TRUE")
        end

        it "is FALSE if this is NOT the pv1, pv2, or father event" do
          event = Factory(:event, :event_type_code => 18) # Birth
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "FALSE")
        end

      end

      describe "prepopulated_respondent_name_collected" do

        it "is FALSE if the person is missing a part of their name" do
          person.stub!(:middle_name).and_return(nil)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_respondent_name_collected", "FALSE")
        end

        it "is TRUE if the person has a first, middle, and last name" do
          # sanity check
          [:first_name, :middle_name, :last_name].each { |name| person.send(name).should_not be_blank }

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_respondent_name_collected", "TRUE")
        end

        it "is TRUE if the person has a first, last and has responded has no middle name previously" do
          Person.any_instance.stub(:middle_name).and_return(nil)
          person.middle_name.should be_nil

          none = mock(NcsCode, :local_code => '-7')
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.choice "PARTICIPANT_VERIF.R_MNAME", none
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_respondent_name_collected", "TRUE")
        end

        it "is TRUE if the person has responded previously" do

          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.str "PARTICIPANT_VERIF.R_FNAME", "fname"
            a.str "PARTICIPANT_VERIF.R_MNAME", "mname"
            a.str "PARTICIPANT_VERIF.R_LNAME", "lname"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_respondent_name_collected", "TRUE")
        end

      end

      describe "prepopulated_should_show_maiden_name_and_nicknames" do

        it "is TRUE for the PV1 event" do
          event = Factory(:event, :event_type_code => 13) # PV1
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_should_show_maiden_name_and_nicknames", "TRUE")
        end

        it "is FALSE for any event other than PV1 and Birth" do
          event = Factory(:event, :event_type_code => 15) # PV2
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_should_show_maiden_name_and_nicknames", "FALSE")
        end

        it "is TRUE for Birth if the PV1 is not complete" do
          pv1_event = Factory(:event, :event_type_code => 13) # PV1
          Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => pv1_event)
          Event.any_instance.stub(:disposition_complete?).and_return(false)

          pv1_event.should_not be_disposition_complete

          event = Factory(:event, :event_type_code => 18) # Birth
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_should_show_maiden_name_and_nicknames", "TRUE")
        end

        it "is FALSE for Birth if the PV1 is complete" do
          pv1_event = Factory(:event, :event_type_code => 13) # PV1
          Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => pv1_event)
          Event.any_instance.stub(:disposition_complete?).and_return(true)

          pv1_event.should be_disposition_complete

          event = Factory(:event, :event_type_code => 18) # Birth
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1, contact_link)
          assert_response_value(rsp.populate, "prepopulated_should_show_maiden_name_and_nicknames", "FALSE")
        end

      end

      describe "prepopulated_person_dob_previously_collected" do

        it "is TRUE if the person has a valid dob" do
          person.stub(:person_dob_date).and_return(Date.new(2001,1,1))

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_person_dob_previously_collected", "TRUE")
        end

        it "is TRUE if the person has responded previously" do
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.date "PARTICIPANT_VERIF.PERSON_DOB", Date.new(2001,1,1)
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_person_dob_previously_collected", "TRUE")
        end

        it "is FALSE if the person has responded refused previously" do
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.refused "PARTICIPANT_VERIF.PERSON_DOB"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_person_dob_previously_collected", "FALSE")
        end

        it "is FALSE if the person has responded don't know previously" do
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.dont_know "PARTICIPANT_VERIF.PERSON_DOB"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_person_dob_previously_collected", "FALSE")
        end

        it "is FALSE if the person has no dob and has not responded previously" do
          person.stub(:person_dob_date).and_return(nil)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt1, survey_pt1)
          assert_response_value(rsp.populate, "prepopulated_person_dob_previously_collected", "TRUE")
        end

      end

    end

    context "with participant verification instrument part two" do

      let(:person) { Factory(:person) }
      let(:mother) { Factory(:participant) }
      let(:child_person) { Factory(:person) }
      let(:child) { Factory(:participant) }

      let(:second_child_person) { Factory(:person) }
      let(:second_child) { Factory(:participant) }

      let(:third_child_person) { Factory(:person) }
      let(:third_child) { Factory(:participant) }


      let(:survey_pt2) { create_participant_verification_part_two_survey_with_prepopulated_fields }

      before(:each) do
        mother.person = person
        mother.save!

        child.person = child_person
        ParticipantPersonLink.create(:person_id => child_person.id, :participant_id => mother.id, :relationship_code => 8) # 8 Child
        ParticipantPersonLink.create(:person_id => person.id, :participant_id => child.id, :relationship_code => 2) # 2 Mother
        child.save!

        # third_child.person = third_child_person
        # ParticipantPersonLink.create(:person_id => third_child_person.id, :participant_id => mother.id, :relationship_code => 8) # 8 Child
        # ParticipantPersonLink.create(:person_id => person.id, :participant_id => third_child.id, :relationship_code => 2) # 2 Mother
        # third_child.save!

        @response_set_pt2, @instrument_pt2 = prepare_instrument(person, child, survey_pt2)
        @response_set_pt2.responses.should be_empty
      end

      describe "prepopulated_should_show_child_name" do

        it "is TRUE if the child (participant) name is unknown" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_name", "TRUE")
        end

        it "is FALSE if the child (participant) name is known" do
          child_person.first_name.should_not be_nil
          child_person.last_name.should_not be_nil

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_name", "FALSE")
        end

        it "is FALSE if the person has previously responded" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.str "PARTICIPANT_VERIF.C_FNAME", "cfname"
            a.str "PARTICIPANT_VERIF.C_LNAME", "clname"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_name", "FALSE")

        end

        it "is TRUE if the person has responded refused previously" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.refused "PARTICIPANT_VERIF.C_FNAME"
            a.refused "PARTICIPANT_VERIF.C_LNAME"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_name", "TRUE")
        end

        it "is TRUE if the person has responded don't know previously" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.dont_know "PARTICIPANT_VERIF.C_FNAME"
            a.dont_know "PARTICIPANT_VERIF.C_LNAME"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_name", "TRUE")
        end

      end

      describe "prepopulated_should_show_child_dob" do

        it "is TRUE if the child (participant) dob is unknown" do
          Person.any_instance.stub(:person_dob_date).and_return(nil)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_dob", "TRUE")
        end

        it "is FALSE if the child (participant) dob is known" do
          Person.any_instance.stub(:person_dob_date).and_return(Date.new(2001,1,1))
          child_person.person_dob_date.should_not be_nil

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_dob", "FALSE")
        end

        it "is FALSE if the person has previously responded" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.date "PARTICIPANT_VERIF.CHILD_DOB", Date.new(2001,1,1)
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_dob", "FALSE")

        end

        it "is TRUE if the person has responded refused previously" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.refused "PARTICIPANT_VERIF.CHILD_DOB"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_dob", "TRUE")
        end

        it "is TRUE if the person has responded don't know previously" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.dont_know "PARTICIPANT_VERIF.CHILD_DOB"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_dob", "TRUE")
        end

      end

      describe "prepopulated_should_show_child_sex" do

        it "is TRUE if the child (participant) sex is unknown" do
          Person.any_instance.stub(:sex_code).and_return(-4)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_sex", "TRUE")
        end

        it "is FALSE if the child (participant) sex is known" do
          Person.any_instance.stub(:sex_code).and_return(1)

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_sex", "FALSE")
        end

        it "is FALSE if the person has previously responded" do
          Person.any_instance.stub(:sex_code).and_return(-4)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.choice "PARTICIPANT_VERIF.CHILD_SEX", mock(NcsCode, :local_code => 1)
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_sex", "FALSE")
        end

        it "is TRUE if the person has responded refused previously" do
          Person.any_instance.stub(:sex_code).and_return(-4)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.refused "PARTICIPANT_VERIF.CHILD_SEX"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_sex", "TRUE")
        end

        it "is TRUE if the person has responded don't know previously" do
          Person.any_instance.stub(:sex_code).and_return(-4)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.dont_know "PARTICIPANT_VERIF.CHILD_SEX"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_child_sex", "TRUE")
        end

      end

      describe "prepopulated_first_child" do

        it "is TRUE if the child (participant) is the first (or only) child" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_first_child", "TRUE")
        end

        it "is FALSE if the child is not the first child" do
          second_child.person = second_child_person
          ParticipantPersonLink.create(:person_id => second_child_person.id, :participant_id => mother.id, :relationship_code => 8) # 8 Child
          ParticipantPersonLink.create(:person_id => person.id, :participant_id => second_child.id, :relationship_code => 2) # 2 Mother
          second_child.save!

          @response_set_pt2_second_child, @instrument_pt2_second_child = prepare_instrument(person, second_child, survey_pt2)
          @response_set_pt2_second_child.responses.should be_empty

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2_second_child, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_first_child", "FALSE")
        end

      end

      describe "prepopulated_resp_guard_previously_collected" do

        it "is FALSE if there is no previous response for RESP_GUARD" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_resp_guard_previously_collected", "FALSE")
        end

        it "is TRUE if there is a previous response for RESP_GUARD" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.RESP_GUARD"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_resp_guard_previously_collected", "TRUE")
        end

      end

      describe "prepopulated_should_show_resp_pcare" do

        it "is TRUE if there is no response for RESP_PCARE" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_resp_pcare", "TRUE")
        end

        it "is TRUE if the person has responded refused previously" do
          Person.any_instance.stub(:sex_code).and_return(-4)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.refused "PARTICIPANT_VERIF.RESP_PCARE"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_resp_pcare", "TRUE")
        end

        it "is TRUE if the person has responded don't know previously" do
          Person.any_instance.stub(:sex_code).and_return(-4)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.dont_know "PARTICIPANT_VERIF.RESP_PCARE"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_resp_pcare", "TRUE")
        end

        it "is FALSE if there is a valid response for RESP_PCARE" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.RESP_PCARE"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_should_show_resp_pcare", "FALSE")
        end

      end

      describe "prepopulated_resp_pcare_equals_one_in_previous_survey" do
        it "is FALSE if there is no previous response" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_resp_pcare_equals_one_in_previous_survey", "FALSE")
        end

        it "is TRUE if there is only one previous response with a value of one" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.RESP_PCARE"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_resp_pcare_equals_one_in_previous_survey", "TRUE")
        end

        it "is TRUE if there is any one previous response with a value of one" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.dont_know "PARTICIPANT_VERIF.RESP_PCARE"
          end
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.RESP_PCARE"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_resp_pcare_equals_one_in_previous_survey", "TRUE")
        end
      end

      describe "prepopulated_pcare_rel_previously_collected" do

        it "is FALSE if there is no previous response for PCARE_REL" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_pcare_rel_previously_collected", "FALSE")
        end

        it "is TRUE if there is a previous response for PCARE_REL" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.choice "PARTICIPANT_VERIF.PCARE_REL", mock(NcsCode, :local_code => 1)
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_pcare_rel_previously_collected", "TRUE")
        end

      end

      describe "prepopulated_ocare_child_previously_collected_and_equals_one" do
        it "is FALSE if there is no previous response" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_ocare_child_previously_collected_and_equals_one", "FALSE")
        end

        it "is TRUE if there is any one previous response with a value of one" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.dont_know "PARTICIPANT_VERIF.OCARE_CHILD"
          end
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.OCARE_CHILD"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_ocare_child_previously_collected_and_equals_one", "TRUE")
        end
      end

      describe "prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected" do

        it "is FALSE if the person has NOT previously responded OCARE_CHILD = 1 && other caregiver name not collected" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.OCARE_CHILD"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected", "FALSE")
        end


        it "is FALSE if the person has NOT previously responded OCARE_CHILD = 1 && other caregiver name not valid" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.OCARE_CHILD"
            a.dont_know "PARTICIPANT_VERIF.O_FNAME"
            a.dont_know "PARTICIPANT_VERIF.O_MNAME"
            a.dont_know "PARTICIPANT_VERIF.O_LNAME"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected", "FALSE")
        end

        it "is TRUE if the person has previously responded OCARE_CHILD = 1 && other caregiver name collected" do
          Person.any_instance.stub(:first_name).and_return(nil)
          Person.any_instance.stub(:last_name).and_return(nil)

          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.yes "PARTICIPANT_VERIF.OCARE_CHILD"
            a.str "PARTICIPANT_VERIF.O_FNAME", "ofname"
            a.str "PARTICIPANT_VERIF.O_MNAME", "omname"
            a.str "PARTICIPANT_VERIF.O_LNAME", "olname"
          end

          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected", "TRUE")
        end

      end

      describe "prepopulated_ocare_rel_previously_collected" do

        it "is FALSE if there is no previous response for OCARE_REL" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_ocare_rel_previously_collected", "FALSE")
        end

        it "is TRUE if there is a previous response for OCARE_REL" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.choice "PARTICIPANT_VERIF.OCARE_REL", mock(NcsCode, :local_code => 1)
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_ocare_rel_previously_collected", "TRUE")
        end

      end

      describe "prepopulated_child_time_previously_collected" do

        it "is FALSE if there is no previous response for CHILD_TIME" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_child_time_previously_collected", "FALSE")
        end

        it "is TRUE if there is a previous response for CHILD_TIME" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.choice "PARTICIPANT_VERIF.CHILD_TIME", mock(NcsCode, :local_code => 1)
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_child_time_previously_collected", "TRUE")
        end

      end

      describe "prepopulated_child_secondary_address_variables_previously_collected" do

        it "is FALSE if there is no previous response for S_ADDRESS_1" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_child_secondary_address_variables_previously_collected", "FALSE")
        end

        it "is TRUE if there is a previous response for S_ADDRESS_1" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.str "PARTICIPANT_VERIF.S_ADDRESS_1", "caddr1"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_child_secondary_address_variables_previously_collected", "TRUE")
        end

      end

      describe "prepopulated_sa_phone_previously_collected" do

        it "is FALSE if there is no previous response for SA_PHONE" do
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_sa_phone_previously_collected", "FALSE")
        end

        it "is TRUE if there is a previous response for SA_PHONE" do
          take_survey(survey_pt2, @response_set_pt2) do |a|
            a.str "PARTICIPANT_VERIF.SA_PHONE", "867-5309"
          end
          rsp = ResponseSetPopulator::ParticipantVerification.new(person, @instrument_pt2, survey_pt2)
          assert_response_value(rsp.populate, "prepopulated_sa_phone_previously_collected", "TRUE")
        end

      end


    end

  end

end