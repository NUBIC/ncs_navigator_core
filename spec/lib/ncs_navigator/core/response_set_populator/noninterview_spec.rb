# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::NonInterview do
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

    context "for non-interview prepopulators"
      let(:survey) { create_non_interview_survey_for_prepopulators }

      before(:each) do
        @participant = Factory(:participant)
        @participant.person = Factory(:person)
        @participant.save!

        response_set, instrument= prepare_instrument(@participant.person,
                                                     @participant, survey)
        response_set.responses.should be_empty
        @rsp = ResponseSetPopulator::NonInterview.new(@participant.person,
                                                      instrument, survey)
      end

      describe "prepopulated_is_declined_participation_prior_to_enrollment" do
        before(:each) do
          @yes = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 1)
          @no = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 2)
          @general = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 1)
        end

        it "should be TRUE if participant declined prior to enrollment" do
          pc = Factory(:participant_consent, :consent_given => @yes,
                       :consent_withdraw => @no, :consent_type => @general,
                       :participant => @participant)
          assert_match(@rsp.populate,
              "prepopulated_is_declined_participation_prior_to_enrollment",
              "TRUE")
        end

        it "should be FALSE if participant declined after the enrollment" do
          assert_match(@rsp.populate,
              "prepopulated_is_declined_participation_prior_to_enrollment",
              "FALSE")
        end
      end

      describe "prepopulated_study_center_type" do
        def set_study_center(center_type)
          # center type is in the form of display_text from NcsCode for
          # readability
          code = NcsCode.for_list_name_and_display_text("RECRUIT_TYPE_CL1",
                                                        center_type)
          NcsNavigator.configuration.recruitment_type_id = code.local_code
          NcsNavigatorCore.recruitment_strategy =
                            RecruitmentStrategy.for_code(code.local_code)
        end
          
        it "should be 'OVC AND EH STUDY CENTER' if OVC type" do
          set_study_center("Original VC")
          assert_match(@rsp.populate,
                                "prepopulated_study_center_type",
                                "OVC AND EH STUDY CENTERS")
        end
        it "should be 'OVC AND EH STUDY CENTER' if EH type" do
          set_study_center("Enhanced Household Enumeration")
          assert_match(@rsp.populate,
                                "prepopulated_study_center_type",
                                "OVC AND EH STUDY CENTERS")
        end
        it "should not be 'OVC AND EH STUDY CENTER' if not EH or OVC type" do
          set_study_center("Two-Tier")
          assert_miss(@rsp.populate,
                                "prepopulated_study_center_type",
                                "OVC AND EH STUDY CENTERS")
        end

        it "should be 'PB AND PBS STUDY CENTERS' if PB type" do
          set_study_center("Provider-Based Recruitment")
          assert_match(@rsp.populate,
                                "prepopulated_study_center_type",
                                "PB AND PBS STUDY CENTERS")
        end
        it "should be 'PB AND PBS STUDY CENTERS' if PBS type" do
          set_study_center("Provider Based Subsample")
          assert_match(@rsp.populate,
                                "prepopulated_study_center_type",
                                "PB AND PBS STUDY CENTERS")
        end
        it "should not be 'PB AND PBS STUDY CENTERS' if not PB or PBS type" do
          set_study_center("Two-Tier")
          assert_miss(@rsp.populate,
                                "prepopulated_study_center_type",
                                "PB AND PBS STUDY CENTERS")
        end

        it "should be 'HILI STUDY CENTERS' if HILI type" do
          set_study_center("Two-Tier")
          assert_match(@rsp.populate,
                                "prepopulated_study_center_type",
                                "HILI STUDY CENTERS")
        end
        it "should not be 'HILI STUDY CENTERS' if not HILI type" do
          set_study_center("Provider Based Subsample")
          assert_miss(@rsp.populate,
                                "prepopulated_study_center_type",
                                "HILI STUDY CENTERS")
        end
      end

  end
end
