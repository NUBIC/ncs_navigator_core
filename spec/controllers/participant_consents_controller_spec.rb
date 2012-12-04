# -*- coding: utf-8 -*-


require 'spec_helper'

describe ParticipantConsentsController do

  def valid_attributes
    {
      :psu_code                        => 2000030,
      :consent_type_code               => 1,
      :consent_form_type_code          => 1,
      :consent_given_code              => 1,
      :consent_language_code           => 1,
      :who_consented_code              => 2,
      :consent_translate_code          => 1,
      :reconsideration_script_use_code => 1,
      :consent_version                 => "1.2"
    }
  end

  context "with an authenticated user" do

    let(:mother_person) { Factory(:person) }
    let(:mother) { Factory(:participant, :enroll_status_code => nil) }
    let(:event) { Factory(:event, :participant => mother) }
    let(:contact) { Factory(:contact) }
    let(:contact_link) { Factory(:contact_link, :event => event,
                                 :instrument => nil, :contact => contact,
                                 :person => mother_person) }

    before(:each) do
      login(user_login)
      mother.person = mother_person
      mother.save!
      mother.children.should be_blank
    end

    describe "GET new" do
      it "assigns a new ParticipantConsent as @participant_consent" do
        get :new, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns(:participant_consent).should be_a_new(ParticipantConsent)
      end

      it "associates the given contact_link.contact with the @participant_consent" do
        get :new, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns[:participant_consent].contact.should == contact_link.contact
      end

      it "associates the given participant with the @participant_consent" do
        get :new, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns[:participant_consent].participant.should == mother
      end

      it "creates three associated participant_consent_sample records with the @participant_consent" do
        get :new, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns[:participant_consent].participant_consent_samples.size.should == 3
      end
    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request" do
          it "creates a new ParticipantConsent" do
            expect {
              post :create, :contact_link_id => contact_link.id,
                   :participant_consent => valid_attributes.merge({:participant_id => mother.id})
            }.to change(ParticipantConsent, :count).by(1)
          end

          it "assigns a newly created ParticipantConsent as @participant_consent" do
            post :create, :contact_link_id => contact_link.id,
                 :participant_consent => valid_attributes.merge({:participant_id => mother.id})
            assigns(:participant_consent).should be_a(ParticipantConsent)
            assigns(:participant_consent).should be_persisted
          end

          it "redirects to the contact link decision page" do
            post :create, :contact_link_id => contact_link.id,
                 :participant_consent => valid_attributes.merge({:participant_id => mother.id})
            response.should redirect_to(decision_page_contact_link_path(contact_link))
          end

          it "updates the participant into a enrolled state" do
            mother.should_not be_enrolled
            post :create, :contact_link_id => contact_link.id,
                 :participant_consent => valid_attributes.merge({:participant_id => mother.id})
            Participant.find(mother.id).should be_enrolled
          end

          describe "Informed Consent event" do
            it "creates an Informed Consent Event record and associates it with the contact link" do
              ic = Event.where(:participant_id => mother.id, :event_type_code => Event.informed_consent_code).first
              ic.should be_nil

              post :create, :contact_link_id => contact_link.id,
                   :participant_consent => valid_attributes.merge({:participant_id => mother.id})

              ic = Event.where(:participant_id => mother.id, :event_type_code => Event.informed_consent_code).last
              ic.should_not be_nil
              ic_cl = ic.contact_links.first
              ic_cl.contact.should  == contact_link.contact
              ic_cl.staff_id.should == contact_link.staff_id
              ic_cl.person.should   == contact_link.person
            end

            it "is created only once for the participant for any particular contact" do
              ic = Event.where(:participant_id => mother.id, :event_type_code => Event.informed_consent_code).first
              ic.should be_nil

              3.times do
                post :create, :contact_link_id => contact_link.id,
                     :participant_consent => valid_attributes.merge({:participant_id => mother.id})
              end

              Event.where(:participant_id => mother.id,
                          :event_type_code => Event.informed_consent_code).count.should == 1
            end

            it "is created for the participant for each individual contact" do
              ic = Event.where(:participant_id => mother.id, :event_type_code => Event.informed_consent_code).first
              ic.should be_nil

              3.times do
                post :create, :contact_link_id => contact_link.id,
                     :participant_consent => valid_attributes.merge({:participant_id => mother.id})
              end

              Event.where(:participant_id => mother.id,
                          :event_type_code => Event.informed_consent_code).count.should == 1

              new_contact = Factory(:contact)
              new_contact_link = Factory(:contact_link,
                                         :event => event,
                                         :contact => new_contact,
                                         :person => mother_person)

              post :create, :contact_link_id => new_contact_link.id,
                   :participant_consent => valid_attributes.merge({:participant_id => mother.id})

              Event.where(:participant_id => mother.id,
                          :event_type_code => Event.informed_consent_code).count.should == 2
            end

          end
        end
      end
    end

    describe "GET new_child" do
      it "assigns a new ParticipantConsent as @participant_consent" do
        get :new_child, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns(:participant_consent).should be_a_new(ParticipantConsent)
      end

      it "associates the given contact_link.contact with the @participant_consent" do
        get :new_child, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns[:participant_consent].contact.should == contact_link.contact
      end

      it "assigns a new child participant as @participant" do
        get :new_child, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns(:participant).should be_a_new(Participant)
      end

      it "assigns the given participant with the @child_guardian" do
        get :new_child, :contact_link_id => contact_link.id, :participant_id => mother.id
        assigns[:child_guardian].should == mother
      end
    end

    describe "POST create_child" do
      describe "with valid params" do
        it "creates a new ParticipantConsent" do
          expect {
            post :create_child,
              :contact_link_id => contact_link.id, :participant_id => mother.id,
              :participant_consent => valid_attributes,
              :person => { :first_name => "fn", :last_name => "ln"}
          }.to change(ParticipantConsent, :count).by(1)
          consent = ParticipantConsent.last
          consent.person_who_consented.should == mother.person
          consent.participant.should_not == mother
          consent.participant.should == Participant.last
          consent.contact.should == contact_link.contact
        end

        it "creates a new Person" do
          expect {
            post :create_child,
              :contact_link_id => contact_link.id, :participant_id => mother.id,
              :participant_consent => valid_attributes,
              :person => { :first_name => "fn", :last_name => "ln"}
          }.to change(Person, :count).by(1)
          child = Person.last
          child.first_name.should == "fn"
          child.last_name.should == "ln"
        end

        it "creates a new Participant" do
          expect {
            post :create_child,
              :contact_link_id => contact_link.id, :participant_id => mother.id,
              :participant_consent => valid_attributes,
              :person => { :first_name => "fn", :last_name => "ln"}
          }.to change(Participant, :count).by(1)
          pc = ParticipantConsent.last
          pc.participant.should_not == mother
          child = pc.participant.person
          child.first_name.should == "fn"
          child.last_name.should == "ln"
        end

        it "creates 3 new ParticipantPersonLinks
            (one for child to self, one for child to mother, and one for mother to child)" do
          expect {
            post :create_child,
              :contact_link_id => contact_link.id, :participant_id => mother.id,
              :participant_consent => valid_attributes,
              :person => { :first_name => "fn", :last_name => "ln"}
          }.to change(ParticipantPersonLink, :count).by(3)
          # check relationship from mother to child
          mother.participant_person_links.reload
          mother.children.count.should == 1
          child = mother.children.first
          # check child participant person reflexive relationship
          child.participant.should_not be_blank
          # check child participant relationship to mother
          child.participant.mother.should == mother_person
        end

        it "creates a new Event" do
          pending
          # TODO: create an Informed Consent event
        end

      end
      describe "with invalid params" do
      end
    end

  end
end