# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimens
#
#  created_at             :datetime
#  data_export_identifier :string(255)
#  id                     :integer          not null, primary key
#  instrument_id          :integer
#  response_set_id        :integer
#  specimen_id            :string(36)       not null
#  specimen_pickup_id     :integer
#  updated_at             :datetime
#

require 'spec_helper'

describe Specimen do
  it "should create a new instance given valid attributes" do
    specimen = Factory(:specimen)
    specimen.should_not be_nil
  end

  it { should belong_to(:specimen_pickup) }
  it { should belong_to(:instrument) }

  it { should belong_to(:response_set) }
  it { should respond_to(:data_export_identifier) }
end

