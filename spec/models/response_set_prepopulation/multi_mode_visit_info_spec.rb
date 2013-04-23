require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe MultiModeVisitInfo do
    it_should_behave_like 'a survey title acceptor', '_MultiModeVisitInfo_' do
      let(:populator) { MultiModeVisitInfo }
    end

    context "with mmvis instrument" do
      def setup(mode, event_type_code = Event.other_code)
        person = Factory(:person)
        participant = Factory(:participant)
        ppl = Factory(:participant_person_link, :participant => participant, :person => person, :relationship_code => 1)

        event = Factory(:event, :participant => participant, :event_type_code => event_type_code)
        survey = create_mmvis_survey_with_prepopulated_questions
        instrument = prepare_prepopulated_instrument(person, participant, survey, mode, event)
        instrument.response_sets.size.should == 1
        @response_set = instrument.response_sets.first
      end


      describe "prepopulated_mode_of_contact" do
        context "Instrument mode is capi" do
          it "sets prepopulated_mode_of_contact to capi" do
            setup(Instrument.capi)
            @response_set.responses.should_not be_empty
            @response_set.should have_response("prepopulated_mode_of_contact", "capi")
          end
        end

        context "Instrument mode is cati" do
          it "sets prepopulated_mode_of_contact to cati" do
            setup(Instrument.cati)
            @response_set.responses.should_not be_empty
            @response_set.should have_response("prepopulated_mode_of_contact", "cati")
          end
        end

        context "Instrument mode is papi" do
          it "sets prepopulated_mode_of_contact to papi" do
            setup(Instrument.papi)
            @response_set.responses.should_not be_empty
            @response_set.should have_response("prepopulated_mode_of_contact", "papi")
          end
        end
      end

      describe "prepopulate_is_birth_or_subsequent_event" do
        context "event.event_type_code is before birth" do
          it "sets prepopulate_is_birth_or_subsequent_event to false" do
            setup(Instrument.capi,Event.pv1_code)
            @response_set.responses.should_not be_empty
            @response_set.should have_response("prepopulate_is_birth_or_subsequent_event", "false")
          end
        end

        context "event.event_type_code is birth" do
          it "sets prepopulate_is_birth_or_subsequent_event to true" do
            setup(Instrument.capi, Event.birth_code)
            @response_set.responses.should_not be_empty
            @response_set.should have_response("prepopulate_is_birth_or_subsequent_event", "true")
          end
        end

        context "event.event_type_code is after birth" do
          it "sets prepopulate_is_birth_or_subsequent_event to true" do
            setup(Instrument.capi, Event.twenty_four_month_visit_code)
            @response_set.responses.should_not be_empty
            @response_set.should have_response("prepopulate_is_birth_or_subsequent_event", "true")
          end
        end

      end
    end
  end
end
