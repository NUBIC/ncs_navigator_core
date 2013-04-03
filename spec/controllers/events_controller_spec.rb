# -*- coding: utf-8 -*-

require 'spec_helper'

describe EventsController do

  def valid_attributes
    {
      :event_repeat_key => 0
    }
  end

  context "with an authenticated user" do
    before(:each) do
      @participant = Factory(:participant)
      Participant.any_instance.stub(:pending_events).and_return(["an event"])
      @event = Factory(:event, :participant => @participant,
                       :event_end_date => nil, :event_end_time => nil,
                       :event_type_code => 18) # Birth Event - non-continuable
      login(user_login)

      EventsController.any_instance.stub(:mark_activity_occurred).and_return(true)
    end

    describe "GET index" do
      # id sort for paginate
      it "defaults to sorting events by id" do
        get :index
        assigns(:q).sorts[0].name.should == "id"
      end

      it "performs user selected sort first; id second" do
        get :index, :q => { :s => "event_type_code asc" }
        assigns(:q).sorts[0].name.should == "event_type_code"
        assigns(:q).sorts[1].name.should == "id"
      end
    end

    describe "GET edit" do
      it "assigns the requested event as @event" do
        get :edit, :id => @event.id
        assigns(:event).should eq(@event)
      end
    end

    describe "PUT update" do

      describe "with open contacts" do
        describe "and a non-continuable event" do

          it "should not allow the user to set the event_end_date or time" do
            contact = Factory(:contact, :contact_end_time => nil)
            Factory(:contact_link, :contact => contact, :event => @event)
            @event.event_end_date.should be_nil
            @event.open_contacts?.should be_true

            put :update, :id => @event.id, :event =>
              {'event_end_date' => '2001-01-01', 'event_end_time' => '12:00', 'event_repeat_key' => '99'}
            updated_event = Event.find(@event.id)
            updated_event.event_end_date.should be_nil
            updated_event.event_repeat_key.should == 99
          end

          it "should alert the user on why we could not close the event" do
            contact = Factory(:contact, :contact_end_time => nil)
            Factory(:contact_link, :contact => contact, :event => @event)
            @event.event_end_date.should be_nil
            @event.open_contacts?.should be_true

            put :update, :id => @event.id, :event =>
              {'event_end_date' => '2001-01-01', 'event_end_time' => '12:00', 'event_repeat_key' => '99'}

            flash[:warning].should == "Event cannot be closed. Please close all contacts associated with this event before setting the event end date."
          end
        end

        describe "and a continuable event" do
          it "should allow the user to set the event_end_date or time" do
            @event.update_attribute(:event_type_code, 10) # Informed Consent - continuable
            contact = Factory(:contact, :contact_end_time => nil)
            Factory(:contact_link, :contact => contact, :event => @event)
            @event.event_end_date.should be_nil
            @event.open_contacts?.should be_true

            put :update, :id => @event.id, :event =>
              {'event_end_date' => '2001-01-01', 'event_end_time' => '12:00', 'event_repeat_key' => '99'}
            updated_event = Event.find(@event.id)
            updated_event.event_end_date.should == Date.parse('2001-01-01')
            updated_event.event_repeat_key.should == 99
          end
        end
      end

      describe "with valid params" do
        describe "with html request" do
          it "updates the requested event" do
            Event.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :id => @event.id, :event => {'these' => 'params'}
          end

          it "assigns the requested event as @event" do
            put :update, :id => @event.id, :event => valid_attributes
            assigns(:event).should eq(@event)
          end

          it "redirects to the event" do
            put :update, :id => @event.id, :event => valid_attributes
            response.should redirect_to(participant_path(@participant))
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the event as @event" do
            Event.any_instance.stub(:save).and_return(false)
            put :update, :id => @event.id.to_s, :event => {}
            assigns(:event).should eq(@event)
          end

          it "re-renders the 'edit' template" do
            Event.any_instance.stub(:save).and_return(false)
            put :update, :id => @event.id.to_s, :event => {}
            response.should render_template("edit")
          end
        end
      end

      describe "for an ineligible participant" do

        before do
          @event.update_attribute(:event_type_code, 34) # PBS Participant Eligibility Screening - screener event
          @participant.person = Factory(:person)
          @participant.save!
          Participant.any_instance.stub(:ineligible? => true)
        end

        it "deletes the participant through the EligibilityAdjudicator" do
          @event.participant.should_not be_nil
          put :update, :id => @event.id, :event =>
            {'event_end_date' => '2001-01-01', 'event_end_time' => '12:00', 'event_repeat_key' => '99'}
          updated_event = Event.find(@event.id)
          updated_event.participant.should be_nil
        end
      end

    end

  end

end
