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

    context "for a participant verification instrument" do

      let(:person) { Factory(:person) }
      let(:survey_pt1) { create_participant_verification_part_one_survey_with_prepopulated_fields }
      # let(:survey_child) { create_participant_verification_child_survey_with_prepopulated_fields }
      # let(:survey_pt2) { create_participant_verification_part_two_survey_with_prepopulated_fields }

      before(:each) do
        participant = Factory(:participant)
        participant.person = person
        participant.save!

        @response_set_pt1, @instrument_pt1 = prepare_instrument(person, participant, survey_pt1)
        @response_set_pt1.responses.should be_empty

        # # Yes this should be the same instrument - bypassing the PSC reference connection for now
        # @response_set_child, @instrument_child = prepare_instrument(person, participant, survey_child)
        # @response_set_child.responses.should be_empty

        # # Yes this should be the same instrument - bypassing the PSC reference connection for now
        # @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, survey_pt2)
        # @response_set_pt2.responses.should be_empty
      end


      describe "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification" do

        it "is TRUE if this is the pv1 event" do
          event = Factory(:event, :event_type_code => 13) # PV1
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "TRUE")
        end

        it "is TRUE if this is the pv2 event" do
          event = Factory(:event, :event_type_code => 15) # PV2
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "TRUE")
        end

        it "is TRUE if this is the father event" do
          event = Factory(:event, :event_type_code => 19) # Father
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "TRUE")
        end

        it "is FALSE if this is NOT the pv1, pv2, or father event" do
          event = Factory(:event, :event_type_code => 18) # Birth
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", "FALSE")
        end

      end

      describe "prepopulated_respondent_name_collected" do

        it "is FALSE if the person is missing a part of their name" do
          person.stub!(:middle_name).and_return(nil)
          person.middle_name.should be_nil

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_respondent_name_collected", "FALSE")
        end

        it "is TRUE if the person has a first, middle, and last name" do
          # sanity check
          [:first_name, :middle_name, :last_name].each { |name| person.send(:name).should_not be_blank }

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_respondent_name_collected", "TRUE")
        end

        it "is TRUE if the person has a first, last and has responded has no middle name previously" do
          person.stub!(:middle_name).and_return(nil)
          person.middle_name.should be_nil

          none = mock(NcsCode, :local_code => '-7')
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.choice "PARTICIPANT_VERIF.R_MNAME", none
          end

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_respondent_name_collected", "TRUE")
        end

        it "is TRUE if the person has responded previously" do

          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.str "PARTICIPANT_VERIF.R_FNAME", "fname"
            a.str "PARTICIPANT_VERIF.R_MNAME", "mname"
            a.str "PARTICIPANT_VERIF.R_LNAME", "lname"
          end

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_respondent_name_collected", "TRUE")
        end

      end

      describe "prepopulated_should_show_maiden_name_and_nicknames" do

        it "is TRUE for the PV1 event" do
          event = Factory(:event, :event_type_code => 13) # PV1
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_should_show_maiden_name_and_nicknames", "TRUE")
        end

        it "is FALSE for any event other than PV1 and Birth" do
          event = Factory(:event, :event_type_code => 15) # PV2
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_should_show_maiden_name_and_nicknames", "FALSE")
        end

        it "is TRUE for Birth if the PV1 is not complete" do
          pv1_event = Factory(:event, :event_type_code => 13) # PV1
          Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => pv1_event)
          Event.any_instance.stub(:disposition_complete?).and_return(false)

          pv1_event.should_not be_disposition_complete

          event = Factory(:event, :event_type_code => 18) # Birth
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_should_show_maiden_name_and_nicknames", "TRUE")
        end

        it "is FALSE for Birth if the PV1 is complete" do
          pv1_event = Factory(:event, :event_type_code => 13) # PV1
          Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => pv1_event)
          Event.any_instance.stub(:disposition_complete?).and_return(true)

          pv1_event.should be_disposition_complete

          event = Factory(:event, :event_type_code => 18) # Birth
          contact_link = Factory(:contact_link, :person => person, :contact => Factory(:contact), :event => event)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1, :contact_link => contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_should_show_maiden_name_and_nicknames", "FALSE")
        end

      end

      describe "prepopulated_person_dob_previously_collected" do

        it "is TRUE if the person has a valid dob" do
          person.stub(:person_dob_date).and_return(Date.today)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_person_dob_previously_collected", "TRUE")
        end

        it "is TRUE if the person has responded previously" do
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.date "PARTICIPANT_VERIF.PERSON_DOB", Date.today
          end

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_person_dob_previously_collected", "TRUE")
        end

        it "is FALSE if the person has responded refused previously" do
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.refused "PARTICIPANT_VERIF.PERSON_DOB"
          end

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_person_dob_previously_collected", "FALSE")
        end

        it "is FALSE if the person has responded don't know previously" do
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.dont_know "PARTICIPANT_VERIF.PERSON_DOB"
          end

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_person_dob_previously_collected", "FALSE")
        end

        it "is FALSE if the person has no dob and has not responded previously" do
          person.stub(:person_dob_date).and_return(nil)

          params = { :person => person, :instrument => @instrument_pt1, :survey => survey_pt1 }
          assert_response_value(ResponseSetPopulator::Base.new(params).process,
            "prepopulated_person_dob_previously_collected", "TRUE")

        end

      end

    end

  end

end