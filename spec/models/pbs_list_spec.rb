# == Schema Information
# Schema version: 20120607203203
#
# Table name: pbs_lists
#
#  id                             :integer         not null, primary key
#  psu_code                       :integer         not null
#  pbs_list_id                    :string(36)      not null
#  provider_id                    :integer
#  practice_num                   :integer
#  in_out_frame_code              :integer
#  in_sample_code                 :integer
#  substitute_provider_id         :integer
#  in_out_psu_code                :integer
#  mos                            :integer
#  cert_flag_code                 :integer
#  stratum                        :string(255)
#  sort_var1                      :integer
#  sort_var2                      :integer
#  sort_var3                      :integer
#  frame_order                    :integer
#  selection_probability_location :decimal(7, 6)
#  sampling_interval_woman        :decimal(4, 2)
#  selection_probability_woman    :decimal(7, 6)
#  selection_probability_overall  :decimal(7, 6)
#  frame_completion_req_code      :integer         not null
#  pr_recruitment_status_code     :integer
#  pr_recruitment_start_date      :date
#  pr_cooperation_date            :date
#  pr_recruitment_end_date        :date
#  transaction_type               :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#

require 'spec_helper'

describe PbsList do
  it "should create a new instance given valid attributes" do
    pbs_list = Factory(:pbs_list)
    pbs_list.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:provider) }
  it { should belong_to(:substitute_provider) }
  it { should belong_to(:in_out_frame) }            # MDES 3.0
  it { should belong_to(:in_sample) }               # MDES 3.0
  it { should belong_to(:in_out_psu) }              # MDES 3.0
  it { should belong_to(:cert_flag) }               # MDES 3.0
  it { should belong_to(:frame_completion_req) }
  it { should belong_to(:pr_recruitment_status) }   # MDES 3.0

  it { should validate_presence_of(:provider) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pbs_list = Factory(:pbs_list)
      pbs_list.public_id.should_not be_nil
      pbs_list.pbs_list_id.should == pbs_list.public_id
      pbs_list.pbs_list_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      pbs_list = PbsList.new
      pbs_list.psu_code = 20000030
      pbs_list.provider = Factory(:provider)
      pbs_list.save!

      obj = PbsList.first
      obj.frame_completion_req.local_code.should == -4

      # TODO: MDES 3.0 code lists
      obj.in_out_frame.should be_nil
      obj.in_sample.should be_nil
      obj.in_out_psu.should be_nil
      obj.cert_flag.should be_nil
      obj.pr_recruitment_status.should be_nil
    end
  end

  context "provider recruitment" do

    let(:pbs_list) { Factory(:pbs_list, :pr_recruitment_start_date => nil, :pr_cooperation_date => nil, :pr_recruitment_end_date => nil) }

    it "knows if provider recruitment has started" do
      pbs_list.should_not be_recruitment_started
      pbs_list.pr_recruitment_start_date = Date.today
      pbs_list.should be_recruitment_started
    end

    it "knows when provider recruitment has ended" do
      pbs_list.should_not be_recruitment_ended
      pbs_list.pr_recruitment_end_date = Date.today
      pbs_list.should be_recruitment_ended
    end

  end

end
