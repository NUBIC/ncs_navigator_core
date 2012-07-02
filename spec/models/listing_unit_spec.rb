

require 'spec_helper'

describe ListingUnit do
  it "creates a new instance given valid attributes" do
    lu = Factory(:listing_unit)
    lu.should_not be_nil
  end

  it "creates a uuid" do
    lu = Factory(:listing_unit)
    lu.list_id.should_not be_nil
    lu.list_id.length.should == 36
    lu.list_id.should == lu.public_id
    lu.public_id.should == lu.uuid
  end

  context "determining next listing unit to process" do

    it "finds all listing units without an associated dwelling unit" do
      10.times do |x|
        lu = Factory(:listing_unit)
        Factory(:dwelling_unit, :listing_unit => lu) if ((x % 2) == 0)
      end

      ListingUnit.without_dwelling.size.should == 5
    end

    it "does not choose a listing_unit that is currently being processed (worked on by another person)" do
      2.times do |x|
        lu = Factory(:listing_unit)
        Factory(:dwelling_unit, :listing_unit => lu) if (x == 1)
      end

      ListingUnit.next_to_process.size.should == 1

      ListingUnit.next_to_process.first.update_attribute(:being_processed, true)
      ListingUnit.next_to_process.should be_empty
    end

  end

  it { should belong_to(:psu) }
  it { should belong_to(:list_source) }
  it { should have_one(:dwelling_unit) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      lu = Factory(:listing_unit)
      lu.public_id.should_not be_nil
      lu.list_id.should == lu.public_id
      lu.list_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      lu = ListingUnit.new
      lu.save!

      ListingUnit.first.list_source.local_code.should == -4
    end
  end

end

