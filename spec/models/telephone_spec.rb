# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: telephones
#
#  cell_permission_code    :integer          not null
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  institute_id            :integer
#  person_id               :integer
#  phone_comment           :text
#  phone_end_date          :string(10)
#  phone_end_date_date     :date
#  phone_ext               :string(5)
#  phone_id                :string(36)       not null
#  phone_info_date         :date
#  phone_info_source_code  :integer          not null
#  phone_info_source_other :string(255)
#  phone_info_update       :date
#  phone_landline_code     :integer          not null
#  phone_nbr               :string(10)
#  phone_rank_code         :integer          not null
#  phone_rank_other        :string(255)
#  phone_share_code        :integer          not null
#  phone_start_date        :string(10)
#  phone_start_date_date   :date
#  phone_type_code         :integer          not null
#  phone_type_other        :string(255)
#  provider_id             :integer
#  psu_code                :integer          not null
#  response_set_id         :integer
#  text_permission_code    :integer          not null
#  transaction_type        :string(255)
#  updated_at              :datetime
#



require 'spec_helper'

describe Telephone do
  it "should create a new instance given valid attributes" do
    phone = Factory(:telephone)
    phone.should_not be_nil
  end

  it { should belong_to(:person) }
  it { should belong_to(:provider) }
  # it { should belong_to(:institute) }
  it { should belong_to(:psu) }
  it { should belong_to(:phone_info_source) }
  it { should belong_to(:phone_type) }
  it { should belong_to(:phone_rank) }
  it { should belong_to(:phone_share) }
  it { should belong_to(:phone_landline) }
  it { should belong_to(:cell_permission) }
  it { should belong_to(:text_permission) }
  it { should belong_to(:response_set) }

  it { should ensure_length_of(:phone_ext).is_at_most(5) }
  # TODO: create tests for these - we override phone_nbr= so the stock shoulda tests fail
  # it { should validate_numericality_of(:phone_nbr) }
  # it { should ensure_length_of(:phone_nbr).is_equal_to(10) }
  it { should ensure_length_of(:phone_end_date).is_equal_to(10) }
  it { should ensure_length_of(:phone_start_date).is_equal_to(10) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      phone = Factory(:telephone)
      phone.public_id.should_not be_nil
      phone.phone_id.should == phone.public_id
      phone.phone_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      phone = Telephone.new
      phone.person = Factory(:person)
      phone.save!

      obj = Telephone.first
      obj.phone_info_source.local_code.should == -4
      obj.phone_type.local_code.should == -4
      obj.phone_rank.local_code.should == -4
      obj.phone_landline.local_code.should == -4
      obj.cell_permission.local_code.should == -4
      obj.text_permission.local_code.should == -4
    end
  end
end

