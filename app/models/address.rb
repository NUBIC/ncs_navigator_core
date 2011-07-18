class Address < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :address_id
  
  belongs_to :person
  belongs_to :dwelling_unit
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                 :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :address_rank,         :conditions => "list_name = 'COMMUNICATION_RANK_CL1'",  :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :address_rank_code
  belongs_to :address_info_source,  :conditions => "list_name = 'INFORMATION_SOURCE_CL1'",  :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :address_info_source_code
  belongs_to :address_info_mode,    :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :address_info_mode_code
  belongs_to :address_type,         :conditions => "list_name = 'ADDRESS_CATEGORY_CL1'",    :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :address_type_code
  belongs_to :address_description,  :conditions => "list_name = 'RESIDENCE_TYPE_CL1'",      :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :address_description_code
  belongs_to :state,                :conditions => "list_name = 'STATE_CL1'",               :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :state_code
  
end
