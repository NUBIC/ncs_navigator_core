# -*- coding: utf-8 -*-

require 'spec_helper'

describe ContactLinksController do
  context "with an authenticated user" do
    before(:each) do
      @participant = Factory(:participant)
      @person = Factory(:person)
      @person_participant_link = Factory(:participant_person_link, :person => @person, :participant => @participant)
      @event = Factory(:event, :participant => @participant, :event_start_date => Date.parse('2010-12-01'),
                       :event_end_date => nil, :event_end_time => nil,
                       :event_type => NcsCode.find_event_by_lbl("pregnancy_visit_1"))
      @contact_link = Factory(:contact_link, :person => @person, :event => @event)
      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(InstrumentPlan.new)
      login(user_login)
    end

    describe "GET index" do

      # id sort for paginate
      it "defaults to sorting contact links by id" do
        get :index
        assigns(:q).sorts[0].name.should == "id"
      end

      it "performs user selected sort first; id second" do
        get :index, :q => { :s => "person_last_name asc" }
        assigns(:q).sorts[0].name.should == "person_last_name"
        assigns(:q).sorts[1].name.should == "id"
      end
    end

    describe "GET select_instrument" do

    	context do
	      before(:each) do
	      	get :select_instrument, :id => @contact_link.id
	      end

	      it "assigns the requested contact_link as @contact_link" do
	        assigns(:contact_link).should eq(@contact_link)
	      end

	      it "assigns the requested contact_link.event as @event" do
	        assigns(:event).should eq(@contact_link.event)
	      end

	      it "assigns the requested contact_link.person as @person" do
	        assigns(:person).should eq(@contact_link.person)
	      end

	      it "assigns the requested contact_link.contact as @contact" do
	        assigns(:contact).should eq(@contact_link.contact)
	      end

	      describe "@participant" do
	      	it "should be the requested contact_link.person.participant if contact_link.person" do
	          assigns(:participant).should eq(@contact_link.person.participant)
	      	end

	      	it "should be null if no contact_link.person" do
	      	  contact_link_no_participant = Factory(:contact_link, :event => @event)
	      	  get :select_instrument, :id => contact_link_no_participant.id
	        	assigns(:participant).should be_nil
	      	end
	      end
      end

      describe "for null participant and event" do
      	before(:each) do
      		contact_link = Factory(:contact_link, :person => Factory(:person))
      		get :select_instrument, :id => contact_link.id
      	end

      	it "@activity_plan should be null" do
      		assigns(:activity_plan).should be_nil
      	end

      	it "@activities_for_event should be null" do
      		assigns(:activities_for_event).should be_nil
      	end

      	it "@current_activity should be null" do
      		assigns(:current_activity).should be_nil
      	end

      	it "@occurred_activities should be null" do
      		assigns(:occurred_activities).should be_nil
      	end

      	it "@saq_activity should be null" do
      		assigns(:saq_activity).should be_nil
      	end
      end

      describe "for a participant with a new schedule" do
      	before(:each) do
      		@plan = InstrumentPlan.from_schedule(participant_schedule)
		      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(@plan)
		      get :select_instrument, :id => @contact_link.id
      	end

      	it "@activity_plan should be participant schedule" do
      		assigns(:activity_plan).should eq(@plan)
      	end

        it "@activities_for_event should be all activities for contact_link.event" do
          assigns(:activities_for_event).size.should == 4
        end

      	it "@current_activity should be first scheduled activity for contact_link.event" do
      		assigns(:current_activity).activity_name.should == "Pregnancy Visit 1 Interview"
      	end

        it "@scheduled_activities should be schedule activities for contact_link.event" do
          assigns(:scheduled_activities).size.should == 3
        end

      	it "@saq_activity should be the SAQ from occurred activities for contact_link.event" do
      		assigns(:saq_activities).size.should == 1
          assigns(:saq_activities).first.activity_name.should == "Pregnancy Visit 1 SAQ"
      	end

        context "with an empty schedule" do
          before(:each) do
            contact_link = Factory(:contact_link, :person => @person, :event => Factory(:event, :event_type => NcsCode.find_event_by_lbl("birth")))
            get :select_instrument, :id => contact_link.id
          end

          it "@activities_for_event should be empty if no schedule activities for contact_link.event" do
            assigns(:activities_for_event).size.should == 0
          end

          it "@current_activity should be null if no schedule activities for contact_link.event" do
            assigns(:current_activity).should be_nil
          end

          it "@saq_activity should be null if no occurred activities for contact_link.event" do
            assigns(:saq_activities).should be_empty
          end
        end

      end

      describe "for a participant with a mostly completed schedule" do
        before(:each) do
          plan = InstrumentPlan.from_schedule(mostly_complete_participant_schedule)
          PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(plan)
          get :select_instrument, :id => @contact_link.id
        end

        it "@current_activity should be first scheduled activity for contact_link.event" do
          assigns(:current_activity).activity_name.should == "Pregnancy Health Care Log"
        end
      end

    end

    describe "GET edit_instrument" do

      it "redirects to the decision page if the instrument is nil" do
        cl = Factory(:contact_link, :instrument => nil)
        get :edit_instrument, :id => cl.id
        response.should redirect_to(decision_page_contact_link_path(cl))
      end

    end

    describe "GET saq_instrument" do

    	before do
    		 NcsNavigatorCore.mdes.stub(:version).and_return("2.0")
    	end

      it "assigns the requested contact_link as @contact_link" do
      	get :saq_instrument, :id => @contact_link.id
        assigns(:contact_link).should eq(@contact_link)
      end

      it "redirects to the decision_page_contact_link_path if no event" do
      	contact_link = Factory(:contact_link, :person => Factory(:person))
    		get :saq_instrument, :id => contact_link.id
        response.should redirect_to(decision_page_contact_link_path(contact_link))
      end

      it "redirects to the decision_page_contact_link_path if no participant" do
      	contact_link = Factory(:contact_link, :event => @event)
    		get :saq_instrument, :id => contact_link.id
        response.should redirect_to(decision_page_contact_link_path(contact_link))
      end

      it "redirects to the decision_page_contact_link_path if occurred saq activity" do
    		get :saq_instrument, :id => @contact_link.id
        response.should redirect_to(decision_page_contact_link_path(@contact_link))
      end

      it "redirects to the decision_page_contact_link_path if no survey for the activity" do
		    PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(InstrumentPlan.from_schedule(participant_schedule))
		    get :saq_instrument, :id => @contact_link.id
        response.should redirect_to(decision_page_contact_link_path(@contact_link))
      end
    end

    def mostly_complete_participant_schedule
      schedule = {
        'days' => {
          '2010-12-01' => {
            'activities' => [
              {
                'id' => '8',
                'activity' => { 'name' => 'Pregnancy Visit 1 Information Sheet' },
                'ideal_date' => '2010-12-01',
                'assignment' => { 'id' => @contact_link.person.participant.p_id },
                'current_state' => { 'name' => 'occurred' },
                'labels' => 'event:pregnancy_visit_1 '
              },
              {
                'id' => '9',
                'activity' => { 'name' => 'Pregnancy Health Care Log' },
                'ideal_date' => '2010-12-01',
                'assignment' => { 'id' => @contact_link.person.participant.p_id },
                'current_state' => { 'name' => 'scheduled' },
                'labels' => 'event:pregnancy_visit_1 '
              }
            ]
          }
        }
      }
    end

    def participant_schedule
    	schedule = {
        'days' => {
        	'2010-12-01' => {
	          'activities' => [
	            {
	              'id' => '1',
	              'activity' => { 'name' => 'Pregnancy Visit 1 Interview', 'type' => 'Instrument' },
	              'ideal_date' => '2010-12-01',
	              'assignment' => { 'id' => @contact_link.person.participant.p_id },
	              'current_state' => { 'name' => 'scheduled' },
	              'labels' => 'event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0 order:01_01 participant_type:mother'
	            },
	            {
	              'id' => '2',
	              'activity' => { 'name' => 'Pregnancy Visit 1 SAQ', 'type' => 'Instrument' },
	              'ideal_date' => '2010-12-01',
	              'assignment' => { 'id' => @contact_link.person.participant.p_id },
	              'current_state' => { 'name' => 'occurred' },
	              'labels' => 'event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_saq_ehpbhi_p2_v2.0 order:02_01 participant_type:mother '
	            },
	            {
	              'id' => '3',
	              'activity' => { 'name' => 'Pregnancy Visit 1 Information Sheet' },
	              'ideal_date' => '2010-12-01',
	              'assignment' => { 'id' => @contact_link.person.participant.p_id },
	              'current_state' => { 'name' => 'scheduled' },
	              'labels' => 'event:pregnancy_visit_1 '
	            },
	            {
	              'id' => '4',
	              'activity' => { 'name' => 'Pregnancy Health Care Log' },
	              'ideal_date' => '2010-12-01',
	              'assignment' => { 'id' => @contact_link.person.participant.p_id },
	              'current_state' => { 'name' => 'scheduled' },
	              'labels' => 'event:pregnancy_visit_1 '
	            }
	          ]
	        }
        }
      }
    end
  end
end
