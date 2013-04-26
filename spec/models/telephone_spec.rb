# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: telephones
#
#  cell_permission_code    :integer          not null
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  institute_id            :integer
#  lock_version            :integer          default(0)
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
  let(:phone) { Factory(:telephone) }

  it "should create a new instance given valid attributes" do
    phone.should_not be_nil
  end

  it { should belong_to(:person) }
  it { should belong_to(:provider) }
  # it { should belong_to(:institute) }
  it { should belong_to(:response_set) }

  it { should ensure_length_of(:phone_ext).is_at_most(5) }
  it { should ensure_length_of(:phone_end_date).is_equal_to(10) }
  it { should ensure_length_of(:phone_start_date).is_equal_to(10) }

  context "as mdes record" do
    it "sets the public_id to a uuid" do
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

  describe '#phone_nbr' do
    it 'strips out punctuation' do
      phone.phone_nbr = '(312) 503-5555'
      phone.phone_nbr.should == '3125035555'
    end

    it 'clears if set to nil' do
      phone.phone_nbr = '1'
      phone.phone_nbr.should_not be_nil # setup

      phone.phone_nbr = nil
      phone.phone_nbr.should be_nil
    end

    it 'blocks numbers that are longer than 10 digits' do
      phone.phone_nbr = '12345678901'
      phone.should_not be_valid
    end

    it 'allows numbers that are exactly 10 digits' do
      phone.phone_nbr = '1234567890'
      phone.should be_valid
    end

    it 'allows numbers that are less than 10 digits' do
      phone.phone_nbr = '123456789'
      phone.should be_valid
    end

    it 'preserves alphabetic phone numbers' do
      phone.phone_nbr = '888-GUD-TEST'
      phone.phone_nbr.should == '888GUDTEST'
    end

    it 'accepts a number' do
      phone.phone_nbr = 456
      phone.should be_valid
      phone.phone_nbr.should == '456'
    end

    describe 'and coded values' do
      it 'allows them' do
        phone.phone_nbr = '-8'
        phone.should be_valid
      end

      it 'does not change them' do
        phone.phone_nbr = '-1'
        phone.phone_nbr.should == '-1'
      end
    end
  end

  describe "#demote_primary_rank_to_seconday" do

    before(:each) do
      @primary_phone = Factory(:telephone)
      @duplicate_phone = Factory(:telephone, :phone_rank_code => 4)
      @business_phone = Factory(:telephone, :phone_type_code => 2)
      @school_phone = Factory(:telephone, :phone_type_code => 3)
    end

    it "changes the rank from primary to seconday" do
      @primary_phone.phone_rank_code.should == 1
      @primary_phone.demote_primary_rank_to_secondary(@primary_phone.phone_type_code)
      @primary_phone.phone_rank_code.should == 2
    end

    it "does nothing if rank is not primary" do
      @duplicate_phone.phone_rank_code.should == 4
      @duplicate_phone.demote_primary_rank_to_secondary(@duplicate_phone.phone_type_code)
      @duplicate_phone.phone_rank_code.should == 4
    end

    it "only changes rank if phone is the same type" do
      @business_phone.phone_rank_code.should == 1
      @business_phone.demote_primary_rank_to_secondary(@business_phone.phone_type_code)
      @business_phone.phone_rank_code.should == 2
    end

    it "does not change rank if phone is a different type" do
      @business_phone.phone_rank_code.should == 1
      @business_phone.demote_primary_rank_to_secondary(@school_phone.phone_type_code)
      @business_phone.phone_rank_code.should == 1
    end
  end

  describe "#dashed" do
    before do
      @phone = Factory(:telephone)
    end

    it "inserts dashes into an unformatted(undashed) phone number" do
      @phone.update_attribute(:phone_nbr, "1234567890")
      @phone.dashed.should == "123-456-7890"
    end

    it "passes already formatted numbers as is" do
      @phone.update_attribute(:phone_nbr, "123-456-7890")
      @phone.dashed.should == "123-456-7890"
    end
  end

end
