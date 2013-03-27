# -*- coding: utf-8 -*-

require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe Birth do
    include SurveyCompletion

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

    def run_populator
      Birth.new(@response_set_pt2).run
    end

    context "for version dependent responses from part one prepopulated in part two" do

      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }
      let(:pv1_survey) { create_pv1_with_fields_for_birth_prepopulation }

      def prepare_surveys(survey1_name, survey1_table, survey2_name)
          @survey_pt1 = create_birth_part_one_survey_with_prepopulated_fields_for_part_two(survey1_name, survey1_table)
          @response_set_pt1, @instrument_pt1 = prepare_instrument(person, participant, @survey_pt1)

          @survey_pt2 = create_birth_part_two_survey_with_prepopulated_fields_from_part_one(survey2_name)
          @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, @survey_pt2)
      end

      before(:each) do
        participant.person = person
        participant.save!
      end

      describe "BIRTH_DELIVER" do

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", "BIRTH_VISIT_3", "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_birth_deliver_from_birth_visit_part_one"
          end

          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", "BIRTH_VISIT_3", "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
          some_other_place = mock(NcsCode, :local_code => 'some_other_place')
          take_survey(@survey_pt1, @response_set_pt1) do |r|
            r.a "BIRTH_VISIT_3.BIRTH_DELIVER", some_other_place
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_birth_deliver_from_birth_visit_part_one", "SOME OTHER PLACE")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.1" do
          prepare_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_ONE", "BIRTH_VISIT_LI_2", "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_birth_deliver_from_birth_visit_part_one"
          end

          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.1" do
          prepare_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_ONE", "BIRTH_VISIT_LI_2", "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO")
          some_other_place = mock(NcsCode, :local_code => 'some_other_place')
          take_survey(@survey_pt1, @response_set_pt1) do |r|
            r.a "BIRTH_VISIT_LI_2.BIRTH_DELIVER", some_other_place
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_birth_deliver_from_birth_visit_part_one", "SOME OTHER PLACE")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.2" do
          prepare_surveys("INS_QUE_Birth_INT_M3.2_V3.1_PART_ONE", "BIRTH_VISIT_4", "INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_birth_deliver_from_birth_visit_part_one"
          end

          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.2" do
          prepare_surveys("INS_QUE_Birth_INT_M3.2_V3.1_PART_ONE", "BIRTH_VISIT_4", "INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO")
          some_other_place = mock(NcsCode, :local_code => 'some_other_place')
          take_survey(@survey_pt1, @response_set_pt1) do |r|
            r.a "BIRTH_VISIT_4.BIRTH_DELIVER", some_other_place
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_birth_deliver_from_birth_visit_part_one", "SOME OTHER PLACE")
        end
      end

      describe "RELEASE" do
        it "response should not exist if the question has not previously been answered for instrument MDES version prior to 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_LI_P2_V10_PART_ONE", "BIRTH_VISIT_LI", "INS_QUE_Birth_INT_LI_P2_V10_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_release_from_birth_visit_part_one"
          end
          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version prior to 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_LI_P2_V10_PART_ONE", "BIRTH_VISIT_LI", "INS_QUE_Birth_INT_LI_P2_V10_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |a|
            a.yes "BIRTH_VISIT_LI.RELEASE"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_release_from_birth_visit_part_one", "YES")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", "BIRTH_VISIT_3", "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_release_from_birth_visit_part_one"
          end
          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", "BIRTH_VISIT_3", "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |r|
            r.yes "BIRTH_VISIT_3.RELEASE"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_release_from_birth_visit_part_one", "YES")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.1" do
          prepare_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_ONE", "BIRTH_VISIT_LI_2", "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_release_from_birth_visit_part_one"
          end
          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.1" do
          prepare_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_ONE", "BIRTH_VISIT_LI_2", "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |a|
            a.yes "BIRTH_VISIT_LI_2.RELEASE"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_release_from_birth_visit_part_one", "YES")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.2" do
          prepare_surveys("INS_QUE_Birth_INT_M3.2_V3.1_PART_ONE", "BIRTH_VISIT_4", "INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_release_from_birth_visit_part_one"
          end
          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.2" do
          prepare_surveys("INS_QUE_Birth_INT_M3.2_V3.1_PART_ONE", "BIRTH_VISIT_4", "INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |a|
            a.yes "BIRTH_VISIT_4.RELEASE"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_release_from_birth_visit_part_one", "YES")
        end

      end

      describe "MULTIPLE" do

        it "should be set to the response from part_one for instrument MDES version prior to 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_LI_P2_V10_PART_ONE", "BIRTH_VISIT_LI", "INS_QUE_Birth_INT_LI_P2_V10_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_multiple_from_birth_visit_part_one"
          end
          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version prior to 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_LI_P2_V10_PART_ONE", "BIRTH_VISIT_LI", "INS_QUE_Birth_INT_LI_P2_V10_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |a|
            a.no "BIRTH_VISIT_LI.MULTIPLE"
          end
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_multiple_from_birth_visit_part_one", "NO")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", "BIRTH_VISIT_3", "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_multiple_from_birth_visit_part_one"
          end

          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.0" do
          prepare_surveys("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", "BIRTH_VISIT_3", "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |r|
            r.no "BIRTH_VISIT_3.MULTIPLE"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_multiple_from_birth_visit_part_one", "NO")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.1" do
          prepare_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_ONE", "BIRTH_VISIT_LI_2", "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_multiple_from_birth_visit_part_one"
          end
          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.1" do
          prepare_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_ONE", "BIRTH_VISIT_LI_2", "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |a|
            a.no "BIRTH_VISIT_LI_2.MULTIPLE"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_multiple_from_birth_visit_part_one", "NO")
        end

        it "response should not exist if the question has not previously been answered for instrument MDES version 3.2" do
          prepare_surveys("INS_QUE_Birth_INT_M3.2_V3.1_PART_ONE", "BIRTH_VISIT_4", "INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO")
          params = { :person => person, :instrument => @instrument_pt2, :survey => @survey_pt2 }
          run_populator
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_multiple_from_birth_visit_part_one"
          end
          responses.should be_empty
        end

        it "should be set to the response from part_one for instrument MDES version 3.2" do
          prepare_surveys("INS_QUE_Birth_INT_M3.2_V3.1_PART_ONE", "BIRTH_VISIT_4", "INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO")
          take_survey(@survey_pt1, @response_set_pt1) do |a|
            a.no "BIRTH_VISIT_4.MULTIPLE"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_multiple_from_birth_visit_part_one", "NO")
        end
      end
    end

    context "for responses from part one prepopulated in part two" do
      let(:person) { Factory(:person) }
      let(:survey_pt1) { create_birth_part_one_survey_with_prepopulated_fields_for_part_two("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", "BIRTH_VISIT_3") }
      let(:survey_pt2) { create_birth_part_two_survey_with_prepopulated_fields_from_part_one("INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO") }
      let(:participant) { Factory(:participant) }
      let(:pv1_survey) { create_pv1_with_fields_for_birth_prepopulation }

      before(:each) do
        participant.person = person
        participant.save!

        @response_set_pt1, @instrument_pt1 = prepare_instrument(person, participant, survey_pt1)
        @response_set_pt1.responses.should be_empty
        # Yes this should be the same instrument - bypassing the PSC reference connection for now
        @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, survey_pt2)
        @response_set_pt2.responses.should be_empty
      end

      describe "prepopulated_is_valid_work_name_provided" do

        it "should be FALSE if work name was not previously answered" do
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "FALSE")
        end

        it "should be FALSE if work name was previously answered as refused" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.refused "PREG_VISIT_1_3.WORK_NAME"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "FALSE")
        end

        it "should be FALSE if work name was previously answered as don't know" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.dont_know "PREG_VISIT_1_3.WORK_NAME"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "FALSE")
        end

        it "should be TRUE if work name was previously answered" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.a "PREG_VISIT_1_3.WORK_NAME", "work_name"
          end
          run_populator

          puts @response_set_pt2.responses.map{|r| [r.question.reference_identifier, r.answer.reference_identifier] }
          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "TRUE")
        end

      end

      describe "prepopulated_is_valid_work_address_provided" do

        it "should be FALSE if work address was not previously answered" do
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "FALSE")
        end

        it "should be FALSE if work address was previously answered as refused" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.refused "PREG_VISIT_1_3.WORK_ADDRESS_1"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "FALSE")
        end

        it "should be FALSE if work address was previously answered as don't know" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.dont_know "PREG_VISIT_1_3.WORK_ADDRESS_1"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "FALSE")
        end

        it "should be TRUE if work address was previously answered" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.a "PREG_VISIT_1_3.WORK_ADDRESS_1", "work_address"
          end
          run_populator

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "TRUE")
        end

      end

      describe "prepopulated_is_pv_one_complete" do
        it "should be TRUE if the pv1 event was completed" do
          # create a completed pv1 event
          previous_pv1 = Factory(:event, :event_type_code => Event.pregnancy_visit_1_code,
            :event_end_date => '2025-12-25', :participant => participant)
          previous_contact = Factory(:contact)
          previous_contact_link = Factory(:contact_link, :person => person, :contact => previous_contact, :event => previous_pv1)
          # ensure that the event has been completed
          pv1_code = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_visit_1_code)
          person.participant.completed_event?(pv1_code).should be_true
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_one_complete", "TRUE")

        end

        it "should be FALSE if the pv1 event was NOT completed" do
          # create a pv1 event that was not complete
          previous_pv1 = Factory(:event, :event_type_code => Event.pregnancy_visit_1_code,
            :event_end_date => nil, :participant => participant)
          previous_contact = Factory(:contact)
          previous_contact_link = Factory(:contact_link, :person => person, :contact => previous_contact, :event => previous_pv1)
          # ensure that the event has been completed
          pv1_code = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_visit_1_code)
          person.participant.completed_event?(pv1_code).should be_false

          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_one_complete", "FALSE")
        end

        it "should be FALSE if no pv1 event was scheduled" do
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_one_complete", "FALSE")
        end
      end

      describe "prepopulated_is_pv_two_complete" do
        it "should be TRUE if the pv2 event was completed" do
          # create a completed pv2 event
          previous_pv2 = Factory(:event, :event_type_code => Event.pregnancy_visit_2_code,
            :event_end_date => '2025-12-25', :participant => participant)
          previous_contact = Factory(:contact)
          previous_contact_link = Factory(:contact_link, :person => person, :contact => previous_contact, :event => previous_pv2)
          # ensure that the event has been completed
          pv2_code = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_visit_2_code)
          person.participant.completed_event?(pv2_code).should be_true

          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_two_complete", "TRUE")
        end

        it "should be FALSE if the pv2 event was NOT completed" do
          # create a pv2 event that was not complete
          previous_pv2 = Factory(:event, :event_type_code => Event.pregnancy_visit_2_code,
            :event_end_date => nil, :participant => participant)
          previous_contact = Factory(:contact)
          previous_contact_link = Factory(:contact_link, :person => person, :contact => previous_contact, :event => previous_pv2)
          # ensure that the event has been completed
          pv2_code = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_visit_2_code)
          person.participant.completed_event?(pv2_code).should be_false
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_two_complete", "FALSE")
        end

        it "should be FALSE if no pv2 event was scheduled" do
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_two_complete", "FALSE")
        end
      end

    end

    context "for prepopulated P_TYPE 15 response in part two of M3.2_V3.1" do

      let(:person) { Factory(:person) }
      let(:survey) { create_birth_part_two_survey_for_m3_1_v_3_2 }

      def build_rsp(participant)
        participant.person = person
        participant.save!
        response_set, instrument = prepare_instrument(person,
                                                        participant,
                                                        survey)
        response_set.responses.should be_empty
        Birth.new(response_set)
      end

      describe "prepopulated_is_p_type_fifteen" do
        it "should be TRUE if participant is of p_code 15 type" do
          if Float(NcsNavigatorCore.mdes_version.number) >= 3.2
            rsp = build_rsp(Factory(:participant, :p_type_code => 15))
            rsp.run
            assert_response_value(@response_set_pt2,
                                  "prepopulated_is_p_type_fifteen",
                                  "TRUE")
          else
            pending
          end
        end

        it "should be FALSE if participant is not of p_code 15 type" do
          if Float(NcsNavigatorCore.mdes_version.number) >= 3.2
            rsp = build_rsp(Factory(:participant))
            rsp.run
            assert_response_value(@response_set_pt2,
                                  "prepopulated_is_p_type_fifteen",
                                  "FALSE")
          else
            pending
          end
        end
      end

    end

    context "with birth baby name instrument" do

      let(:person) { Factory(:person) }
      let(:survey) { create_birth_survey_with_prepopulated_mode_of_contact }

      before(:each) do
        participant = Factory(:participant)
        participant.person = person
        participant.save!

        @response_set, @instrument = prepare_instrument(person, participant, survey)
        @response_set.responses.should be_empty
      end

      describe "in person" do
        it "sets prepopulated_mode_of_contact to CAPI" do
          Birth.new(@response_set).run
          @response_set.responses.should_not be_empty
          @response_set.should == @response_set
          @response_set.responses.first.question.reference_identifier.should == "prepopulated_mode_of_contact"
          @response_set.responses.first.to_s.should == "CAPI"
        end
      end

      describe "telephone" do
        it "sets prepopulated_mode_of_contact to CATI" do
          Birth.new(@response_set).tap do |p|
            p.mode = Instrument.cati
            p.run
          end
          @response_set.responses.should_not be_empty
          @response_set.should == @response_set
          @response_set.responses.first.question.reference_identifier.should == "prepopulated_mode_of_contact"
          @response_set.responses.first.to_s.should == "CATI"
        end
      end
    end
  end
end
