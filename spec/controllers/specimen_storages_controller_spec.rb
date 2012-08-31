# -*- coding: utf-8 -*-
require 'spec_helper'

describe SpecimenStoragesController do
  context "with an authenticated user" do
    before(:each) do
      login(user_login)
      @specimen_storage_container = Factory(:specimen_storage_container)
      @specimen_storage = Factory(:specimen_storage)
    end


    def valid_attributes
      {:specimen_storage=>{:specimen_storage_container_id=>@specimen_storage_container.id, :placed_in_storage_datetime=>Time.now, :storage_comment => "something"}}
    end

    # TODO - doesn't work in the group of tests, works in the speck itself
    # describe "GET new" do
    #       it "assigns a new specimen_storage as @specimen_storage" do
    #         get :new, :container_id => "1"
    #         @specimen_storage_container = SpecimenStorageContainer.where(:id => "1").first
    #         # @specimen_storage = @specimen_storage_container.build_specimen_storage()
    #         assigns(:specimen_storage).should be_a_new(SpecimenStorage)
    #       end
    #     end

    describe "GET edit" do
      it "assigns the requested specimen_storage as @specimen_storage" do
        get :edit, :id => @specimen_storage.id
        assigns(:specimen_storage).should eq(@specimen_storage)
      end
    end    
    
    describe "POST create" do
      describe "with valid params" do
        it "creates a new specimen_storage object" do
          expect {
            post :create, valid_attributes
          }.to change(SpecimenStorage, :count).by(1)
        end
    
        it "assigns a newly created specimen_storage as @specimen_storage" do
          post :create, valid_attributes
          assigns(:specimen_storage).should be_a(SpecimenStorage)
          assigns(:specimen_storage).should be_persisted
        end
        
         describe "with json request" do
           describe "with not repeating specimen_storage" do
             it "creates a new SpecimenStorage" do
               expect {
                 post :create, valid_attributes, :format => 'json'
               }.to change(SpecimenStorage, :count).by(1)
             end
           end
         end
         
        describe "forms json" do 
          it "with newly created @specimen_storage id" do
            post :create, :specimen_storage=>{:specimen_storage_container_id=>@specimen_storage_container.id, :placed_in_storage_datetime=>Time.now, :storage_comment => "something"}, :format => 'json'
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
        end
      end
      describe "with json request" do
        it "generates json with error list" do
          post :create, :specimen_storage => {}, :format => 'json'
          json = {"placed_in_storage_datetime"=>["can't be blank"], "specimen_storage_container_id"=>["can't be blank"]}
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
        it "forms json with updated @specimen_storage storage_comment" do
          put :update, :id => @specimen_storage.id, :specimen_storage => {:storage_comment => "another comment"}, :format => 'json'
          specimen_storage = SpecimenStorage.last
          response.body.should eq specimen_storage.to_json
        end
      end  
      
      describe "with json request" do
        it "forms json with nil for placed_in_storage_datetime in @specimen_storage" do
          put :update, :id => @specimen_storage.id, :specimen_storage => {:placed_in_storage_datetime => ""}, :format => 'json'
          json = { "placed_in_storage_datetime"  => ["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end      
    end
  end
end
