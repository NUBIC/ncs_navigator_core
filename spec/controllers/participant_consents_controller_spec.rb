# -*- coding: utf-8 -*-


require 'spec_helper'

describe ParticipantConsentsController do

  context "with an authenticated user" do

    let(:contact) { Factory(:contact) }
    let(:contact_link) { Factory(:contact_link, :contact => contact) }
    let(:participant) { Factory(:participant) }

    before(:each) do
      login(user_login)
    end

    describe "GET new" do
      it "assigns a new ParticipantConsent as @participant_consent" do
        get :new, :contact_link_id => contact_link.id, :participant_id => participant.id
        assigns(:participant_consent).should be_a_new(ParticipantConsent)
      end

      it "associates the given contact_link.contact with the @participant_consent" do
        get :new, :contact_link_id => contact_link.id, :participant_id => participant.id
        assigns[:participant_consent].contact.should == contact_link.contact
      end

      it "associates the given participant with the @participant_consent" do
        get :new, :contact_link_id => contact_link.id, :participant_id => participant.id
        assigns[:participant_consent].participant.should == participant
      end

      it "creates three associated participant_consent_sample records with the @participant_consent" do
        
        get :new, :contact_link_id => contact_link.id, :participant_id => participant.id
        assigns[:participant_consent].participant_consent_samples.size.should == 3
      end

    end

  end
end