# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: specimen_equipments
#
#  created_at                             :datetime
#  equipment_id                           :string(36)       not null
#  equipment_type_code                    :integer          not null
#  equipment_type_other                   :string(255)
#  government_asset_tag_number            :string(36)
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
#  retired_date                           :string(10)
#  retired_reason_code                    :integer          not null
#  retired_reason_other                   :string(255)
#  serial_number                          :string(50)       not null
#  specimen_processing_shipping_center_id :integer
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#


require 'spec_helper'

describe SpecimenEquipment do
  it "should create a new instance given valid attributes" do
    specimen_equipment = Factory(:specimen_equipment)
    specimen_equipment.should_not be_nil
  end

  it { should belong_to(:specimen_processing_shipping_center) }

  context "as mdes record" do
    it "sets the public_id to a uuid" do
      se = Factory(:specimen_equipment)
      se.public_id.should_not be_nil
      se.equipment_id.should == se.public_id
      se.equipment_id.to_s.should == "4567"
    end
  end
end

