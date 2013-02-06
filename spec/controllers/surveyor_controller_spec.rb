# -*- coding: utf-8 -*-


require 'spec_helper'

describe SurveyorController do

  before(:each) do
    login(user_login)
  end


  describe "GET show" do

    before(:each) do
      event = Factory(:event, :event_start_date => Date.parse('2011-01-01'))
      @instrument  = Factory(:instrument, :event => event)
      contact_link = Factory(:contact_link, :event => event, :instrument => @instrument)
      @survey = Factory(:survey,
        :title => "xyz", :access_code => "xyz", :sections => [Factory(:survey_section)])
      @response_set = Factory(:response_set, :access_code => "pdq",
        :survey => @survey, :instrument => @instrument)
    end

    it "sets the activity_plan_for_participant" do

      participant = Factory(:participant)

      event = @instrument.event.event_type.to_s

      schedule = {
        'days' => {
          '2011-01-01' => {
            'activities' => [
              {
                'id' => '1',
                'activity' => { 'name' => event },
                'ideal_date' => '2011-01-01',
                'assignment' => { 'id' => participant.p_id },
                'current_state' => { 'name' => 'scheduled' },
                'labels' => "event:#{event.downcase.gsub(" ", "_")}",
              }
            ]
          }
        }
      }

      plan = InstrumentPlan.from_schedule(schedule)
      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(plan)

      @response_set.participant = participant
      @response_set.save!
      get :show, :survey_code => @survey.access_code, :response_set_code => @response_set.access_code
      assigns[:activities_for_event].should_not be_nil
      assigns[:activities_for_event].should_not be_empty
    end

    it "safely handles response_sets without a participant" do
      @response_set.participant.should be_nil
      get :show, :survey_code => @survey.access_code, :response_set_code => @response_set.access_code
      assigns[:activities_for_event].should_not be_nil
      assigns[:activities_for_event].should be_empty
    end

    it "sets participant'mother as participant for activity_plan from psc if participant is child" do
      mother_participant = Factory(:participant)
      mother_person = Factory(:person)
      person_participant_link_for_mother = Factory(:participant_person_link, :participant => mother_participant, :person => mother_person)
      child_participant = Factory(:participant, :p_type_code => 6)
      person_participant_link_for_child = Factory(:participant_person_link, :participant => child_participant, :person => mother_person, :relationship_code => 2)

      @response_set.participant = child_participant
      @response_set.save!

      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(InstrumentPlan.new)
      get :show, :survey_code => @survey.access_code, :response_set_code => @response_set.access_code
      assigns[:participant].should == mother_participant
    end

    it "sets participant as participant for activity_plan from psc if participant is not child" do
      participant = Factory(:participant)
      @response_set.participant = participant
      @response_set.save!

      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(InstrumentPlan.new)
      get :show, :survey_code => @survey.access_code, :response_set_code => @response_set.access_code
      assigns[:participant].should == participant
    end

  end

  describe 'PUT one set of responses' do
    describe 'when there is an exception' do
      # Test setup copied from surveyor's surveyor_controller_spec, mostly.

      let(:survey_code) { 'XYZ' }
      let!(:survey) { Factory(:survey, :title => survey_code, :access_code => survey_code) }

      let(:response_set_code) { 'PDQ' }
      let!(:response_set) { Factory(:response_set, :access_code => response_set_code, :survey => survey) }

      let(:responses_ui_hash) { {} }

      let(:params) {
        {
          :survey_code => survey_code,
          :response_set_code => response_set_code,
          :r => responses_ui_hash.empty? ? nil : responses_ui_hash
        }
      }

      def do_put
        xhr :put, :update, params
      end

      def a_ui_response(hash)
        { 'api_id' => 'something' }.merge(hash)
      end

      before do
        responses_ui_hash['11'] = a_ui_response('answer_id' => '56', 'question_id' => '9')

        ResponseSet.stub!(:find_by_access_code).and_return(response_set)
      end

      it 'retries the update on an optimistic locking failure' do
        response_set.should_receive(:update_from_ui_hash).ordered.
          with(responses_ui_hash).and_raise(ActiveRecord::StaleObjectError)
        response_set.should_receive(:update_from_ui_hash).ordered.
          with(responses_ui_hash)

        lambda { do_put }.should_not raise_error
      end

      it 'retries the update on a constraint violation' do
        response_set.should_receive(:update_from_ui_hash).ordered.
          with(responses_ui_hash).and_raise(ActiveRecord::StatementInvalid)
        response_set.should_receive(:update_from_ui_hash).ordered.
          with(responses_ui_hash)

        lambda { do_put }.should_not raise_error
      end

      it 'only retries three times' do
        response_set.should_receive(:update_from_ui_hash).exactly(3).times.
          with(responses_ui_hash).and_raise(ActiveRecord::StaleObjectError)

        lambda { do_put }.should raise_error(ActiveRecord::StaleObjectError)
      end

      it 'does not retry for other errors' do
        response_set.should_receive(:update_from_ui_hash).once.
          with(responses_ui_hash).and_raise('Bad news')

        lambda { do_put }.should raise_error('Bad news')
      end
    end
  end

  context "Updating after a survey" do
    before do
      @survey_controller =  SurveyorController.new
      @person = Factory(:person)
      @participant = Factory(:participant)
      @response_set = Factory(:response_set, :user_id => @person.id, :participant_id => @participant.id)
    end

    describe "#update_participant_based_on_survey" do
      before do
        @ineligible_person = Factory(:person)
        @eligible_person   = Factory(:person)
        @participant.stub!(:update_state_after_survey).and_return true
        ApplicationController.any_instance.stub!(:psc).and_return true
        @eligible_response_set = Factory(:response_set, :person => @ineligible_person, :participant_id => @participant.id)
        @ineligible_response_set = Factory(:response_set, :person => @eligible_person, :participant_id => @participant.id)
      end

      it "calls #update_state_after_survey for eligible people" do
        @response_set.participant.should_receive(:update_state_after_survey)
        @survey_controller.send(:update_participant_based_on_survey, @eligible_response_set)
      end

      it "for ineligible people, disassociates them from the response set" do
        @survey_controller.send(:update_participant_based_on_survey, @ineligible_response_set)
        @response_set.participant.should be_nil
      end

      it "for ineligible people, deletes any events associated with them" do
        Factory(:event, :participant_id => @participant.id)
        Factory(:event, :participant_id => @participant.id)
        @survey_controller.send(:update_participant_based_on_survey, @ineligible_response_set)
        Event.where(:participant_id => @participant.id).count.should be(0)
      end

      it "for ineligible people, deletes their participant record and participant person link" do
        Factory(:participant_person_link, :person_id => @ineligible_person.id, :participant_id => @participant.id)
        @survey_controller.send(:update_participant_based_on_survey, @ineligible_response_set)
        @ineligible_person.participant.should be_nil
      end

      it "for ineligible people, creates an ineligibility record" do
        provider = Factory(:provider)
        Factory(:person_provider_link, :person_id => @person.id, :provider_id => provider.id)
        Factory(:participant_person_link, :person_id => @person.id, :participant_id => @participant.id)
        @survey_controller.send(:update_participant_based_on_survey, @ineligibile_response_set)
        SampledPersonsIneligibility.count.should == 1
      end
    end

    describe "#person_taking_screener_ineligible?" do
      before do
        @screener_survey     = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0")
        @non_screener_survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
        @screener_response_set     = Factory(:response_set, :survey_id => @screener_survey.id)
        @non_screener_response_set = Factory(:response_set, :survey_id => @non_screener_survey.id)
        @ineligible_person = double("person", :eligible? => false)
        @eligible_person   = double("person", :eligible? => true)
      end

      it "if survey is screener and the person is eligible, returns false" do
        @survey_controller.send(:person_taking_screener_ineligible?, @eligible_person, @screener_response_set).should be_false
      end

      it "if survey is screener and the person is not eligible returns true" do
        @survey_controller.send(:person_taking_screener_ineligible?, @ineligible_person, @screener_response_set).should be_true
      end

      it "if survey is not screener and the person is eligible, returns false" do
        @survey_controller.send(:person_taking_screener_ineligible?, @eligible_person, @non_screener_response_set).should be_false
      end

      it "if survey is not screener and the person is not eligible, returns false" do
        @survey_controller.send(:person_taking_screener_ineligible?, @ineligible_person, @non_screener_response_set).should be_false
      end
    end

    describe "#delete_participant_person_links" do
      before do
        @participant_person_link = Factory(:participant_person_link, :person_id => @person.id, :participant_id => @participant.id)
      end

      it "deletes all participant_person_links for a particular participant person combination" do
        @survey_controller.send(:delete_participant_person_links, @person, @participant)
        @person.participant.should be_nil
      end
    end

    describe "#disassociates_participant_from_all_events" do
      before do
        @event1 = Factory(:event, :participant_id => @participant.id)
        @event2 = Factory(:event, :participant_id => @participant.id)
      end
      it "sets the participant_id to nil for all events associated with the person" do
        @survey_controller.send(:disassociates_participant_from_all_events, @participant)
        Event.where(:participant_id => @participant.id).count.should be(0)
      end
    end

    describe "#disassociates_participant_from_response_set" do
      before do
        @response_set = Factory(:response_set, :participant_id => @participant)
      end

      it "sets the participant_id to nil for the response set" do
        @survey_controller.send(:disassociates_participant_from_response_set, @participant)
        @response_set.participant.should be_nil
      end
    end

    describe "#creates_ineligibility_record" do
      before do
        provider = Factory(:provider)
        Factory(:person_provider_link, :person_id => @person.id, :provider_id => provider.id)
        Factory(:participant_person_link, :person_id => @person.id, :participant_id => @participant.id)
      end

      it "calls #create_from_particpant! from the SampledPersonsIneligibility class" do
        SampledPersonsIneligibility.should_receive(:create_from_participant!).with(@participant).and_return(an_instance_of(SampledPersonsIneligibility))
        @survey_controller.send(:creates_ineligibility_record, @participant)
      end

      it "creates an ineligibility record" do
        @survey_controller.send(:creates_ineligibility_record, @participant)
        SampledPersonsIneligibility.count.should == 1
      end
    end
  end
end
