# -*- coding: utf-8 -*-

# == Schema Information
# Schema version: 20120404205955
#
# Table name: emails
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  email_id                :string(36)      not null
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
#  response_set_id         :integer
#

# A Person, an Institution and a Provider will have at least one and sometimes many Email addresses.
class Email < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :email_id, :date_fields => [:email_start_date, :email_end_date]

  belongs_to :person
  belongs_to :response_set

  ncs_coded_attribute :psu,               'PSU_CL1'
  ncs_coded_attribute :email_info_source, 'INFORMATION_SOURCE_CL2'
  ncs_coded_attribute :email_type,        'EMAIL_TYPE_CL1'
  ncs_coded_attribute :email_rank,        'COMMUNICATION_RANK_CL1'
  ncs_coded_attribute :email_share,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :email_active,      'CONFIRM_TYPE_CL2'

  ##
  # Updates the rank to secondary if current rank is primary
  def demote_primary_rank_to_secondary
    return unless self.email_rank_code == 1
    secondary_rank = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2)
    if !secondary_rank.blank?
      self.email_rank = secondary_rank
      self.save
    end
  end

end