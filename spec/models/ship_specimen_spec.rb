# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: ship_specimens
#
#  created_at           :datetime
#  id                   :integer          not null, primary key
#  specimen_id          :integer
#  specimen_shipping_id :integer
#  updated_at           :datetime
#  volume_amount        :decimal(6, 2)
#  volume_unit          :string(36)
#

require 'spec_helper'

describe ShipSpecimen do

  it "creates a new instance given valid attributes" do
    ship_spec = Factory(:ship_specimen)
    ship_spec.should_not be_nil
  end

  it { should belong_to(:specimen) }
  it { should belong_to(:specimen_shipping) }
end

