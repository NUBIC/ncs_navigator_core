

require 'spec_helper'

describe ParticipantVisitConsentsController do

  context "with an authenticated user" do

    let(:contact) { Factory(:contact) }
    let(:contact_link) { Factory(:contact_link, :contact => contact) }
    let(:participant_visit_consent) { Factory(:participant_visit_consent) }

    before(:each) do
      login(user_login)
    end

    describe "GET new" do
      it "assigns a new ParticipantVisitConsent as @participant_visit_consent" do
        get :new, :contact_link_id => contact_link.id
        assigns(:participant_visit_consent).should be_a_new(ParticipantVisitConsent)
      end

      it "associates the given contact_link.contact with the @participant_visit_consent" do
        get :new, :contact_link_id => contact_link.id
        assigns[:participant_visit_consent].contact.should == contact_link.contact
      end

      it "associates the given contact_link.event.participant with the @participant_visit_consent" do
        get :new, :contact_link_id => contact_link.id
        assigns[:participant_visit_consent].participant.should == contact_link.event.participant
      end

      it "associates the given contact_link.person with the @participant_visit_consent as vis_person_who_consented" do
        get :new, :contact_link_id => contact_link.id
        assigns[:participant_visit_consent].vis_person_who_consented.should == contact_link.person
      end

    end

    describe "GET new.json" do
      it "returns a json representation of the desired participant_visit_consent"
    end

    describe "GET edit" do

      before do
        participant_visit_consent.contact = contact
        participant_visit_consent.save!
      end

      it "assigns the requested participant_visit_consent associated with the contact_link as @participant_visit_consent" do
        get :edit, :id => participant_visit_consent.id, :contact_link_id => contact_link.id
        assigns(:participant_visit_consent).should eq(participant_visit_consent)
      end

    end

    def valid_attributes
      {
        :participant_id               => contact_link.event.participant_id,
        :vis_person_who_consented_id  => contact_link.person_id,
        :contact_id                   => contact_link.contact_id,
        :vis_language_code            => 1,
        :vis_consent_type_code        => 1,
        :vis_consent_response_code    => 1,
        :vis_who_consented_code       => 1,
        :vis_translate_code           => 1,
        :vis_comments                 => "some comments",
      }
    end

    describe "POST create" do
      let(:vis_consent_type_codes) { NcsCode.ncs_code_lookup(:vis_consent_type_code).map{ |c| c[1] } }

      describe "with valid params" do
        describe "with html request" do
          it "creates several new ParticipantVisitConsents" do
            expect {
              post :create, :participant_visit_consent => valid_attributes, :contact_link_id => contact_link.id, :vis_consent_type_codes => vis_consent_type_codes
            }.to change(ParticipantVisitConsent, :count).by(vis_consent_type_codes.size)
          end

          it "assigns a newly created participant_visit_consent as @participant_visit_consent" do
            post :create, :participant_visit_consent => valid_attributes, :contact_link_id => contact_link.id, :vis_consent_type_codes => vis_consent_type_codes
            assigns(:participant_visit_consent).should be_a(ParticipantVisitConsent)
            assigns(:participant_visit_consent).should be_persisted
          end

          it "redirects to the decision_page_contact_link page" do
            post :create, :participant_visit_consent => valid_attributes, :contact_link_id => contact_link.id, :vis_consent_type_codes => vis_consent_type_codes
            response.should redirect_to(decision_page_contact_link_path(contact_link))
          end
        end

        describe "with json request" do
          it "creates several new ParticipantVisitConsents" do
            expect {
              post :create, :participant_visit_consent => valid_attributes, :contact_link_id => contact_link.id, :format => 'json', :vis_consent_type_codes => vis_consent_type_codes
            }.to change(ParticipantVisitConsent, :count).by(vis_consent_type_codes.size)
          end
        end

      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved participant_visit_consent as @participant_visit_consent" do
            # Trigger the behavior that occurs when invalid params are submitted
            ParticipantVisitConsent.any_instance.stub(:save).and_return(false)
            post :create, :participant_visit_consent => {}, :contact_link_id => contact_link.id, :vis_consent_type_codes => vis_consent_type_codes
            assigns(:participant_visit_consent).should be_a_new(ParticipantVisitConsent)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            ParticipantVisitConsent.any_instance.stub(:save).and_return(false)
            post :create, :participant_visit_consent => {}, :contact_link_id => contact_link.id, :vis_consent_type_codes => vis_consent_type_codes
            response.should render_template("new")
          end
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        describe "with html request" do
          it "updates the requested participant_visit_consent" do
            ParticipantVisitConsent.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :id => participant_visit_consent.id, :participant_visit_consent => {'these' => 'params'}, :contact_link_id => contact_link.id
          end

          it "assigns the requested participant_visit_consent as @participant_visit_consent" do
            put :update, :id => participant_visit_consent.id, :participant_visit_consent => valid_attributes, :contact_link_id => contact_link.id
            assigns(:participant_visit_consent).should eq(participant_visit_consent)
          end

          it "redirects to the decision_page_contact_link page" do
            put :update, :id => participant_visit_consent.id, :participant_visit_consent => valid_attributes, :contact_link_id => contact_link.id
            response.should redirect_to(decision_page_contact_link_path(contact_link))
          end
        end

        describe "with json request" do
          it "forms json with updated @participant_visit_consent id" do
            put :update, :id => participant_visit_consent.id, :participant_visit_consent => {}, :contact_link_id => contact_link.id, :format => 'json'
            response.body.should eq participant_visit_consent.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the participant_visit_consent as @participant_visit_consent" do
            ParticipantVisitConsent.any_instance.stub(:save).and_return(false)
            put :update, :id => participant_visit_consent.id.to_s, :participant_visit_consent => {}, :contact_link_id => contact_link.id
            assigns(:participant_visit_consent).should eq(participant_visit_consent)
          end

          it "re-renders the 'edit' template" do
            ParticipantVisitConsent.any_instance.stub(:save).and_return(false)
            put :update, :id => participant_visit_consent.id.to_s, :participant_visit_consent => {}, :contact_link_id => contact_link.id
            response.should render_template("edit")
          end
        end

        describe "with json request" do
          it "forms json with updated participant_visit_consent id" do
            put :update, :id => participant_visit_consent.id, :participant_visit_consent => {}, :contact_link_id => contact_link.id, :format => 'json'
            # json = { "project"  => ["can't be blank"]}
            # ActiveSupport::JSON.decode(response.body).should eq json
          end
        end
      end
    end

  end
end