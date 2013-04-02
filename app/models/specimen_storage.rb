# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimen_storages
#
#  created_at                             :datetime
#  id                                     :integer          not null, primary key
#  master_storage_unit_code               :integer          not null
#  master_storage_unit_id                 :string(255)
#  placed_in_storage_datetime             :datetime
#  psu_code                               :integer          not null
#  removed_from_storage_datetime          :datetime
#  specimen_equipment_id                  :integer
#  specimen_processing_shipping_center_id :integer
#  specimen_storage_container_id          :integer          not null
#  staff_id                               :string(36)       not null
#  storage_comment                        :string(255)      not null
#  storage_comment_other                  :string(255)
#  temp_event_endtime                     :string(5)
#  temp_event_high_temp                   :decimal(6, 2)
#  temp_event_low_temp                    :decimal(6, 2)
#  temp_event_starttime                   :string(5)
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

class SpecimenStorage < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :specimen_storage_container_id 

  belongs_to :specimen_processing_shipping_center
  belongs_to :specimen_equipment
  belongs_to :specimen_storage_container

  validates_presence_of :specimen_storage_container_id
  validates_presence_of :placed_in_storage_datetime
  validates_presence_of :staff_id 

  ncs_coded_attribute :master_storage_unit,       'STORAGE_AREA_CL1'
  ncs_coded_attribute :psu,                       'PSU_CL1'
end

