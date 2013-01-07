# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: emails
#
#  created_at              :datetime
#  email                   :string(100)
#  email_active_code       :integer          not null
#  email_comment           :text
#  email_end_date          :string(10)
#  email_end_date_date     :date
#  email_id                :string(36)       not null
#  email_info_date         :date
#  email_info_source_code  :integer          not null
#  email_info_source_other :string(255)
#  email_info_update       :date
#  email_rank_code         :integer          not null
#  email_rank_other        :string(255)
#  email_share_code        :integer          not null
#  email_start_date        :string(10)
#  email_start_date_date   :date
#  email_type_code         :integer          not null
#  email_type_other        :string(255)
#  id                      :integer          not null, primary key
#  institute_id            :integer
#  lock_version            :integer          default(0)
#  person_id               :integer
#  provider_id             :integer
#  psu_code                :integer          not null
#  response_set_id         :integer
#  transaction_type        :string(255)
#  updated_at              :datetime
#



require 'spec_helper'

describe Email do
  it "should create a new instance given valid attributes" do
    email = Factory(:email)
    email.should_not be_nil
  end

  it { should belong_to(:person) }
  it { should belong_to(:psu) }
  it { should belong_to(:email_info_source) }
  it { should belong_to(:email_type) }
  it { should belong_to(:email_rank) }
  it { should belong_to(:email_share) }
  it { should belong_to(:email_active) }
  it { should belong_to(:response_set) }
  it { should belong_to(:provider) }
  it { should belong_to(:institute) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      email = Factory(:email)
      email.public_id.should_not be_nil
      email.email_id.should == email.public_id
      email.email_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      email = Email.new
      email.person = Factory(:person)
      email.save!

      obj = Email.first
      obj.email_info_source.local_code.should == -4
      obj.email_type.local_code.should == -4
      obj.email_rank.local_code.should == -4
      obj.email_share.local_code.should == -4
      obj.email_active.local_code.should == -4
    end
  end

  describe "#demote_primary_rank_to_seconday" do

    before(:each) do
      @primary_email = Factory(:email)
      @duplicate_email = Factory(:email, :email_rank_code => 4)
      @business_email = Factory(:email, :email_type_code => 2)
      @school_email = Factory(:email, :email_type_code => 3)
    end

    it "changes the rank from primary to seconday" do
      @primary_email.email_rank_code.should == 1
      @primary_email.demote_primary_rank_to_secondary(@primary_email.email_type_code)
      @primary_email.email_rank_code.should == 2
    end

    it "does nothing if rank is not primary" do
      @duplicate_email.email_rank_code.should == 4
      @duplicate_email.demote_primary_rank_to_secondary(@duplicate_email.email_type_code)
      @duplicate_email.email_rank_code.should == 4
    end

    it "only changes rank if email is the same type" do
      @business_email.email_rank_code.should == 1
      @business_email.demote_primary_rank_to_secondary(@business_email.email_type_code)
      @business_email.email_rank_code.should == 2
    end

    it "does not change rank if email is a different type" do
      @business_email.email_rank_code.should == 1
      @business_email.demote_primary_rank_to_secondary(@school_email.email_type_code)
      @business_email.email_rank_code.should == 1
    end
  end

end
