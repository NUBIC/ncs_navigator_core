# -*- coding: utf-8 -*-
require 'spec_helper'

describe SpecimenPickupsController do
  
  def valid_attributes
    {:specimen_pickup_datetime =>"2012-03-05 15:36:19", :specimen_pickup_comment_code => "3", :specimen_transport_temperature => "-1"}
  end
  
  context "with an authenticated user" do
    before(:each) do
      login(user_login)
    end
    
    describe "POST create" do
      describe "with valid params" do
        it "creates a new specimen pickup object" do
           Factory(:specimen_processing_shipping_center)
           expect {
             post :create, :specimen_pickup => valid_attributes
           }.to change(SpecimenPickup, :count).by(1)
         end
    
         it "assigns a newly created specimen pickup as @specimen_pickup" do
           Factory(:specimen_processing_shipping_center)
           post :create, :specimen_pickup =>  valid_attributes
           assigns(:specimen_pickup).should be_a(SpecimenPickup)
           assigns(:specimen_pickup).should be_persisted
         end
       
         it "redirects to the created specimen_pickup" do
           Factory(:specimen_processing_shipping_center)
           post :create, :specimen_pickup => valid_attributes
           @specimen_pickup = SpecimenPickup.find(:all)
           response.should redirect_to(specimen_pickup_path(@specimen_pickup))
         end
      end
    end
  end
end