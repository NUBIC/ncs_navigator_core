# == Schema Information
# Schema version: 20120120165946
#
# Table name: ppg_status_histories
#
#  id                    :integer         not null, primary key
#  psu_code              :integer         not null
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

  ##
  # Given a collection of participant ids return the most recent ppg_status
  # associated with these participants
  # @param[Array<Integer>]
  # @result[Array[Participant]]
  def self.current_status(participant_ids)
    return nil if participant_ids.blank?
    inner_select = "select max(ppg_status_date) from ppg_status_histories ppg1
                    where ppg1.participant_id = ppg_status_histories.participant_id"
    PpgStatusHistory.where("participant_id in (?) and ppg_status_date = (#{inner_select})", participant_ids).all
  end


end
