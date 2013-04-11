# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: ppg_details
#
#  created_at          :datetime
#  due_date_2          :string(10)
#  due_date_3          :string(10)
#  id                  :integer          not null, primary key
#  lock_version        :integer          default(0)
#  orig_due_date       :string(10)
#  participant_id      :integer
#  ppg_details_id      :string(36)       not null
#  ppg_first_code      :integer          not null
#  ppg_pid_status_code :integer          not null
#  psu_code            :integer          not null
#  response_set_id     :integer
#  transaction_type    :string(36)
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
    it "returns nil if no due date" do
      ppg = Factory(:ppg_detail, :orig_due_date => nil, :due_date_2 => nil, :due_date_3 => nil)
      ppg.due_date.should be_nil
    end

    it "does not include the 'unknown' due date (i.e. 9777-97-97)" do
      ppg = Factory(:ppg_detail, :orig_due_date => '2011-12-25', :due_date_2 => '9777-97-97', :due_date_3 => '9777-97-97')
      ppg.due_date.should == '2011-12-25'

      ppg.update_due_date('2011-12-26', :due_date_2)
      ppg.due_date.should == '2011-12-26'
    end

    it "returns the most recently known due date" do
      ppg = Factory(:ppg_detail, :orig_due_date => nil, :due_date_2 => nil, :due_date_3 => nil)
      ppg.due_date.should be_nil

      date = Date.parse("2525-01-09")

      dt = 9.months.since(date).strftime("%Y-%m-%d")
      ppg.update_due_date(dt)
      ppg.due_date.should == dt
      ppg.orig_due_date.should == dt

      dt2 = 8.months.since(date).strftime("%Y-%m-%d")
      ppg.update_due_date(dt2)
      ppg.orig_due_date.should == dt
      ppg.due_date_2.should == dt2
      ppg.due_date.should == dt2

      dt3 = 7.months.since(date).strftime("%Y-%m-%d")
      ppg.update_due_date(dt3)
      ppg.orig_due_date.should == dt
      ppg.due_date_2.should == dt2
      ppg.due_date_3.should == dt3
      ppg.due_date.should == dt3

    end

    it "doesn't return invalid dates" do
      ppg = Factory(:ppg_detail, :orig_due_date => '2012-02-09', :due_date_2 => '9666-96-96', :due_date_3 => '9666-96-96')
      ppg.due_date.should == '2012-02-09'
    end

    it "ignores empty strings" do
      ppg = Factory(:ppg_detail, :orig_due_date => '2012-02-09', :due_date_2 => '', :due_date_3 => '9666-96-96')
      ppg.due_date.should == '2012-02-09'
    end

  end

  it { should belong_to(:participant) }
  it { should belong_to(:response_set) }

  context "associated ppg_status_history" do
    let(:participant) { Factory(:participant) }
    let(:pd_status1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1) }
    let(:ppg_status1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1) }

    describe 'automatically created history entry' do
      let(:ppg_details) { PpgDetail.where(:participant_id => participant.id) }
      let(:ppg_status_histories) { PpgStatusHistory.where(:participant_id => participant.id) }

      context do
        before(:each) do
          PpgStatusHistory.where(
            :participant_id => participant.id, :ppg_status_code => ppg_status1.local_code).
            count.should == 0
          Factory(:ppg_detail, :participant => participant)
          ppg_details.count.should == 1
          ppg_status_histories.count.should == 1
        end

        it 'uses the same code value as ppg_first' do
          ppg_details.first.ppg_first.local_code.should ==
            ppg_status_histories.first.ppg_status.local_code
        end

        it 'uses a code value from PPG_STATUS_CL1' do
          ppg_status_histories.first.ppg_status.list_name.should == 'PPG_STATUS_CL1'
        end
      end

      describe 'history date' do
        describe 'when specified' do
          let(:desired_date_s) { '2010-04-07' }
          let(:desired_date)   { Date.parse(desired_date_s) }

          before do
            Factory(:ppg_detail, :participant => participant,
            :desired_history_date => desired_date)
          end

          it 'is the desired date for ppg_status_date' do
            ppg_status_histories.first.ppg_status_date.should == desired_date_s
          end

          it 'is the desired date for ppg_status_date_date' do
            ppg_status_histories.first.ppg_status_date_date.should == desired_date
          end
        end

        describe 'when not specified' do
          let(:today)   { Date.today }
          let(:today_s) { today.to_s }

          before do
            Factory(:ppg_detail, :participant => participant)
          end

          it "uses today's date for ppg_status_date" do
            ppg_status_histories.first.ppg_status_date.should == today_s
          end

          it "is today's date for ppg_status_date_date" do
            ppg_status_histories.first.ppg_status_date_date.should == today
          end
        end
      end
    end

    describe "#importer_mode" do

      it "suppresses the creation of associated ppg_status_history" do
        PpgStatusHistory.where(:participant_id => participant.id).where(:ppg_status_code => ppg_status1.local_code).count.should == 0
        PpgDetail.importer_mode do
          Factory(:ppg_detail, :ppg_first_code => pd_status1.local_code, :participant => participant)
          pd = PpgDetail.where(:participant_id => participant.id)
          psh = PpgStatusHistory.where(:participant_id => participant.id)

          pd.count.should == 1
          psh.count.should == 0
        end
      end

      it "turns the callback back on after processing in importer mode" do
        PpgStatusHistory.where(:participant_id => participant.id).where(:ppg_status_code => ppg_status1.local_code).count.should == 0

        PpgDetail.importer_mode do
          Factory(:ppg_detail, :ppg_first_code => pd_status1.local_code, :participant => participant)
          pd = PpgDetail.where(:participant_id => participant.id)
          psh = PpgStatusHistory.where(:participant_id => participant.id)

          pd.count.should == 1
          psh.count.should == 0
        end

        Factory(:ppg_detail, :ppg_first_code => pd_status1.local_code, :participant => participant)
        pd = PpgDetail.where(:participant_id => participant.id)
        psh = PpgStatusHistory.where(:participant_id => participant.id)

        pd.count.should == 2
        psh.count.should == 1
      end

    end

  end

end

