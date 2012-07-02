# -*- coding: utf-8 -*-
require 'spec_helper'

describe Sample do
  it "should create a new instance given valid attributes" do
    sample = Factory(:sample)
    sample.should_not be_nil
  end

  it { should belong_to(:instrument) }
end

