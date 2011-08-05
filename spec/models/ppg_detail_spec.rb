# == Schema Information
# Schema version: 20110805151543
#
# Table name: ppg_details
#
#  id                  :integer         not null, primary key
#  psu_code            :string(36)      not null
#  ppg_details_id      :binary          not null
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
  
  it "should create a new instance given valid attributes" do
    ppg = Factory(:ppg_detail)
    ppg.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:ppg_pid_status) }
  it { should belong_to(:ppg_first) }
  
end
