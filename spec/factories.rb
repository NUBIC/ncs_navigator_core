# encoding: utf-8

# http://github.com/thoughtbot/factory_girl/tree/master
require 'rubygems'
require 'factory_girl'

Factory.define :ncs_code do |code|
  code.list_name        "PSU_CL1"
  code.list_description "Description"
  code.display_text     "Cook County, IL (Wave 1)"
  code.local_code       20000030
end

Factory.define :person do |pers|
  pers.psu                            { |a| a.association(:ncs_code, :list_name => "PSU_CL1", :local_code => 20000030) }
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
  pers.person_dob                     nil
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
  pers.date_move                      nil
  pers.p_tracing                      { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  pers.p_info_source                  { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL4", :display_text => "Person/Self", :local_code => 1) }
  pers.p_info_source_other            nil
  pers.p_info_date                    nil
  pers.p_info_update                  nil
  pers.person_comment                 nil
  pers.transaction_type               nil
  pers.person_id                      nil
end

Factory.define :person_race do |pr|
  pr.psu    { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  pr.race   { |a| a.association(:ncs_code, :list_name => "RACE_CL1", :display_text => "White", :local_code => 1) }
  pr.association :person, :factory => :person
end

Factory.define :address do |addr|
  addr.association  :person,        :factory => :person
  addr.association  :dwelling_unit, :factory => :dwelling_unit
  addr.psu          { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  addr.address_rank { |a| a.association(:ncs_code, :list_name => "COMMUNICATION_RANK_CL1", :display_text => "Primary", :local_code => 1) }
  addr.address_info_source { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL1", :display_text => "Person/Self", :local_code => 1) }
  addr.address_info_mode { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-Person", :local_code => 1) }
  addr.address_type { |a| a.association(:ncs_code, :list_name => "ADDRESS_CATEGORY_CL1", :display_text => "Home/Residential", :local_code => 1) }
  addr.address_description { |a| a.association(:ncs_code, :list_name => "RESIDENCE_TYPE_CL1", :display_text => "Single-Family Home", :local_code => 1) }
  addr.state { |a| a.association(:ncs_code, :list_name => "STATE_CL1", :display_text => "Michigan", :local_code => 23) }
end

Factory.define :telephone do |phone|
  phone.association  :person,        :factory => :person
  phone.psu               { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  phone.phone_info_source { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL2", :display_text => "Person/Self", :local_code => 1) }
  phone.phone_type        { |a| a.association(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Home", :local_code => 1) }
  phone.phone_rank        { |a| a.association(:ncs_code, :list_name => "COMMUNICATION_RANK_CL1", :display_text => "Primary", :local_code => 1) }
  phone.phone_landline    { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  phone.phone_share       { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  phone.cell_permission   { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  phone.text_permission   { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
end

Factory.define :email do |email|
  email.association  :person,        :factory => :person
  email.psu               { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  email.email_info_source { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL2",  :display_text => "Person/Self", :local_code => 1) }
  email.email_type        { |a| a.association(:ncs_code, :list_name => "EMAIL_TYPE_CL1",          :display_text => "Personal", :local_code => 1) }
  email.email_rank        { |a| a.association(:ncs_code, :list_name => "COMMUNICATION_RANK_CL1",  :display_text => "Primary", :local_code => 1) }
  email.email_share       { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2",        :display_text => "Yes", :local_code => 1) }
  email.email_active      { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2",        :display_text => "Yes", :local_code => 1) }
end

Factory.define :contact do |c|
  c.psu               { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  c.contact_type      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1",        :display_text => "In-person", :local_code => 1) }
  c.contact_language  { |a| a.association(:ncs_code, :list_name => "LANGUAGE_CL2",            :display_text => "English", :local_code => 1) }
  c.contact_interpret { |a| a.association(:ncs_code, :list_name => "TRANSLATION_METHOD_CL3",  :display_text => "Bilingual Interviewer", :local_code => 1) }
  c.contact_location  { |a| a.association(:ncs_code, :list_name => "CONTACT_LOCATION_CL1",    :display_text => "Person/participant home", :local_code => 1) }
  c.contact_private   { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2",        :display_text => "Yes", :local_code => 1) }
  c.who_contacted     { |a| a.association(:ncs_code, :list_name => "CONTACTED_PERSON_CL1",    :display_text => "NCS Participant", :local_code => 1) }
end

Factory.define :contact_link do |cl|
  cl.psu               { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  cl.association :person,     :factory => :person
  cl.association :contact,    :factory => :contact
  cl.association :event,      :factory => :event
  cl.association :instrument, :factory => :instrument
  cl.staff_id "staff_public_id"
  # TODO: create the following
  # cl.association :provider
end

Factory.define :event do |e|
  e.association :participant, :factory => :participant
  e.psu                         { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  e.event_type                  { |a| a.association(:ncs_code, :list_name => "EVENT_TYPE_CL1",        :display_text => "Household Enumeration", :local_code => 1) }
  e.event_disposition_category  { |a| a.association(:ncs_code, :list_name => "EVENT_DSPSTN_CAT_CL1",  :display_text => "Household Enumeration Events", :local_code => 1) }
  e.event_breakoff              { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2",      :display_text => "Yes", :local_code => 1) }
  e.event_incentive_type        { |a| a.association(:ncs_code, :list_name => "INCENTIVE_TYPE_CL1",    :display_text => "Monetary", :local_code => 1) }
end

Factory.define :instrument do |ins|

  ins.association :event, :factory => :event
  ins.psu                   { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ins.instrument_type       { |a| a.association(:ncs_code, :list_name => "INSTRUMENT_TYPE_CL1",         :display_text => "Household Enumeration Interview", :local_code => 1) }
  ins.instrument_breakoff   { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2",            :display_text => "Yes", :local_code => 1) }
  ins.instrument_status     { |a| a.association(:ncs_code, :list_name => "INSTRUMENT_STATUS_CL1",       :display_text => "Not started", :local_code => 1) }
  ins.instrument_mode       { |a| a.association(:ncs_code, :list_name => "INSTRUMENT_ADMIN_MODE_CL1",   :display_text => "In-person, Computer Assisted (CAPI/CASI)", :local_code => 1) }
  ins.instrument_method     { |a| a.association(:ncs_code, :list_name => "INSTRUMENT_ADMIN_METHOD_CL1", :display_text => "Self-administered", :local_code => 1) }
  ins.supervisor_review     { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2",            :display_text => "Yes", :local_code => 1) }
  ins.data_problem          { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2",            :display_text => "Yes", :local_code => 1) }
  ins.instrument_version "1.2"

end

Factory.define :fieldwork do |f|
  f.start_date  { Date.today }
  f.end_date    { Date.today + 7 }
  f.client_id   { '1234567890' }
end