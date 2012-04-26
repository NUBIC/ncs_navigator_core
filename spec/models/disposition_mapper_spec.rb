# -*- coding: utf-8 -*-


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

  it "returns the category by for_event_disposition_category_code" do
    [
      [1, DispositionMapper::HOUSEHOLD_ENUMERATION_EVENT],
      [2, DispositionMapper::PREGNANCY_SCREENER_EVENT],
      [3, DispositionMapper::GENERAL_STUDY_VISIT_EVENT],
      [4, DispositionMapper::MAILED_BACK_SAQ_EVENT],
      [5, DispositionMapper::TELEPHONE_INTERVIEW_EVENT],
      [6, DispositionMapper::INTERNET_SURVEY_EVENT],
      [0, DispositionMapper::GENERAL_STUDY_VISIT_EVENT]
    ].each do |code, expected|
      DispositionMapper.for_event_disposition_category_code(code).should == expected
    end

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

  context "determining disposition for an event" do

    before(:each) do
      @general_study = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :display_text => "General Study Visits (including CASI SAQs)", :local_code => 3)
      @pregnancy_screen = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :display_text => "Pregnancy Screening Events", :local_code => 2)
    end

    describe "#get_key_from_event_disposition_category" do

      it "finds GENERAL_STUDY_VISIT_EVENT" do
        DispositionMapper.get_key_from_event_disposition_category(@general_study).should == DispositionMapper::GENERAL_STUDY_VISIT_EVENT
      end

      it "finds PREGNANCY_SCREENER_EVENT" do
        DispositionMapper.get_key_from_event_disposition_category(@pregnancy_screen).should == DispositionMapper::PREGNANCY_SCREENER_EVENT
      end
    end

    describe "#disposition_text_for_event" do

      it "returns the given disposition code if no event disposition category given" do
        DispositionMapper.disposition_text_for_event(nil, 55).should == 55
      end

      it "returns the disposition text for a matching event disposition category and code" do
        DispositionMapper.disposition_text_for_event(@general_study, 55).should == "Eligible Non-response- Other"
        DispositionMapper.disposition_text_for_event(@general_study, 16).should == "Participant incarcerated"
      end

    end

  end
end