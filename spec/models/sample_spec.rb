# == Schema Information
# Schema version: 20120507183332
#
# Table name: samples
#
#  id            :integer         not null, primary key
#  sample_id     :string(36)      not null
#  instrument_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe Sample do
  it "should create a new instance given valid attributes" do
    sample = Factory(:sample)
    sample.should_not be_nil
  end

  it { should belong_to(:instrument) }
end
