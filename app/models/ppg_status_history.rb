# == Schema Information
# Schema version: 20111205213437
#
# Table name: ppg_status_histories
#
#  id                    :integer         not null, primary key
#  psu_code              :string(36)      not null
#  ppg_history_id        :string(36)      not null
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
  ncs_coded_attribute :psu,             'PSU_CL1'
  ncs_coded_attribute :ppg_status,      'PPG_STATUS_CL1'
  ncs_coded_attribute :ppg_info_source, 'INFORMATION_SOURCE_CL3'
  ncs_coded_attribute :ppg_info_mode,   'CONTACT_TYPE_CL1'

end
