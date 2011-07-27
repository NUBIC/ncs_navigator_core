class Instrument < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :instrument_id
  
  belongs_to :event
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                     :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_type,      :conditions => "list_name = 'INSTRUMENT_TYPE_CL1'",         :foreign_key => :instrument_type_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_breakoff,  :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :instrument_breakoff_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_status,    :conditions => "list_name = 'INSTRUMENT_STATUS_CL1'",       :foreign_key => :instrument_status_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_mode,      :conditions => "list_name = 'INSTRUMENT_ADMIN_MODE_CL1'",   :foreign_key => :instrument_mode_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_method,    :conditions => "list_name = 'INSTRUMENT_ADMIN_METHOD_CL1'", :foreign_key => :instrument_method_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :supervisor_review,    :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :supervisor_review_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :data_problem,         :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :data_problem_code,         :class_name => 'NcsCode', :primary_key => :local_code  
  
  validates_presence_of :instrument_version
  
end
