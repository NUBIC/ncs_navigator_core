# == Schema Information
# Schema version: 20111212224350
#
# Table name: addresses
#
#  id                        :integer         not null, primary key
#  psu_code                  :integer         not null
#  address_id                :string(36)      not null
#  person_id                 :integer
#  dwelling_unit_id          :integer
#  address_rank_code         :integer         not null
#  address_rank_other        :string(255)
#  address_info_source_code  :integer         not null
#  address_info_source_other :string(255)
#  address_info_mode_code    :integer         not null
#  address_info_mode_other   :string(255)
#  address_info_date         :date
#  address_info_update       :date
#  address_start_date        :string(10)
#  address_start_date_date   :date
#  address_end_date          :string(10)
#  address_end_date_date     :date
#  address_type_code         :integer         not null
#  address_type_other        :string(255)
#  address_description_code  :integer         not null
#  address_description_other :string(255)
#  address_one               :string(100)
#  address_two               :string(100)
#  unit                      :string(10)
#  city                      :string(50)
#  state_code                :integer         not null
#  zip                       :string(5)
#  zip4                      :string(4)
#  address_comment           :text
#  transaction_type          :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#

require 'spec_helper'

describe Address do
  it "should create a new instance given valid attributes" do
    addr = Factory(:address)
    addr.should_not be_nil
  end

  it "should describe itself" do
    addr = Factory(:address)
    addr.to_s.should == "#{addr.state}"

    addr.address_one = "1 Main"
    addr.city = "Detroit"
    addr.to_s.should == "1 Main Detroit #{addr.state}"

    addr.zip = "48220"
    addr.to_s.should == "1 Main Detroit #{addr.state} 48220"


    addr.zip4 = "1111"
    addr.to_s.should == "1 Main Detroit #{addr.state} 48220-1111"
  end

  it { should belong_to(:person) }
  it { should belong_to(:dwelling_unit) }
  it { should belong_to(:psu) }
  it { should belong_to(:address_rank) }
  it { should belong_to(:address_info_source) }
  it { should belong_to(:address_info_mode) }
  it { should belong_to(:address_type) }
  it { should belong_to(:address_description) }
  it { should belong_to(:state) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      addr = Factory(:address)
      addr.public_id.should_not be_nil
      addr.address_id.should == addr.public_id
      addr.address_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Address)

      addr = Address.new
      addr.psu = Factory(:ncs_code)
      addr.person = Factory(:person)
      addr.dwelling_unit = Factory(:dwelling_unit)
      addr.save!

      obj = Address.first
      obj.address_rank.local_code.should == -4
      obj.address_info_source.local_code.should == -4
      obj.address_info_mode.local_code.should == -4
      obj.address_type.local_code.should == -4
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
end
