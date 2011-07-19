# == Schema Information
# Schema version: 20110715213911
#
# Table name: household_units
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  hh_status_code               :integer         not null
#  hh_eligibility_code          :integer         not null
#  hh_structure_code            :integer         not null
#  hh_structure_other           :string(255)
#  hh_comment                   :text
#  number_of_age_eligible_women :integer
#  number_of_pregnant_women     :integer
#  number_of_pregnant_minors    :integer
#  number_of_pregnant_adults    :integer
#  number_of_pregnant_over49    :integer
#  transaction_type             :string(36)
#  hh_id                        :binary          not null
#  created_at                   :datetime
#  updated_at                   :datetime
#

class HouseholdUnit < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :hh_id
  
  belongs_to :psu,            :conditions => "list_name = 'PSU_CL1'",                   :foreign_key => :psu_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hh_status,      :conditions => "list_name = 'CONFIRM_TYPE_CL2'",          :foreign_key => :hh_status_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hh_eligibility, :conditions => "list_name = 'HOUSEHOLD_ELIGIBILITY_CL2'", :foreign_key => :hh_eligibility_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hh_structure,   :conditions => "list_name = 'RESIDENCE_TYPE_CL2'",        :foreign_key => :hh_structure_code,   :class_name => 'NcsCode', :primary_key => :local_code
end
