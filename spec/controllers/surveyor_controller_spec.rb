# -*- coding: utf-8 -*-


require 'spec_helper'

describe SurveyorController do

  before(:each) do
    login(user_login)
  end


  describe "GET show" do

    before(:each) do
      @instrument  = Factory(:instrument, :event => Factory(:event, :event_start_date => Date.parse('2011-01-01')))
      @survey = Factory(:survey,
        :title => "xyz", :access_code => "xyz", :sections => [Factory(:survey_section)])
      @response_set = Factory(:response_set, :access_code => "pdq",
        :survey => @survey, :instrument => @instrument)
    end

    it "sets the activity_plan_for_participant" do

      participant = Factory(:participant)

      event = @instrument.event.to_s

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
end
