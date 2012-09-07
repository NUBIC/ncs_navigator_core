# -*- coding: utf-8 -*-


require 'spec_helper'

# TODO - WILL BE DELETED
describe SamplesController do
  # before(:each) do
  #   login(user_login)
  # end
  # 
  # it "returns the result of not shipped samples" do
  #   sr1 = Factory(:sample_receipt_store)
  # 
  #   controller = SamplesController.new
  #   results = controller.array_of_not_shipped_samples
  #   results.size.should == 1
  #   # results.first.sample_id.should.eql?("sampleId")
  # end
  # 
  # it "returns the result of selected samples" do
  #   sr1 = Factory(:sample_receipt_store, :sample_id => "sampleId1")
  #   sr2 = Factory(:sample_receipt_store, :sample_id => "sampleId2")
  #   sr3 = Factory(:sample_receipt_store, :sample_id => "sampleId3")
  #   sr4 = Factory(:sample_receipt_store, :sample_id => "sampleId4")
  # 
  #   controller = SamplesController.new
  #   results = controller.array_of_selected_samples(["sampleId2","sampleId4"])
  #   results.size.should == 2
  # end
  # 
  # it "should fail on error" do
  #   Factory(:sample_receipt_shipping_center)
  #   SampleShipping.any_instance.stub(:save).and_return(false)
  #   post :generate, :sample_shipping => {}
  # end
  # 
  # it "should not save unles saves all objects" do
  #   ss1 = Factory.build(:sample_shipping, :shipper_id => "1")
  #   ss2 = Factory.build(:sample_shipping, :shipper_id => nil)
  #   ss3 = Factory.build(:sample_shipping, :shipper_id => "1")
  #   ss4 = Factory.build(:sample_shipping, :shipper_id => "1")
  # 
  #   srs_array = [ss1, ss2, ss3, ss4]
  #   SampleShipping.transaction do
  #     srs_array.each do |srs|
  #       raise ActiveRecord::Rollback unless srs.save
  #     end
  #   end
  #   results = SampleShipping.find(:all, :conditions => { :shipment_tracking_number => ss1.shipment_tracking_number })
  #   results.size.should == 0
  # end
  # 
  # it "should save properly created sample_shipping objects" do
  # 
  #   ss1 = Factory.build(:sample_shipping, :shipper_id => "1")
  #   ss2 = Factory.build(:sample_shipping, :shipper_id => "1")
  #   ss3 = Factory.build(:sample_shipping, :shipper_id => "1")
  # 
  #   ss_array = [ss1, ss2, ss3]
  #   SampleShipping.transaction do
  #     ss_array.each do |ss|
  #       raise ActiveRecord::Rollback unless ss.save
  #     end
  #   end
  #   results = SampleShipping.find(:all, :conditions => { :shipment_tracking_number => ss1.shipment_tracking_number })
  #   results.size.should == 3
  # end
end