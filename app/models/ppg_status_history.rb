class PpgStatusHistory < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :ppg_history_id

  belongs_to :participant
  belongs_to :psu,              :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_status,       :conditions => "list_name = 'PPG_STATUS_CL1'",          :foreign_key => :ppg_status_code,   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_info_source,  :conditions => "list_name = 'INFORMATION_SOURCE_CL3'",  :foreign_key => :ppg_info_source_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_info_mode,    :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :ppg_info_mode_code,     :class_name => 'NcsCode', :primary_key => :local_code

end
