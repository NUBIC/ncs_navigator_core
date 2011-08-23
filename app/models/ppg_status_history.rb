# == Schema Information
# Schema version: 20110823212243
#
# Table name: ppg_status_histories
#
#  id                    :integer         not null, primary key
#  psu_code              :string(36)      not null
#  ppg_history_id        :binary          not null
#  participant_id        :integer
#  ppg_status_code       :integer         not null
#  ppg_status_date       :string(10)
#  ppg_info_source_code  :integer         not null
#  ppg_info_source_other :string(255)
#  ppg_info_mode_code    :integer         not null
#  ppg_info_mode_other   :string(255)
#  ppg_comment           :text
#  transaction_type      :string(36)
#  created_at            :datetime
#  updated_at            :datetime
#

class PpgStatusHistory < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :ppg_history_id

  belongs_to :participant
  belongs_to :psu,              :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_status,       :conditions => "list_name = 'PPG_STATUS_CL1'",          :foreign_key => :ppg_status_code,       :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_info_source,  :conditions => "list_name = 'INFORMATION_SOURCE_CL3'",  :foreign_key => :ppg_info_source_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_info_mode,    :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :ppg_info_mode_code,    :class_name => 'NcsCode', :primary_key => :local_code

end
