# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130403145616
#
# Table name: specimen_pickups
#
#  created_at                             :datetime
#  event_id                               :integer
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
#  specimen_id                            :string(36)       not null
#  specimen_pickup_comment_code           :integer          not null
#  specimen_pickup_comment_other          :string(255)
#  specimen_pickup_datetime               :datetime         not null
#  specimen_processing_shipping_center_id :integer
#  specimen_transport_temperature         :decimal(6, 2)
#  staff_id                               :string(50)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

require 'spec_helper'

describe SpecimenPickup do
  it "should create a new instance given valid attributes" do
    specimen_pickup = Factory(:specimen_pickup)
    specimen_pickup.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:event) }
  it { should belong_to(:specimen_processing_shipping_center) } 
end

