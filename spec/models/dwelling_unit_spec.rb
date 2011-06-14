# == Schema Information
# Schema version: 20110613210555
#
# Table name: dwelling_units
#
#  id                 :integer         not null, primary key
#  psu_code           :integer
#  duplicate_du_code  :integer
#  missed_du_code     :integer
#  du_type_code       :integer
#  du_type_other      :string(255)
#  du_ineligible_code :integer
#  du_access_code     :integer
#  duid_comment       :text
#  transaction_type   :string(255)
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

end
