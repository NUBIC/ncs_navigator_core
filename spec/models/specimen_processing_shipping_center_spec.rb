require 'spec_helper'

describe SpecimenProcessingShippingCenter do
  it "should create a new instance given valid attributes" do
    specimen_processing_shipping_center = Factory(:specimen_processing_shipping_center)
    specimen_processing_shipping_center.should_not be_nil
  end
  
  it { should belong_to(:address) }
  it { should belong_to(:psu) } 
  
  context "as mdes record" do
    it "has the srsc_id" do
      spsc = Factory(:specimen_processing_shipping_center)
      spsc.specimen_processing_shipping_center_id.to_s.should == "spsc_id"
    end

    it "saves an object for all required params" do
      spsc = SpecimenProcessingShippingCenter.create(:specimen_processing_shipping_center_id => "spscId134", :psu_code => "20000030")
      spsc.save!
      obj = SpecimenProcessingShippingCenter.find(spsc.id)
      obj.psu.local_code.should == 20000030
    end
  end  
end

