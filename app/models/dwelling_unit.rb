# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: dwelling_units
#
#  being_processed    :boolean          default(FALSE)
#  created_at         :datetime
#  du_access_code     :integer          not null
#  du_id              :string(36)       not null
#  du_ineligible_code :integer          not null
#  du_type_code       :integer          not null
#  du_type_other      :string(255)
#  duid_comment       :text
#  duplicate_du_code  :integer          not null
#  id                 :integer          not null, primary key
#  listing_unit_id    :integer
#  missed_du_code     :integer          not null
#  psu_code           :integer          not null
#  ssu_id             :string(255)
#  transaction_type   :string(36)
#  tsu_id             :string(255)
#  updated_at         :datetime
#



# DU is a specific street address within a sampling unit.
# There is a one-to-one relationship between Listing and DU.
# This is not a mandatory one-to-one relationship because some DUs may not appear in the Listing and vice versa
#
# Dwelling Units are an identified address. Once identified the data in this record will rarely change.
#
#  Possible reasons for modification:
#  * Dwelling disappears
#  * New association with household
#
class DwellingUnit < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :du_id

  has_many :dwelling_household_links
  has_many :household_units, :through => :dwelling_household_links
  has_one :address

  accepts_nested_attributes_for :address, :allow_destroy => true

  belongs_to :listing_unit
  ncs_coded_attribute :psu,           'PSU_CL1'
  ncs_coded_attribute :duplicate_du,  'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :missed_du,     'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :du_type,       'RESIDENCE_TYPE_CL2'
  ncs_coded_attribute :du_ineligible, 'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :du_access,     'CONFIRM_TYPE_CL2'

  scope :without_household, joins("LEFT OUTER JOIN dwelling_household_links ON dwelling_units.id = dwelling_household_links.dwelling_unit_id").where("dwelling_household_links.id is NULL")
  scope :next_to_process, without_household.where("dwelling_units.being_processed IS FALSE").readonly(false)

  ##
  # Gets the ssu_id and ssu_name from the
  # NcsNavigator.configuration.sampling_units_file
  # @return [Array<Array>]
  def self.ssus
    result = []
    Rails.application.csv_impl.parse(File.open(DwellingUnit.sampling_units_file.to_s), :headers => true, :header_converters => :symbol) do |row|
      result << [row[:ssu_name], row[:ssu_id]]
    end
    result
  end

  ##
  # Gets the tsu_id and tsu_name from the
  # NcsNavigator.configuration.sampling_units_file
  # @return [Array<Array>]
  def self.tsus
    result = []
    Rails.application.csv_impl.parse(File.open(DwellingUnit.sampling_units_file.to_s), :headers => true, :header_converters => :symbol) do |row|
      result << [row[:tsu_name], row[:tsu_id]] unless row[:tsu_id] == "."
    end
    result
  end

  private

    def self.sampling_units_file
      NcsNavigator.configuration.sampling_units_file
    end

end

