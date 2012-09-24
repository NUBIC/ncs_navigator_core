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


end