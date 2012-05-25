# -*- coding: utf-8 -*-

require 'spec_helper'

describe ParticipantVisitRecordsController do

  context "with an authenticated user" do

    let(:contact) { Factory(:contact) }
    let(:contact_link) { Factory(:contact_link, :contact => contact) }
    let(:participant_visit_record) { Factory(:participant_visit_record) }

    before(:each) do
      login(user_login)
    end

    describe "GET new" do
      it "assigns a new ParticipantVisitRecord as @participant_visit_record" do
        get :new, :contact_link_id => contact_link.id
        assigns(:participant_visit_record).should be_a_new(ParticipantVisitRecord)
      end

      it "associates the given contact_link.contact with the @participant_visit_record" do
        get :new, :contact_link_id => contact_link.id
        assigns[:participant_visit_record].contact.should == contact_link.contact
      end

      it "associates the given contact_link.event.participant with the @participant_visit_record" do
        get :new, :contact_link_id => contact_link.id
        assigns[:participant_visit_record].participant.should == contact_link.event.participant
      end

      it "associates the given contact_link.person with the @participant_visit_record as rvis_person" do
        get :new, :contact_link_id => contact_link.id
        assigns[:participant_visit_record].rvis_person.should == contact_link.person
      end

    end

    describe "GET new.json" do
      it "returns a json representation of the desired participant_visit_record"
    end

    describe "GET edit" do

      it "assigns the requested participant_visit_record as @participant_visit_record" do
        get :edit, :id => participant_visit_record.id, :contact_link_id => contact_link.id
        assigns(:participant_visit_record).should eq(participant_visit_record)
      end

    end

    def valid_attributes
      {
        :participant_id            => contact_link.event.participant_id,
        :rvis_person_id            => contact_link.person_id,
        :contact_id                => contact_link.contact_id,
        :rvis_language_code        => 1,
        :rvis_who_consented_code   => 1,
        :rvis_translate_code       => 1,
        :rvis_sections_code        => 1,
        :rvis_during_interv_code   => 1,
        :rvis_during_bio_code      => 1,
        :rvis_bio_cord_code        => 1,
        :rvis_during_env_code      => 1,
        :rvis_during_thanks_code   => 1,
        :rvis_after_saq_code       => 1,
        :rvis_reconsideration_code => 1,
      }
    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request" do
          it "creates a new ParticipantVisitRecord" do
            expect {
              post :create, :participant_visit_record => valid_attributes, :contact_link_id => contact_link.id
            }.to change(ParticipantVisitRecord, :count).by(1)
          end

          it "assigns a newly created participant_visit_record as @participant_visit_record" do
            post :create, :participant_visit_record => valid_attributes, :contact_link_id => contact_link.id
            assigns(:participant_visit_record).should be_a(ParticipantVisitRecord)
            assigns(:participant_visit_record).should be_persisted
          end

          it "redirects to the decision_page_contact_link page" do
            post :create, :participant_visit_record => valid_attributes, :contact_link_id => contact_link.id
            response.should redirect_to(decision_page_contact_link_path(contact_link))
          end
        end

        describe "with json request" do
          it "creates a new ParticipantVisitRecord" do
            expect {
              post :create, :participant_visit_record => valid_attributes, :contact_link_id => contact_link.id, :format => 'json'
            }.to change(ParticipantVisitRecord, :count).by(1)
          end
        end

      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved participant_visit_record as @participant_visit_record" do
            # Trigger the behavior that occurs when invalid params are submitted
            ParticipantVisitRecord.any_instance.stub(:save).and_return(false)
            post :create, :participant_visit_record => {}, :contact_link_id => contact_link.id
            assigns(:participant_visit_record).should be_a_new(ParticipantVisitRecord)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            ParticipantVisitRecord.any_instance.stub(:save).and_return(false)
            post :create, :participant_visit_record => {}, :contact_link_id => contact_link.id
            response.should render_template("new")
          end
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        describe "with html request" do
          it "updates the requested participant_visit_record" do
            ParticipantVisitRecord.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :id => participant_visit_record.id, :participant_visit_record => {'these' => 'params'}, :contact_link_id => contact_link.id
          end

          it "assigns the requested participant_visit_record as @participant_visit_record" do
            put :update, :id => participant_visit_record.id, :participant_visit_record => valid_attributes, :contact_link_id => contact_link.id
            assigns(:participant_visit_record).should eq(participant_visit_record)
          end

          it "redirects to the decision_page_contact_link page" do
            put :update, :id => participant_visit_record.id, :participant_visit_record => valid_attributes, :contact_link_id => contact_link.id
            response.should redirect_to(decision_page_contact_link_path(contact_link))
          end
        end

        describe "with json request" do
          it "forms json with updated @participant_visit_record id" do
            put :update, :id => participant_visit_record.id, :participant_visit_record => {}, :contact_link_id => contact_link.id, :format => 'json'
            response.body.should eq participant_visit_record.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the participant_visit_record as @participant_visit_record" do
            ParticipantVisitRecord.any_instance.stub(:save).and_return(false)
            put :update, :id => participant_visit_record.id.to_s, :participant_visit_record => {}, :contact_link_id => contact_link.id
            assigns(:participant_visit_record).should eq(participant_visit_record)
          end

          it "re-renders the 'edit' template" do
            ParticipantVisitRecord.any_instance.stub(:save).and_return(false)
            put :update, :id => participant_visit_record.id.to_s, :participant_visit_record => {}, :contact_link_id => contact_link.id
            response.should render_template("edit")
          end
        end

        describe "with json request" do
          it "forms json with updated participant_visit_record id" do
            put :update, :id => participant_visit_record.id, :participant_visit_record => {}, :contact_link_id => contact_link.id, :format => 'json'
            # json = { "project"  => ["can't be blank"]}
            # ActiveSupport::JSON.decode(response.body).should eq json
          end
        end
      end
    end

  end
end