require 'spec_helper'

describe SpecimenReceiptsController do
  context "with an authenticated user" do
    before(:each) do
      login(user_login)
      @specimen_receipt = Factory(:specimen_receipt)
    end


    def valid_attributes
      { :specimen_id => "BE567-UR55", :receipt_datetime =>"2012-03-05 15:36:19", :storage_container_id => "12", :specimen_processing_shipping_center_id => "123ABC", 
        :staff_id => "someone special"}
    end

    describe "GET new" do
      it "assigns a new specimen_receipt as @specimen_receipt" do
        get :new
        assigns(:specimen_receipt).should be_a_new(SpecimenReceipt)
      end
    end
    
    describe "GET edit" do
      it "assigns the requested specimen_receipt as @specimen_receipt" do
        get :edit, :id => @specimen_receipt.id.to_s
        assigns(:specimen_receipt).should eq(@specimen_receipt)
      end
    end    

    describe "POST create" do
      describe "with valid params" do
        it "creates a new specimen receipt object" do
          expect {
            post :create, :specimen_receipt => valid_attributes
          }.to change(SpecimenReceipt, :count).by(1)
        end

        it "assigns a newly created specimen receipt as @specimen_recipt" do
          post :create, :specimen_receipt => valid_attributes
          assigns(:specimen_receipt).should be_a(SpecimenReceipt)
          assigns(:specimen_receipt).should be_persisted
        end
        
        describe "with json request" do
          describe "with not repeating specimen receipt" do
            it "creates a new SpecimenReceipt" do
              expect {
                post :create, :specimen_receipt => valid_attributes, :format => 'json'
              }.to change(SpecimenReceipt, :count).by(1)
            end
          end
        end
        
        describe "forms json" do 
          it "with newly created @specimen_receipt id" do
            post :create, :specimen_receipt => valid_attributes, :format => 'json'
            specimen_receipt = SpecimenReceipt.last
            response.body.should eq specimen_receipt.to_json
          end
        end
      end
      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved specimen_receipt as @specimen_receipt" do
            # Trigger the behavior that occurs when invalid params are submitted
            SpecimenReceipt.any_instance.stub(:save).and_return(false)
            post :create, :specimen_receipt => {}
            assigns(:specimen_receipt).should be_a_new(SpecimenReceipt)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            SpecimenReceipt.any_instance.stub(:save).and_return(false)
            post :create, :specimen_receipt => {}
            response.should render_template("new")
          end
        end
      end
      describe "with json request" do
        it "generates json with error list" do
          post :create, :specimen_receipt => {}, :format => 'json'
          json = { "receipt_datetime" => ["can't be blank"], 
                   "storage_container_id"  => ["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end      
    end
    
    describe "PUT update" do
      describe "with json request" do
        it "forms json with updated  @specimen_receipt id" do
          put :update, :id =>  @specimen_receipt.id, :specimen_receipt => {}, :format => 'json'
          response.body.should eq @specimen_receipt.to_json
        end
      end
      
      describe "with json request and date change" do
        it "forms json with updated @specimen_receipt storage_container_id" do
          put :update, :id => @specimen_receipt.id, :specimen_receipt => {:storage_container_id => "234"}, :format => 'json'
          specimen_receipt = SpecimenReceipt.last
          response.body.should eq specimen_receipt.to_json
        end
      end  
      
      describe "with json request" do
        it "forms json with updated @specimen_receipt" do
          put :update, :id => @specimen_receipt.id, :specimen_receipt => {:storage_container_id => nil}, :format => 'json'
          json = { "storage_container_id"  => ["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end      
    end
  end
end
