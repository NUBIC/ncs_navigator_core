# -*- coding: utf-8 -*-

require 'spec_helper'

describe ContactsController do

  def mock_contact(stubs={})
    @mock_contact ||= mock_model(Contact, stubs)
  end

  def mock_contact_link(stubs={})
    @mock_contact_link ||= mock_model(ContactLink, stubs)
  end

  def mock_event(stubs={})
    @mock_event ||= mock_model(Event, stubs)
  end

  context "with an authenticated user" do
    before(:each) do
      login(user_login)
      @person = Factory(:person)
    end

    context "for a new person" do
      before(:each) do
        login(user_login)
        Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)

        @preg_screen_event = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Screener", :local_code => 29)
        @ppg12_event = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low Intensity Data Collection", :local_code => 33)

        @person      = Factory(:person)
        @participant = Factory(:participant)
        @participant.person = @person
        @participant.save!

        @person.upcoming_events.should == ["LO-Intensity: Pregnancy Screener"]
        @person.should be_participant
      end

      describe "GET new" do

        before(:each) do
          Contact.stub(:new).and_return(mock_contact)
          params = {:participant => @participant, :event_type => @preg_screen_event, :psu_code => NcsNavigatorCore.psu_code, :event_start_date => Date.today}
          Event.stub(:new).with(params).and_return(mock_event(params))
        end

        it "assigns a new contact as @contact" do
          get :new, :person_id => @person.id
          assigns[:contact].should equal(mock_contact)
        end

        it "assigns a new event as @event" do
          get :new, :person_id => @person.id
          assigns[:event].should equal(mock_event)
          assigns[:event].event_type.should equal(@preg_screen_event)
        end
      end

      describe "GET edit" do

        before(:each) do
          params = {:participant => @participant, :event_type => @preg_screen_event, :psu_code => NcsNavigatorCore.psu_code}
          Event.stub(:new).with(params).and_return(mock_event(params))
          Contact.stub(:find).with("37").and_return(mock_contact)
          ContactLink.stub(:where).and_return([mock_contact_link(:event => mock_event)])
          mock_contact.should_receive(:contact_end_time=)
        end

        it "assigns the requested contact as @contact" do
          get :edit, :id => "37", :person_id => @person.id
          assigns[:contact].should equal(mock_contact)
        end

        it "assigns the contact link event as @event" do
          get :edit, :id => "37", :person_id => @person.id
          assigns[:event].should equal(mock_event)
        end

      end

      describe "GET edit with next_event param" do
        it "creates a new contact link and event when continuing to next event" do
          create_missing_in_error_ncs_codes(Event)
          @contact = Factory(:contact)
          contact_link = Factory(:contact_link, :person => @person, :contact => @contact, :event => Factory(:event, :event_type => @preg_screen_event))
          status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2)
          @person.upcoming_events.should == ["LO-Intensity: Pregnancy Screener"]

          @participant.register!
          @participant.assign_to_pregnancy_probability_group!
          Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)

          @person.participant.reload
          @person.contact_links.reload
          @person.upcoming_events.should == ["LO-Intensity: PPG 1 and 2"]
          @person.contact_links.size.should == 1
          get :edit, :id => @contact.id, :person_id => @person.id, :next_event => true
          @person.contact_links.reload
          @person.contact_links.size.should == 2
          @person.contact_links.map(&:event).map(&:event_type).should == [@ppg12_event, @preg_screen_event]
          @person.contact_links.map(&:contact).uniq.should == [@contact]
        end

      end

    end

    context "for a low_intensity_ppg2_participant" do
      before(:each) do
        login(user_login)
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2)
        Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
        @ppg12_event = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low Intensity Data Collection", :local_code => 33)
        @person      = Factory(:person)
        @participant = Factory(:low_intensity_ppg2_participant)
        @participant.person = @person
        @participant.save!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)
        Contact.stub(:new).and_return(mock_contact)

        @person.upcoming_events.should == ["LO-Intensity: PPG 1 and 2"]
      end

      describe "GET new" do

        before(:each) do
          params = {:participant => @participant, :event_type => @ppg12_event, :psu_code => NcsNavigatorCore.psu_code, :event_start_date => Date.today}
          Event.stub(:new).with(params).and_return(mock_event(params))
        end

        it "assigns a new contact as @contact" do
          get :new, :person_id => @person.id
          assigns[:contact].should equal(mock_contact)
        end

        it "assigns a new event as @event" do
          get :new, :person_id => @person.id
          assigns[:event].should equal(mock_event)
          assigns[:event].event_type.should equal(@ppg12_event)
        end
      end

      describe "GET new with a given event_type" do
        it "assigns a new event as @event with the given event type" do
          @preg_screen_event = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Screener", :local_code => 29)
          get :new, :person_id => @person.id, :event_type_id => @preg_screen_event.id
          assigns[:event].event_type.should == @preg_screen_event
        end
      end

    end

  end
end