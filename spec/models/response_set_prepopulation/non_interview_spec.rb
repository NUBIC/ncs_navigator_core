require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)
require File.expand_path('../../../shared/custom_recruitment_strategy', __FILE__)


module ResponseSetPrepopulation
  describe NonInterview do
    it_should_behave_like 'a survey title acceptor', '_NonIntRespQues_' do
      let(:populator) { NonInterview }
    end

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

        @response_set, instrument= prepare_instrument(@participant.person,
                                                     @participant, survey)
        @response_set.responses.should be_empty
        @rsp = NonInterview.new(@response_set)
      end

      describe "prepopulated_is_declined_participation_prior_to_enrollment" do
        before(:each) do
          @yes = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 1)
          @no = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL2", 2)
          @general = NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", 1)
        end

        it "should be TRUE if participant declined prior to enrollment" do
          pending
          pc = Factory(:participant_consent, :consent_given => @yes,
                       :consent_withdraw => @no, :consent_type => @general,
                       :participant => @participant)
          @rsp.run
          assert_match(@response_set,
              "prepopulated_is_declined_participation_prior_to_enrollment",
              "TRUE")
        end

        it "should be FALSE if participant declined after the enrollment" do
          @rsp.run
          assert_match(@response_set,
              "prepopulated_is_declined_participation_prior_to_enrollment",
              "FALSE")
        end
      end

      describe "prepopulated_study_center_type" do

        context "for 'OriginalVanguard'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { OriginalVanguard.new }

          before do
            NcsNavigatorCore.stub(:recruitment_type_id).and_return(4)
          end

          it "should be 'OVC AND EH STUDY CENTER' if OVC type" do
            @rsp.run
            assert_match(@response_set,
                                  "prepopulated_study_center_type",
                                  "OVC AND EH STUDY CENTERS")
          end
        end

        context "for 'EnhancedHousehold'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { EnhancedHousehold.new }

          before do
            NcsNavigatorCore.stub(:recruitment_type_id).and_return(1)
          end

          it "should be 'OVC AND EH STUDY CENTER' if EH type" do
            @rsp.run
            assert_match(@response_set,
                                  "prepopulated_study_center_type",
                                  "OVC AND EH STUDY CENTERS")
          end
        end

        context "for 'TwoTier'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { TwoTier.new }

          before do
            NcsNavigatorCore.stub(:recruitment_type_id).and_return(3)
          end

          it "should not be 'OVC AND EH STUDY CENTER' if not EH or OVC type" do
            @rsp.run
            assert_miss(@response_set,
                                  "prepopulated_study_center_type",
                                  "OVC AND EH STUDY CENTERS")
          end

          it "should not be 'PB AND PBS STUDY CENTERS' if not PB or PBS type" do
            @rsp.run
            assert_miss(@response_set,
                                  "prepopulated_study_center_type",
                                  "PB AND PBS STUDY CENTERS")
          end

          it "should be 'HILI STUDY CENTERS' if HILI type" do
            @rsp.run
            assert_match(@response_set,
                                  "prepopulated_study_center_type",
                                  "HILI STUDY CENTERS")
          end
        end

        context "for 'ProviderBased'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { ProviderBased.new }

          before do
            NcsNavigatorCore.stub(:recruitment_type_id).and_return(2)
          end

          it "should be 'PB AND PBS STUDY CENTERS' if PB type" do
            @rsp.run
            assert_match(@response_set,
                                  "prepopulated_study_center_type",
                                  "PB AND PBS STUDY CENTERS")
          end

        end

        context "for 'ProviderBasedSubsample'" do
          include_context 'custom recruitment strategy'
          let(:recruitment_strategy) { ProviderBasedSubsample.new }

          before do
            NcsNavigatorCore.stub(:recruitment_type_id).and_return(5)
          end

          it "should be 'PB AND PBS STUDY CENTERS' if PBS type" do
            @rsp.run
            assert_match(@response_set,
                                  "prepopulated_study_center_type",
                                  "PB AND PBS STUDY CENTERS")
          end

          it "should not be 'HILI STUDY CENTERS' if not HILI type" do
            @rsp.run
            assert_miss(@response_set,
                                  "prepopulated_study_center_type",
                                  "HILI STUDY CENTERS")
          end
        end

      end
  end
end
