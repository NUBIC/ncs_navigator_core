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

