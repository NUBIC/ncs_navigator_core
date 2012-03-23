# == Schema Information
# Schema version: 20120321181032
#
# Table name: dwelling_units
#
#  id                 :integer         not null, primary key
#  psu_code           :integer         not null
#  duplicate_du_code  :integer         not null
#  missed_du_code     :integer         not null
#  du_type_code       :integer         not null
#  du_type_other      :string(255)
#  du_ineligible_code :integer         not null
#  du_access_code     :integer         not null
#  duid_comment       :text
#  transaction_type   :string(36)
#  du_id              :string(36)      not null
#  listing_unit_id    :integer
#  created_at         :datetime
#  updated_at         :datetime
#  being_processed    :boolean
#  ssu_id             :string(255)
#  tsu_id             :string(255)
#

require 'spec_helper'

describe DwellingUnit do

  it "should create a new instance given valid attributes" do
    du = Factory(:dwelling_unit)
    du.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:duplicate_du) }
  it { should belong_to(:missed_du) }
  it { should belong_to(:du_type) }
  it { should belong_to(:du_ineligible) }
  it { should belong_to(:du_access) }

  it { should have_many(:dwelling_household_links) }
  it { should have_many(:household_units).through(:dwelling_household_links) }

  context "determining next dwelling unit to process" do

    it "should find all dwelling units not linked to a household" do

      10.times do |x|
        du = Factory(:dwelling_unit)
        Factory(:dwelling_household_link, :dwelling_unit => du) if ((x % 2) == 0)
      end

      DwellingUnit.without_household.size.should == 5
    end

    it "does not choose a dwelling unit that is currently being processed (worked on by another person)" do
      2.times do |x|
        du = Factory(:dwelling_unit)
        Factory(:dwelling_household_link, :dwelling_unit => du) if (x == 1)
      end

      DwellingUnit.next_to_process.size.should == 1

      DwellingUnit.next_to_process.first.update_attribute(:being_processed, true)
      DwellingUnit.next_to_process.should be_empty
    end

  end

  context "ssu and tsu" do

    require 'pathname'
    before(:each) do
      pathname = Pathname.new("#{Rails.root}/spec/spec_ssus.csv")
      DwellingUnit.stub!(:sampling_units_file).and_return(pathname)
    end

    describe "#ssus" do

      it "returns the list of ssu_ids and ssu_names from the configuration sampling_units_file" do
        ssus = DwellingUnit.ssus
        ssus.size.should == 2
        ssus.first.should == ["Area 51", '51']
      end

    end

    describe "#tsus" do

      it "returns the list of tsu_ids and tsu_names from the configuration sampling_units_file" do
        tsus = DwellingUnit.tsus
        tsus.size.should == 1
        tsus.first.should == ["Area 51", '51']
      end

    end

  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      du = Factory(:dwelling_unit)
      du.public_id.should_not be_nil
      du.du_id.should == du.public_id
      du.du_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(DwellingUnit)

      du = DwellingUnit.new
      du.psu = Factory(:ncs_code)
      du.save!

      DwellingUnit.first.duplicate_du.local_code.should == -4
      DwellingUnit.first.du_ineligible.local_code.should == -4
    end
  end

end
