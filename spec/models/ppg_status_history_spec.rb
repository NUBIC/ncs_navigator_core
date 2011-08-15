# == Schema Information
# Schema version: 20110811161140
#
# Table name: ppg_status_histories
#
#  id                    :integer         not null, primary key
#  psu_code              :string(36)      not null
#  ppg_history_id        :binary          not null
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
#

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
  
end
