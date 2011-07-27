class Event < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :event_id
  
  belongs_to :participant
  belongs_to :psu,                        :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_type,                 :conditions => "list_name = 'EVENT_TYPE_CL1'",          :foreign_key => :event_type_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_disposition_category, :conditions => "list_name = 'EVENT_DSPSTN_CAT_CL1'",    :foreign_key => :event_disposition_category_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_breakoff,             :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :event_breakoff_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_incentive_type,       :conditions => "list_name = 'INCENTIVE_TYPE_CL1'",      :foreign_key => :event_incentive_type_code,       :class_name => 'NcsCode', :primary_key => :local_code

end
