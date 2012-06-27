# == Schema Information
# Schema version: 20120626221317
#
# Table name: ppg_status_histories
#
#  id                    :integer         not null, primary key
#  psu_code              :integer         not null
#  ppg_history_id        :string(36)      not null
#  participant_id        :integer
#  ppg_status_code       :integer         not null
#  ppg_status_date       :string(10)
#  ppg_info_source_code  :integer         not null
#  ppg_info_source_other :string(255)
#  ppg_info_mode_code    :integer         not null
#  ppg_info_mode_other   :string(255)
#  ppg_comment           :text
#  transaction_type      :string(36)
#  created_at            :datetime
#  updated_at            :datetime
#  response_set_id       :integer
#  ppg_status_date_date  :date
#

# -*- coding: utf-8 -*-

require 'spec_helper'

describe PpgStatusHistory do
  it "should create a new instance given valid attributes" do
    ppg = Factory(:ppg_status_history)
    ppg.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:ppg_status) }
  it { should belong_to(:ppg_info_source) }
  it { should belong_to(:ppg_info_mode) }
  it { should belong_to(:response_set) }

  describe ".set_ppg_status_date" do

    it "sets the ppg_status_date to created_at if not set" do
      ppg = Factory(:ppg_status_history, :ppg_status_date => nil)
      ppg.ppg_status_date.should == Time.now.strftime(MdesRecord::DEFAULT_DATE_FORMAT)
    end

    it "does not update the ppg_status_date if already set" do
      ppg = Factory(:ppg_status_history, :ppg_status_date => '2012-01-01')
      ppg.ppg_status_date.should == '2012-01-01'
    end

  end

  context "determining the current ppg_status" do

    let(:participant1) { Factory(:participant) }
    let(:participant2) { Factory(:participant) }

    describe "#current_ppg_status" do

      before(:each) do
        @ppg2_1 = Factory(:ppg2_status, :participant => participant1)
        @ppg1_1 = Factory(:ppg1_status, :participant => participant1)

        @ppg2_2 = Factory(:ppg2_status, :participant => participant2)
      end

      it "returns the most recent ppg_status" do
        all = PpgStatusHistory.current_ppg_status.all
        all.should include @ppg1_1
        all.should include @ppg2_2
      end

      it "returns the most recent ppg_status for the given participant" do
        @ppg3 = Factory(:ppg3_status, :participant => participant1)
        PpgStatusHistory.current_ppg_status.for_participant(participant1).all.should == [@ppg3]
      end

      it "returns all records matching the given status code" do
        PpgStatusHistory.current_ppg_status.with_status(2).all.should == [@ppg2_2]
      end

    end

  end


end
