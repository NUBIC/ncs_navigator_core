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
          params = { :person => nil, :instrument => instrument, :survey => survey }
          lambda { ResponseSetPopulator::Base.new(params) }.
            should raise_error(ResponseSetPopulator::InitializationError, 'No person provided')
        end

        it "throws an exception if there is no instrument" do
          params = { :person => person, :instrument => nil, :survey => survey }
          lambda { ResponseSetPopulator::Base.new(params) }.
            should raise_error(ResponseSetPopulator::InitializationError, 'No instrument provided')
        end

        it "throws an exception if there is no survey" do
          params = { :person => person, :instrument => instrument, :survey => nil }
          lambda { ResponseSetPopulator::Base.new(params) }.
            should raise_error(ResponseSetPopulator::InitializationError, 'No survey provided')
        end

        it "creates a new object with the required parameters" do
          params = { :person => person, :instrument => instrument, :survey => survey }
          rsp = ResponseSetPopulator::Base.new(params)
          rsp.should_not be_nil
          rsp.person.should == person
          rsp.instrument.should == instrument
          rsp.survey.should == survey
        end

        describe "with a contact link" do
          it "accepts contact link as an optional parameters" do
            params = { :person => person, :instrument => instrument, :survey => survey, :contact_link => contact_link }
            rsp = ResponseSetPopulator::Base.new(params)
            rsp.should_not be_nil
            rsp.person.should == person
            rsp.instrument.should == instrument
            rsp.survey.should == survey
            rsp.contact_link.should == contact_link
          end

          it "extracts the contact and event from the contact_link" do
            params = { :person => person, :instrument => instrument, :survey => survey, :contact_link => contact_link }
            rsp = ResponseSetPopulator::Base.new(params)
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
            handler = ResponseSetPopulator::Base.populator_for(response_set)
            handler.should == ResponseSetPopulator::PregnancyScreener
          end
        end

        context "with a tracing instrument" do
          it "chooses the ResponseSetPopulator::PregnancyScreener" do
            survey = create_tracing_module_survey_with_email_operational_data
            response_set, instrument = prepare_instrument(person, participant, survey)
            handler = ResponseSetPopulator::Base.populator_for(response_set)
            handler.should == ResponseSetPopulator::TracingModule
          end
        end

      end
    end
  end
end