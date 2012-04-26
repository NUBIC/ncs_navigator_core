# encoding: utf-8

require 'spec_helper'

describe Participant do

  context "in low intensity arm" do

    let(:ppg1_participant) { Factory(:low_intensity_ppg1_participant) }
    let(:ppg2_participant) { Factory(:low_intensity_ppg2_participant) }
    let(:ppg3_participant) { Factory(:low_intensity_ppg3_participant) }
    let(:ppg4_participant) { Factory(:low_intensity_ppg4_participant) }
    let(:ppg5_participant) { Factory(:low_intensity_ppg5_participant) }
    let(:ppg6_participant) { Factory(:low_intensity_ppg6_participant) }

    it "is in the correct pregnancy participant group" do
      ppg1_participant.should be_low_intensity
      ppg1_participant.ppg_status.local_code.should == 1

      ppg2_participant.should be_low_intensity
      ppg2_participant.ppg_status.local_code.should == 2

      ppg3_participant.should be_low_intensity
      ppg3_participant.ppg_status.local_code.should == 3

      ppg4_participant.should be_low_intensity
      ppg4_participant.ppg_status.local_code.should == 4

      ppg5_participant.should be_low_intensity
      ppg5_participant.ppg_status.local_code.should == 5

      ppg6_participant.should be_low_intensity
      ppg6_participant.ppg_status.local_code.should == 6
    end

    it "knows if pregnant" do
      ppg1_participant.should be_pregnant
      ppg1_participant.should be_known_to_be_pregnant

      ppg2_participant.should_not be_pregnant
      ppg2_participant.should_not be_known_to_be_pregnant

      ppg3_participant.should_not be_pregnant
      ppg3_participant.should_not be_known_to_be_pregnant

      ppg4_participant.should_not be_pregnant
      ppg4_participant.should_not be_known_to_be_pregnant

      ppg5_participant.should_not be_pregnant
      ppg5_participant.should_not be_known_to_be_pregnant

      ppg6_participant.should_not be_pregnant
      ppg6_participant.should_not be_known_to_be_pregnant
    end

  end

  context "in high intensity arm" do
    let(:ppg1_participant) { Factory(:high_intensity_ppg1_participant) }
    let(:ppg2_participant) { Factory(:high_intensity_ppg2_participant) }
    let(:ppg3_participant) { Factory(:high_intensity_ppg3_participant) }
    let(:ppg4_participant) { Factory(:high_intensity_ppg4_participant) }
    let(:ppg5_participant) { Factory(:high_intensity_ppg5_participant) }
    let(:ppg6_participant) { Factory(:high_intensity_ppg6_participant) }

    it "is in the correct pregnancy participant group" do
      ppg1_participant.should be_high_intensity
      ppg1_participant.ppg_status.local_code.should == 1

      ppg2_participant.should be_high_intensity
      ppg2_participant.ppg_status.local_code.should == 2

      ppg3_participant.should be_high_intensity
      ppg3_participant.ppg_status.local_code.should == 3

      ppg4_participant.should be_high_intensity
      ppg4_participant.ppg_status.local_code.should == 4

      ppg5_participant.should be_high_intensity
      ppg5_participant.ppg_status.local_code.should == 5

      ppg6_participant.should be_high_intensity
      ppg6_participant.ppg_status.local_code.should == 6
    end

    it "knows if pregnant" do
      ppg1_participant.should be_pregnant
      ppg1_participant.should be_known_to_be_pregnant

      ppg2_participant.should_not be_pregnant
      ppg2_participant.should_not be_known_to_be_pregnant

      ppg3_participant.should_not be_pregnant
      ppg3_participant.should_not be_known_to_be_pregnant

      ppg4_participant.should_not be_pregnant
      ppg4_participant.should_not be_known_to_be_pregnant

      ppg5_participant.should_not be_pregnant
      ppg5_participant.should_not be_known_to_be_pregnant

      ppg6_participant.should_not be_pregnant
      ppg6_participant.should_not be_known_to_be_pregnant
    end

  end

end