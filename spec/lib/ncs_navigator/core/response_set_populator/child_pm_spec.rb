# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::ChildPM do
    include SurveyCompletion

    def get_response(response_set, reference_identifier)
      response = response_set.responses.select { |r|
        r.question.reference_identifier == reference_identifier
      }.first
      response.should_not be_nil
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

    context "for child PM prepopulators"
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

      describe "prepopulated_is_6_month_event" do
        before(:each) do
          init_common_vars(:create_pm_child_anthr_survey_for_6_month_event)
        end

        it "should be TRUE if EVENT_TYPE = 6_months" do
          event = Factory(:event, :event_type_code => 24) # 6 Month
          rsp = ResponseSetPopulator::ChildPM.new(@person, @instrument, @survey,
                                                  :event => event)
          assert_match(rsp.populate, "prepopulated_is_6_month_event", "TRUE") 
        end

        it "should be FASLSE if EVENT_TYPE = 6_months" do
          event = Factory(:event, :event_type_code => 26) # Not 6-Months
          rsp = ResponseSetPopulator::ChildPM.new(@person, @instrument, @survey,
                                                  :event => event)
          assert_match(rsp.populate, "prepopulated_is_6_month_event", "FALSE") 
        end
      end

      describe "prepopulated_should_show_upper_arm_length" do
        before(:each) do
          init_common_vars(
                  :create_pm_child_bp_survey_for_upper_arm_circ_prepopulators)
          @rsp = ResponseSetPopulator::ChildPM.new(@person, @instrument,
                                                   @survey)
        end

        def take_anthropo_survey(answer)
          survey = create_pm_child_anthr_survey_for_upper_arm_circ_prepopulators
          response_set, instrument = prepare_instrument(@person, @participant,
                                                        survey)
          response_set.responses.should be_empty

          take_survey(survey, response_set) do |a|
            if !answer
              neg_8 = mock(NcsCode, :local_code => 'neg_8')
              a.choice("CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1", neg_8)
            else
              a.str("CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1", answer)
            end
          end
        end

        it "should be TRUE if AN_MID_UPPER_ARM_CIRC was previously collected" do
          take_anthropo_survey("18.5")
          assert_multiple_match(@rsp.populate, {
              "prepopulated_should_show_upper_arm_length" => "TRUE",
              "BP_MID_UPPER_ARM_CIRC" => "18.5"
            }
          )
          
        end

        it "should be FALSE if AN_MID_UPPER_ARM_CIRC was not collected" do
          take_anthropo_survey(nil)
          assert_match(@rsp.populate,
              "prepopulated_should_show_upper_arm_length", "FALSE")
        end

        it "should be FALSE if anthropometry survey wasn't completed" do
          assert_match(@rsp.populate,
              "prepopulated_should_show_upper_arm_length", "FALSE")
        end

      end

  end
end
