# -*- coding: utf-8 -*-
require 'spec_helper'

describe ShipSpecimen do

  it "creates a new instance given valid attributes" do
    ship_spec = Factory(:ship_specimen)
    ship_spec.should_not be_nil
  end

  it { should belong_to(:specimen) }
  it { should belong_to(:specimen_shipping) }
end

