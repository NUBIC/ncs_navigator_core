# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::NonInterview do
    include SurveyCompletion

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
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
          assert_response_value(@rsp.populate,
              "prepopulated_is_declined_participation_prior_to_enrollment",
              "TRUE")
        end
        it "should be FALSE if participant declined after the enrollment" do
          assert_response_value(@rsp.populate,
              "prepopulated_is_declined_participation_prior_to_enrollment",
              "FALSE")
        end
      end

  end
end
