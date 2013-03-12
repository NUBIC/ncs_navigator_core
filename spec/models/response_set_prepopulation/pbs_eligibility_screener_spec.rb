require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe PbsEligibilityScreener do
    it_should_behave_like 'a survey title acceptor', '_PBSamplingScreen_' do
      let(:populator) { PbsEligibilityScreener }
    end

    context "with pbs eligibility screener instrument" do
			
			def init_instrument_and_response_set(event = nil)
        @survey = create_pbs_eligibility_screener_survey_with_prepopulated_questions
        @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
        # sanity check that there are no responses in response set
        @response_set.responses.should be_empty
			end

			def run_populator(event = nil, mode = nil)
	      init_instrument_and_response_set(event)
	      populator.mode = mode
	      populator.run
	    end

			let(:populator) { PbsEligibilityScreener.new(@response_set) }

      before(:each) do
        @person = Factory(:person)
        @participant = Factory(:participant)
        @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)
      end

      describe "contact type" do
        describe "in person" do
          it "sets prepopulated_mode_of_contact to CAPI" do
            run_populator
            @response_set.responses.should_not be_empty
            assert_response_value(@response_set, "prepopulated_mode_of_contact", "CAPI")
          end
        end

        describe "telephone" do
          it "sets prepopulated_mode_of_contact to CATI" do
            run_populator(nil, Instrument.cati)
            assert_response_value(@response_set, "prepopulated_mode_of_contact", "CATI")
          end
        end
      end

      it "sets the psu id" do
        NcsNavigatorCore.stub(:psu).and_return("the_psu")
        run_populator
        assert_response_value(@response_set, "prepopulated_psu_id", "the_psu")
      end

      describe "for a participant associated with a provider" do

        it "sets the practice number" do
          provider = Factory(:provider)
          pbs_list = Factory(:pbs_list, :practice_num => 999, :provider => provider)
          person_provider_link = Factory(:person_provider_link, :person => @person, :provider => provider)

          run_populator
          assert_response_value(@response_set, "prepopulated_practice_num", "999")
        end

        it "does not create a response if the value is nil" do
          provider = Factory(:provider)
          pbs_list = Factory(:pbs_list, :practice_num => nil, :provider => provider)
          person_provider_link = Factory(:person_provider_link, :person => @person, :provider => provider)

          run_populator
          rs = @response_set
          response = rs.responses.select { |r| r.question.reference_identifier == "prepopulated_practice_num" }.first
          response.should be_nil
        end

        it "sets the location id" do
          provider = Factory(:provider)
          person_provider_link = Factory(:person_provider_link, :person => @person, :provider => provider)

          run_populator
          assert_response_value(@response_set, "prepopulated_provider_id", provider.public_id)
        end

        it "sets the name of the practice" do
          provider = Factory(:provider, :name_practice => "provider name of practice")
          person_provider_link = Factory(:person_provider_link, :person => @person, :provider => provider)

          run_populator
          assert_response_value(@response_set, "prepopulated_name_practice", "provider name of practice")
        end

        it "uses the first known provider to prepopulate" do
          provider = Factory(:provider, :name_practice => "provider name of practice")
          person_provider_link = Factory(:person_provider_link, :person => @person, :provider => provider)

          provider = Factory(:provider, :name_practice => "NOT THIS ONE")
          person_provider_link = Factory(:person_provider_link, :person => @person, :provider => provider)

          run_populator
          assert_response_value(@response_set, "prepopulated_name_practice", "provider name of practice")
        end

      end
    end

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

  end
end
