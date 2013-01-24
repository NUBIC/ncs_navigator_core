# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::MMother do
    include SurveyCompletion

    def get_response(response_set, reference_identifier)
      response = response_set.responses.select { |r|
        r.question.reference_identifier == reference_identifier
      }.first
      response
    end

    def assert_match(response_set, reference_identifier, value)
      get_response(response_set, reference_identifier).to_s.should == value
    end

    def assert_miss(response_set, reference_identifier, value)
      get_response(response_set, reference_identifier).to_s.should_not == value
    end

    def assert_multiple_match(response_set, question_value)
      question_value.each_pair do |question, value|
        assert_match(response_set, question, value)
      end
    end

    def init_common_vars(survey_template)
      @survey = send(survey_template)
      @participant = Factory(:participant)
      @person = Factory(:person)
      @participant.person = @person
      @participant.save!
      @response_set, @instrument = prepare_instrument(@person, @participant,
                                                      @survey)
      @response_set.responses.should be_empty
    end

    context "for 18MM v2.x prepopulators"
      describe "prepopulated_should_show_upper_arm_length" do
        before(:each) do
          init_common_vars(:create_18mm_v2_survey_for_mold_prepopulators)
          @rsp = ResponseSetPopulator::MMother.new(@person, @instrument,
                                                   @survey)
        end

        def take_mmother_survey(question_dexp_identifier, answer)
          survey = create_18mm_v2_survey_part_three_for_mold_prepopulators
          response_set, instrument = prepare_instrument(@person, @participant,
                                                        survey)
          response_set.responses.should be_empty

          answer_code = mock(NcsCode, :local_code => answer)
          take_survey(survey, response_set) do |a|
            a.choice(question_dexp_identifier, answer_code)
          end
        end

        it "should be TRUE if response to MOLD question was YES" do
          take_mmother_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", 1)
          assert_match(@rsp.populate,
                       "prepopulated_should_show_room_mold_child", "TRUE")
        end
        it "should be FALSE if response to MOLD question was NO" do
          take_mmother_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", 2)
          assert_match(@rsp.populate,
                       "prepopulated_should_show_room_mold_child", "FALSE")
        end

        it "should be FALSE if response to MOLD question was REFUSED" do
          take_mmother_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", "neg_1")
          assert_match(@rsp.populate,
                       "prepopulated_should_show_room_mold_child", "FALSE")
        end
        it "should be FALSE if response to MOLD question was REFUSED" do
          take_mmother_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", "neg_2")
          assert_match(@rsp.populate,
                       "prepopulated_should_show_room_mold_child", "FALSE")
        end
        it "should be FALSE if 18MM part 3 survey was not completed" do
          assert_match(@rsp.populate,
                       "prepopulated_should_show_room_mold_child", "FALSE")
        end
      end

  end
end
