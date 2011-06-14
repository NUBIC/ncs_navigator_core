# http://github.com/thoughtbot/factory_girl/tree/master
require 'rubygems'
require 'factory_girl'

Factory.define :ncs_code do |code|
  
  code.list_name        "PSU_CL1"
  code.list_description "Participating Primary Sample Units"
  code.display_text     "Cook County, IL (Wave 1)"
  code.local_code       "20000030"
  
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
  hh.hh_eligibilty                { |a| a.association(:ncs_code, :list_name => "HOUSEHOLD_ELIGIBILITY_CL2", :display_text => "Household is eligible", :local_code => 1) }
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
  
  
end
