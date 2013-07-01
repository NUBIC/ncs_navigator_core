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
      # this removes the call to Ops to get staff members
      # if you need to get the staff list, update this
      controller.stub(:set_staff_list_from_authority => true)
    end

    context "for a new person" do
      before(:each) do
        login(user_login)
        @preg_screen_event = NcsCode.pregnancy_screener
        @ppg12_event = NcsCode.low_intensity_data_collection

        @person      = Factory(:person)
        @participant = Factory(:participant)
        @participant.person = @person
        @participant.save!

        @person.upcoming_events.size.should == 1
        @person.upcoming_events.first.should include("Pregnancy Screener")
        @person.should be_participant
      end

      describe "GET new" do
        context "for an Event" do

          before(:each) do
            Contact.stub(:new).and_return(mock_contact)
            params = {:participant => @participant, :event_type => @preg_screen_event,
                      :psu_code => NcsNavigatorCore.psu_code, :event_start_date => Date.parse("2525-02-01")}
            @event = Factory(:event, params)
            Event.stub(:new).with(params).and_return(@event)
            Event.stub(:schedule_and_create_placeholder).and_return(nil)
            @participant.events << @event
          end

          it "assigns a new contact as @contact" do
            get :new, :person_id => @person.id
            assigns[:contact].should equal(mock_contact)
          end

          it "assigns a new event as @event" do
            get :new, :person_id => @person.id, :event_id => @event.id
            assigns[:event].should == @event
            assigns[:event].event_type.should == @preg_screen_event
          end
        end

        # TODO: be able to create a Contact without an Event - Task #3285
        context "without an Event or a Participant" do
          before(:each) do
            Contact.stub(:new).and_return(mock_contact)
          end

          it "succeeds as an eventless contact" do
            person = Factory(:person)
            expect { get :new, :person_id => person.id }.to_not raise_error
          end
        end
      end

      describe "GET edit" do
        before(:each) do
          @event = Factory(:event, :event_type => @preg_screen_event)
          @contact_link = Factory(:contact_link, :person => @person, :event => @event)
        end

        context "with a mock contact" do
          before do
            Contact.stub(:find).with("37").and_return(mock_contact(
              :set_default_end_time => nil,
              :multiple_unique_events_for_contact? => false
            ))
          end

          it "assigns the requested contact as @contact" do
            get :edit, :id => "37", :contact_link_id => @contact_link.id
            assigns[:contact].should equal(mock_contact)
          end

          it "assigns the contact link event as @event" do
            get :edit, :id => "37", :contact_link_id => @contact_link.id
            assigns[:event].id.should equal(@event.id)
          end
        end

        describe "disposition_group" do
          let(:event) { Factory(:event, :event_type_code => Event.pregnancy_visit_1_code) }
          let(:contact) { Factory(:contact, :contact_type_code => contact_type_code) }
          let(:contact_link) { Factory(:contact_link, :contact => contact, :event => event) }

          describe "when event determines disposition_group" do
            let(:contact_type_code) { Contact::MAILING_CONTACT_CODE }
            it "is Pregnancy Screener Event" do
              get :edit, :id => contact.id, :contact_link_id => @contact_link.id
              assigns[:disposition_group].should == "Pregnancy Screener Event"
            end
          end

          describe "when contact_type is mail" do
            let(:contact_type_code) { Contact::MAILING_CONTACT_CODE }
            it "is Mail" do
              get :edit, :id => contact.id, :contact_link_id => contact_link.id
              assigns[:disposition_group].should == "Mail"
            end
          end

          describe "when contact_type is telephone" do
            let(:contact_type_code) { Contact::TELEPHONE_CONTACT_CODE }
            it "is Telephone" do
              get :edit, :id => contact.id, :contact_link_id => contact_link.id
              assigns[:disposition_group].should == "Telephone"
            end
          end

          describe "when contact_type is nil" do
            let(:contact_type_code) { nil }
            it "is DispositionMapper::GENERAL_STUDY_VISIT_EVENT" do
              get :edit, :id => contact.id, :contact_link_id => contact_link.id
              assigns[:disposition_group].should == DispositionMapper::GENERAL_STUDY_VISIT_EVENT
            end

            describe "and an instrument exists" do
              let(:instrument) { Factory(:instrument, :survey => survey) }
              let(:contact_link_w_instrument) { Factory(:contact_link, :contact => contact, :event => event, :instrument => instrument) }

              describe "with a survey" do
                let(:survey) { Factory(:survey, :title => "survey_title") }
                it "is the survey title" do
                  get :edit, :id => contact.id, :contact_link_id => contact_link_w_instrument.id
                  assigns[:disposition_group].should == "survey_title"
                end
              end

              describe "without a survey" do
                let(:survey) { nil }
                it "is DispositionMapper::GENERAL_STUDY_VISIT_EVENT" do
                  get :edit, :id => contact.id, :contact_link_id => contact_link_w_instrument.id
                  assigns[:disposition_group].should == DispositionMapper::GENERAL_STUDY_VISIT_EVENT
                end
              end
            end

          end
        end
      end

      describe "GET edit with next_event param" do
        it "creates a new contact link and event when continuing to next event" do
          Event.stub(:schedule_and_create_placeholder).and_return(nil)

          date = Date.parse("2525-02-01")
          @contact = Factory(:contact)
          event = Factory(:event, :participant => @participant,
                          :event_start_date => date, :event_end_date => date,
                          :event_type => NcsCode.pregnancy_screener)
          event2 = Factory(:event, :participant => @participant,
                          :event_start_date => date, :event_end_date => nil,
                          :event_type => @ppg12_event)
          contact_link = Factory(:contact_link, :person => @person, :contact => @contact, :event => event)
          @person.upcoming_events.to_s.should include("Pregnancy Screener")

          @participant.register!
          @participant.assign_to_pregnancy_probability_group!
          @participant.events << event
          @participant.events << event2
          Factory(:ppg_status_history, :participant => @participant, :ppg_status_code => 2)

          @person.participant.reload
          @person.contact_links.reload
          @person.upcoming_events.to_s.should include("PPG 1 and 2")
          @person.contact_links.size.should == 1

          get :edit, :id => @contact.id, :contact_link_id => contact_link.id, :next_event => true
          @person.contact_links.reload
          @person.contact_links.size.should == 2
          @person.contact_links.map(&:event).compact.map(&:event_type).uniq.should == [@ppg12_event, @preg_screen_event]
          @person.contact_links.map(&:contact).uniq.should == [@contact]
        end
      end

      describe "GET edit - contact end time" do
        before do
          @contact_link = Factory(:contact_link, :person => @person,
            :contact => Factory(:contact),
            :event => Factory(:event, :event_type => @preg_screen_event))
        end

        it "sets the default end_time for the contact" do
          contact = Factory(:contact, :contact_date_date => Date.today, :contact_end_time => nil)
          get :edit, :id => contact.id, :contact_link_id => @contact_link.id
          assigns[:contact].contact_end_time.should_not be_blank
        end

        it "does not set the end_time for a contact that happened in the past" do
          contact = Factory(:contact, :contact_date_date => 2.days.ago.to_date, :contact_end_time => nil)
          get :edit, :id => contact.id, :contact_link_id => @contact_link.id
          assigns[:contact].contact_end_time.should be_blank
        end
      end
    end

    context "for an existing person" do
      describe "PUT update" do
        before(:each) do
          @person = Factory(:person)
          participant = Factory(:participant)
          participant.person = @person
          participant.save!

          @contact_link = Factory(
            :contact_link,
            :person => @person,
            :provider => nil,
            :contact => Factory(:contact),
            :event => nil
          )
          @contact_link_event = Factory(
            :contact_link,
            :person => @person,
            :provider => nil,
            :contact => Factory(:contact),
            :event => Factory(:event)
          )
          @contact_link_no_part = Factory(
            :contact_link,
            :person => Factory(:person),
            :provider => nil,
            :contact => Factory(:contact),
            :event => nil
          )
        end

        def valid_attributes(contact_link, staff_id = nil)
          hsh = {
            "person_id" => contact_link.person.id,
            "contact_link_id" => contact_link.id,
            "id" => contact_link.contact.id
          }
          hsh["staff_id"] = staff_id unless staff_id.nil?
          hsh
        end

        it "redirects to the contact link's decision page when linked to an event but not to a provider" do
          post :update, valid_attributes(@contact_link_event)
          response.should redirect_to(
              decision_page_contact_link_path(@contact_link_event)
          )
        end

        it "redirects to participant when not linked to an event" do
          post :update, valid_attributes(@contact_link)
          response.should redirect_to(participant_path(@person.participant))
        end

        it "redirects to contact links if not linked to an event and person is not a participant" do
          @person.participant = nil
          @person.save!
          post :update, valid_attributes(@contact_link_no_part)
          response.should redirect_to(contact_links_path)
        end

        it "updates the staff_id attribute if given" do
          @contact_link.staff_id.should_not == "asdf" # sanity check
          post :update, valid_attributes(@contact_link, "asdf")
          updated_contact_link = ContactLink.find @contact_link.id
          updated_contact_link.staff_id.should == "asdf"
        end

      end
    end

    context "for a low_intensity_ppg2_participant" do
      let(:date) { Date.parse("2525-02-01") }
      before(:each) do
        login(user_login)
        @person      = Factory(:person)
        @participant = Factory(:low_intensity_ppg2_participant)
        @participant.person = @person
        @event = Factory(:event, :participant => @participant,
                        :event_start_date => date, :event_end_date => date,
                        :event_type => NcsCode.pregnancy_screener)
        @participant.events << @event
        @participant.save!
        Factory(:ppg_status_history, :participant => @participant, :ppg_status_code => 2)
        Contact.stub(:new).and_return(mock_contact)

        @person.upcoming_events.to_s.should include("PPG 1 and 2")
      end

      describe "GET new" do
        before(:each) do
          expected_params = {
            :participant => @participant,
            :event_type => NcsCode.low_intensity_data_collection,
            :psu_code => NcsNavigatorCore.psu_code,
            :event_start_date => date
          }
          @event33 = Factory(:event, expected_params)
          @participant.events << @event33
          Event.stub(:new).with(expected_params).and_return(@event33)
          Event.stub(:schedule_and_create_placeholder).and_return(nil)
        end

        it "assigns a new contact as @contact" do
          get :new, :person_id => @person.id
          assigns[:contact].should equal(mock_contact)
        end

        it "assigns a new event as @event" do
          get :new, :person_id => @person.id, :event_id => @event33.id
          assigns[:event].should == @event33
          assigns[:event].event_type.local_code.should == 33
        end

        describe "with a given event_type" do
          it "assigns a new event as @event with the given event type" do
            @participant.pending_events.should == [@event33]

            Event.stub(:schedule_and_create_placeholder).and_return(nil)

            get :new, :person_id => @person.id, :event_id => @event33.id, :event_type_id => NcsCode.low_intensity_data_collection.id
            assigns[:event].event_type.local_code.should == NcsCode.low_intensity_data_collection.local_code
          end
        end

      end

    end

    context "PBS provider recruitment event" do

      before(:each) do
        @event = Factory(:event, :event_type_code => 22, :event_start_date => nil, :event_start_time => nil)
        @provider = Factory(:provider)
        @pbs_list = Factory(:pbs_list, :provider => @provider, :pr_recruitment_start_date => nil)
        @provider.pbs_list = @pbs_list
        @provider.save!
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
            :contact_date => '2525-03-03',
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

            it "redirects to the pbs_lists page" do
              post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => contact_attrs
              response.should redirect_to(pbs_list_path(@provider.pbs_list))
            end

            it "sets PR_RECRUITMENT_START_DATE on Provider PBS List to contact date" do
              @pbs_list.pr_recruitment_start_date.should be_blank
              post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => contact_attrs
              PbsList.find(@provider.pbs_list.id).pr_recruitment_start_date.should == Contact.last.contact_date_date
            end

            it "updates the Provider recruitment event record with information from contact" do
              @event.event_start_date.should be_blank
              @event.event_start_time.should be_blank
              post :provider_recruitment, :person_id => @person.id, :event_id => @event.id, :provider_id => @provider.id, :contact => contact_attrs
              e = Event.find(@event.id)
              c = Contact.last
              e.event_start_date.should == c.contact_date_date
              e.event_start_time.should == c.contact_start_time
              e.event_disposition.should == c.contact_disposition
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

      describe "PUT provider_recruitment" do
        def contact_attrs
          {
            "contact_start_time" => "11:22",
            "contact_end_time" => "11:27",
          }
        end

        before(:each) do
          @contact = Factory(:contact)
          @contact_link = Factory(:contact_link, :person => @person, :contact => @contact, :event => @event, :provider => @provider)
        end

        describe "with valid params" do
          describe "with html request" do
            it "updates the requested contact" do
              Contact.any_instance.should_receive(:update_attributes).with(contact_attrs)
              put :update, :id => @contact.id, :contact => contact_attrs, :contact_link_id => @contact_link.id
            end

            it "redirects to the provider's pbs_lists page" do
              put :update, :id => @contact.id, :contact => contact_attrs, :contact_link_id => @contact_link
              response.should redirect_to(pbs_list_path(@provider.pbs_list))
            end

            it "with no provider pbs_lists redirects to the all pbs_lists page" do
              @contact_link.provider = Factory(:provider)
              @contact_link.save!
              put :update, :id => @contact.id, :contact => contact_attrs, :contact_link_id => @contact_link
              response.should redirect_to(pbs_lists_path)
            end
          end
        end
      end
    end

  end
end
