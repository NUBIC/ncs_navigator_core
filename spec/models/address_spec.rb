# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: addresses
#
#  address_comment           :text
#  address_description_code  :integer          not null
#  address_description_other :string(255)
#  address_end_date          :string(10)
#  address_end_date_date     :date
#  address_id                :string(36)       not null
#  address_info_date         :date
#  address_info_mode_code    :integer          not null
#  address_info_mode_other   :string(255)
#  address_info_source_code  :integer          not null
#  address_info_source_other :string(255)
#  address_info_update       :date
#  address_one               :string(100)
#  address_rank_code         :integer          not null
#  address_rank_other        :string(255)
#  address_start_date        :string(10)
#  address_start_date_date   :date
#  address_two               :string(100)
#  address_type_code         :integer          not null
#  address_type_other        :string(255)
#  city                      :string(50)
#  created_at                :datetime
#  dwelling_unit_id          :integer
#  id                        :integer          not null, primary key
#  institute_id              :integer
#  lock_version              :integer          default(0)
#  person_id                 :integer
#  provider_id               :integer
#  psu_code                  :integer          not null
#  response_set_id           :integer
#  state_code                :integer          not null
#  transaction_type          :string(255)
#  unit                      :string(10)
#  updated_at                :datetime
#  zip                       :string(5)
#  zip4                      :string(4)




require 'spec_helper'

describe Address do
  let(:addr) { Factory(:address) }

  it "should create a new instance given valid attributes" do
    addr.should_not be_nil
  end

  it { should belong_to(:person) }
  it { should belong_to(:provider) }
  it { should belong_to(:institute) }
  it { should belong_to(:dwelling_unit) }
  it { should belong_to(:response_set) }

  it { should ensure_length_of(:address_one).is_at_most(100) }
  it { should ensure_length_of(:address_two).is_at_most(100) }
  it { should ensure_length_of(:city).is_at_most(50) }
  it { should ensure_length_of(:unit).is_at_most(10) }
  it { should ensure_length_of(:zip).is_at_most(5) }
  it { should ensure_length_of(:zip4).is_at_most(4) }
  it { should validate_numericality_of(:zip) }
  it { should validate_numericality_of(:zip4) }
  it { should ensure_length_of(:address_end_date).is_equal_to(10) }
  it { should ensure_length_of(:address_start_date).is_equal_to(10) }

  describe '#zip' do
    describe 'validity' do
      it "allows imported semilegal coded values" do
        addr.zip = '-1'
        addr.should be_valid
      end

      it 'allows leading zeros' do
        addr.zip = '04567'
        addr.should be_valid
      end
    end
  end

  describe '#zip4' do
    describe 'validity' do
      it "allows imported semilegal coded values" do
        addr.zip4 = '-1'
        addr.should be_valid
      end

      it 'allows leading zeros' do
        addr.zip4 = '0001'
        addr.should be_valid
      end
    end
  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      addr = Factory(:address)
      addr.public_id.should_not be_nil
      addr.address_id.should == addr.public_id
      addr.address_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      addr = Address.new
      addr.psu_code = 20000030
      addr.person = Factory(:person)
      addr.dwelling_unit = Factory(:dwelling_unit)
      addr.save!

      obj = Address.first
      obj.address_rank.local_code.should == -4
      obj.address_info_source.local_code.should == -4
      obj.address_description.local_code.should == -4
      obj.state.local_code.should == -4
    end
  end

  context "mdes date formatting" do

    it "should set the corresponding date field with the user entered date" do
      dt = Date.today
      addr = Factory(:address)
      addr.address_start_date = nil
      addr.address_start_date_date = dt
      addr.address_end_date = nil
      addr.address_end_date_date = dt
      addr.save!
      addr = Address.last
      addr.address_start_date.should == dt.strftime('%Y-%m-%d')
      addr.address_end_date.should == dt.strftime('%Y-%m-%d')
    end

    it "should set the address_start_date if the user said the information is unknown" do
      addr = Factory(:address)
      addr.address_start_date_modifier = "unknown"
      addr.address_start_date = nil
      addr.address_end_date = nil
      addr.save!

      addr = Address.last
      addr.address_start_date.should == '9666-96-96'
    end

    it "should set the address_end_date if the user said the information is unknown" do
      addr = Factory(:address)
      addr.address_start_date = nil
      addr.address_end_date = nil
      addr.address_end_date_modifier = "unknown"
      addr.save!

      addr = Address.last
      addr.address_end_date.should == '9666-96-96'
      addr.address_start_date.should be_nil
    end

  end

  describe "#demote_primary_rank_to_seconday" do

    before(:each) do
      @primary_address = Factory(:address)
      @duplicate_address = Factory(:address, :address_rank_code => 4)
      @business_address = Factory(:address, :address_type_code => 2)
      @school_address = Factory(:address, :address_type_code => 3)
    end

    it "changes the rank from primary to seconday" do
      @primary_address.address_rank_code.should == 1
      @primary_address.demote_primary_rank_to_secondary(@primary_address.address_type_code)
      @primary_address.address_rank_code.should == 2
    end

    it "does nothing if rank is not primary" do
      @duplicate_address.address_rank_code.should == 4
      @duplicate_address.demote_primary_rank_to_secondary(@duplicate_address.address_type_code)
      @duplicate_address.address_rank_code.should == 4
    end

    it "only changes rank if address is the same type" do
      @business_address.address_rank_code.should == 1
      @business_address.demote_primary_rank_to_secondary(@business_address.address_type_code)
      @business_address.address_rank_code.should == 2
    end

    it "does not change rank if address is a different type" do
      @business_address.address_rank_code.should == 1
      @business_address.demote_primary_rank_to_secondary(@school_address.address_type_code)
      @business_address.address_rank_code.should == 1
    end
  end

  describe "#blank?" do
    before do
      @blank_address = Factory(:address, :state_code => nil)
      @address_with_only_zip_code_filled_in = Factory(:address, :state_code => nil, :zip => "23456")
      @address_with_only_address_one_filled_in = Factory(:address, :state_code => nil, :address_one => "1213 Sycamore Ave")
    end

    it "returns true if address_one, address_two, unit, city, state, zip code, and zip+4 are all nil, blank, or missing-in-error" do
      @blank_address.blank?.should be_true
    end

    it "returns false if any of the following are filled in: address_one, address_two, unit, city, state, zip code, and zip+4" do
      @address_with_only_zip_code_filled_in.blank?.should be_false
      @address_with_only_address_one_filled_in.blank?.should be_false
    end
  end

  describe "zip_code" do
    before do
      @address_with_full_zip = Factory(:address, :zip => 23456, :zip4 => 1234)
      @address_without_zip4  = Factory(:address, :zip => 34567)
    end

    it "returns the full, hyphenated zip code if both the zip and zip4 are present" do
      @address_with_full_zip.zip_code.should == '23456-1234'
    end

    it "returns only the five-digit zip if the zip4 is not present" do
      @address_without_zip4.zip_code.should == '34567'

    end

  end

  describe "to_s" do
    before do
      @address = Factory(:address,
                         :address_rank_code => 1,
                         :address_one => "123 73rd Ave.",
                         :address_two => "Apt. 1C",
                         :city => "Rockville",
                         :state_code => 30,
                         :zip => "20850")
    end

    it "prints out correctly" do
      @address.to_s.should == "123 73rd Ave. Apt. 1C Rockville, New Hampshire 20850"
    end
  end

end
