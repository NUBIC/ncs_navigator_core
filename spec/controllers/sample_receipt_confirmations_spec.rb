# -*- coding: utf-8 -*-
require 'spec_helper'

describe SampleReceiptConfirmationsController do
  context "with an authenticated user" do
    before(:each) do
      @sample_shipping1 = Factory(:sample_shipping, :sample_id => "sampleId1", :shipment_tracking_number => "123ABC")
      @sample_shipping2 = Factory(:sample_shipping, :sample_id => "sampleId2", :shipment_tracking_number => "567CDE")
      @sample_receipt_confirmations_edit1 = Factory(:sample_receipt_confirmation, :shipment_tracking_number => "123ABC", :staff_id => "someone special")
      @sample_receipt_confirmations_edit2 = Factory(:sample_receipt_confirmation, :shipment_tracking_number => "876FGH", :staff_id => "someone special")    
      login(user_login)
    end
    
    def valid_attributes
      {:shipment_receipt_datetime => @sample_receipt_confirmations_edit2.shipment_receipt_datetime, :shipment_tracking_number =>"567CDE", 
       :shipper_id => "shipper_id", :sample_id => @sample_receipt_confirmations_edit2.sample_id, 
       :shipment_received_by =>"Jane Dow", 
       :sample_receipt_temp => "2.00", 
       :sample_receipt_shipping_center_id =>"GCSC", 
       :staff_id => "someone special",
      }
    end
    
    def invalid_attributes
      {:shipment_tracking_number =>"567CDE", 
       :shipper_id => "shipper_id", :sample_id => @sample_receipt_confirmations_edit2.sample_id, 
       :sample_receipt_shipping_center_id =>"GCSC", 
      }
    end
    
    it "returns the result of not new and edit samples" do
      controller = SampleReceiptConfirmationsController.new
      results = controller.array_of_samples_per_tracking_number("123ABC")
      results.size.should == 2
    end
    
    describe "POST create" do
      describe "with valid params" do
        it "creates a new sample_receipt_confirmation object" do
          expect {
            post :create, :tracking_number => "567CDE", :sample_receipt_confirmation => valid_attributes
          }.to change(SampleReceiptConfirmation, :count).by(1)
        end

        it "assigns a newly created sample_receipt_confirmation as @sample_receipt_confirmation" do
          post :create, :sample_receipt_confirmation => valid_attributes
          assigns(:sample_receipt_confirmation).should be_a(SampleReceiptConfirmation)
          assigns(:sample_receipt_confirmation).should be_persisted
        end
        
        describe "with json request" do
          describe "with not repeating sample_receipt_confirmation" do
            it "creates a new SampleReceiptConfirmation" do
              expect {
                post :create, :sample_receipt_confirmation => valid_attributes, :format => 'json'
              }.to change(SampleReceiptConfirmation, :count).by(1)
            end
          end
        end
          
        describe "forms json" do 
          it "with newly created @sample_receipt_confirmation id" do
            post :create, :sample_receipt_confirmation => valid_attributes, :format => 'json'
            sample_receipt_confirmation = SampleReceiptConfirmation.last
            response.body.should eq sample_receipt_confirmation.to_json
          end
        end
      end
      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved sample_receipt_confirmation as @sample_receipt_confirmation" do
            # Trigger the behavior that occurs when invalid params are submitted
            SampleReceiptConfirmation.any_instance.stub(:save).and_return(false)
            post :create, :sample_receipt_confirmation => {}
            assigns(:sample_receipt_confirmation).should be_a_new(SampleReceiptConfirmation)
          end
        end
      end
      describe "with json request" do
        it "generates json with error list" do
          post :create, :sample_receipt_confirmation => invalid_attributes, :format => 'json'
          json = { "shipment_receipt_datetime" => ["can't be blank"], "sample_receipt_temp"=> ["can't be blank"], "shipment_received_by" =>["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end      
    end
    describe "PUT update" do
      describe "with json request and date change" do
        it "forms json with updated @sample_receipt_confirmation " do
          put :update, :id => @sample_receipt_confirmations_edit2.id, :sample_receipt_confirmation => {:shipment_received_by =>"By Me"}, :format => 'json'
          sample_receipt_confirmation = SampleReceiptConfirmation.last
          response.body.should eq sample_receipt_confirmation.to_json
        end
      end  
      
      describe "with json request" do
        it "forms json with updated @sample_receipt_store" do
          put :update, :id => @sample_receipt_confirmations_edit2.id, :sample_receipt_confirmation => {:shipment_received_by => nil}, :format => 'json'
          json = { "shipment_received_by"  => ["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end      
    end    
  end
end