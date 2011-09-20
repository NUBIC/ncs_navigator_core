# == Schema Information
# Schema version: 20110920210459
#
# Table name: telephones
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  phone_id                :binary          not null
#  person_id               :integer
#  phone_info_source_code  :integer         not null
#  phone_info_source_other :string(255)
#  phone_info_date         :date
#  phone_info_update       :date
#  phone_nbr               :string(10)
#  phone_ext               :string(5)
#  phone_type_code         :integer         not null
#  phone_type_other        :string(255)
#  phone_rank_code         :integer         not null
#  phone_rank_other        :string(255)
#  phone_landline_code     :integer         not null
#  phone_share_code        :integer         not null
#  cell_permission_code    :integer         not null
#  text_permission_code    :integer         not null
#  phone_comment           :text
#  phone_start_date        :string(10)
#  phone_start_date_date   :date
#  phone_end_date          :string(10)
#  phone_end_date_date     :date
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

# A Person, an Institution and a Provider will have at least one and sometimes many phone numbers.
class Telephone < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :phone_id, :date_fields => [:phone_start_date, :phone_end_date]
  
  belongs_to :person

  belongs_to :psu,                :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :phone_info_source,  :conditions => "list_name = 'INFORMATION_SOURCE_CL2'",  :foreign_key => :phone_info_source_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :phone_type,         :conditions => "list_name = 'PHONE_TYPE_CL1'",          :foreign_key => :phone_type_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :phone_rank,         :conditions => "list_name = 'COMMUNICATION_RANK_CL1'",  :foreign_key => :phone_rank_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :phone_landline,     :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :phone_landline_code,     :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :phone_share,        :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :phone_share_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :cell_permission,    :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :cell_permission_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :text_permission,    :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :text_permission_code,    :class_name => 'NcsCode', :primary_key => :local_code
end
