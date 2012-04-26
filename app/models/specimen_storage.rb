# == Schema Information
# Schema version: 20120420163434
#
# Table name: specimen_storages
#
#  id                                     :integer         not null, primary key
#  psu_code                               :integer         not null
#  specimen_processing_shipping_center_id :integer
#  storage_container_id                   :string(36)      not null
#  placed_in_storage_datetime             :datetime
#  staff_id                               :string(36)      not null
#  specimen_equipment_id                  :integer
#  master_storage_unit_code               :integer         not null
#  storage_comment                        :string(255)     not null
#  storage_comment_other                  :string(255)
#  removed_from_storage_datetime          :datetime
#  temp_event_starttime                   :string(5)
#  temp_event_endtime                     :string(5)
#  temp_event_low_temp                    :decimal(6, 2)
#  temp_event_high_temp                   :decimal(6, 2)
#  transaction_type                       :string(36)
#  created_at                             :datetime
#  updated_at                             :datetime
#

class SpecimenStorage < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :storage_container_id 

  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :specimen_processing_shipping_center
  belongs_to :specimen_equipment
  
  validates_presence_of :storage_container_id
  validates_presence_of :placed_in_storage_datetime
  validates_presence_of :staff_id 
  ncs_coded_attribute :master_storage_unit,       'STORAGE_AREA_CL1'
end
