require 'spec_helper'

describe SpecimensController do
  before(:each) do
    login(user_login)
    create_missing_in_error_ncs_codes(SpecimenReceipt)
    create_missing_in_error_ncs_codes(SpecimenShipping)
    create_missing_in_error_ncs_codes(SpecimenProcessingShippingCenter)    
  end
  
  it "returns the result of not shipped specs" do
    
    sr1 = Factory(:specimen_receipt, :specimen_id => "specimenId1", :storage_container_id => "storageId1")
    sr2 = Factory(:specimen_receipt, :specimen_id => "specimenId2", :storage_container_id => "storageId2")
  
    sh1 = Factory(:specimen_shipping, :storage_container_id => "storageId1")
          
    controller = SpecimensController.new
    results = controller.array_of_not_shipped_specs
    results.size.should == 1
    results.first.storage_container_id.should.eql?("storageId2")
  end
  
  it "returns the list of results based on array of ids passed" do
    sr1 = Factory(:specimen_receipt, :specimen_id => "specimenId1", :storage_container_id => "storageId1")
    sr2 = Factory(:specimen_receipt, :specimen_id => "specimenId2", :storage_container_id => "storageId2")
    sr3 = Factory(:specimen_receipt, :specimen_id => "specimenId3", :storage_container_id => "storageId3")
    sr4 = Factory(:specimen_receipt, :specimen_id => "specimenId4", :storage_container_id => "storageId4")

    specimens_controller = SpecimensController.new
    results = specimens_controller.array_of_selected_specs(["storageId2","storageId4"])
    results.size.should == 2
  end
  
  it "should create the hash from array" do
    
    sr1 = Factory(:specimen_receipt, :specimen_id => "specimenId1", :storage_container_id => "storageId1")
    sr2 = Factory(:specimen_receipt, :specimen_id => "specimenId2", :storage_container_id => "storageId2")
    sr3 = Factory(:specimen_receipt, :specimen_id => "specimenId3", :storage_container_id => "storageId3")
    sr4 = Factory(:specimen_receipt, :specimen_id => "specimenId4", :storage_container_id => "storageId4")
    sr5 = Factory(:specimen_receipt, :specimen_id => "specimenId5", :storage_container_id => "storageId3")
    sr6 = Factory(:specimen_receipt, :specimen_id => "specimenId6", :storage_container_id => "storageId3")
    
    specimens_controller = SpecimensController.new
    results = specimens_controller.hash_from_array([sr1, sr2, sr3, sr4, sr5, sr6])
    results.keys.size.should == 4
    results.keys.should == ["storageId1", "storageId2", "storageId3", "storageId4"]
  end
  
  it "should fail on error" do
    Factory(:specimen_processing_shipping_center)
    SpecimenShipping.any_instance.stub(:save).and_return(false)
    post :generate, :specimen_shipping => {}
  end
  
  it "should not save any specimen shipping unless all objects are saved" do
    sh1 = Factory.build(:specimen_shipping, :storage_container_id => "storageId1")
    sh2 = Factory.build(:specimen_shipping, :storage_container_id => "storageId2")
    sh3 = Factory.build(:specimen_shipping, :storage_container_id => nil)
    sh4 = Factory.build(:specimen_shipping, :storage_container_id => "storageId4")
  
    sh_array = [sh1, sh2, sh3, sh4]
    SpecimenShipping.transaction do
      sh_array.each do |sh|
        raise ActiveRecord::Rollback unless sh.save
      end
    end
    results = SpecimenShipping.find(:all, :conditions => { :shipment_tracking_number => sh1.shipment_tracking_number })
    results.size.should == 0    
  end
  
  it "should save properly created objects" do
    sh1 = Factory.build(:specimen_shipping, :storage_container_id => "storageId1")
    sh2 = Factory.build(:specimen_shipping, :storage_container_id => "storageId2")
    sh3 = Factory.build(:specimen_shipping, :storage_container_id => "storageId3")  
    sh_array = [sh1, sh2, sh3]
    SpecimenShipping.transaction do
      sh_array.each do |sh|
        raise ActiveRecord::Rollback unless sh.save
      end
    end
    results = SpecimenShipping.find(:all, :conditions => { :shipment_tracking_number => sh1.shipment_tracking_number })
    results.size.should == 3    
  end
  
  describe "setting parameters" do
    
    it "should set the shipper id" do
      Factory(:specimen_processing_shipping_center)
      NcsNavigatorCore.stub!(:shipper_id).and_return "shipper_id"
      get :verify
      assigns[:shipper_id].should == NcsNavigatorCore.shipper_id
    end
  end
  
end