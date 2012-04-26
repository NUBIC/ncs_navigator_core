require 'spec_helper'

describe SpecimenSampleProcessesController do
  context "with an authenticated user" do
    before(:each) do
      login(user_login)
      @sample1 = Factory(:sample, :sample_id => "EC123-DB11")
      @sample2 = Factory(:sample, :sample_id => "EC234-DB22")
      @sample3 = Factory(:sample, :sample_id => "EC345-DB33")
      
      @specimen1 = Factory(:specimen, :specimen_id => "BE456-UR44")  
      @specimen2 = Factory(:specimen, :specimen_id => "BE567-UR55")  
      @specimen3 = Factory(:specimen, :specimen_id => "BE678-UR66")  
      @specimen4 = Factory(:specimen, :specimen_id => "BE789-UR77")  
    end

    describe "GET index" do
      before(:each) do
        Sample.count.should == 3
        Specimen.count.should == 4
      end
      
      describe "plain index" do
        it "returns proper values" do
          get :index
          assigns[:samples].count.should equal(3)
          assigns[:samples].should include @sample1
          assigns[:samples].should include @sample2
          assigns[:samples].should include @sample3
          
          assigns[:specimens].count.should equal(4)
          assigns[:specimens].should include @specimen1
          assigns[:specimens].should include @specimen2
          assigns[:specimens].should include @specimen3
          assigns[:specimens].should include @specimen4
        end
      end
      
      describe "receive by specimen_id" do
        it "returns complete matches" do
          get :receive, :specimen_id =>["BE567-UR55", "BE789-UR77"], :sample_id => ["EC234-DB22"]
          assigns[:specimens].count.should equal(2)
          assigns[:specimens].should include @specimen2.specimen_id
          assigns[:specimens].should include @specimen4.specimen_id
          assigns[:specimens].should_not include @specimen1.specimen_id
          assigns[:specimens].should_not include @specimen3.specimen_id
          
          assigns[:samples].count.should equal(1)
          assigns[:samples].should include @sample2.sample_id
          assigns[:samples].should_not include @sample1.sample_id
          assigns[:samples].should_not include @sample3.sample_id
        end
      end
    end
  end
end
