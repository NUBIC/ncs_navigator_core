# -*- coding: utf-8 -*-

require 'spec_helper'

describe ParticipantsHelper do
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ParticipantsHelper)
  end

  context "text" do
    describe ".displayable_event_name" do

      let(:event) { Factory(:event) }
      let(:lo_i_participant) { Factory(:low_intensity_ppg1_participant) }
      let(:hi_i_participant) { Factory(:high_intensity_ppg1_participant) }

      describe "non two-tier recruitement strategy" do

        before do
          helper.stub!(:recruitment_strategy).and_return(ProviderBased)
        end

        it "returns event.to_s for a lo I participant" do
          helper.displayable_event_name(event, lo_i_participant).should == event.to_s
        end

        it "returns event.to_s for a hi I participant" do
          helper.displayable_event_name(event, hi_i_participant).should == event.to_s
        end

      end

      describe "two-tier recruitement strategy" do

        before do
          helper.stub!(:recruitment_strategy).and_return(TwoTier)
        end

        it "returns Lo I: + event.to_s for a lo I participant" do
          expected = "#{PatientStudyCalendar::LOW_INTENSITY}: #{event.to_s}"
          helper.displayable_event_name(event, lo_i_participant).should == expected
        end

        it "returns Hi I: + event.to_s for a hi I participant" do
          expected = "#{PatientStudyCalendar::HIGH_INTENSITY}: #{event.to_s}"
          helper.displayable_event_name(event, hi_i_participant).should == expected
        end

      end

    end
  end

end