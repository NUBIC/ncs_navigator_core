# -*- coding: utf-8 -*-


# http://github.com/thoughtbot/factory_girl/tree/master
require 'rubygems'
require 'factory_girl'

Factory.define :person do |pers|
  pers.psu_code                       20000030
  pers.prefix_code                    1
  pers.first_name                     "Fred"
  pers.last_name                      "Rogers"
  pers.middle_name                    "N."
  pers.maiden_name                    nil
  pers.suffix_code                    1
  pers.title                          "Senor"
  pers.sex_code                       1
  pers.age                            99
  pers.age_range_code                 7
  pers.person_dob                     nil
  pers.deceased_code                  1
  pers.ethnic_group_code              2
  pers.language_code                  1
  pers.language_other                 nil
  pers.language_new_code              1
  pers.language_new_other             nil
  pers.marital_status_code            1
  pers.marital_status_other           nil
  pers.preferred_contact_method_code  1
  pers.preferred_contact_method_other nil
  pers.planned_move_code              2
  pers.move_info_code                 1
  pers.when_move_code                 2
  pers.date_move                      nil
  pers.p_tracing_code                 1
  pers.p_info_source_code             1
  pers.p_info_source_other            nil
  pers.p_info_date                    nil
  pers.p_info_update                  nil
  pers.person_comment                 nil
  pers.transaction_type               nil
  pers.person_id                      nil
  pers.household_units { |household| [household.association(:household_unit)] }
end

Factory.define :person_race do |pr|
  pr.psu_code    20000030
  pr.race_code   1
  pr.association :person, :factory => :person
end

Factory.define :address do |addr|
  addr.association  :person,        :factory => :person
  addr.association  :dwelling_unit, :factory => :dwelling_unit
  addr.psu_code          20000030
  addr.address_rank_code 1
  addr.address_info_source_code 1
  addr.address_info_mode_code 1
  addr.address_type_code 1
  addr.address_description_code 1
  addr.state_code 23
end

Factory.define :mdes_min_address, :class => Address do |addr|
  addr.psu_code          20000030
  addr.address_rank_code 1
  addr.address_info_source_code 1
  addr.address_info_mode_code 1
  addr.address_type_code 1
  addr.address_description_code 1
  addr.state_code 23
end

Factory.define :telephone do |phone|
  phone.association  :person,        :factory => :person
  phone.association  :provider,      :factory => :provider
  phone.psu_code               20000030
  phone.phone_info_source_code 1
  phone.phone_type_code        1
  phone.phone_rank_code        1
  phone.phone_landline_code    1
  phone.phone_share_code       1
  phone.cell_permission_code   1
  phone.text_permission_code   1
end

Factory.define :email do |email|
  email.association  :person,        :factory => :person
  email.psu_code               20000030
  email.email_info_source_code 1
  email.email_type_code        1
  email.email_rank_code        1
  email.email_share_code       1
  email.email_active_code      1
end

Factory.define :contact do |c|
  c.psu_code               20000030
  c.contact_type_code      1
  c.contact_language_code  1
  c.contact_interpret_code 1
  c.contact_location_code  1
  c.contact_private_code   1
  c.who_contacted_code     1
end

Factory.define :contact_link do |cl|
  cl.psu_code               20000030
  cl.association :person,     :factory => :person
  cl.association :contact,    :factory => :contact
  cl.association :event,      :factory => :event
  cl.association :instrument, :factory => :instrument
  cl.staff_id "staff_public_id"
  cl.association :provider,   :factory => :provider
end

Factory.define :mdes_min_contact_link, :class => ContactLink do |cl|
  cl.psu_code    20000030
  cl.association :contact,    :factory => :contact
  cl.staff_id    "staff_public_id"
end

Factory.define :event do |e|
  e.association :participant, :factory => :participant
  e.psu_code                         20000030
  e.event_type_code                  1
  e.event_disposition_category_code  1
  e.event_breakoff_code              1
  e.event_incentive_type_code        1
  e.psc_ideal_date                   nil
end

Factory.define :mdes_min_event, :class => Event do |e|
  e.psu_code                         20000030
  e.event_type_code                  1
  e.event_disposition                40
  e.event_disposition_category_code  1
  e.event_breakoff_code              1
  e.event_incentive_type_code        1
end

Factory.define :instrument do |ins|

  ins.association :event, :factory => :event
  ins.psu_code                   20000030
  ins.instrument_type_code       1
  ins.instrument_breakoff_code   1
  ins.instrument_status_code     1
  ins.instrument_mode_code       1
  ins.instrument_method_code     1
  ins.supervisor_review_code     1
  ins.data_problem_code          1
  ins.instrument_version "1.2"
  ins.instrument_repeat_key      0

end

Factory.define :legacy_instrument_data_record do |rec|
  rec.association :instrument, :factory => :instrument
  rec.mdes_version    '2.0'
  rec.mdes_table_name 'birth_visit'
  rec.public_id       'IMP-42'
end

Factory.define :legacy_instrument_data_record_with_value, :parent => :legacy_instrument_data_record do |rec|
  rec.after_create do |with_value|
    Factory(:legacy_instrument_data_value, :legacy_instrument_data_record => with_value)
  end
end

Factory.define :legacy_instrument_data_value do |val|
  val.association :legacy_instrument_data_record,
    :factory => :legacy_instrument_data_record

  val.mdes_variable_name 'child_dob'
  val.value              '2007-09-09'
end

Factory.define :fieldwork do |f|
  f.start_date     { Date.today }
  f.end_date       { Date.today + 7 }
  f.client_id      { '1234567890' }
  f.staff_id       { 'foo' }
  f.generated_for  { 'nobody' }
end

Factory.define :sampled_persons_ineligibility do |spi|

  spi.association :person, :factory => :person
  spi.association :provider, :factory => :provider
  spi.psu_code                   20000030
  spi.age_eligible_code          1
  spi.county_of_residence_code   1
  spi.first_prenatal_visit_code  1
  spi.ineligible_by_code          1
end

Factory.define :ineligible_batch do |ib|
  ib.association :provider, :factory => :provider
  ib.date_first_visit_date       { Date.today }
  ib.people_count                1
  ib.pre_screening_status_code   1
  ib.provider_intro_outcome_code 1
  ib.psu_code                    20000030
  ib.sampled_person_code         1
end
