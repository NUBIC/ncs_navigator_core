# == Schema Information
# Schema version: 20110715213911
#
# Table name: ncs_codes
#
#  id               :integer         not null, primary key
#  list_name        :string(255)
#  list_description :string(255)
#  display_text     :string(255)
#  local_code       :integer
#  global_code      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

require 'spec_helper'

describe NcsCode do
  
  it "should create a new instance given valid attributes" do
    code = Factory(:ncs_code)
  end
  
  it "should display attributes with user friendly method names (syntactic sugar)" do
    code = Factory(:ncs_code)
    code.to_s.should == "#{code.display_text}"
    code.code.should == code.local_code
  end
  
  it { should validate_presence_of(:list_name) }
  it { should validate_presence_of(:display_text) }
  it { should validate_presence_of(:local_code) }
  
end
