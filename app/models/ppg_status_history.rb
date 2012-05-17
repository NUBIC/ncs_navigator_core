# == Schema Information
# Schema version: 20120515181518
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
#  response_set_id       :integer
#  ppg_status_date_date  :date
#

# -*- coding: utf-8 -*-

class PpgStatusHistory < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :ppg_history_id, :date_fields => [:ppg_status_date]

  belongs_to :participant
  belongs_to :response_set
  ncs_coded_attribute :psu,             'PSU_CL1'
  ncs_coded_attribute :ppg_status,      'PPG_STATUS_CL1'
  ncs_coded_attribute :ppg_info_source, 'INFORMATION_SOURCE_CL3'
  ncs_coded_attribute :ppg_info_mode,   'CONTACT_TYPE_CL1'

  before_save :set_ppg_status_date

  scope :current_ppg_status, joins("inner join (select participant_id, max(updated_at) as updated_at from ppg_status_histories group by participant_id) as inner_ppg on inner_ppg.participant_id = ppg_status_histories.participant_id and inner_ppg.updated_at = ppg_status_histories.updated_at")
  scope :for_participant, lambda { |participant| where(:participant_id => participant.id) }
  scope :with_status, lambda { |code| where(:ppg_status_code => code) }

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

  private

    def set_ppg_status_date
      if self.ppg_status_date.blank? && self.ppg_status_date_date.blank?
        date = self.created_at.blank? ? Time.now : self.created_at
        self.ppg_status_date_date = date
        self.ppg_status_date = date.strftime(MdesRecord::DEFAULT_DATE_FORMAT)
      end
    end

end
