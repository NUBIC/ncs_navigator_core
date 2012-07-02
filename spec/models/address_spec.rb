# -*- coding: utf-8 -*-


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
    addr.to_s.should == "1 Main Detroit, #{addr.state}"

    addr.zip = "48220"
    addr.to_s.should == "1 Main Detroit, #{addr.state} 48220"

    addr.zip4 = "1111"
    addr.to_s.should == "1 Main Detroit, #{addr.state} 48220-1111"
  end

  it { should belong_to(:person) }
  it { should belong_to(:provider) }
  it { should belong_to(:dwelling_unit) }
  it { should belong_to(:psu) }
  it { should belong_to(:address_rank) }
  it { should belong_to(:address_info_source) }
  it { should belong_to(:address_info_mode) }
  it { should belong_to(:address_type) }
  it { should belong_to(:address_description) }
  it { should belong_to(:state) }
  it { should belong_to(:response_set) }

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

