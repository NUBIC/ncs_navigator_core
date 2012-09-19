# -*- coding: utf-8 -*-


require 'spec_helper'

describe SurveyorController do

  before(:each) do
    login(user_login)
  end


  describe "GET show" do

    before(:each) do
      @instrument  = Factory(:instrument, :event => Factory(:event))
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

    it "sets correct participant for activity_plan from psc for multiple survey for single instrument" do
      @response_set.participant = Factory(:participant)
      @response_set.save!
      survey1 = Factory(:survey,
        :title => "abc", :access_code => "abc", :sections => [Factory(:survey_section)])
      response_set1 = Factory(:response_set, :access_code => "efg",
        :survey => survey1, :instrument => @instrument, :participant => Factory(:participant))

      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(InstrumentPlan.new)
      get :show, :survey_code => survey1.access_code, :response_set_code => response_set1.access_code
      assigns[:participant].should == response_set1.instrument.response_sets.first.participant
    end

    it "sets correct participant for activity_plan from psc for single survey" do
      @response_set.participant = Factory(:participant)
      @response_set.save!

      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(InstrumentPlan.new)
      get :show, :survey_code => @survey.access_code, :response_set_code => @response_set.access_code
      assigns[:participant].should == @response_set.instrument.response_sets.first.participant
    end

  end


end