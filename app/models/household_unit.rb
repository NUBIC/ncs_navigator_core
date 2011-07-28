# == Schema Information
# Schema version: 20110727185512
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

# The definition of a household is really based on the individual person's definition of a family.
# The common definition is residence at the same address; however, the composition of the household might be 
# parent/child; siblings; roommates, or other combinations of relationships. 
# SCs will initially assign a household an ID (HH_ID) during the recruitment process, once a family/household 
# residing at a DU is identified. HH_IDs follow families as they move outside of the original DU. 
# (Several scenarios are described in the Dwelling Unit Household Linkage Transmission Table.) 
# Children may be associated with multiple households, including households where non-residential fathers, 
# other family members or informants who provide information may live. 
# (Several Scenarios are described in the Household Person Linkage Table.)
class HouseholdUnit < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :hh_id
  
  belongs_to :psu,            :conditions => "list_name = 'PSU_CL1'",                   :foreign_key => :psu_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hh_status,      :conditions => "list_name = 'CONFIRM_TYPE_CL2'",          :foreign_key => :hh_status_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hh_eligibility, :conditions => "list_name = 'HOUSEHOLD_ELIGIBILITY_CL2'", :foreign_key => :hh_eligibility_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hh_structure,   :conditions => "list_name = 'RESIDENCE_TYPE_CL2'",        :foreign_key => :hh_structure_code,   :class_name => 'NcsCode', :primary_key => :local_code
  
  has_many :household_person_links
  has_many :people, :through => :household_person_links
  
  accepts_nested_attributes_for :household_person_links, :allow_destroy => true
end
