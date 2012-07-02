# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: samples
#
#  created_at    :datetime
#  id            :integer          not null, primary key
#  instrument_id :integer
#  sample_id     :string(36)       not null
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

