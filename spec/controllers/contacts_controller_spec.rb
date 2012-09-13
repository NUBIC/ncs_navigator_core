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
        @preg_screen_event = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 29)
        @ppg12_event = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33)

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
          # TODO: Event is a value object. Why stub?
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
          Contact.stub(:find).with("37").and_return(mock_contact(:set_default_end_time => nil))
          ContactLink.stub(:where).and_return([mock_contact_link(:event => mock_event)])
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
          @contact = Factory(:contact)
          contact_link = Factory(:contact_link, :person => @person, :contact => @contact, :event => Factory(:event, :event_type => @preg_screen_event))
          @person.upcoming_events.to_s.should include("Pregnancy Screener")

          @participant.register!
          @participant.assign_to_pregnancy_probability_group!
          Factory(:ppg_status_history, :participant => @participant, :ppg_status_code => 2)

          @person.participant.reload
          @person.contact_links.reload
          @person.upcoming_events.to_s.should include("PPG 1 and 2")
          @person.contact_links.size.should == 1
          get :edit, :id => @contact.id, :person_id => @person.id, :next_event => true
          @person.contact_links.reload
          @person.contact_links.size.should == 2
          @person.contact_links.map(&:event).map(&:event_type).should == [@ppg12_event, @preg_screen_event]
          @person.contact_links.map(&:contact).uniq.should == [@contact]
        end

      end

      describe "GET edit - contact end time" do

        before do
          ContactLink.stub(:where).and_return([mock_contact_link(:event => mock_event)])
        end

        it "sets the default end_time for the contact" do
          contact = Factory(:contact, :contact_date_date => Date.today, :contact_end_time => nil)
          get :edit, :id => contact.id, :person_id => @person.id
          assigns[:contact].contact_end_time.should_not be_blank
        end

        it "does not set the end_time for a contact that happened in the past" do
          contact = Factory(:contact, :contact_date_date => 2.days.ago.to_date, :contact_end_time => nil)
          get :edit, :id => contact.id, :person_id => @person.id
          assigns[:contact].contact_end_time.should be_blank
        end
      end


    end



    context "for a low_intensity_ppg2_participant" do
      before(:each) do
        login(user_login)
        @person      = Factory(:person)
        @participant = Factory(:low_intensity_ppg2_participant)
        @participant.person = @person
        @participant.save!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status_code => 2)
        Contact.stub(:new).and_return(mock_contact)

        @person.upcoming_events.to_s.should include("PPG 1 and 2")
      end

      describe "GET new" do
        before(:each) do
          expected_params = {
            :participant => @participant,
            :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33),
            :psu_code => NcsNavigatorCore.psu_code,
            :event_start_date => Date.today
          }
          # TODO: Event is a value object. Why stub?
          Event.stub(:new).with(expected_params).and_return(mock_event(expected_params))
        end

        it "assigns a new contact as @contact" do
          get :new, :person_id => @person.id
          assigns[:contact].should equal(mock_contact)
        end

        it "assigns a new event as @event" do
          get :new, :person_id => @person.id
          assigns[:event].should equal(mock_event)
          assigns[:event].event_type.local_code.should equal(33)
        end
      end

      describe "GET new with a given event_type" do
        it "assigns a new event as @event with the given event type" do
          # TODO: code?
          @preg_screen_event = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 29)
          get :new, :person_id => @person.id, :event_type_id => @preg_screen_event.id
          assigns[:event].event_type.local_code.should == @preg_screen_event.local_code
        end
      end

    end

    context "PBS provider recruitment event" do

      before(:each) do
        @event = Factory(:event, :event_type_code => 22)
        @provider = Factory(:provider)
      end

      describe "GET provider_recruitment" do

        it "assigns the requested event as @event" do
          get :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id
          assigns(:event).should eq(@event)
        end

        it "assigns the requested provider as @provider" do
          get :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id
          assigns(:event).should eq(@event)
        end

        it "assigns a new contact as @contact" do
          Contact.stub(:new).and_return(mock_contact)
          get :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id
          assigns[:contact].should equal(mock_contact)
        end

      end

      describe "POST provider_recruitment" do

        def contact_attrs
          {
            :contact_date => Date.today,
            :contact_start_time => "11:22",
            :contact_end_time => "11:27",
          }
        end

        describe "with valid params" do
          describe "with html request" do
            it "creates a new Contact" do
              expect {
                post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => contact_attrs
              }.to change(Contact, :count).by(1)
            end

            it "assigns a newly created contact as @contact" do
              post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => contact_attrs
              assigns(:contact).should be_a(Contact)
              assigns(:contact).should be_persisted
            end

            it "redirects to the post_recruitment_contact provider page" do
              post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => contact_attrs
              response.should redirect_to(post_recruitment_contact_provider_path(@provider, :contact_id => assigns(:contact).id))
            end
          end
        end

        describe "with invalid params" do
          describe "with html request" do
            it "assigns a newly created but unsaved contact as @contact" do
              # Trigger the behavior that occurs when invalid params are submitted
              Contact.any_instance.stub(:save).and_return(false)
              post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => {}
              assigns(:contact).should be_a_new(Contact)
            end

            it "re-renders the 'provider_recruitment' template" do
              # Trigger the behavior that occurs when invalid params are submitted
              Contact.any_instance.stub(:save).and_return(false)
              post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => {}
              response.should render_template("provider_recruitment")
            end
          end

        end
      end


    end

  end
end