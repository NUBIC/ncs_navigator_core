# == Schema Information
# Schema version: 20111205175632
#
# Table name: ppg_details
#
#  id                  :integer         not null, primary key
#  psu_code            :string(36)      not null
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
  
end
