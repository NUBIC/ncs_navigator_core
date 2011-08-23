# == Schema Information
# Schema version: 20110823212243
#
# Table name: emails
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  email_id                :binary          not null
#  person_id               :integer
#  email                   :string(100)
#  email_rank_code         :integer         not null
#  email_rank_other        :string(255)
#  email_info_source_code  :integer         not null
#  email_info_source_other :string(255)
#  email_info_date         :date
#  email_info_update       :date
#  email_type_code         :integer         not null
#  email_type_other        :string(255)
#  email_share_code        :integer         not null
#  email_active_code       :integer         not null
#  email_comment           :text
#  email_start_date        :string(10)
#  email_start_date_date   :date
#  email_end_date          :string(10)
#  email_end_date_date     :date
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

# A Person, an Institution and a Provider will have at least one and sometimes many Email addresses.
class Email < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :email_id, :date_fields => [:email_start_date, :email_end_date]
  
  belongs_to :person

  belongs_to :psu,                :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :email_info_source,  :conditions => "list_name = 'INFORMATION_SOURCE_CL2'",  :foreign_key => :email_info_source_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :email_type,         :conditions => "list_name = 'EMAIL_TYPE_CL1'",          :foreign_key => :email_type_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :email_rank,         :conditions => "list_name = 'COMMUNICATION_RANK_CL1'",  :foreign_key => :email_rank_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :email_share,        :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :email_share_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :email_active,       :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :email_active_code,       :class_name => 'NcsCode', :primary_key => :local_code

end
