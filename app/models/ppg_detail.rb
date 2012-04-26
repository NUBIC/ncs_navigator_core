# -*- coding: utf-8 -*-

# == Schema Information
# Schema version: 20120426034324
#
# Table name: ppg_details
#
#  id                  :integer         not null, primary key
#  psu_code            :integer         not null
#  ppg_details_id      :string(36)      not null
#  participant_id      :integer
#  ppg_pid_status_code :integer         not null
#  ppg_first_code      :integer         not null
#  orig_due_date       :string(10)
#  due_date_2          :string(10)
#  due_date_3          :string(10)
#  transaction_type    :string(36)
#  created_at          :datetime
#  updated_at          :datetime
#  response_set_id     :integer
#

# Basic non-repeating Pregnancy Probability Group (PPG) status information
# is stored here for each woman who completes a pregnancy screener.
# Eligibility criteria for administration of the pregnancy screener are based on 4 elements:
# * gender (i.e., female);
# * primary residence (i.e., participant lives in a sampled Dwelling Unit);
# * age (i.e., 18-49);
# * currently known as pregnant – regardless of age.
#
# In the event that a mother has several pregnancies, each pregnancy would have its own
# PPG Details record.
# There is a one-to-many relationship between Participant and PPG Details.
class PpgDetail < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :ppg_details_id

  belongs_to :participant
  belongs_to :response_set
  ncs_coded_attribute :psu,            'PSU_CL1'
  ncs_coded_attribute :ppg_pid_status, 'PARTICIPANT_STATUS_CL1'
  ncs_coded_attribute :ppg_first,      'PPG_STATUS_CL2'

  after_create :create_associated_ppg_status_history

  def to_s
    "#{ppg_first}"
  end

  ##
  # Return the most recently updated due date that is a valid date
  # @return [String]
  def due_date
    [due_date_3, due_date_2, orig_due_date].compact.select { |d| d != '9777-97-97' }.first
  end

  ##
  # Helper method to set the most recently known due_date
  # @param [Date]
  def update_due_date(due_date, attribute = nil)
    if attribute.nil?
      set_next_due_date(due_date)
    else
      self.update_attribute(attribute, due_date)
    end
  end

  def self.importer_mode
    PpgDetail.skip_callback(:create, :after, :create_associated_ppg_status_history)
    yield
    PpgDetail.set_callback(:create, :after, :create_associated_ppg_status_history)
  end

  private

    def create_associated_ppg_status_history
      ppg_status = NcsCode.for_attribute_name_and_local_code(:ppg_status_code, self.ppg_first_code)
      if ppg_status && self.ppg_first_code < 6
        PpgStatusHistory.create(:participant => self.participant, :psu => self.psu, :ppg_status => ppg_status)
      end
    end

    def set_next_due_date(due_date)
      if orig_due_date.blank?
        self.update_attribute(:orig_due_date, due_date)
      elsif due_date_2.blank?
        self.update_attribute(:due_date_2, due_date)
      elsif due_date_3.blank?
        self.update_attribute(:due_date_3, due_date)
      else
        nil
      end
    end

end
