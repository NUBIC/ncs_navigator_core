# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::ChildAndAdHoc do
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

    def get_response_as_string(response_set, reference_identifier)
      response = response_set.responses.select { |r|
        r.question.reference_identifier == reference_identifier
      }.first
      response.to_s
    end

    def init_common_vars(survey_template, *args)
      @survey = send(survey_template, *args)
      @participant = Factory(:participant)
      @person = Factory(:person)
      @participant.person = @person
      @participant.save!
      @response_set, @instrument = prepare_instrument(@person, @participant,
                                                    @survey)
      @response_set.responses.should be_empty
    end

    def complete_event(event, event_complete)
      event.event_disposition_category_code = 3 # General Study Visit Event Code
      event.event_disposition = 60 # Completed Consent/Interview in English
      event.save!
    end

    def make_contact(event_type_code, event_complete = true)
      event = Factory(:event, :event_type_code => event_type_code,
                      :participant => @participant)
      complete_event(event, event_complete) if event_complete

      contact = Factory(:contact)
      contact_link = Factory(:contact_link, :person => @person,
                              :contact => contact, :event => event)
      event
    end

    context "for ad-hoc prepopulators"
      describe "prepopulate_is_birth_or_subsequent_event" do
        before(:each) do
          init_common_vars(:create_generic_true_false_prepopulator_survey,
                "INS_QUE_InternetUseContactPref_SUR_EHPBHI_M2.2_V1.1",
                "prepopulate_is_birth_or_subsequent_event")
        end

        it "should be TRUE if current event is birth" do
          event = Factory(:event, :event_type_code => Event::birth_code,
                          :participant => @participant)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey, :event => event)
          get_response_as_string(rsp.populate,
                  "prepopulate_is_birth_or_subsequent_event").should == "TRUE"
        end

        it "should be FALSE if current event is not birth" do
          event = Factory(:event, :event_type_code => Event::father_visit_code,
                          :participant => @participant)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey, :event => event)
          get_response_as_string(rsp.populate,
                  "prepopulate_is_birth_or_subsequent_event").should == "FALSE"
        end
      end

      describe "prepopulated_is_9_months_completed" do
        before(:each) do
          init_common_vars(:create_generic_true_false_prepopulator_survey,
                "INS_QUE_InternetUseContactPref_SUR_EHPBHI_M2.2_V1.1",
                "prepopulated_is_9_months_completed")
        end

        it "should be TRUE if 9-month event was completed" do
          make_contact(Event::nine_month_visit_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_9_months_completed").should == "TRUE"
        end

        it "should be FALSE if 9-month event was started but not completed" do
          make_contact(Event::nine_month_visit_code, event_complete = false)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_9_months_completed").should == "FALSE"
        end

        it "should be FALSE if other events but not 9-month were completed" do
          make_contact(Event::father_visit_saq_code) # Not 9-month
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_9_months_completed").should == "FALSE"
        end

        it "should be FALSE if no events were completed" do
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_9_months_completed").should == "FALSE"
        end
      end

      describe "prepopulated_is_3_months_completed" do
        before(:each) do
          init_common_vars(:create_generic_true_false_prepopulator_survey,
                "INS_QUE_InternetUseContactPref_SUR_EHPBHI_M2.2_V1.1",
                "prepopulated_is_3_months_completed")
          # Current father event
          @event = make_contact(Event::father_visit_code, event_complete = false)
        end

        it "should be TRUE if 3-month event was completed" do
          make_contact(Event::three_month_visit_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_3_months_completed").should == "TRUE"
        end

        it "should be FALSE if 3-month event was started but not completed" do
          make_contact(Event::three_month_visit_code, event_complete = false)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_3_months_completed").should == "FALSE"
        end

        it "should be FALSE if other events but not 3-month were completed" do
          make_contact(Event::father_visit_saq_code) # Not 3-month
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_3_months_completed").should == "FALSE"
        end

        it "should be FALSE if no events were completed" do
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_3_months_completed").should == "FALSE"
        end
      end

      describe "prepopulated_is_subsequent_father_interview" do
        before(:each) do
          init_common_vars(:create_generic_true_false_prepopulator_survey,
                "INS_QUE_Father_INT_EHPBHI_M2.1_V2.0",
                "prepopulated_is_subsequent_father_interview")
          # Current father event
          @event = make_contact(Event::father_visit_code, event_complete = false)
        end

        it "should be TRUE if a completed father interview took place before" do
          # Previous father event
          make_contact(Event::father_visit_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => @event)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_subsequent_father_interview"
                ).should == "TRUE"
        end

        it "should be TRUE if a incomplete father interview took place before" do
          # Previous father event
          make_contact(Event::father_visit_saq_code, event_complete = false)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => @event)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_subsequent_father_interview"
                ).should == "TRUE"
        end

        it "should be TRUE if father interview never took place before" do
          make_contact(Event::three_month_visit_code) # Not father
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => @event)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_subsequent_father_interview"
                ).should == "FALSE"
        end

        it "should be FALSE if no interviews ever took place before" do
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => @event)
          get_response_as_string(rsp.populate,
                  "prepopulated_is_subsequent_father_interview"
                ).should == "FALSE"
        end
      end

      describe "prepopulated_event_type" do
        before(:each) do
          init_common_vars(:create_con_reconsideration_for_events)
        end

        it "should be '12 MONTH' if EVENT_TYPE = 12_months" do
          event = Factory(:event, :event_type_code =>
                                              Event::twelve_month_visit_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_event_type", "12 MONTH") 
        end

        it "should be 'PV1 or PV2' if EVENT_TYPE = pv1" do
          event = Factory(:event, :event_type_code =>
                                              Event::pregnancy_visit_1_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_event_type", "PV1 or PV2") 
        end
        it "should be 'PV1 or PV2' if EVENT_TYPE = pv1 SAQ" do
          event = Factory(:event, :event_type_code =>
                                              Event::pregnancy_visit_1_saq_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_event_type", "PV1 or PV2") 
        end

        it "should be 'PV1 or PV2' if EVENT_TYPE = pv2" do
          event = Factory(:event, :event_type_code =>
                                              Event::pregnancy_visit_2_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_event_type", "PV1 or PV2") 
        end
        it "should be 'PV1 or PV2' if EVENT_TYPE = pv2 SQA" do
          event = Factory(:event, :event_type_code =>
                                              Event::pregnancy_visit_2_saq_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_event_type", "PV1 or PV2") 
        end 

        it "should be nil if EVENT_TYPE is not 12-month, pv1 or pv2" do
          event = Factory(:event, :event_type_code =>
                                              Event::pregnancy_screener_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_event_type", "") 
        end 
      end

    context "for child prepopulators"
      describe "prepopulated_is_12_month_visit" do
        before(:each) do
          init_common_vars(:create_bio_child_anthr_survey_for_12_month_visit)
        end

        it "should be TRUE if EVENT_TYPE = 12_months" do
          event = Factory(:event, :event_type_code =>
                                              Event::twelve_month_visit_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_is_12_month_visit", "TRUE") 
        end

        it "should be FALSE if EVENT_TYPE = 12_months" do
          event = Factory(:event, :event_type_code =>
                                Event::pregnancy_screener_code) # Not 12 Months
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_is_12_month_visit", "FALSE") 
        end
      end

      describe "prepopulated_is_6_month_event" do
        before(:each) do
          init_common_vars(:create_pm_child_anthr_survey_for_6_month_event)
        end

        it "should be TRUE if EVENT_TYPE = 6_months" do
          event = Factory(:event, :event_type_code =>
                                              Event::six_month_visit_code)
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_is_6_month_event", "TRUE") 
        end

        it "should be FALSE if EVENT_TYPE = 6_months" do
          event = Factory(:event, :event_type_code =>
                                Event::pregnancy_screener_code) # Not 6 Months
          rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                        @survey,
                                                        :event => event)
          assert_match(rsp.populate, "prepopulated_is_6_month_event", "FALSE") 
        end
      end

      describe "prepopulated_should_show_upper_arm_length" do
        before(:each) do
          init_common_vars(
                  :create_pm_child_bp_survey_for_upper_arm_circ_prepopulators)
          @rsp = ResponseSetPopulator::ChildAndAdHoc.new(@person, @instrument,
                                                         @survey)
        end

        def take_anthropo_survey(answer)
          survey = create_pm_child_anthr_survey_for_upper_arm_circ_prepopulators
          response_set, instrument = prepare_instrument(@person, @participant,
                                                        survey)
          response_set.responses.should be_empty

          take_survey(survey, response_set) do |r|
            if !answer
              neg_8 = mock(NcsCode, :local_code => 'neg_8')
              r.a "CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1", neg_8
            else
              r.a "CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1", '1', :value => answer
            end
          end
        end

        it "should set up previously collected AN_MID_UPPER_ARM_CIRC" do
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
