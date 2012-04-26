require 'spec_helper'

describe SpecimenStoragesController do
  context "with an authenticated user" do
    before(:each) do
      login(user_login)
      create_missing_in_error_ncs_codes(SpecimenStorage)
      @specimen_storage = Factory(:specimen_storage)
    end


    def valid_attributes
      { :storage_container_id => "12", :storage_comment => "some storage comment", :placed_in_storage_datetime =>"2012-03-05 15:36:19", :staff_id => "someone special"}
    end

    describe "GET new" do
      it "assigns a new specimen_storage as @specimen_storage" do
        get :new
        assigns(:specimen_storage).should be_a_new(SpecimenStorage)
      end
    end
    
    describe "GET edit" do
      it "assigns the requested specimen_storage as @specimen_storage" do
        get :edit, :id => @specimen_storage.id.to_s
        assigns(:specimen_storage).should eq(@specimen_storage)
      end
    end    
    
    describe "POST create" do
      describe "with valid params" do
        it "creates a new specimen_storage object" do
          expect {
            post :create, :specimen_storage => valid_attributes
          }.to change(SpecimenStorage, :count).by(1)
        end
    
        it "assigns a newly created specimen_storage as @specimen_storage" do
          post :create, :specimen_storage => valid_attributes
          assigns(:specimen_storage).should be_a(SpecimenStorage)
          assigns(:specimen_storage).should be_persisted
        end
        
         describe "with json request" do
           describe "with not repeating specimen_storage" do
             it "creates a new SpecimenStorage" do
               expect {
                 post :create, :specimen_storage => valid_attributes, :format => 'json'
               }.to change(SpecimenStorage, :count).by(1)
             end
           end
         end
         
        describe "forms json" do 
          it "with newly created @specimen_storage id" do
            post :create, :specimen_storage => valid_attributes, :format => 'json'
            specimen_storage = SpecimenStorage.last
            response.body.should eq specimen_storage.to_json
          end
        end
      end
      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved specimen_storage as @specimen_storage" do
            # Trigger the behavior that occurs when invalid params are submitted
            SpecimenStorage.any_instance.stub(:save).and_return(false)
            post :create, :specimen_storage => {}
            assigns(:specimen_storage).should be_a_new(SpecimenStorage)
          end
    
          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            SpecimenStorage.any_instance.stub(:save).and_return(false)
            post :create, :specimen_storage => {}
            response.should render_template("new")
          end
        end
      end
      describe "with json request" do
        it "generates json with error list" do
          post :create, :specimen_storage => {}, :format => 'json'
          json = { "placed_in_storage_datetime" => ["can't be blank"], 
                   "storage_container_id"  => ["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end      
    end
    
    describe "PUT update" do
      describe "with json request" do
        it "forms json with updated  @specimen_storage id" do
          put :update, :id =>  @specimen_storage.id, :specimen_storage => {}, :format => 'json'
          response.body.should eq @specimen_storage.to_json
        end
      end
      
      describe "with json request and date change" do
        it "forms json with updated @specimen_storage storage_container_id" do
          put :update, :id => @specimen_storage.id, :specimen_storage => {:storage_container_id => "234"}, :format => 'json'
          specimen_storage = SpecimenStorage.last
          response.body.should eq specimen_storage.to_json
        end
      end  
      
      describe "with json request" do
        it "forms json with updated @specimen_storage" do
          put :update, :id => @specimen_storage.id, :specimen_storage => {:storage_container_id => nil}, :format => 'json'
          json = { "storage_container_id"  => ["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end      
    end
  end
end
