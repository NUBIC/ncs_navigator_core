# == Schema Information
# Schema version: 20111212224350
#
# Table name: dwelling_units
#
#  id                 :integer         not null, primary key
#  psu_code           :integer         not null
#  duplicate_du_code  :integer         not null
#  missed_du_code     :integer         not null
#  du_type_code       :integer         not null
#  du_type_other      :string(255)
#  du_ineligible_code :integer         not null
#  du_access_code     :integer         not null
#  duid_comment       :text
#  transaction_type   :string(36)
#  du_id              :string(36)      not null
#  listing_unit_id    :integer
#  created_at         :datetime
#  updated_at         :datetime
#  being_processed    :boolean
#  ssu_id             :string(255)
#  tsu_id             :string(255)
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
  include MdesRecord
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

end
