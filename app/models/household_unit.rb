# -*- coding: utf-8 -*-


# The definition of a household is really based on the individual person's definition of a family.
#
# The common definition is residence at the same address; however, the composition of the household might be
# parent/child; siblings; roommates, or other combinations of relationships.
# SCs will initially assign a household an ID (HH_ID) during the recruitment process, once a family/household
# residing at a DU is identified. HH_IDs follow families as they move outside of the original DU.
# (Several scenarios are described in the Dwelling Unit Household Linkage Transmission Table.)
# Children may be associated with multiple households, including households where non-residential fathers,
# other family members or informants who provide information may live.
#
# (Several Scenarios are described in the Household Person Linkage Table.)
#
# A household record is created when it is determined that a household is eligible for the NCS and also records the reason it is eligible.
# "Household information becomes known during the Enumeration or the Pregnancy Screening process.
#  The Household table should be completed at that time."
# Once a household is identified it continues to be associated with the participant(s) and people related to them.
#
class HouseholdUnit < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :hh_id

  ncs_coded_attribute :psu,            'PSU_CL1'
  ncs_coded_attribute :hh_status,      'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :hh_eligibility, 'HOUSEHOLD_ELIGIBILITY_CL2'
  ncs_coded_attribute :hh_structure,   'RESIDENCE_TYPE_CL2'

  has_many :household_person_links
  has_many :people, :through => :household_person_links

  has_many :dwelling_household_links
  has_many :dwelling_units, :through => :dwelling_household_links

  accepts_nested_attributes_for :household_person_links, :allow_destroy => true
end

