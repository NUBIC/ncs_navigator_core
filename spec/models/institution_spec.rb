# == Schema Information
# Schema version: 20121220214234
#
# Table name: institutions
#
#  created_at                  :datetime
#  id                          :integer          not null, primary key
#  institute_comment           :text
#  institute_id                :string(255)      not null
#  institute_info_date         :date
#  institute_info_source_code  :integer          not null
#  institute_info_source_other :string(255)
#  institute_info_update       :date
#  institute_name              :string(255)
#  institute_owner_code        :integer          not null
#  institute_owner_other       :string(255)
#  institute_relation_code     :integer          not null
#  institute_relation_other    :string(255)
#  institute_size              :integer
#  institute_type_code         :integer          not null
#  institute_type_other        :string(255)
#  institute_unit_code         :integer          not null
#  institute_unit_other        :string(255)
#  psu_code                    :string(36)       not null
#  response_set_id             :integer
#  transaction_type            :string(36)
#  updated_at                  :datetime
#

require 'spec_helper'

describe Institution do
  it "should create a new instance given valid attributes" do
    institution = Factory(:institution)
    institution.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:institute_type) }
  it { should belong_to(:institute_relation) }
  it { should belong_to(:institute_owner) }
  it { should belong_to(:institute_unit) }
  it { should belong_to(:institute_info_source) }

  it { should have_many(:addresses) }

  describe ".to_s" do
    it "returns the name_practice" do
      Factory(:provider, :name_practice => "expected").to_s.should == "expected"
    end

    it "returns an empty string if there is no name_practice" do
      Factory(:provider, :name_practice => nil).to_s.should == ""
    end
  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      institution = Factory(:institution)
      institution.public_id.should_not be_nil
      institution.institute_id.should == institution.public_id
      institution.institute_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      institution = Institution.new
      institution.psu_code = 20000030
      institution.save!

      obj = Institution.first
      obj.institute_type.local_code.should == -4
      obj.institute_relation.local_code.should == -4
      obj.institute_owner.local_code.should == -4
      obj.institute_unit.local_code.should == -4
      obj.institute_info_source.local_code.should == -4
    end
  end


end
