# -*- coding: utf-8 -*-


require 'spec_helper'

describe TelephonesController do

  def valid_attributes(person=nil)
    v={:phone_nbr => "3125551234"}
    v[:person_id] = person.id unless person.nil?
    v
  end

  context "with an authenticated user" do
    before(:each) do
      @person = Factory(:person)
      @telephone = Factory(:telephone, :person => @person)
      login(user_login)
    end

    describe "GET new" do
      it "assigns a new telephone as @telephone" do
        get :new, :person_id => @person.id
        assigns(:telephone).should be_a_new(Telephone)
      end
    end

    describe "GET edit" do
      it "assigns the requested telephone as @telephone" do
        get :edit, :person_id => @person.id, :id => @telephone.id
        assigns(:telephone).should eq(@telephone)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request without a person" do
          it "creates a new Telephone" do
            expect {
              post :create, :telephone => valid_attributes
            }.to change(Telephone, :count).by(1)
          end

          it "assigns a newly created telephone as @telephone" do
            post :create, :telephone => valid_attributes
            assigns(:telephone).should be_a(Telephone)
            assigns(:telephone).should be_persisted
          end

          it "redirects to the edit telephone form" do
            post :create, :telephone => valid_attributes
            response.should redirect_to(edit_telephone_path(assigns(:telephone)))
          end
        end

        describe "with html request for non-participant person" do
          before(:each) do
            @person1 = Factory(:person)
          end
          it "associates person with telephone" do
            @person1.telephones.should be_empty

            post :create, :telephone => valid_attributes(@person1)
            assigns(:telephone).should be_a(Telephone)

            person = Person.find(@person1.id)
            person.telephones.should_not be_empty
            person.telephones.first.should == assigns(:telephone)
          end

          it "redirects to the person" do
            post :create, :telephone => valid_attributes(@person1)
            response.should redirect_to(person_path(@person1))
          end
        end

        describe "with html request for participant" do
          it "redirects to the participant" do
            @person2 = Factory(:person)
            @participant2 = Factory(:participant)
            @person2.participant = @participant2
            @person2.save
            post :create, :telephone => valid_attributes(@person2)
            response.should redirect_to(participant_path(@participant2))
          end
        end

        describe "with json request" do
          it "creates a new Telephone" do
            expect {
              post :create, :person_id => @person.id, :telephone => valid_attributes, :format => 'json'
            }.to change(Telephone, :count).by(1)
          end
        end
      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved telephone as @telephone" do
            # Trigger the behavior that occurs when invalid params are submitted
            Telephone.any_instance.stub(:save).and_return(false)
            post :create, :person_id => @person.id, :telephone => {}
            assigns(:telephone).should be_a_new(Telephone)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            Telephone.any_instance.stub(:save).and_return(false)
            post :create, :person_id => @person.id, :telephone => {}
            response.should render_template("new")
          end
        end

        describe "with json request" do
          it "generates json with error list" do
            post :create, :person_id => @person.id, :telephone => {}, :format => 'json'
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
          it "updates the requested telephone" do
            Telephone.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :person_id => @person.id, :id => @telephone.id, :telephone => {'these' => 'params'}
          end

          it "assigns the requested telephone as @telephone" do
            put :update, :person_id => @person.id, :id => @telephone.id, :telephone => valid_attributes
            assigns(:telephone).should eq(@telephone)
          end

          it "redirects to the edit telephone form when no person associated" do
            (@telephone_no_person = Telephone.new(valid_attributes)).save
            put :update, :id => @telephone_no_person.id, :telephone => valid_attributes
            response.should redirect_to(edit_telephone_path(@telephone_no_person))
          end

          it "redirects to the person when non-participant associated" do
            put :update, :id => @telephone.id, :telephone => valid_attributes
            response.should redirect_to(person_path(@person))
          end

          it "redirects to the participant when associated" do
            @person3 = Factory(:person)
            @participant3 = Factory(:participant)
            @person3.participant = @participant3
            @telephone3 = Factory(:telephone, :person=> @person3)
            @person3.save

            put :update, :id => @telephone3.id, :telephone => valid_attributes
            response.should redirect_to(participant_path(@participant3))
          end
        end

        describe "with json request" do
          it "forms json with updated @telephone id" do
            put :update, :person_id => @person.id, :id => @telephone.id, :telephone => {}, :format => 'json'
            response.body.should eq @telephone.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the telephone as @telephone" do
            Telephone.any_instance.stub(:save).and_return(false)
            put :update, :person_id => @person.id, :id => @telephone.id.to_s, :telephone => {}
            assigns(:telephone).should eq(@telephone)
          end

          it "re-renders the 'edit' template" do
            Telephone.any_instance.stub(:save).and_return(false)
            put :update, :person_id => @person.id, :id => @telephone.id.to_s, :telephone => {}
            response.should render_template("edit")
          end
        end

        describe "with json request" do
          it "forms json with updated @telephone id" do
            put :update, :person_id => @person.id, :id => @telephone.id, :telephone => {}, :format => 'json'
            # json = { "project"  => ["can't be blank"]}
            # ActiveSupport::JSON.decode(response.body).should eq json
          end
        end
      end
    end

  end

end
