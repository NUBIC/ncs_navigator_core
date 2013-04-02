# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: telephones
#
#  cell_permission_code    :integer          not null
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  institute_id            :integer
#  lock_version            :integer          default(0)
#  person_id               :integer
#  phone_comment           :text
#  phone_end_date          :string(10)
#  phone_end_date_date     :date
#  phone_ext               :string(5)
#  phone_id                :string(36)       not null
#  phone_info_date         :date
#  phone_info_source_code  :integer          not null
#  phone_info_source_other :string(255)
#  phone_info_update       :date
#  phone_landline_code     :integer          not null
#  phone_nbr               :string(10)
#  phone_rank_code         :integer          not null
#  phone_rank_other        :string(255)
#  phone_share_code        :integer          not null
#  phone_start_date        :string(10)
#  phone_start_date_date   :date
#  phone_type_code         :integer          not null
#  phone_type_other        :string(255)
#  provider_id             :integer
#  psu_code                :integer          not null
#  response_set_id         :integer
#  text_permission_code    :integer          not null
#  transaction_type        :string(255)
#  updated_at              :datetime
#



# A Person, an Institution and a Provider will have at least one and sometimes many phone numbers.
class Telephone < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :phone_id, :date_fields => [:phone_start_date, :phone_end_date]

  belongs_to :person
  belongs_to :institute, :class_name => 'Institution', :foreign_key => :institute_id
  belongs_to :provider
  belongs_to :response_set

  ncs_coded_attribute :psu,               'PSU_CL1'
  ncs_coded_attribute :phone_info_source, 'INFORMATION_SOURCE_CL2'
  ncs_coded_attribute :phone_type,        'PHONE_TYPE_CL1'
  ncs_coded_attribute :phone_rank,        'COMMUNICATION_RANK_CL1'
  ncs_coded_attribute :phone_landline,    'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :phone_share,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :cell_permission,
    :list_name => { 'CONFIRM_TYPE_CL2' => '2.0', 'CONFIRM_TYPE_CL21' => '> 2.0' }
  ncs_coded_attribute :text_permission,
    :list_name => { 'CONFIRM_TYPE_CL2' => '2.0', 'CONFIRM_TYPE_CL10' => '> 2.0' }

  validates :phone_ext,        :length => { :maximum => 5 },  :allow_blank => true
  validates :phone_nbr,        :length => { :maximum => 10 }, :allow_blank => true, :numericality => true
  validates :phone_end_date,   :length => { :is => 10 },      :allow_blank => true
  validates :phone_start_date, :length => { :is => 10 },      :allow_blank => true

  HOME_PHONE_CODE = 1
  WORK_PHONE_CODE = 2
  CELL_PHONE_CODE = 3
  FAX_PHONE_CODE  = 4

  def to_s
    self.phone_nbr
  end

  def self.home_phone_type
    NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", HOME_PHONE_CODE)
  end

  def self.work_phone_type
    NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", WORK_PHONE_CODE)
  end

  def self.cell_phone_type
    NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", CELL_PHONE_CODE)
  end

  def self.fax_phone_type
    NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", FAX_PHONE_CODE)
  end

  def self.other_phone_type
    NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", -5)
  end

  def phone_nbr=(nbr)
    self[:phone_nbr] =
      case nbr
      when nil
        nil
      when /^-/
        nbr
      when String
        nbr.scan(/\d|[a-zA-Z]/).join
      else
        nbr.to_s
      end
  end

  ##
  # Updates the rank to secondary if current rank is primary
  def demote_primary_rank_to_secondary(phone_type)
    return unless self.phone_rank_code == 1
    secondary_rank = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2)
    if !secondary_rank.blank? && phone_type == self.phone_type_code
      self.phone_rank = secondary_rank
      self.save
    end
  end

  def type_code
    self.phone_type_code
  end

  def rank_code
    self.phone_rank_code
  end

end
