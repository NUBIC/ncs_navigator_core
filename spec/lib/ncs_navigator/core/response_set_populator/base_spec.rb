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

        describe "with a contact link" do
          it "accepts contact link as an optional parameters" do
            rsp = ResponseSetPopulator::Base.new(person, instrument, survey, contact_link)
            rsp.should_not be_nil
            rsp.person.should == person
            rsp.instrument.should == instrument
            rsp.survey.should == survey
            rsp.contact_link.should == contact_link
          end

          it "extracts the contact and event from the contact_link" do
            rsp = ResponseSetPopulator::Base.new(person, instrument, survey, contact_link)
            rsp.should_not be_nil
            rsp.contact_link.should == contact_link
            rsp.event.should == contact_link.event
            rsp.contact.should == contact_link.contact
          end
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
    end
  end
end