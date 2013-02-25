# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: pbs_lists
#
#  cert_flag_code                 :integer
#  created_at                     :datetime
#  frame_completion_req_code      :integer          not null
#  frame_order                    :integer
#  id                             :integer          not null, primary key
#  in_out_frame_code              :integer
#  in_out_psu_code                :integer
#  in_sample_code                 :integer
#  mos                            :integer
#  pbs_list_id                    :string(36)       not null
#  pr_cooperation_date            :date
#  pr_recruitment_end_date        :date
#  pr_recruitment_start_date      :date
#  pr_recruitment_status_code     :integer
#  practice_num                   :integer
#  provider_id                    :integer
#  psu_code                       :integer          not null
#  sampling_interval_woman        :decimal(4, 2)
#  selection_probability_location :decimal(7, 6)
#  selection_probability_overall  :decimal(7, 6)
#  selection_probability_woman    :decimal(7, 6)
#  sort_var1                      :integer
#  sort_var2                      :integer
#  sort_var3                      :integer
#  stratum                        :string(255)
#  substitute_provider_id         :integer
#  transaction_type               :string(255)
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
  it { should belong_to(:in_out_frame) }
  it { should belong_to(:in_sample) }
  it { should belong_to(:in_out_psu) }
  it { should belong_to(:cert_flag) }
  it { should belong_to(:frame_completion_req) }
  it { should belong_to(:pr_recruitment_status) }

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

      obj.in_out_frame.local_code.should == -4
      obj.in_sample.local_code.should == -4
      obj.in_out_psu.local_code.should == -4
      obj.cert_flag.local_code.should == -4
      obj.pr_recruitment_status.local_code.should == -4
    end
  end

  context "provider recruitment" do

    let(:pbs_list) { Factory(:pbs_list, :pr_recruitment_start_date => nil, :pr_cooperation_date => nil, :pr_recruitment_end_date => nil) }

    it "knows if provider recruitment has started" do
      pbs_list.should_not be_recruitment_started
      pbs_list.pr_recruitment_start_date = Date.today
      pbs_list.pr_recruitment_status_code = 3
      pbs_list.should be_recruitment_started
    end

    it "knows when provider recruitment has ended" do
      pbs_list.should_not be_recruitment_ended
      pbs_list.pr_recruitment_end_date = Date.today
      pbs_list.pr_recruitment_status_code = 1
      pbs_list.should be_recruitment_ended
    end

  end

  describe ".has_substitute_provider?" do

    it "returns true if the pbs_list record has an associated substitute_provider" do
      provider = Factory(:provider, :name_practice => "provider")
      sub = Factory(:provider, :name_practice => "substitute_provider")
      Factory(:pbs_list, :provider => provider, :substitute_provider => sub).has_substitute_provider?.should be_true
    end

    it "returns false if the pbs_list record does not have an associated substitute_provider" do
      provider = Factory(:provider, :name_practice => "provider")
      Factory(:pbs_list, :provider => provider, :substitute_provider => nil).has_substitute_provider?.should be_false
    end

  end

  describe ".provider_recruited?" do

    it "returns true if the pr_cooperation_date is set and the pr_recruitment_status_code is 1 (recruited)" do
      pbs = Factory(:pbs_list, :pr_cooperation_date => Date.today, :pr_recruitment_status_code => 1)
      pbs.should be_provider_recruited
    end

    it "returns false if the pr_cooperation_date is not set" do
      pbs = Factory(:pbs_list, :pr_cooperation_date => nil, :pr_recruitment_status_code => 1)
      pbs.should_not be_provider_recruited
    end

    it "returns false if the pr_recruitment_status_code is NOT 1 (recruited)" do
      pbs = Factory(:pbs_list, :pr_cooperation_date => Date.today, :pr_recruitment_status_code => 2)
      pbs.should_not be_provider_recruited
    end
  end

  describe "latest_provider_logistic_completion_date" do
    before(:each) do
      @provider = Factory(:provider)
      @pbs_list = Factory(:pbs_list, :provider => @provider)
    end

    it "returns logistic completion date if provider logistic is complete" do
      Factory(:provider_logistic, :completion_date => Date.new(2012, 05, 10), :provider => @provider)
      @pbs_list.latest_provider_logistic_completion_date.should == Date.new(2012, 05, 10)
    end

    it "returns nil if provider logistic is not complete" do
      Factory(:provider_logistic, :provider => @provider)
      @pbs_list.latest_provider_logistic_completion_date.should == nil
    end
  end

  describe "earliest_provider_recruitment_contact_date" do
    before(:each) do
      @provider = Factory(:provider)
      @pbs_list = Factory(:pbs_list, :provider => @provider)
    end

    it "returns last contact date from the provider recruitment contacts" do
      Factory(:contact_link, :event => Factory(:event, :event_type_code => 22), :person => Factory(:person),
        :contact => Factory(:contact, :contact_date_date => Date.new(2012, 05, 11)), :provider => @provider)
      @pbs_list.earliest_provider_recruitment_contact_date.should == Date.new(2012, 05, 11)
    end

    it "returns nil if provider recruitment contacts is empty" do
      @pbs_list.earliest_provider_recruitment_contact_date.should == nil
    end
  end

  describe "mark_in_progress" do
    it "set the recruitment_status_code to the 3" do
      pbs_list = Factory(:pbs_list)
      pbs_list.mark_in_progress!
      pbs_list.pr_recruitment_status_code.should == 3
    end
  end

  describe "update_recruitment_dates" do
    before(:each) do
      @provider = Factory(:provider)
      @pbs_list = Factory(:pbs_list, :provider => @provider, :pr_recruitment_start_date => nil, :pr_cooperation_date => nil, :pr_recruitment_end_date => nil)
    end

    describe "set the recruitment start date to" do
      it "nil if no provider contacts exist" do
        @pbs_list.pr_recruitment_start_date.should be_nil
        @pbs_list.update_recruitment_dates!
        @pbs_list.pr_recruitment_start_date.should be_nil
      end

      it "lastest provider contact date" do
        @pbs_list.pr_recruitment_start_date.should be_nil
        Factory(:contact_link, :event => Factory(:event, :event_type_code => 22), :person => Factory(:person),
                :contact => Factory(:contact, :contact_date_date => Date.new(2012, 05, 11)), :provider => @provider)
        @pbs_list.update_recruitment_dates!
        @pbs_list.pr_recruitment_start_date.should == Date.new(2012, 05, 11)
      end
    end

    describe "set the cooperation date to" do
      it "nil if no provider recruited" do
        @pbs_list.pr_cooperation_date.should be_nil
        @pbs_list.update_recruitment_dates!
        @pbs_list.pr_cooperation_date.should be_nil
      end

      it "earliest successful provider recruitment contact date" do
        @pbs_list.pr_recruitment_start_date.should be_nil
        Factory(:contact_link, :event => Factory(:event, :event_type_code => 22), :person => Factory(:person),
                :contact => Factory(:contact, :contact_disposition => 70, :contact_date_date => Date.new(2012, 05, 12)), :provider => @provider)
        @pbs_list.update_recruitment_dates!
        @pbs_list.pr_cooperation_date.should == Date.new(2012, 05, 12)
      end
    end

    describe "set the recruitment end date to" do
      it "nil if no provider logistice exist" do
        @pbs_list.pr_recruitment_end_date.should be_nil
        @pbs_list.update_recruitment_dates!
        @pbs_list.pr_recruitment_end_date.should be_nil
      end

      it "nil if provider logistic is not complete" do
        Factory(:provider_logistic, :provider => @provider)
        @pbs_list.pr_recruitment_end_date.should be_nil
        @pbs_list.update_recruitment_dates!
        @pbs_list.pr_recruitment_end_date.should be_nil
      end

      it "logistic completion date if provider logistic is complete" do
        @pbs_list.pr_recruitment_end_date.should be_nil
        Factory(:provider_logistic, :completion_date => Date.new(2012, 05, 15), :provider => @provider)
        @pbs_list.update_recruitment_dates!
        @pbs_list.pr_recruitment_end_date.should == Date.new(2012, 05, 15)
      end
    end
  end

  describe "update_recruitment_status" do
    before(:each) do
      @provider = Factory(:provider)
      @pbs_list = Factory(:pbs_list, :provider => @provider)
    end

    it "marks the recruitment_status to the in_progress if no provider recruited contacts " do
      @pbs_list.update_recruitment_status!
      @pbs_list.pr_recruitment_status_code.should == 3
    end

    it "marks the recruitment_status to the recruited if recruitment logistics is completed" do
      Factory(:provider_logistic, :completion_date => Date.new(2012, 05, 15), :provider => @provider)
      @pbs_list.update_recruitment_status!
      @pbs_list.pr_recruitment_status_code.should == 1
    end

    it "updates the provider event end date to the latest provider logistic completion date if such event exist" do
      Factory(:contact_link, :event => Factory(:event, :event_type_code => 22), :person => Factory(:person),
        :contact => Factory(:contact, :contact_disposition => 70, :contact_date_date => Date.new(2012, 05, 12)), :provider => @provider)
      Factory(:provider_logistic, :completion_date => Date.new(2012, 05, 17), :provider => @provider)
      @pbs_list.update_recruitment_status!
      @pbs_list.provider.provider_recruitment_event.event_end_date.should == Date.new(2012, 05, 17);
    end
  end

  describe ".is_hospital_type" do
    before do
      @hospital_pbs_list1 = Factory(:pbs_list, :in_out_frame_code => 4)
      @hospital_pbs_list2 = Factory(:pbs_list, :in_out_frame_code => 4)
      @non_hospital_pbs_list = Factory(:pbs_list, :in_out_frame_code => 1)
    end

    it "returns pbs_lists that have hospital sources" do
      PbsList.is_hospital_type.should == [@hospital_pbs_list1, @hospital_pbs_list2]
    end

    it "does not return pbs_lists that do not have hospital sources" do
      PbsList.is_hospital_type.should_not include(@non_hospital_pbs_list1)
    end
  end

  describe "#hospital?" do
    before do
      not_hospital = NcsCode.where(:list_name => 'INOUT_FRAME_CL1', :local_code => 1).first.local_code
      hospital     = NcsCode.where(:list_name => 'INOUT_FRAME_CL1', :local_code => 4).first.local_code
      @non_hospital_pbs_list = Factory(:pbs_list, :in_out_frame_code => not_hospital)
      @hospital_pbs_list     = Factory(:pbs_list, :in_out_frame_code => hospital)
    end

    it "true when in_out_frame_code is a hospital value" do
      @hospital_pbs_list.hospital?.should be_true
    end

    it "false when in_out_frame_codde is not a hospital value" do
      @non_hospital_pbs_list.hospital?.should be_false
    end
  end

end
