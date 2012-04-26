# -*- coding: utf-8 -*-

Factory.define :listing_unit do |lu|
  lu.psu_code         2000030
  lu.list_line        1
  lu.list_source_code 1
  lu.list_comment     "comment"
  lu.transaction_type nil
  lu.ssu_id        '42'
  lu.tsu_id        nil
end

Factory.define :dwelling_unit do |du|
  du.psu_code           2000030
  du.duplicate_du_code  1
  du.missed_du_code     1
  du.du_type_code       1
  du.du_type_other nil
  du.du_ineligible_code 2
  du.du_access_code     1
  du.duid_comment  "No comment"
  du.ssu_id        nil
  du.tsu_id        nil
  du.association   :listing_unit, :factory => :listing_unit
end

Factory.define :household_unit do |hh|
  hh.psu_code                     2000030
  hh.hh_status_code               1
  hh.hh_eligibility_code          1
  hh.number_of_age_eligible_women 1
  hh.number_of_pregnant_women     1
  hh.number_of_pregnant_minors    0
  hh.number_of_pregnant_adults    1
  hh.number_of_pregnant_over49    0
  hh.hh_structure_code            1
  hh.hh_structure_other           nil
  hh.hh_comment                   "No comment"
  hh.transaction_type             nil
end

Factory.define :dwelling_household_link do |link|
  link.association :dwelling_unit,  :factory => :dwelling_unit
  link.association :household_unit, :factory => :household_unit
  link.psu_code        2000030
  link.is_active_code  1
  link.du_rank_code    1
end

Factory.define :household_person_link do |link|
  link.association :person,  :factory => :person
  link.association :household_unit, :factory => :household_unit
  link.psu_code        2000030
  link.is_active_code  1
  link.hh_rank_code    1
end
