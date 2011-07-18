# == Schema Information
# Schema version: 20110715213911
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
#  start_date              :date
#  email_end_date          :string(10)
#  end_date                :date
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

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
