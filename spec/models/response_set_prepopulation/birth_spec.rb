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

    context "for responses from part one prepopulated in part two" do

      let(:person) { Factory(:person) }
      let(:survey_pt1) { create_birth_part_one_survey_with_prepopulated_fields_for_part_two }
      let(:survey_pt2) { create_birth_part_two_survey_with_prepopulated_fields_from_part_one }
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

        @rsp = Birth.new(@response_set_pt2)
      end


      describe "BIRTH_DELIVER" do

        it "response should not exist if the question has not previously been answered" do
          params = { :person => person, :instrument => @instrument_pt2, :survey => survey_pt2 }
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_birth_deliver_from_birth_visit_part_one"
          end
          @response_set_pt2.prepopulate

          responses.should be_empty
        end

        it "should be set to the response from part_one" do
          some_other_place = mock(NcsCode, :local_code => 'some_other_place')
          take_survey(survey_pt1, @response_set_pt1) do |r|
            r.a "BIRTH_VISIT_3.BIRTH_DELIVER", some_other_place
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_birth_deliver_from_birth_visit_part_one", "SOME OTHER PLACE")
        end

      end

      describe "RELEASE" do

        it "response should not exist if the question has not previously been answered" do
          params = { :person => person, :instrument => @instrument_pt2, :survey => survey_pt2 }
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_release_from_birth_visit_part_one"
          end
          @response_set_pt2.prepopulate

          responses.should be_empty
        end

        it "should be set to the response from part_one" do
          take_survey(survey_pt1, @response_set_pt1) do |r|
            r.yes "BIRTH_VISIT_3.RELEASE"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_release_from_birth_visit_part_one", "YES")
        end

      end

      describe "MULTIPLE" do
        it "response should not exist if the question has not previously been answered" do
          params = { :person => person, :instrument => @instrument_pt2, :survey => survey_pt2 }
          responses = @response_set_pt2.responses.select do |r|
            r.question.reference_identifier == "prepopulated_multiple_from_birth_visit_part_one"
          end
          @response_set_pt2.prepopulate

          responses.should be_empty
        end

        it "should be set to the response from part_one" do
          take_survey(survey_pt1, @response_set_pt1) do |r|
            r.no "BIRTH_VISIT_3.MULTIPLE"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_multiple_from_birth_visit_part_one", "NO")
        end

      end

      describe "prepopulated_is_valid_work_name_provided" do

        it "should be FALSE if work name was not previously answered" do
        	@response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "FALSE")
        end

        it "should be FALSE if work name was previously answered as refused" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.refused "PREG_VISIT_1_3.WORK_NAME"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "FALSE")
        end

        it "should be FALSE if work name was previously answered as don't know" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.dont_know "PREG_VISIT_1_3.WORK_NAME"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "FALSE")
        end

        it "should be TRUE if work name was previously answered" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.a "PREG_VISIT_1_3.WORK_NAME", "work_name"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_name_provided", "TRUE")
        end

      end

      describe "prepopulated_is_valid_work_address_provided" do

        it "should be FALSE if work address was not previously answered" do
        	@response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "FALSE")
        end

        it "should be FALSE if work address was previously answered as refused" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.refused "PREG_VISIT_1_3.WORK_ADDRESS_1"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "FALSE")
        end

        it "should be FALSE if work address was previously answered as don't know" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.dont_know "PREG_VISIT_1_3.WORK_ADDRESS_1"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "FALSE")
        end

        it "should be TRUE if work address was previously answered" do
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.a "PREG_VISIT_1_3.WORK_ADDRESS_1", "work_address"
          end
          @response_set_pt2.prepopulate

          assert_response_value(@response_set_pt2, "prepopulated_is_valid_work_address_provided", "TRUE")
        end

      end

      describe "prepopulated_is_pv_one_complete" do
        it "should be TRUE if the pv1 event was completed" do
          Participant.any_instance.stub(:completed_event?).and_return(true)
          @response_set_pt2.prepopulate
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_one_complete", "TRUE")
        end

        it "should be FALSE if the pv1 event was NOT completed" do
          Participant.any_instance.stub(:completed_event?).and_return(false)
          @response_set_pt2.prepopulate
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_one_complete", "FALSE")
        end
      end

      describe "prepopulated_is_pv_two_complete" do
        it "should be TRUE if the pv2 event was completed" do
          Participant.any_instance.stub(:completed_event?).and_return(true)
          @response_set_pt2.prepopulate
          assert_response_value(@response_set_pt2, "prepopulated_is_pv_two_complete", "TRUE")
        end

        it "should be FALSE if the pv2 event was NOT completed" do
          Participant.any_instance.stub(:completed_event?).and_return(false)
          @response_set_pt2.prepopulate
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
