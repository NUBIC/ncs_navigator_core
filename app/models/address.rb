# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: addresses
#
#  address_comment           :text
#  address_description_code  :integer          not null
#  address_description_other :string(255)
#  address_end_date          :string(10)
#  address_end_date_date     :date
#  address_id                :string(36)       not null
#  address_info_date         :date
#  address_info_mode_code    :integer          not null
#  address_info_mode_other   :string(255)
#  address_info_source_code  :integer          not null
#  address_info_source_other :string(255)
#  address_info_update       :date
#  address_one               :string(100)
#  address_rank_code         :integer          not null
#  address_rank_other        :string(255)
#  address_start_date        :string(10)
#  address_start_date_date   :date
#  address_two               :string(100)
#  address_type_code         :integer          not null
#  address_type_other        :string(255)
#  city                      :string(50)
#  created_at                :datetime
#  dwelling_unit_id          :integer
#  id                        :integer          not null, primary key
#  institute_id              :integer
#  lock_version              :integer          default(0)
#  person_id                 :integer
#  provider_id               :integer
#  psu_code                  :integer          not null
#  response_set_id           :integer
#  state_code                :integer          not null
#  transaction_type          :string(255)
#  unit                      :string(10)
#  updated_at                :datetime
#  zip                       :string(5)
#  zip4                      :string(4)
#



# A Dwelling Unit will have exactly one Address.
# A Person, an Institution and a Provider will have at least one and sometimes many Addresses.
class Address < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :address_id, :date_fields => [:address_start_date, :address_end_date]

  belongs_to :person
  belongs_to :dwelling_unit
  belongs_to :response_set
  belongs_to :provider
  belongs_to :institute, :class_name => 'Institution', :foreign_key => :institute_id
  ncs_coded_attribute :psu,                 'PSU_CL1'
  ncs_coded_attribute :address_rank,        'COMMUNICATION_RANK_CL1'
  ncs_coded_attribute :address_info_source, 'INFORMATION_SOURCE_CL1'
  ncs_coded_attribute :address_info_mode,   'CONTACT_TYPE_CL1'
  ncs_coded_attribute :address_type,        'ADDRESS_CATEGORY_CL1'
  ncs_coded_attribute :address_description, 'RESIDENCE_TYPE_CL1'
  ncs_coded_attribute :state,               'STATE_CL1'

  validates :address_one,         :length => { :maximum => 100 }, :allow_blank => true
  validates :address_two,         :length => { :maximum => 100 }, :allow_blank => true
  validates :city,                :length => { :maximum => 50 },  :allow_blank => true
  validates :unit,                :length => { :maximum => 10 },  :allow_blank => true
  validates :zip,                 :length => { :maximum => 5 },   :allow_blank => true, :numericality => true
  validates :zip4,                :length => { :maximum => 4 },   :allow_blank => true, :numericality => true
  validates :address_end_date,    :length => { :is => 10 },       :allow_blank => true
  validates :address_start_date,  :length => { :is => 10 },       :allow_blank => true

  CONTENT_FIELDS = %w(address_one address_two unit city state_code zip zip4)
  MISSING_IN_ERROR = -4

  def self.home_address_type
    NcsCode.for_list_name_and_local_code("ADDRESS_CATEGORY_CL1", 1)
  end

  def self.work_address_type
    NcsCode.for_list_name_and_local_code("ADDRESS_CATEGORY_CL1", 2)
  end

  def self.mailing_address_type
    NcsCode.for_list_name_and_local_code("ADDRESS_CATEGORY_CL1", 4)
  end

  ##
  # Concatentate Address information into a complete string
  # if that data exists.
  # @return [String]
  def to_s(separator = ' ')
    addr = []
    city_state = []
    postal_code = []
    addr << address_one
    addr << address_two
    addr << unit
    city_state << city
    city_state << state.to_s.downcase.capitalize if state && state.local_code != -4
    addr << city_state.reject { |n| n.blank? || n.to_i < 0 }.join(', ')

    if zip4.blank? || zip4.to_i < 0
      addr << zip
    else
      addr << "#{zip}-#{zip4}" unless zip.blank?
    end

    addr.reject { |n| n.blank? || n.to_i < 0 }.join(separator)
  end

  ##
  # Updates the rank to secondary if current rank is primary
  def demote_primary_rank_to_secondary(address_type)
    return unless self.address_rank_code == 1
    secondary_rank = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2)
    if !secondary_rank.blank? && address_type == self.address_type_code
      self.address_rank = secondary_rank
      self.save
    end
  end

  def blank?
    CONTENT_FIELDS.all? { |cf| v = send(cf); v.blank? || v == MISSING_IN_ERROR }
  end

  def zip_code
    zip4.blank? ? zip.to_s : zip.to_s + '-' + zip4.to_s
  end

  def type_code
    self.address_type_code
  end

  def rank_code
    self.address_rank_code
  end

end
