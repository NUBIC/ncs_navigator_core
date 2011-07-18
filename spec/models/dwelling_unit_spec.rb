# == Schema Information
# Schema version: 20110715213911
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
#  du_id              :binary          not null
#  listing_unit_id    :integer
#  created_at         :datetime
#  updated_at         :datetime
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
  
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      du = Factory(:dwelling_unit)
      du.public_id.should_not be_nil
      du.du_id.should == du.public_id
      du.du_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(DwellingUnit)
      
      du = DwellingUnit.new
      du.psu = Factory(:ncs_code)
      du.save!
    
      DwellingUnit.first.duplicate_du.local_code.should == -4
      DwellingUnit.first.du_ineligible.local_code.should == -4
    end
  end

end
