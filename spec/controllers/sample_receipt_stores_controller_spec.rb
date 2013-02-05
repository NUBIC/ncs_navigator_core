# -*- coding: utf-8 -*-
require 'spec_helper'

describe SampleReceiptStoresController do
  context "with an authenticated user" do
    before(:each) do
      login(user_login)
      @sample = Factory(:sample)
      @sample_receipt_store = Factory(:sample_receipt_store)
    end


    def valid_attributes
      { :sample_id => @sample.id, :sample_receipt_shipping_center_id => "123ABC",
        :staff_id => "someone special", :receipt_datetime => DateTime.parse('2012-12-25 12:00:00'),
        :placed_in_storage_datetime => DateTime.parse('2012-12-25 12:00:00')}
    end

    describe "GET new" do
      it "assigns a new sample_receipt_store as @sample_receipt_store" do
        get :new, :sample_id => @sample.sample_id
        assigns(:sample_receipt_store).should be_a_new(SampleReceiptStore)
      end
    end

    describe "GET edit" do
      it "assigns the requested sample_receipt_store as @sample_receipt_store" do
        get :edit, :id => @sample_receipt_store.sample_id.to_s
        assigns(:sample_receipt_store).should eq(@sample_receipt_store)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new sample_receipt_store object" do
          expect {
            post :create, :sample_receipt_store => valid_attributes
          }.to change(SampleReceiptStore, :count).by(1)
        end

        it "assigns a newly created sample_receipt_store as @sample_receipt_store" do
          post :create, :sample_receipt_store => valid_attributes
          assigns(:sample_receipt_store).should be_a(SampleReceiptStore)
          assigns(:sample_receipt_store).should be_persisted
        end

        describe "with json request" do
          describe "with not repeating sample_receipt_store" do
            it "creates a new SampleReceiptStore" do
              expect {
                post :create, :sample_receipt_store => valid_attributes, :format => 'json'
              }.to change(SampleReceiptStore, :count).by(1)
            end
          end
        end

        describe "forms json" do
          it "with newly created @sample_receipt_store id" do
            post :create, :sample_receipt_store => valid_attributes, :format => 'json'
            sample_receipt_store = SampleReceiptStore.last
            response.body.should eq sample_receipt_store.to_json
          end
        end
      end
      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved sample_receipt_store as @sample_receipt_store" do
            # Trigger the behavior that occurs when invalid params are submitted
            SampleReceiptStore.any_instance.stub(:save).and_return(false)
            post :create, :sample_receipt_store => {}
            assigns(:sample_receipt_store).should be_a_new(SampleReceiptStore)
          end
        end
      end
      describe "with json request" do
        it "generates json with error list" do
          post :create, :sample_receipt_store => {}, :format => 'json'
          json = { "placed_in_storage_datetime"=>["can't be blank"], "receipt_datetime"=>["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end
    end

    describe "PUT update" do
      describe "with json request and date change" do
        it "forms json with updated @sample_receipt_store storage_container_id" do
          put :update, :id => @sample_receipt_store.id, :sample_receipt_store => {:receipt_datetime =>"2012-03-07 15:36:19"}, :format => 'json'
          sample_receipt_store = SampleReceiptStore.last
          response.body.should eq sample_receipt_store.to_json
        end
      end

      describe "with json request" do
        it "forms json with updated @sample_receipt_store" do
          put :update, :id => @sample_receipt_store.id, :sample_receipt_store => {:receipt_datetime => nil}, :format => 'json'
          json = { "receipt_datetime"=>["can't be blank"]}
          ActiveSupport::JSON.decode(response.body).should eq json
        end
      end
    end
  end
end
