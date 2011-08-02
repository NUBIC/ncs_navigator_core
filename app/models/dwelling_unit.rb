# == Schema Information
# Schema version: 20110727185512
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
#  du_id              :binary          not null
#  listing_unit_id    :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# DU is a specific street address within a sampling unit. 
# There is a one-to-one relationship between Listing and DU. 
# This is not a mandatory one-to-one relationship because some DUs may not appear in the Listing and vice versa
class DwellingUnit < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :du_id

  has_many :dwelling_household_links
  has_many :houshold_units, :through => :dwelling_household_links
  has_one :address
  
  accepts_nested_attributes_for :address, :allow_destroy => true
  
  belongs_to :listing_unit
  belongs_to :psu,           :conditions => "list_name = 'PSU_CL1'",            :foreign_key => :psu_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :duplicate_du,  :conditions => "list_name = 'CONFIRM_TYPE_CL2'",   :foreign_key => :duplicate_du_code,   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :missed_du,     :conditions => "list_name = 'CONFIRM_TYPE_CL2'",   :foreign_key => :missed_du_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :du_type,       :conditions => "list_name = 'RESIDENCE_TYPE_CL2'", :foreign_key => :du_type_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :du_ineligible, :conditions => "list_name = 'CONFIRM_TYPE_CL3'",   :foreign_key => :du_ineligible_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :du_access,     :conditions => "list_name = 'CONFIRM_TYPE_CL2'",   :foreign_key => :du_access_code,      :class_name => 'NcsCode', :primary_key => :local_code

  scope :without_household, joins("LEFT OUTER JOIN dwelling_household_links ON dwelling_units.id = dwelling_household_links.dwelling_unit_id").where("dwelling_household_links.id is NULL")
  scope :next_to_process, without_household.where("dwelling_units.being_processed IS FALSE").readonly(false)

end
