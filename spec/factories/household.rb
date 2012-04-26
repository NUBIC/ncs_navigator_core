# encoding: utf-8

Factory.define :listing_unit do |lu|
  lu.psu              { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  lu.list_line        1
  lu.list_source      { |a| a.association(:ncs_code, :list_name => "LISTING_SOURCE_CL1", :display_text => "Traditional Listing Effort", :local_code => 1) }
  lu.list_comment     "comment"
  lu.transaction_type nil
  lu.ssu_id        '42'
  lu.tsu_id        nil
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
  du.ssu_id        nil
  du.tsu_id        nil
  du.association   :listing_unit, :factory => :listing_unit
end

Factory.define :household_unit do |hh|
  hh.psu                          { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  hh.hh_status                    { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  hh.hh_eligibility               { |a| a.association(:ncs_code, :list_name => "HOUSEHOLD_ELIGIBILITY_CL2", :display_text => "Household is eligible", :local_code => 1) }
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