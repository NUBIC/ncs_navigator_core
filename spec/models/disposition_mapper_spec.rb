require 'spec_helper'

describe DispositionMapper do

  it "gets all the disposition options grouped by event" do
    grouped_options = DispositionMapper.get_grouped_options

    grouped_options.keys.sort.should == DispositionMapper::EVENTS
  end

  it "returns only the disposition options for the given event" do
    grouped_options = DispositionMapper.get_grouped_options("General Study Visit Event")
    grouped_options.keys.size.should == 1
    grouped_options.keys.should == ["General Study Visit Event"]
  end

  context "determining the event given a contact type" do
    it "handles Telephone" do
      grouped_options = DispositionMapper.get_grouped_options("Telephone")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Telephone Interview Event"]
    end

    it "handles Mail" do
      grouped_options = DispositionMapper.get_grouped_options("Mail")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Mailed Back SAQ Event"]
    end
  end

  context "determining the event given a survey title" do
    it "handles Household Enumeration Surveys" do
      grouped_options = DispositionMapper.get_grouped_options("INS_QUE_HHEnum_INT_EH_P2_V1.2")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Household Enumeration Event"]
    end

    it "handles Pregnancy Screener Surveys" do
      grouped_options = DispositionMapper.get_grouped_options("INS_QUE_PregScreen_INT_HILI_P2_V2.0")
      grouped_options.keys.size.should == 1
      grouped_options.keys.should == ["Pregnancy Screener Event"]
    end
  end
end
