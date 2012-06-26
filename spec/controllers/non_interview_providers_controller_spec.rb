# -*- coding: utf-8 -*-

require 'spec_helper'

describe NonInterviewProvidersController do

  def valid_attributes
    {}
  end

  context "with an authenticated user" do

    let(:provider) { Factory(:provider) }
    let(:contact) { Factory(:contact) }
    let(:non_interview_provider) { Factory(:non_interview_provider) }

    before(:each) do
      login(user_login)
    end

    describe "GET new" do

      it "assigns a new non_interview_provider as @non_interview_provider" do
        get :new, :contact_id => contact.id, :provider_id => provider.id
        assigns(:non_interview_provider).should be_a_new(NonInterviewProvider)
      end

      it "assigns the requested contact as @contact" do
        get :new, :contact_id => contact.id, :provider_id => provider.id
        assigns(:contact).should eq(contact)
      end

    end

    describe "GET edit" do
      it "assigns the requested non_interview_provider as @non_interview_provider" do
        get :edit, :id => non_interview_provider.id, :contact_id => contact.id, :provider_id => provider.id
        assigns(:non_interview_provider).should eq(non_interview_provider)
      end

      it "assigns the requested contact as @contact" do
        get :edit, :id => non_interview_provider.id, :contact_id => contact.id, :provider_id => provider.id
        assigns(:contact).should eq(contact)
      end

      it "assigns the requested non_interview_provider.provider as @provider" do
        get :edit, :id => non_interview_provider.id, :contact_id => contact.id, :provider_id => provider.id
        assigns(:provider).should eq(non_interview_provider.provider)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new NonInterviewProvider" do
          expect {
            post :create, :non_interview_provider => valid_attributes, :contact_id => contact.id, :provider_id => provider.id
          }.to change(NonInterviewProvider, :count).by(1)
        end

        it "assigns a newly created non_interview_provider as @non_interview_provider" do
          post :create, :non_interview_provider => valid_attributes, :contact_id => contact.id, :provider_id => provider.id
          assigns(:non_interview_provider).should be_a(NonInterviewProvider)
          assigns(:non_interview_provider).should be_persisted
        end

        it "redirects to the created non_interview_provider" do
          post :create, :non_interview_provider => valid_attributes, :contact_id => contact.id, :provider_id => provider.id
          response.should redirect_to(edit_provider_path(provider.id))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved non_interview_provider as @non_interview_provider" do
          # Trigger the behavior that occurs when invalid params are submitted
          NonInterviewProvider.any_instance.stub(:save).and_return(false)
          post :create, :non_interview_provider => {}, :contact_id => contact.id, :provider_id => provider.id
          assigns(:non_interview_provider).should be_a_new(NonInterviewProvider)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          NonInterviewProvider.any_instance.stub(:save).and_return(false)
          post :create, :non_interview_provider => {}, :contact_id => contact.id, :provider_id => provider.id
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested non_interview_provider" do
          non_interview_provider = NonInterviewProvider.create! valid_attributes
          NonInterviewProvider.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => non_interview_provider.id, :non_interview_provider => {'these' => 'params'}, :contact_id => contact.id, :provider_id => provider.id
        end

        it "assigns the requested non_interview_provider as @non_interview_provider" do
          non_interview_provider = NonInterviewProvider.create! valid_attributes
          put :update, :id => non_interview_provider.id, :non_interview_provider => valid_attributes, :contact_id => contact.id, :provider_id => provider.id
          assigns(:non_interview_provider).should eq(non_interview_provider)
        end

        it "redirects to the non_interview_provider" do
          non_interview_provider = NonInterviewProvider.create! valid_attributes
          put :update, :id => non_interview_provider.id, :non_interview_provider => valid_attributes, :contact_id => contact.id, :provider_id => provider.id
          response.should redirect_to(edit_provider_path(non_interview_provider.provider_id))
        end
      end

      describe "with invalid params" do
        it "assigns the non_interview_provider as @non_interview_provider" do
          non_interview_provider = NonInterviewProvider.create! valid_attributes
          NonInterviewProvider.any_instance.stub(:save).and_return(false)
          put :update, :id => non_interview_provider.id.to_s, :non_interview_provider => {}, :contact_id => contact.id, :provider_id => provider.id
          assigns(:non_interview_provider).should eq(non_interview_provider)
        end

        it "re-renders the 'edit' template" do
          non_interview_provider = NonInterviewProvider.create! valid_attributes
          NonInterviewProvider.any_instance.stub(:save).and_return(false)
          put :update, :id => non_interview_provider.id.to_s, :non_interview_provider => {}, :contact_id => contact.id, :provider_id => provider.id
          response.should render_template("edit")
        end
      end
    end
  end
end