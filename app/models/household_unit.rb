# == Schema Information
# Schema version: 20110613210555
#
# Table name: household_units
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer
#  hh_status_code               :integer
#  hh_eligibilty_code           :integer
#  number_of_age_eligible_women :integer
#  number_of_pregnant_women     :integer
#  number_of_pregnant_minors    :integer
#  number_of_pregnant_adults    :integer
#  number_of_pregnant_over49    :integer
#  hh_structure_code            :integer
#  hh_structure_other           :string(255)
#  hh_comment                   :text
#  transaction_type             :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#

class HouseholdUnit < ActiveRecord::Base
  
  belongs_to :psu,           :conditions => "list_name = 'PSU_CL1'",                   :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :hh_status,     :conditions => "list_name = 'CONFIRM_TYPE_CL2'",          :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :hh_status_code
  belongs_to :hh_eligibilty, :conditions => "list_name = 'HOUSEHOLD_ELIGIBILITY_CL2'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :hh_eligibilty_code
  belongs_to :hh_structure,  :conditions => "list_name = 'RESIDENCE_TYPE_CL2'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :hh_structure_code
    
end
