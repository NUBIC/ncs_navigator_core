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

      plan = InstrumentPlan.new(schedule)
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

  end


end