# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::Base do

    context "processing response sets" do
      let(:person) { Factory(:person) }
      let(:survey) { Factory(:survey) }
      let(:contact) { Factory(:contact) }
      let(:instrument) { Factory(:instrument) }
      let(:participant) { Factory(:participant) }
      let(:event) { Factory(:event, :participant => participant) }
      let(:contact_link) { Factory(:contact_link, :person => person, :event => event, :contact => contact) }

      before(:each) do
        participant.person = person
        participant.save!
      end

      describe "#new" do

        it "throws an exception if there is no person" do
          lambda { ResponseSetPopulator::Base.new(nil, instrument, survey) }.
            should raise_error(ResponseSetPopulator::InitializationError, 'No person provided')
        end

        it "throws an exception if there is no instrument" do
          lambda { ResponseSetPopulator::Base.new(person, nil, survey) }.
            should raise_error(ResponseSetPopulator::InitializationError, 'No instrument provided')
        end

        it "throws an exception if there is no survey" do
          lambda { ResponseSetPopulator::Base.new(person, instrument, nil) }.
            should raise_error(ResponseSetPopulator::InitializationError, 'No survey provided')
        end

        it "creates a new object with the required parameters" do
          rsp = ResponseSetPopulator::Base.new(person, instrument, survey)
          rsp.should_not be_nil
          rsp.person.should == person
          rsp.instrument.should == instrument
          rsp.survey.should == survey
        end

        describe "with a mode" do
          it "accepts mode as an optional parameters" do
            rsp = ResponseSetPopulator::Base.new(person, instrument, survey, :mode => Instrument.cati)
            rsp.mode.should == Instrument.cati
            rsp.mode_to_text.should == 'cati'
          end

          it "defaults mode to 'capi'" do
            rsp = ResponseSetPopulator::Base.new(person, instrument, survey)
            rsp.mode.should == Instrument.capi
            rsp.mode_to_text.should == 'capi'
          end
        end

        describe "with an event" do
        end

      end

      describe "#populator_for" do

        context "with a pregnancy screener instrument" do
          it "chooses the ResponseSetPopulator::PregnancyScreener" do
            survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
            response_set, instrument = prepare_instrument(person, participant, survey)
            handler = ResponseSetPopulator::Base.populator_for(survey)
            handler.should == ResponseSetPopulator::PregnancyScreener
          end
        end

        context "with a tracing instrument" do
          it "chooses the ResponseSetPopulator::PregnancyScreener" do
            survey = create_tracing_module_survey_with_email_operational_data
            response_set, instrument = prepare_instrument(person, participant, survey)
            handler = ResponseSetPopulator::Base.populator_for(survey)
            handler.should == ResponseSetPopulator::TracingModule
          end
        end

        context "with a low intensity instrument" do
          it "chooses the ResponseSetPopulator::LowIntensity" do
            survey = create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data
            response_set, instrument = prepare_instrument(person, participant, survey)
            handler = ResponseSetPopulator::Base.populator_for(survey)
            handler.should == ResponseSetPopulator::LowIntensity
          end
        end

      end

      describe "#mode_to_text" do
        it "returns 'capi' when given mode is not specified" do
          ResponseSetPopulator::Base.new(person, instrument, survey).mode_to_text.should == "capi"
        end
        it "returns 'capi' when given Instrument.capi" do
          ResponseSetPopulator::Base.new(person, instrument, survey, :mode => Instrument.capi).mode_to_text.should == "capi"
        end
        it "returns 'cati' when given Instrument.cati" do
          ResponseSetPopulator::Base.new(person, instrument, survey, :mode => Instrument.cati).mode_to_text.should == "cati"
        end
        it "returns 'papi' when given Instrument.papi" do
          ResponseSetPopulator::Base.new(person, instrument, survey, :mode => Instrument.papi).mode_to_text.should == "papi"
        end
      end
    end
  end
end