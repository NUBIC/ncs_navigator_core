# == Schema Information
# Schema version: 20120607203203
#
# Table name: specimens
#
#  id                 :integer         not null, primary key
#  specimen_id        :string(36)      not null
#  specimen_pickup_id :integer
#  instrument_id      :integer
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe Specimen do
  it "should create a new instance given valid attributes" do
    specimen = Factory(:specimen)
    specimen.should_not be_nil
  end
  
  it { should belong_to(:specimen_pickup) }
  it { should belong_to(:instrument) }  
end
