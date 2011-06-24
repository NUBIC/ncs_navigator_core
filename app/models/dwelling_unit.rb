# == Schema Information
# Schema version: 20110624163825
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
#  created_at         :datetime
#  updated_at         :datetime
#

class DwellingUnit < ActiveRecord::Base

  has_many :dwelling_household_links
  has_many :houshold_units, :through => :dwelling_household_links
  
  belongs_to :psu,           :conditions => "list_name = 'PSU_CL1'",            :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :duplicate_du,  :conditions => "list_name = 'CONFIRM_TYPE_CL2'",   :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :duplicate_du_code
  belongs_to :missed_du,     :conditions => "list_name = 'CONFIRM_TYPE_CL2'",   :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :missed_du_code
  belongs_to :du_type,       :conditions => "list_name = 'RESIDENCE_TYPE_CL2'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :du_type_code
  belongs_to :du_ineligible, :conditions => "list_name = 'CONFIRM_TYPE_CL3'",   :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :du_ineligible_code
  belongs_to :du_access,     :conditions => "list_name = 'CONFIRM_TYPE_CL2'",   :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :du_access_code

  validates_presence_of :psu
  validates_presence_of :duplicate_du
  validates_presence_of :missed_du
  validates_presence_of :du_type
  validates_presence_of :du_ineligible
  validates_presence_of :du_access
  
end
