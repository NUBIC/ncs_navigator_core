require 'spec_helper'

describe AddressesController do

  def valid_attributes
    {
      :address_one => "2 Main",
      :city => "Chicago",
      # :state => Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "ILLINOIS", :local_code => 1),
      :zip => "60666"
    }
  end


  context "with an authenticated user" do
    before(:each) do
      create_missing_in_error_ncs_codes(Address)
      @person = Factory(:person)
      @address = Factory(:address, :person => @person)
      login(user_login)
    end

    describe "GET new" do
      it "assigns a new address as @address" do
        get :new, :person_id => @person.id
        assigns(:address).should be_a_new(Address)
      end
    end

    describe "GET edit" do
      it "assigns the requested address as @address" do
        get :edit, :person_id => @person.id, :id => @address.id
        assigns(:address).should eq(@address)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request" do
          it "creates a new Address" do
            expect {
              post :create, :person_id => @person.id, :address => valid_attributes
            }.to change(Address, :count).by(1)
          end

          it "assigns a newly created address as @address" do
            post :create, :person_id => @person.id, :address => valid_attributes
            assigns(:address).should be_a(Address)
            assigns(:address).should be_persisted
          end

          it "redirects to the edit address form" do
            post :create, :person_id => @person.id, :address => valid_attributes
            response.should redirect_to(person_path(@person))
          end
        end

        describe "with json request" do
          it "creates a new Address" do
            expect {
              post :create, :person_id => @person.id, :address => valid_attributes, :format => 'json'
            }.to change(Address, :count).by(1)
          end
        end
      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved address as @address" do
            # Trigger the behavior that occurs when invalid params are submitted
            Address.any_instance.stub(:save).and_return(false)
            post :create, :person_id => @person.id, :address => {}
            assigns(:address).should be_a_new(Address)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            Address.any_instance.stub(:save).and_return(false)
            post :create, :person_id => @person.id, :address => {}
            response.should render_template("new")
          end
        end

        describe "with json request" do
          it "generates json with error list" do
            post :create, :person_id => @person.id, :address => {}, :format => 'json'
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
            put :update, :person_id => @person.id, :id => @address.id, :address => {'these' => 'params'}
          end

          it "assigns the requested address as @address" do
            put :update, :person_id => @person.id, :id => @address.id, :address => valid_attributes
            assigns(:address).should eq(@address)
          end

          it "redirects to the address" do
            put :update, :person_id => @person.id, :id => @address.id, :address => valid_attributes
            response.should redirect_to(person_path(@person))
          end
        end

        describe "with json request" do
          it "forms json with updated @address id" do
            put :update, :person_id => @person.id, :id => @address.id, :address => {}, :format => 'json'
            response.body.should eq @address.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the address as @address" do
            Address.any_instance.stub(:save).and_return(false)
            put :update, :person_id => @person.id, :id => @address.id.to_s, :address => {}
            assigns(:address).should eq(@address)
          end

          it "re-renders the 'edit' template" do
            Address.any_instance.stub(:save).and_return(false)
            put :update, :person_id => @person.id, :id => @address.id.to_s, :address => {}
            response.should render_template("edit")
          end
        end

        describe "with json request" do
          it "forms json with updated @address id" do
            put :update, :person_id => @person.id, :id => @address.id, :address => {}, :format => 'json'
            # json = { "project"  => ["can't be blank"]}
            # ActiveSupport::JSON.decode(response.body).should eq json
          end
        end
      end
    end

  end

end
