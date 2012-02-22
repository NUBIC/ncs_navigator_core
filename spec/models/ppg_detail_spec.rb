# == Schema Information
# Schema version: 20120222225559
#
# Table name: ppg_details
#
#  id                  :integer         not null, primary key
#  psu_code            :integer         not null
#  ppg_details_id      :string(36)      not null
#  participant_id      :integer
#  ppg_pid_status_code :integer         not null
#  ppg_first_code      :integer         not null
#  orig_due_date       :string(10)
#  due_date_2          :string(10)
#  due_date_3          :string(10)
#  transaction_type    :string(36)
#  created_at          :datetime
#  updated_at          :datetime
#  response_set_id     :integer
#

require 'spec_helper'

describe PpgDetail do

  it "creates a new instance given valid attributes" do
    ppg = Factory(:ppg_detail)
    ppg.should_not be_nil
  end

  it "describes itself" do
    ppg = Factory(:ppg_detail)
    ppg.to_s.should == ppg.ppg_first.to_s
  end

  context "due date" do
    it "should return nil if no due date" do
      ppg = Factory(:ppg_detail, :orig_due_date => nil, :due_date_2 => nil, :due_date_3 => nil)
      ppg.due_date.should be_nil
    end

    it "should return the most recently known due date" do
      ppg = Factory(:ppg_detail, :orig_due_date => nil, :due_date_2 => nil, :due_date_3 => nil)
      ppg.due_date.should be_nil

      dt = 9.months.from_now.strftime("%Y%m%d")
      ppg.update_due_date(dt)
      ppg.due_date.should == dt
      ppg.orig_due_date.should == dt

      dt2 = 8.months.from_now.strftime("%Y%m%d")
      ppg.update_due_date(dt2)
      ppg.orig_due_date.should == dt
      ppg.due_date_2.should == dt2
      ppg.due_date.should == dt2

      dt3 = 7.months.from_now.strftime("%Y%m%d")
      ppg.update_due_date(dt3)
      ppg.orig_due_date.should == dt
      ppg.due_date_2.should == dt2
      ppg.due_date_3.should == dt3
      ppg.due_date.should == dt3

    end
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:ppg_pid_status) }
  it { should belong_to(:ppg_first) }
  it { should belong_to(:response_set) }

  context "associated ppg_status_history" do

    let(:participant) { Factory(:participant) }
    let(:pd_status1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1: Pregnant", :local_code => 1) }
    let(:ppg_status1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant", :local_code => 1) }

    before(:each) do
      create_missing_in_error_ncs_codes(PpgStatusHistory)
    end

    it "creates a ppg_status_history record when first creating ppg_detail" do
      PpgStatusHistory.where(:participant_id => participant.id).where(:ppg_status_code => ppg_status1.local_code).count.should == 0
      Factory(:ppg_detail, :ppg_first_code => pd_status1.local_code, :participant => participant)
      pd = PpgDetail.where(:participant_id => participant.id)
      psh = PpgStatusHistory.where(:participant_id => participant.id)

      pd.count.should == 1
      psh.count.should == 1
      pd.first.ppg_first.local_code.should == psh.first.ppg_status.local_code
      pd.first.ppg_first.display_text.should == psh.first.ppg_status.display_text
    end

  end

end
