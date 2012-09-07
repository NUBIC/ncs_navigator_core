# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: samples
#
#  created_at             :datetime
#  data_export_identifier :string(255)
#  id                     :integer          not null, primary key
#  instrument_id          :integer
#  response_set_id        :integer
#  sample_id              :string(36)       not null
#  sample_shipping_id     :integer
#  updated_at             :datetime
#  volume_amount          :decimal(6, 2)
#  volume_unit            :string(36)
#

require 'spec_helper'

describe Sample do
  it "should create a new instance given valid attributes" do
    sample = Factory(:sample)
    sample.should_not be_nil
  end

  it { should belong_to(:instrument) }

  it { should belong_to(:response_set) }
  it { should respond_to(:data_export_identifier) }

end

