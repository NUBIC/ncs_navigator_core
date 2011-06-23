# == Schema Information
# Schema version: 20110623215337
#
# Table name: household_units
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  hh_status_code               :integer         not null
#  hh_eligibilty_code           :integer         not null
#  hh_structure_code            :integer         not null
#  hh_structure_other           :string(255)
#  hh_comment                   :text
#  number_of_age_eligible_women :integer
#  number_of_pregnant_women     :integer
#  number_of_pregnant_minors    :integer
#  number_of_pregnant_adults    :integer
#  number_of_pregnant_over49    :integer
#  transaction_type             :string(36)
#  created_at                   :datetime
#  updated_at                   :datetime
#

require 'spec_helper'

describe HouseholdUnit do
  
  it "should create a new instance given valid attributes" do
    hh = Factory(:household_unit)
    hh.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:hh_status) }
  it { should belong_to(:hh_eligibilty) }
  it { should belong_to(:hh_structure) }

  it { should validate_presence_of(:psu) }
  it { should validate_presence_of(:hh_status) }
  it { should validate_presence_of(:hh_eligibilty) }
  it { should validate_presence_of(:hh_structure) }
  
end
