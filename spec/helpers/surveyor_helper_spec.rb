# -*- coding: utf-8 -*-

require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SurveyorHelper. For example:
#
# describe SurveyorHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe SurveyorHelper do

  describe "#no_event_section_menu_message" do

    let(:response_set) { Factory(:response_set) }

    context "no response set given" do
      it "returns the generic 'Survey' message" do
        helper.no_event_section_menu_message(nil).should == "No Event associated with this Survey."
      end
    end

    context "non_interview_report_associated" do
      it "returns Non Interview Report message" do
        response_set.stub(:non_interview_report_associated? => true)
        helper.no_event_section_menu_message(response_set).should == "No Event associated with this Non Interview Report."
      end
    end

    context "participant_consent_associated" do
      it "returns Participant Consent message" do
        response_set.stub(:participant_consent_associated? => true)
        helper.no_event_section_menu_message(response_set).should == "No Event associated with this Participant Consent."
      end
    end

    context "instrument_associated" do
      it "returns Instrument message" do
        response_set.stub(:instrument_associated? => true)
        helper.no_event_section_menu_message(response_set).should == "No Event associated with this Instrument."
      end
    end

  end

end