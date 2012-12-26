# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: emails
#
#  created_at              :datetime
#  email                   :string(100)
#  email_active_code       :integer          not null
#  email_comment           :text
#  email_end_date          :string(10)
#  email_end_date_date     :date
#  email_id                :string(36)       not null
#  email_info_date         :date
#  email_info_source_code  :integer          not null
#  email_info_source_other :string(255)
#  email_info_update       :date
#  email_rank_code         :integer          not null
#  email_rank_other        :string(255)
#  email_share_code        :integer          not null
#  email_start_date        :string(10)
#  email_start_date_date   :date
#  email_type_code         :integer          not null
#  email_type_other        :string(255)
#  id                      :integer          not null, primary key
#  lock_version            :integer          default(0)
#  person_id               :integer
#  psu_code                :integer          not null
#  response_set_id         :integer
#  transaction_type        :string(255)
#  updated_at              :datetime
#



# A Person, an Institution and a Provider will have at least one and sometimes many Email addresses.
class Email < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :email_id, :date_fields => [:email_start_date, :email_end_date]

  belongs_to :person
  belongs_to :response_set
  belongs_to :provider
  belongs_to :institute, :class_name => 'Institution', :foreign_key => :institute_id
  ncs_coded_attribute :psu,               'PSU_CL1'
  ncs_coded_attribute :email_info_source, 'INFORMATION_SOURCE_CL2'
  ncs_coded_attribute :email_type,        'EMAIL_TYPE_CL1'
  ncs_coded_attribute :email_rank,        'COMMUNICATION_RANK_CL1'
  ncs_coded_attribute :email_share,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :email_active,      'CONFIRM_TYPE_CL2'

  def to_s
    self.email
  end

  ##
  # Updates the rank to secondary if current rank is primary
  def demote_primary_rank_to_secondary(email_type)
    return unless self.email_rank_code == 1
    secondary_rank = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2)
    if !secondary_rank.blank? && email_type == self.email_type_code
      self.update_attribute(:email_rank, secondary_rank)
    end
  end

  def filter_criteria
    :email
  end

  def type_code
    :email_type_code
  end

  def rank_code
    :email_rank_code
  end

end
