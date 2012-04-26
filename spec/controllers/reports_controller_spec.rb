# -*- coding: utf-8 -*-

require 'spec_helper'

describe ReportsController do

  context "with an authenticated user" do
    before(:each) do
      login(user_login)
    end

    describe "GET case_status" do

      it "sets the default dates parameters for the report" do
        get :case_status
        assigns[:start_date].should == Date.today.to_s(:db)
        assigns[:end_date].should == 1.week.from_now.to_date.to_s(:db)
      end

    end

    describe "POST case_status" do

      it "generates a CSV report"

    end

    describe "GET upcoming_births" do

      let(:pregnant_participant) { Factory(:participant) }
      let(:trying_participant) { Factory(:participant) }
      let(:loss_participant) { Factory(:participant) }

      before(:each) do
        Factory(:ppg1_detail, :participant => pregnant_participant, :orig_due_date => 6.months.from_now.strftime("%Y-%m-%d"))
        Factory(:ppg2_detail, :participant => trying_participant, :orig_due_date => nil)
        Factory(:ppg1_detail, :participant => loss_participant, :orig_due_date => 6.months.from_now.strftime("%Y-%m-%d"), :created_at => 2.months.ago)
        Factory(:ppg3_status, :participant => loss_participant)
      end

      it "returns all participants with a due_date > today" do
        get :upcoming_births
        assigns[:pregnant_participants].should == [pregnant_participant]
      end

      it "only returns participants who are currently known to be pregnant" do
        get :upcoming_births
        assigns[:pregnant_participants].should_not include loss_participant
      end

    end

  end

end