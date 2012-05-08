# == Schema Information
# Schema version: 20120507183332
#
# Table name: emails
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  email_id                :string(36)      not null
#  person_id               :integer
#  email                   :string(100)
#  email_rank_code         :integer         not null
#  email_rank_other        :string(255)
#  email_info_source_code  :integer         not null
#  email_info_source_other :string(255)
#  email_info_date         :date
#  email_info_update       :date
#  email_type_code         :integer         not null
#  email_type_other        :string(255)
#  email_share_code        :integer         not null
#  email_active_code       :integer         not null
#  email_comment           :text
#  email_start_date        :string(10)
#  email_start_date_date   :date
#  email_end_date          :string(10)
#  email_end_date_date     :date
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  response_set_id         :integer
#

# -*- coding: utf-8 -*-

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
end
