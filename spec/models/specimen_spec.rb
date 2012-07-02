# -*- coding: utf-8 -*-
require 'spec_helper'

describe Specimen do
  it "should create a new instance given valid attributes" do
    specimen = Factory(:specimen)
    specimen.should_not be_nil
  end
  
  it { should belong_to(:specimen_pickup) }
  it { should belong_to(:instrument) }  
end

