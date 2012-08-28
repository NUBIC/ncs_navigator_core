# -*- coding: utf-8 -*-
require 'spec_helper'

# Todo - will not be used
describe SpecimensController do
  # before(:each) do
  #   login(user_login)
  # end
  # 
  # it "returns the result of not shipped specs" do
  #   
  #   sr1 = Factory(:specimen_receipt, :specimen_id => "specimenId1")
  #   sr2 = Factory(:specimen_receipt, :specimen_id => "specimenId2")
  # 
  #   sh1 = Factory(:specimen_shipping, :storage_container_id => "storageId1")
  #         
  #   controller = SpecimensController.new
  #   results = controller.array_of_not_shipped_specs
  #   results.size.should == 1
  #   results.first.storage_container_id.should.eql?("storageId2")
  # end
  # 
  # it "returns the list of results based on array of ids passed" do
  #   sr1 = Factory(:specimen_receipt, :specimen_id => "specimenId1", :storage_container_id => "storageId1")
  #   sr2 = Factory(:specimen_receipt, :specimen_id => "specimenId2", :storage_container_id => "storageId2")
  #   sr3 = Factory(:specimen_receipt, :specimen_id => "specimenId3", :storage_container_id => "storageId3")
  #   sr4 = Factory(:specimen_receipt, :specimen_id => "specimenId4", :storage_container_id => "storageId4")
  # 
  #   specimens_controller = SpecimensController.new
  #   results = specimens_controller.array_of_selected_spec_receipts(["storageId2","storageId4"])
  #   results.size.should == 2
  # end
  # 
  # it "should create the hash from array" do
  #   sr1 = Factory(:specimen_receipt, :specimen_id => "specimenId1", :storage_container_id => "storageId1")
  #   sr2 = Factory(:specimen_receipt, :specimen_id => "specimenId2", :storage_container_id => "storageId2")
  #   sr3 = Factory(:specimen_receipt, :specimen_id => "specimenId3", :storage_container_id => "storageId3")
  #   sr4 = Factory(:specimen_receipt, :specimen_id => "specimenId4", :storage_container_id => "storageId4")
  #   sr5 = Factory(:specimen_receipt, :specimen_id => "specimenId5", :storage_container_id => "storageId3")
  #   sr6 = Factory(:specimen_receipt, :specimen_id => "specimenId6", :storage_container_id => "storageId3")
  #   
  #   specimens_controller = SpecimensController.new
  #   results = specimens_controller.hash_from_array([sr1, sr2, sr3, sr4, sr5, sr6])
  #   results.keys.size.should == 4
  #   results.keys.should == ["storageId1", "storageId2", "storageId3", "storageId4"]
  # end
  # 
  # it "should fail on error" do
  #   Factory(:specimen_processing_shipping_center)
  #   SpecimenShipping.any_instance.stub(:save).and_return(false)
  #   post :generate, :specimen_shipping => {}
  # end
  # 
  # it "should not save any specimen shipping unless all objects are saved" do
  #   ssc = Factory(:specimen_storage_container, :storage_container_id => "CONTAINER1")
  #   sh1 = Factory.build(:specimen_shipping)
  #     sh1.specimen_storage_containers << ssc
  #   # sh2 = Factory.build(:specimen_shipping, :storage_container_id => "storageId2")
  #   # sh3 = Factory.build(:specimen_shipping, :storage_container_id => nil)
  #   # sh4 = Factory.build(:specimen_shipping, :storage_container_id => "storageId4")
  # 
  #   # @specimen_shipping = SpecimenShipping.new(@params)
  #   # specimen_storage_containers = params[:specimen_storage_container_id]
  #   # specimen_storage_containers.each do |ssc| 
  #   #   @specimen_shipping.specimen_storage_containers << SpecimenStorageContainer.find_by_storage_container_id(ssc)
  #   # end  
  # 
  #   # sh_array = [sh1, sh2, sh3, sh4]
  #   SpecimenShipping.transaction do
  #     raise ActiveRecord::Rollback unless sh.save
  #   end
  #   results = SpecimenShipping.find(:all, :conditions => { :shipment_tracking_number => sh1.shipment_tracking_number })
  #   results.size.should == 0    
  # end
  # 
  # it "should save properly created objects" do
  #   sh1 = Factory.build(:specimen_shipping, :storage_container_id => "storageId1")
  #   sh2 = Factory.build(:specimen_shipping, :storage_container_id => "storageId2")
  #   sh3 = Factory.build(:specimen_shipping, :storage_container_id => "storageId3")  
  #   sh_array = [sh1, sh2, sh3]
  #   SpecimenShipping.transaction do
  #     sh_array.each do |sh|
  #       raise ActiveRecord::Rollback unless sh.save
  #     end
  #   end
  #   results = SpecimenShipping.find(:all, :conditions => { :shipment_tracking_number => sh1.shipment_tracking_number })
  #   results.size.should == 3    
  # end
  # 
  # it "should save all the referenced object" do
  #   array_of_spec_shipping_records = []
  #   s1 = Factory.create(:specimen, :specimen_id => "specimenId1")
  #   s2 = Factory.create(:specimen, :specimen_id => "specimenId2")
  #   s3 = Factory.create(:specimen, :specimen_id => "specimenId3")
  #   
  #   sr1 = Factory.build(:specimen_receipt, :specimen_id => "specimenId1", :storage_container_id => "storageId1")
  #   sr2 = Factory.build(:specimen_receipt, :specimen_id => "specimenId2", :storage_container_id => "storageId2")
  #   sr3 = Factory.build(:specimen_receipt, :specimen_id => "specimenId3", :storage_container_id => "storageId1")
  # 
  #   @volume_amt = {"specimenId1"=>"1", "specimenId2"=>"0.25", "specimenId3"=>"3"}
  #   @volume_unit = {"specimenId1"=>"butilka", "specimenId2"=>"mL", "specimenId3"=>"banki"}
  # 
  #   @specimen_receipts_hash = {"storageId1"=>[sr1, sr3], "storageId2"=>[sr2]}    
  # 
  #   @specimen_receipts_hash.each do |key, value|
  #      sh = Factory.build(:specimen_shipping, :storage_container_id => key)
  #      
  #      value.each do |sr|
  #        ship_specimen = sh.ship_specimens.build(      
  #            :specimen_shipping  => sh,
  #            :specimen_id        => Specimen.where(:specimen_id => sr.specimen_id).first.id, 
  #            :volume_amount      => @volume_amt[sr.specimen_id],
  #            :volume_unit        => @volume_unit[sr.specimen_id])
  #      end
  #      array_of_spec_shipping_records << sh
  #    end
  # 
  #   SpecimenShipping.transaction do
  #     array_of_spec_shipping_records.each do |sh|
  #       raise ActiveRecord::Rollback unless sh.save
  #     end
  #   end
  #   results = SpecimenShipping.find(:all)
  #   results.size.should == 2 
  #   ship_specimen_results = ShipSpecimen.find(:all)
  #   ship_specimen_results.size.should == 3
  #      
  # end  
end