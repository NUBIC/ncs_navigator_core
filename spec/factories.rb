# http://github.com/thoughtbot/factory_girl/tree/master
require 'rubygems'
require 'factory_girl'

Factory.define :ncs_code do |code|
  code.list_name        "PSU_CL1"
  code.list_description "Description"
  code.display_text     "Cook County, IL (Wave 1)"
  code.local_code       "20000030"
end

Factory.define :person do |pers|
  pers.psu                            { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  pers.prefix                         { |a| a.association(:ncs_code, :list_name => "NAME_PREFIX_CL1", :display_text => "Mr.", :local_code => 1) }
  pers.first_name                     "Fred"
  pers.last_name                      "Rogers"
  pers.middle_name                    "N."
  pers.maiden_name                    nil
  pers.suffix                         { |a| a.association(:ncs_code, :list_name => "NAME_SUFFIX_CL1", :display_text => "Jr.", :local_code => 1) }
  pers.title                          "Senor"
  pers.sex                            { |a| a.association(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Male", :local_code => 1) }
  pers.age                            99
  pers.age_range                      { |a| a.association(:ncs_code, :list_name => "AGE_RANGE_CL1", :display_text => "65+", :local_code => 7) }
  pers.person_dob                     "1901-91-91"
  pers.date_of_birth                  nil
  pers.deceased                       { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  pers.ethnic_group                   { |a| a.association(:ncs_code, :list_name => "ETHNICITY_CL1", :display_text => "Not Hispanic or Latino", :local_code => 2) }
  pers.language                       { |a| a.association(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1) }
  pers.language_other                 nil
  pers.marital_status                 { |a| a.association(:ncs_code, :list_name => "MARITAL_STATUS_CL1", :display_text => "Married", :local_code => 1) }
  pers.marital_status_other           nil
  pers.preferred_contact_method       { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
  pers.preferred_contact_method_other nil
  pers.planned_move                   { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL1", :display_text => "No", :local_code => 2) }
  pers.move_info                      { |a| a.association(:ncs_code, :list_name => "MOVING_PLAN_CL1", :display_text => "Address Known", :local_code => 1) }
  pers.when_move                      { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL4", :display_text => "No", :local_code => 2) }
  pers.moving_date                    nil
  pers.date_move                      nil
  pers.p_tracing                      { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  pers.p_info_source                  { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL4", :display_text => "Person/Self", :local_code => 1) }
  pers.p_info_source_other            nil
  pers.p_info_date                    nil
  pers.p_info_update                  nil
  pers.person_comment                 nil
  pers.transaction_type               nil
end

Factory.define :person_race do |pr|
  pr.psu    { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  pr.race   { |a| a.association(:ncs_code, :list_name => "RACE_CL1", :display_text => "White", :local_code => 1) }
  pr.association :person, :factory => :person
end

Factory.define :dwelling_unit do |du|
  du.psu           { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  du.duplicate_du  { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  du.missed_du     { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  du.du_type       { |a| a.association(:ncs_code, :list_name => "RESIDENCE_TYPE_CL2", :display_text => "Single-Family Home", :local_code => 1) }
  du.du_type_other nil
  du.du_ineligible { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL3", :display_text => "No", :local_code => 2) }
  du.du_access     { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1)}
  du.duid_comment  "No comment"
end

Factory.define :household_unit do |hh|
  hh.psu                          { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  hh.hh_status                    { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  hh.hh_eligibility                { |a| a.association(:ncs_code, :list_name => "HOUSEHOLD_ELIGIBILITY_CL2", :display_text => "Household is eligible", :local_code => 1) }
  hh.number_of_age_eligible_women 1
  hh.number_of_pregnant_women     1
  hh.number_of_pregnant_minors    0
  hh.number_of_pregnant_adults    1
  hh.number_of_pregnant_over49    0
  hh.hh_structure                 { |a| a.association(:ncs_code, :list_name => "RESIDENCE_TYPE_CL2", :display_text => "Single-Family Home", :local_code => 1) }
  hh.hh_structure_other           nil
  hh.hh_comment                   "No comment"
  hh.transaction_type             nil
end

Factory.define :dwelling_household_link do |link|
  link.association :dwelling_unit,  :factory => :dwelling_unit
  link.association :household_unit, :factory => :household_unit
  link.psu        { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  link.is_active  { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  link.du_rank    { |a| a.association(:ncs_code, :list_name => "COMMUNICATION_RANK_CL1", :display_text => "Primary", :local_code => 1) }
end

Factory.define :household_person_link do |link|
  link.association :person,  :factory => :person
  link.association :household_unit, :factory => :household_unit
  link.psu        { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  link.is_active  { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  link.hh_rank    { |a| a.association(:ncs_code, :list_name => "COMMUNICATION_RANK_CL1", :display_text => "Primary", :local_code => 1) }
end

Factory.define :participant do |par|
  par.association :person,  :factory => :person
  par.psu                       { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  par.p_type                    { |a| a.association(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "Age-eligible woman", :local_code => 1) }
  par.p_type_other              nil
  par.status_info_source        { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL4", :display_text => "Person/Self", :local_code => 1) }
  par.status_info_source_other  nil
  par.status_info_mode          { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
  par.status_info_mode_other    nil
  par.status_info_date          Date.today
  par.enroll_status             { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  par.enroll_date               Date.today
  par.pid_entry                 { |a| a.association(:ncs_code, :list_name => "STUDY_ENTRY_METHOD_CL1", :display_text => "Advance letter mailed by NCS.", :local_code => 1) }
  par.pid_entry_other           nil
  par.pid_age_eligibility       { |a| a.association(:ncs_code, :list_name => "AGE_ELIGIBLE_CL2", :display_text => "Age-Eligible", :local_code => 1) }
  par.pid_comment               nil
  par.transaction_type          nil
end

Factory.define :participant_person_link do |link|
  link.association :participant,  :factory => :participant
  link.association :person,  :factory => :person
  link.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  link.relationship       { |a| a.association(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Participant/Self", :local_code => 1) }
  link.relationship_other nil
  link.is_active          { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  link.transaction_type   nil
end