class Email < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :email_id
  
  belongs_to :person

  belongs_to :psu,                :conditions => "list_name = 'PSU_CL1'",                 :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :email_info_source,  :conditions => "list_name = 'INFORMATION_SOURCE_CL2'",  :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :email_info_source_code
  belongs_to :email_type,         :conditions => "list_name = 'EMAIL_TYPE_CL1'",          :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :email_type_code
  belongs_to :email_rank,         :conditions => "list_name = 'COMMUNICATION_RANK_CL1'",  :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :email_rank_code
  belongs_to :email_share,        :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :email_share_code
  belongs_to :email_active,       :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :email_active_code

end
