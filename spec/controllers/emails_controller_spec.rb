# -*- coding: utf-8 -*-


require 'spec_helper'

describe EmailsController do

  def valid_attributes(person=nil)
    v = {:email => "fake@dev.null"}
    v[:person_id] = person.id unless person.nil?
    v
  end

  context "with an authenticated user" do
    before(:each) do
      @person = Factory(:person)
      @email = Factory(:email, :person => @person)

      login(user_login)
    end

    describe "GET new" do
      it "assigns a new email as @email" do
        get :new, :person_id => @person.id
        assigns(:email).should be_a_new(Email)
      end
    end

    describe "GET edit" do
      it "assigns the requested email as @email" do
        get :edit, :person_id => @person.id, :id => @email.id
        assigns(:email).should eq(@email)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request without a person" do
          it "creates a new Email" do
            expect {
              post :create, :email => valid_attributes
            }.to change(Email, :count).by(1)
          end

          it "assigns a newly created email as @email" do
            post :create, :email => valid_attributes
            assigns(:email).should be_a(Email)
            assigns(:email).should be_persisted
          end

          it "redirects to the edit email form" do
            post :create, :email => valid_attributes
            response.should redirect_to(edit_email_path(assigns(:email)))
          end
        end

        describe "with html request for non-participant person" do
          before(:each) do
            @person1 = Factory(:person)
          end
          it "associates person with email" do
            @person1.emails.should be_empty

            post :create, :email => valid_attributes(@person1)
            assigns(:email).should be_a(Email)

            person = Person.find(@person1.id)
            person.emails.should_not be_empty
            person.emails.first.should == assigns(:email)
          end

          it "redirects to the person" do
            post :create, :email => valid_attributes(@person1)
            response.should redirect_to(person_path(@person1))
          end
        end

        describe "with html request for participant" do
          it "redirects to the participant" do
            @person2 = Factory(:person)
            @participant2 = Factory(:participant)
            @person2.participant = @participant2
            @person2.save
            post :create, :email => valid_attributes(@person2)
            response.should redirect_to(participant_path(@participant2))
          end
        end

        describe "with json request" do
          it "creates a new Email" do
            expect {
              post :create, :person_id => @person.id, :email => valid_attributes(@person), :format => 'json'
            }.to change(Email, :count).by(1)
          end
        end
      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved email as @email" do
            # Trigger the behavior that occurs when invalid params are submitted
            Email.any_instance.stub(:save).and_return(false)
            post :create, :person_id => @person.id, :email => {}
            assigns(:email).should be_a_new(Email)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            Email.any_instance.stub(:save).and_return(false)
            post :create, :person_id => @person.id, :email => {}
            response.should render_template("new")
          end
        end

        describe "with json request" do
          it "generates json with error list" do
            post :create, :person_id => @person.id, :email => {}, :format => 'json'
            # json = { "xxx" => ["can't be blank"],
            #          "yyy" => ["is not included in the list"]}
            # ActiveSupport::JSON.decode(response.body).should eq json
          end
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        describe "with html request" do
          it "updates the requested email" do
            Email.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :person_id => @person.id, :id => @email.id, :email => {'these' => 'params'}
          end

          it "assigns the requested email as @email" do
            put :update, :person_id => @person.id, :id => @email.id, :email => valid_attributes
            assigns(:email).should eq(@email)
          end

          it "redirects to the edit email form when no person associated" do
            (@email_no_person = Email.new(valid_attributes)).save
            put :update, :id => @email_no_person.id, :email => valid_attributes
            response.should redirect_to(edit_email_path(@email_no_person))
          end

          it "redirects to the person when non-participant associated" do
            put :update, :id => @email.id, :email => valid_attributes
            response.should redirect_to(person_path(@person))
          end

          it "redirects to the participant when associated" do
            @person3 = Factory(:person)
            @participant3 = Factory(:participant)
            @person3.participant = @participant3
            @email3 = Factory(:email, :person=> @person3)
            @person3.save

            put :update, :id => @email3.id, :email => valid_attributes
            response.should redirect_to(participant_path(@participant3))
          end
        end

        describe "with json request" do
          it "forms json with updated @email id" do
            put :update, :person_id => @person.id, :id => @email.id, :email => {}, :format => 'json'
            response.body.should eq @email.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the email as @email" do
            Email.any_instance.stub(:save).and_return(false)
            put :update, :person_id => @person.id, :id => @email.id.to_s, :email => {}
            assigns(:email).should eq(@email)
          end

          it "re-renders the 'edit' template" do
            Email.any_instance.stub(:save).and_return(false)
            put :update, :person_id => @person.id, :id => @email.id.to_s, :email => {}
            response.should render_template("edit")
          end
        end

        describe "with json request" do
          it "forms json with updated @email id" do
            put :update, :person_id => @person.id, :id => @email.id, :email => {}, :format => 'json'
            # json = { "project"  => ["can't be blank"]}
            # ActiveSupport::JSON.decode(response.body).should eq json
          end
        end
      end
    end

  end

end
