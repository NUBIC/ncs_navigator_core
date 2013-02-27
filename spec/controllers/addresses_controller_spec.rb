# -*- coding: utf-8 -*-


require 'spec_helper'

describe AddressesController do

  def valid_attributes(person=nil)
    v={
      :address_one => "2 Main",
      :city => "Chicago",
      :state_code => 1,
      :zip => "60666"
    }
    v[:person_id] = person.id unless person.nil?
    v
  end

  context "with an authenticated user" do
    before(:each) do
      @person = Factory(:person)
      @address1 = Factory(:address, :person => @person, :address_one => "1 Main Street")
      @address2 = Factory(:address, :person => @person, :address_one => "2 State Street")
      @address3 = Factory(:address, :person => @person, :address_one => "3 My Way")
      login(user_login)
    end

    describe "GET index" do

      before(:each) do
        Address.count.should == 3
      end

      describe "without search parameters" do
        it "assigns all addresses as @addresses" do
          get :index
          assigns[:addresses].count.should equal(3)
          assigns[:addresses].should include @address1
          assigns[:addresses].should include @address2
          assigns[:addresses].should include @address3
        end
      end

      describe "searching by address one" do
        it "returns complete matches" do
          get :index, :q => { :address_one_cont => "1 Main Street" }
          assigns[:addresses].count.should equal(1)
          assigns[:addresses].should include @address1
          assigns[:addresses].should_not include @address2
          assigns[:addresses].should_not include @address3
        end

        it "returns partial matches" do
          get :index, :q => { :address_one_cont => "1" }
          assigns[:addresses].count.should equal(1)
          assigns[:addresses].should include @address1
          assigns[:addresses].should_not include @address2
          assigns[:addresses].should_not include @address3
        end
      end
    end

    describe "GET new" do
      it "assigns a new address as @address" do
        get :new
        assigns(:address).should be_a_new(Address)
      end
    end

    describe "GET edit" do
      it "assigns the requested address as @address" do
        get :edit, :id => @address1.id
        assigns(:address).should eq(@address1)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request" do
          it "creates a new Address" do
            expect {
              post :create, :address => valid_attributes
            }.to change(Address, :count).by(1)
          end

          it "assigns a newly created address as @address" do
            post :create, :address => valid_attributes
            assigns(:address).should be_a(Address)
            assigns(:address).should be_persisted
          end

          it "redirects to the edit address form" do
            post :create, :address => valid_attributes
            response.should redirect_to(edit_address_path(Address.last))
          end
        end

        describe "with html request for non-participant person" do
          before(:each) {@homeless_person1 = Factory(:person)}
          it "associates person with address" do
            @homeless_person1.addresses.should be_empty

            post :create, :address => valid_attributes(@homeless_person1)
            assigns(:address).should be_a(Address)

            person = Person.find(@homeless_person1.id)
            person.addresses.should_not be_empty
          end

          it "redirects to the person" do
            post :create, :address => valid_attributes(@homeless_person1)
            response.should redirect_to(person_path(@homeless_person1))
          end
        end

        describe "with html request for participant" do
          before(:each) do
            @homeless_person2 = Factory(:person)
            @homeless_participant2 = Factory(:participant)
            @homeless_person2.participant = @homeless_participant2
            @homeless_person2.save
          end

          it "associates person with address" do
            @homeless_person2.addresses.should be_empty

            post :create, :address => valid_attributes(@homeless_person2)
            assigns(:address).should be_a(Address)

            person = Person.find(@homeless_person2.id)
            person.addresses.should_not be_empty
          end

          it "redirects to the participant" do
            post :create, :address => valid_attributes(@homeless_person2)
            response.should redirect_to(participant_path(@homeless_participant2))
          end
        end

        describe "with json request" do
          it "creates a new Address" do
            expect {
              post :create, :address => valid_attributes, :format => 'json'
            }.to change(Address, :count).by(1)
          end
        end
      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved address as @address" do
            # Trigger the behavior that occurs when invalid params are submitted
            Address.any_instance.stub(:save).and_return(false)
            post :create, :address => {}
            assigns(:address).should be_a_new(Address)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            Address.any_instance.stub(:save).and_return(false)
            post :create, :address => {}
            response.should render_template("new")
          end
        end

        describe "with json request" do
          it "generates json with error list" do
            post :create, :address => {}, :format => 'json'
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
          it "updates the requested address" do
            Address.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :id => @address1.id, :address => {'these' => 'params'}
          end

          it "assigns the requested address as @address" do
            put :update, :id => @address1.id, :address => valid_attributes
            assigns(:address).should eq(@address1)
          end

          it "redirects to the edit address form when no person associated" do
            @address5 = Factory(:address, :person => nil, :address_one => "5 Lake Street")
            put :update, :id => @address5.id, :address => valid_attributes
            response.should redirect_to(edit_address_path(@address5))
          end

          it "redirects to the person when non-participant associated" do
            put :update, :id => @address1.id, :address => valid_attributes
            response.should redirect_to(person_path(@person))
          end

          it "redirects to the participant when associated" do
            @person1 = Factory(:person)
            @participant = Factory(:participant)
            @person1.participant = @participant
            @person1.save
            @address4 = Factory(:address, :person => @person1,:address_one => "4 Ogden Ave")
            put :update, :id => @address4.id, :address => valid_attributes
            response.should redirect_to(participant_path(@participant))
          end

        end

        describe "with json request" do
          it "forms json with updated @address id" do
            put :update, :id => @address1.id, :address => {}, :format => 'json'
            response.body.should eq @address1.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the address as @address" do
            Address.any_instance.stub(:save).and_return(false)
            put :update, :id => @address1.id.to_s, :address => {}
            assigns(:address).should eq(@address1)
          end

          it "re-renders the 'edit' template" do
            Address.any_instance.stub(:save).and_return(false)
            put :update, :id => @address1.id.to_s, :address => {}
            response.should render_template("edit")
          end
        end

        describe "with json request" do
          it "forms json with updated @address id" do
            put :update, :id => @address1.id, :address => {}, :format => 'json'
            # json = { "project"  => ["can't be blank"]}
            # ActiveSupport::JSON.decode(response.body).should eq json
          end
        end
      end
    end

  end

end
