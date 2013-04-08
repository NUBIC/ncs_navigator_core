# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130409233256) do

  create_table "addresses", :force => true do |t|
    t.integer  "psu_code",                                                :null => false
    t.string   "address_id",                :limit => 36,                 :null => false
    t.integer  "person_id"
    t.integer  "dwelling_unit_id"
    t.integer  "address_rank_code",                                       :null => false
    t.string   "address_rank_other"
    t.integer  "address_info_source_code",                                :null => false
    t.string   "address_info_source_other"
    t.integer  "address_info_mode_code",                                  :null => false
    t.string   "address_info_mode_other"
    t.date     "address_info_date"
    t.date     "address_info_update"
    t.string   "address_start_date",        :limit => 10
    t.date     "address_start_date_date"
    t.string   "address_end_date",          :limit => 10
    t.date     "address_end_date_date"
    t.integer  "address_type_code",                                       :null => false
    t.string   "address_type_other"
    t.integer  "address_description_code",                                :null => false
    t.string   "address_description_other"
    t.string   "address_one",               :limit => 100
    t.string   "address_two",               :limit => 100
    t.string   "unit",                      :limit => 10
    t.string   "city",                      :limit => 50
    t.integer  "state_code",                                              :null => false
    t.string   "zip",                       :limit => 5
    t.string   "zip4",                      :limit => 4
    t.text     "address_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.integer  "provider_id"
    t.integer  "institute_id"
    t.integer  "lock_version",                             :default => 0
  end

  create_table "answers", :force => true do |t|
    t.integer  "question_id"
    t.text     "text"
    t.text     "short_text"
    t.text     "help_text"
    t.integer  "weight"
    t.string   "response_class"
    t.string   "reference_identifier"
    t.string   "data_export_identifier"
    t.string   "common_namespace"
    t.string   "common_identifier"
    t.integer  "display_order"
    t.boolean  "is_exclusive"
    t.integer  "display_length"
    t.string   "custom_class"
    t.string   "custom_renderer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_value"
    t.string   "api_id"
    t.string   "display_type"
  end

  add_index "answers", ["api_id"], :name => "uq_answers_api_id", :unique => true
  add_index "answers", ["display_order"], :name => "idx_answers_display_order"
  add_index "answers", ["question_id"], :name => "idx_answers_question_id"
  add_index "answers", ["reference_identifier"], :name => "idx_answers_reference_identifier"

  create_table "appointment_sheets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_links", :force => true do |t|
    t.integer  "psu_code",                       :null => false
    t.string   "contact_link_id",  :limit => 36, :null => false
    t.integer  "contact_id",                     :null => false
    t.integer  "event_id"
    t.integer  "instrument_id"
    t.string   "staff_id",         :limit => 36, :null => false
    t.integer  "person_id"
    t.integer  "provider_id"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "psu_code",                                                                           :null => false
    t.string   "contact_id",              :limit => 36,                                              :null => false
    t.integer  "contact_disposition"
    t.integer  "contact_type_code",                                                                  :null => false
    t.string   "contact_type_other"
    t.string   "contact_date",            :limit => 10
    t.date     "contact_date_date"
    t.string   "contact_start_time"
    t.string   "contact_end_time"
    t.integer  "contact_language_code",                                                              :null => false
    t.string   "contact_language_other"
    t.integer  "contact_interpret_code",                                                             :null => false
    t.string   "contact_interpret_other"
    t.integer  "contact_location_code",                                                              :null => false
    t.string   "contact_location_other"
    t.integer  "contact_private_code",                                                               :null => false
    t.string   "contact_private_detail"
    t.decimal  "contact_distance",                      :precision => 6, :scale => 2
    t.integer  "who_contacted_code",                                                                 :null => false
    t.string   "who_contacted_other"
    t.text     "contact_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                                        :default => 0
  end

  create_table "dependencies", :force => true do |t|
    t.integer  "question_id"
    t.integer  "question_group_id"
    t.string   "rule"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dependencies", ["question_group_id"], :name => "idx_dependencies_question_group_id"
  add_index "dependencies", ["question_id"], :name => "idx_dependencies_question_id"

  create_table "dependency_conditions", :force => true do |t|
    t.integer  "dependency_id"
    t.string   "rule_key"
    t.integer  "question_id"
    t.string   "operator"
    t.integer  "answer_id"
    t.datetime "datetime_value"
    t.integer  "integer_value"
    t.float    "float_value"
    t.string   "unit"
    t.text     "text_value"
    t.string   "string_value"
    t.string   "response_other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dependency_conditions", ["answer_id"], :name => "idx_dependency_conditions_answer_id"
  add_index "dependency_conditions", ["dependency_id"], :name => "idx_dependency_conditions_dependency_id"
  add_index "dependency_conditions", ["question_id"], :name => "idx_dependency_conditions_question_id"

  create_table "dwelling_household_links", :force => true do |t|
    t.integer  "psu_code",                        :null => false
    t.string   "hh_du_id",          :limit => 36, :null => false
    t.integer  "dwelling_unit_id",                :null => false
    t.integer  "household_unit_id",               :null => false
    t.integer  "is_active_code",                  :null => false
    t.integer  "du_rank_code",                    :null => false
    t.string   "du_rank_other"
    t.string   "transaction_type",  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dwelling_unit_type_non_interview_reports", :force => true do |t|
    t.integer  "psu_code",                                   :null => false
    t.string   "nir_dutype_id",                :limit => 36, :null => false
    t.integer  "non_interview_report_id"
    t.integer  "nir_dwelling_unit_type_code",                :null => false
    t.string   "nir_dwelling_unit_type_other"
    t.string   "transaction_type",             :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dwelling_units", :force => true do |t|
    t.integer  "psu_code",                                            :null => false
    t.integer  "duplicate_du_code",                                   :null => false
    t.integer  "missed_du_code",                                      :null => false
    t.integer  "du_type_code",                                        :null => false
    t.string   "du_type_other"
    t.integer  "du_ineligible_code",                                  :null => false
    t.integer  "du_access_code",                                      :null => false
    t.text     "duid_comment"
    t.string   "transaction_type",   :limit => 36
    t.string   "du_id",              :limit => 36,                    :null => false
    t.integer  "listing_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                  :default => false
    t.string   "ssu_id"
    t.string   "tsu_id"
  end

  create_table "emails", :force => true do |t|
    t.integer  "psu_code",                                              :null => false
    t.string   "email_id",                :limit => 36,                 :null => false
    t.integer  "person_id"
    t.string   "email",                   :limit => 100
    t.integer  "email_rank_code",                                       :null => false
    t.string   "email_rank_other"
    t.integer  "email_info_source_code",                                :null => false
    t.string   "email_info_source_other"
    t.date     "email_info_date"
    t.date     "email_info_update"
    t.integer  "email_type_code",                                       :null => false
    t.string   "email_type_other"
    t.integer  "email_share_code",                                      :null => false
    t.integer  "email_active_code",                                     :null => false
    t.text     "email_comment"
    t.string   "email_start_date",        :limit => 10
    t.date     "email_start_date_date"
    t.string   "email_end_date",          :limit => 10
    t.date     "email_end_date_date"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.integer  "lock_version",                           :default => 0
    t.integer  "provider_id"
    t.integer  "institute_id"
  end

  create_table "environmental_equipments", :force => true do |t|
    t.integer  "psu_code",                                        :null => false
    t.integer  "sample_receipt_shipping_center_id"
    t.string   "equipment_id",                      :limit => 36, :null => false
    t.integer  "equipment_type_code",                             :null => false
    t.string   "equipment_type_other"
    t.string   "serial_number",                     :limit => 50, :null => false
    t.string   "government_asset_tag_number",       :limit => 36
    t.string   "retired_date",                      :limit => 10
    t.integer  "retired_reason_code",                             :null => false
    t.string   "retired_reason_other"
    t.string   "transaction_type",                  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_type_order", :force => true do |t|
    t.integer "event_type_code", :null => false
  end

  add_index "event_type_order", ["event_type_code"], :name => "index_event_type_order_on_event_type_code", :unique => true

  create_table "events", :force => true do |t|
    t.integer  "psu_code",                                                                                       :null => false
    t.string   "event_id",                           :limit => 36,                                               :null => false
    t.integer  "participant_id"
    t.integer  "event_type_code",                                                                                :null => false
    t.string   "event_type_other"
    t.integer  "event_repeat_key"
    t.integer  "event_disposition"
    t.integer  "event_disposition_category_code",                                                                :null => false
    t.date     "event_start_date"
    t.string   "event_start_time"
    t.date     "event_end_date"
    t.string   "event_end_time"
    t.integer  "event_breakoff_code",                                                                            :null => false
    t.integer  "event_incentive_type_code",                                                                      :null => false
    t.decimal  "event_incentive_cash",                             :precision => 12, :scale => 2
    t.string   "event_incentive_noncash"
    t.text     "event_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scheduled_study_segment_identifier"
    t.integer  "lock_version",                                                                    :default => 0
    t.date     "psc_ideal_date"
  end

  create_table "fieldworks", :force => true do |t|
    t.string   "fieldwork_id",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "client_id"
    t.date     "end_date"
    t.date     "start_date"
    t.binary   "original_data"
    t.text     "generation_log"
    t.string   "latest_merge_status"
    t.integer  "latest_merge_id"
    t.string   "staff_id"
    t.text     "contact_links"
    t.text     "contacts"
    t.text     "event_templates"
    t.text     "events"
    t.string   "generated_for"
    t.text     "instrument_plans"
    t.text     "instruments"
    t.text     "people"
    t.text     "surveys"
  end

  add_index "fieldworks", ["fieldwork_id"], :name => "index_fieldworks_on_fieldwork_id", :unique => true

  create_table "household_person_links", :force => true do |t|
    t.integer  "psu_code",                        :null => false
    t.string   "person_hh_id",      :limit => 36, :null => false
    t.integer  "person_id",                       :null => false
    t.integer  "household_unit_id",               :null => false
    t.integer  "is_active_code",                  :null => false
    t.integer  "hh_rank_code",                    :null => false
    t.string   "hh_rank_other"
    t.string   "transaction_type",  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "household_units", :force => true do |t|
    t.integer  "psu_code",                                                      :null => false
    t.integer  "hh_status_code",                                                :null => false
    t.integer  "hh_eligibility_code",                                           :null => false
    t.integer  "hh_structure_code",                                             :null => false
    t.string   "hh_structure_other"
    t.text     "hh_comment"
    t.integer  "number_of_age_eligible_women"
    t.integer  "number_of_pregnant_women"
    t.integer  "number_of_pregnant_minors"
    t.integer  "number_of_pregnant_adults"
    t.integer  "number_of_pregnant_over49"
    t.string   "transaction_type",             :limit => 36
    t.string   "hh_id",                        :limit => 36,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                            :default => false
  end

  create_table "institution_person_links", :force => true do |t|
    t.integer  "psu_code",                               :null => false
    t.string   "person_institute_id",      :limit => 36, :null => false
    t.integer  "person_id",                              :null => false
    t.integer  "institution_id",                         :null => false
    t.integer  "is_active_code",                         :null => false
    t.integer  "institute_relation_code",                :null => false
    t.string   "institute_relation_other"
    t.string   "transaction_type",         :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "institution_person_links", ["institution_id", "person_id"], :name => "index_institution_person_links_on_institution_id_and_person_id", :unique => true

  create_table "institutions", :force => true do |t|
    t.integer  "psu_code",                                  :null => false
    t.string   "institute_id",                              :null => false
    t.integer  "institute_type_code",                       :null => false
    t.string   "institute_type_other"
    t.string   "institute_name"
    t.integer  "institute_relation_code",                   :null => false
    t.string   "institute_relation_other"
    t.integer  "institute_owner_code",                      :null => false
    t.string   "institute_owner_other"
    t.integer  "institute_size"
    t.integer  "institute_unit_code",                       :null => false
    t.string   "institute_unit_other"
    t.integer  "institute_info_source_code",                :null => false
    t.string   "institute_info_source_other"
    t.date     "institute_info_date"
    t.date     "institute_info_update"
    t.text     "institute_comment"
    t.string   "transaction_type",            :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
  end

  create_table "instruments", :force => true do |t|
    t.integer  "psu_code",                                              :null => false
    t.string   "instrument_id",            :limit => 36,                :null => false
    t.integer  "event_id"
    t.integer  "instrument_type_code",                                  :null => false
    t.string   "instrument_type_other"
    t.string   "instrument_version",       :limit => 36,                :null => false
    t.integer  "instrument_repeat_key",                  :default => 0, :null => false
    t.date     "instrument_start_date"
    t.string   "instrument_start_time"
    t.date     "instrument_end_date"
    t.string   "instrument_end_time"
    t.integer  "instrument_breakoff_code",                              :null => false
    t.integer  "instrument_status_code",                                :null => false
    t.integer  "instrument_mode_code",                                  :null => false
    t.string   "instrument_mode_other"
    t.integer  "instrument_method_code",                                :null => false
    t.integer  "supervisor_review_code",                                :null => false
    t.integer  "data_problem_code",                                     :null => false
    t.text     "instrument_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
    t.integer  "survey_id"
    t.integer  "lock_version",                           :default => 0
  end

  create_table "legacy_instrument_data_records", :force => true do |t|
    t.integer  "instrument_id",                   :null => false
    t.integer  "parent_record_id"
    t.string   "mdes_version",     :limit => 16,  :null => false
    t.string   "mdes_table_name",  :limit => 100, :null => false
    t.string   "public_id",        :limit => 36,  :null => false
    t.integer  "psu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "legacy_instrument_data_records", ["instrument_id"], :name => "idx_legacy_instrument_data_record_instrument"

  create_table "legacy_instrument_data_values", :force => true do |t|
    t.integer  "legacy_instrument_data_record_id",               :null => false
    t.string   "mdes_variable_name",               :limit => 50, :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "legacy_instrument_data_values", ["legacy_instrument_data_record_id"], :name => "idx_legacy_instrument_data_value_record"

  create_table "listing_units", :force => true do |t|
    t.integer  "psu_code",                                          :null => false
    t.string   "list_id",          :limit => 36,                    :null => false
    t.integer  "list_line"
    t.integer  "list_source_code",                                  :null => false
    t.text     "list_comment"
    t.string   "transaction_type", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                :default => false
    t.string   "ssu_id"
    t.string   "tsu_id"
  end

  create_table "mdes_version", :id => false, :force => true do |t|
    t.string "number", :limit => 10, :null => false
  end

  create_table "merges", :force => true do |t|
    t.integer  "fieldwork_id"
    t.text     "conflict_report"
    t.text     "log"
    t.text     "proposed_data"
    t.datetime "merged_at"
    t.datetime "crashed_at"
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "synced_at"
    t.string   "staff_id"
    t.string   "client_id"
    t.string   "username",        :null => false
  end

  create_table "ncs_codes", :force => true do |t|
    t.string   "list_name"
    t.string   "display_text"
    t.integer  "local_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ncs_codes", ["list_name"], :name => "idx_ncs_codes_list"
  add_index "ncs_codes", ["local_code", "list_name"], :name => "un_ncs_codes_code_and_list", :unique => true
  add_index "ncs_codes", ["local_code"], :name => "idx_ncs_codes_code"

  create_table "no_access_non_interview_reports", :force => true do |t|
    t.integer  "psu_code",                              :null => false
    t.string   "nir_no_access_id",        :limit => 36, :null => false
    t.integer  "non_interview_report_id"
    t.integer  "nir_no_access_code",                    :null => false
    t.string   "nir_no_access_other"
    t.string   "transaction_type",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_interview_provider_refusals", :force => true do |t|
    t.integer  "psu_code",                                :null => false
    t.string   "nir_provider_refusal_id",   :limit => 36, :null => false
    t.integer  "non_interview_provider_id"
    t.integer  "refusal_reason_pbs_code",                 :null => false
    t.string   "refusal_reason_pbs_other"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_interview_providers", :force => true do |t|
    t.integer  "psu_code",                                   :null => false
    t.string   "non_interview_provider_id",    :limit => 36, :null => false
    t.integer  "contact_id"
    t.integer  "provider_id"
    t.integer  "nir_type_provider_code",                     :null => false
    t.string   "nir_type_provider_other"
    t.integer  "nir_closed_info_code",                       :null => false
    t.string   "nir_closed_info_other"
    t.date     "when_closure"
    t.integer  "perm_closure_code",                          :null => false
    t.integer  "who_refused_code",                           :null => false
    t.string   "who_refused_other"
    t.integer  "refuser_strength_code",                      :null => false
    t.integer  "ref_action_provider_code",                   :null => false
    t.integer  "who_confirm_noprenatal_code",                :null => false
    t.string   "who_confirm_noprenatal_other"
    t.integer  "nir_moved_info_code",                        :null => false
    t.string   "nir_moved_info_other"
    t.date     "when_moved"
    t.integer  "perm_moved_code",                            :null => false
    t.text     "nir_pbs_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_interview_reports", :force => true do |t|
    t.integer  "psu_code",                                                                   :null => false
    t.string   "nir_id",                         :limit => 36,                               :null => false
    t.integer  "contact_id"
    t.text     "nir"
    t.integer  "dwelling_unit_id"
    t.integer  "person_id"
    t.integer  "nir_vacancy_information_code",                                               :null => false
    t.string   "nir_vacancy_information_other"
    t.integer  "nir_no_access_code",                                                         :null => false
    t.string   "nir_no_access_other"
    t.integer  "nir_access_attempt_code",                                                    :null => false
    t.string   "nir_access_attempt_other"
    t.integer  "nir_type_person_code",                                                       :null => false
    t.string   "nir_type_person_other"
    t.integer  "cog_inform_relation_code",                                                   :null => false
    t.string   "cog_inform_relation_other"
    t.text     "cog_disability_description"
    t.integer  "permanent_disability_code",                                                  :null => false
    t.integer  "deceased_inform_relation_code",                                              :null => false
    t.string   "deceased_inform_relation_other"
    t.integer  "year_of_death"
    t.integer  "state_of_death_code",                                                        :null => false
    t.integer  "who_refused_code",                                                           :null => false
    t.string   "who_refused_other"
    t.integer  "refuser_strength_code",                                                      :null => false
    t.integer  "refusal_action_code",                                                        :null => false
    t.text     "long_term_illness_description"
    t.integer  "permanent_long_term_code",                                                   :null => false
    t.integer  "reason_unavailable_code",                                                    :null => false
    t.string   "reason_unavailable_other"
    t.date     "date_available_date"
    t.string   "date_available",                 :limit => 10
    t.date     "date_moved_date"
    t.string   "date_moved",                     :limit => 10
    t.decimal  "moved_length_time",                            :precision => 6, :scale => 2
    t.integer  "moved_unit_code",                                                            :null => false
    t.integer  "moved_inform_relation_code",                                                 :null => false
    t.string   "moved_inform_relation_other"
    t.text     "nir_other"
    t.string   "transaction_type",               :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_authorization_forms", :force => true do |t|
    t.integer  "psu_code",                          :null => false
    t.string   "auth_form_id",        :limit => 36, :null => false
    t.integer  "participant_id"
    t.integer  "contact_id"
    t.integer  "provider_id"
    t.integer  "auth_form_type_code",               :null => false
    t.string   "auth_type_other"
    t.integer  "auth_status_code",                  :null => false
    t.string   "auth_status_other"
    t.string   "transaction_type",    :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_consent_samples", :force => true do |t|
    t.integer  "psu_code",                                    :null => false
    t.string   "participant_consent_sample_id", :limit => 36, :null => false
    t.integer  "participant_id"
    t.integer  "participant_consent_id"
    t.integer  "sample_consent_type_code",                    :null => false
    t.integer  "sample_consent_given_code",                   :null => false
    t.string   "transaction_type",              :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_consents", :force => true do |t|
    t.integer  "psu_code",                                                      :null => false
    t.string   "participant_consent_id",          :limit => 36,                 :null => false
    t.integer  "participant_id"
    t.string   "consent_version",                 :limit => 9
    t.date     "consent_expiration"
    t.integer  "consent_type_code",                                             :null => false
    t.integer  "consent_form_type_code",                                        :null => false
    t.integer  "consent_given_code",                                            :null => false
    t.date     "consent_date"
    t.integer  "consent_withdraw_code",                                         :null => false
    t.integer  "consent_withdraw_type_code",                                    :null => false
    t.integer  "consent_withdraw_reason_code",                                  :null => false
    t.date     "consent_withdraw_date"
    t.integer  "consent_language_code",                                         :null => false
    t.string   "consent_language_other"
    t.integer  "person_who_consented_id"
    t.integer  "who_consented_code",                                            :null => false
    t.integer  "person_wthdrw_consent_id"
    t.integer  "who_wthdrw_consent_code",                                       :null => false
    t.integer  "consent_translate_code",                                        :null => false
    t.text     "consent_comments"
    t.integer  "contact_id"
    t.integer  "reconsideration_script_use_code",                               :null => false
    t.string   "transaction_type",                :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "consent_reconsent_code",                        :default => -4, :null => false
    t.integer  "consent_reconsent_reason_code",                 :default => -4, :null => false
    t.string   "consent_reconsent_reason_other"
  end

  create_table "participant_high_intensity_state_transitions", :force => true do |t|
    t.integer  "participant_id"
    t.string   "event"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
  end

  add_index "participant_high_intensity_state_transitions", ["participant_id"], :name => "participant_high_intensity_state_idx"

  create_table "participant_low_intensity_state_transitions", :force => true do |t|
    t.integer  "participant_id"
    t.string   "event"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
  end

  add_index "participant_low_intensity_state_transitions", ["participant_id"], :name => "participant_low_intensity_state_idx"

  create_table "participant_person_links", :force => true do |t|
    t.integer  "psu_code",                                                  :null => false
    t.integer  "person_id",                                                 :null => false
    t.integer  "participant_id",                                            :null => false
    t.integer  "relationship_code",                                         :null => false
    t.string   "relationship_other"
    t.integer  "is_active_code",                                            :null => false
    t.string   "transaction_type",            :limit => 36
    t.string   "person_pid_id",               :limit => 36,                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.integer  "primary_caregiver_flag_code",               :default => -4, :null => false
  end

  create_table "participant_staff_relationships", :force => true do |t|
    t.integer "participant_id"
    t.string  "staff_id"
    t.boolean "primary"
  end

  add_index "participant_staff_relationships", ["participant_id"], :name => "index_participant_staff_relationships_on_participant_id"

  create_table "participant_visit_consents", :force => true do |t|
    t.integer  "psu_code",                                  :null => false
    t.string   "pid_visit_consent_id",        :limit => 36, :null => false
    t.integer  "participant_id"
    t.integer  "vis_consent_type_code",                     :null => false
    t.integer  "vis_consent_response_code",                 :null => false
    t.integer  "vis_language_code",                         :null => false
    t.string   "vis_language_other"
    t.integer  "vis_person_who_consented_id"
    t.integer  "vis_who_consented_code",                    :null => false
    t.integer  "vis_translate_code",                        :null => false
    t.text     "vis_comments"
    t.integer  "contact_id"
    t.string   "transaction_type",            :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_visit_records", :force => true do |t|
    t.integer  "psu_code",                                :null => false
    t.string   "rvis_id",                   :limit => 36, :null => false
    t.integer  "participant_id"
    t.integer  "rvis_language_code",                      :null => false
    t.string   "rvis_language_other"
    t.integer  "rvis_person_id"
    t.integer  "rvis_who_consented_code",                 :null => false
    t.integer  "rvis_translate_code",                     :null => false
    t.integer  "contact_id"
    t.datetime "time_stamp_1"
    t.datetime "time_stamp_2"
    t.integer  "rvis_sections_code",                      :null => false
    t.integer  "rvis_during_interv_code",                 :null => false
    t.integer  "rvis_during_bio_code",                    :null => false
    t.integer  "rvis_bio_cord_code",                      :null => false
    t.integer  "rvis_during_env_code",                    :null => false
    t.integer  "rvis_during_thanks_code",                 :null => false
    t.integer  "rvis_after_saq_code",                     :null => false
    t.integer  "rvis_reconsideration_code",               :null => false
    t.string   "transaction_type",          :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", :force => true do |t|
    t.integer  "psu_code",                                                   :null => false
    t.string   "p_id",                      :limit => 36,                    :null => false
    t.integer  "p_type_code",                                                :null => false
    t.string   "p_type_other"
    t.integer  "status_info_source_code",                                    :null => false
    t.string   "status_info_source_other"
    t.integer  "status_info_mode_code",                                      :null => false
    t.string   "status_info_mode_other"
    t.date     "status_info_date"
    t.integer  "enroll_status_code",                                         :null => false
    t.date     "enroll_date"
    t.integer  "pid_entry_code",                                             :null => false
    t.string   "pid_entry_other"
    t.integer  "pid_age_eligibility_code",                                   :null => false
    t.text     "pid_comment"
    t.string   "transaction_type",          :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                         :default => false
    t.boolean  "high_intensity",                          :default => false
    t.string   "low_intensity_state"
    t.string   "high_intensity_state"
    t.text     "enrollment_status_comment"
    t.boolean  "being_followed",                          :default => false
    t.integer  "lock_version",                            :default => 0
  end

  create_table "pbs_lists", :force => true do |t|
    t.integer  "psu_code",                                                                   :null => false
    t.string   "pbs_list_id",                    :limit => 36,                               :null => false
    t.integer  "provider_id"
    t.integer  "practice_num"
    t.integer  "in_out_frame_code"
    t.integer  "in_sample_code"
    t.integer  "substitute_provider_id"
    t.integer  "in_out_psu_code"
    t.integer  "mos"
    t.integer  "cert_flag_code"
    t.string   "stratum"
    t.integer  "sort_var1"
    t.integer  "sort_var2"
    t.integer  "sort_var3"
    t.integer  "frame_order"
    t.decimal  "selection_probability_location",               :precision => 7, :scale => 6
    t.decimal  "sampling_interval_woman",                      :precision => 4, :scale => 2
    t.decimal  "selection_probability_woman",                  :precision => 7, :scale => 6
    t.decimal  "selection_probability_overall",                :precision => 7, :scale => 6
    t.integer  "frame_completion_req_code",                                                  :null => false
    t.integer  "pr_recruitment_status_code"
    t.date     "pr_recruitment_start_date"
    t.date     "pr_cooperation_date"
    t.date     "pr_recruitment_end_date"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pbs_provider_roles", :force => true do |t|
    t.integer  "psu_code",                              :null => false
    t.string   "provider_role_pbs_id",    :limit => 36, :null => false
    t.integer  "provider_id"
    t.integer  "provider_role_pbs_code",                :null => false
    t.string   "provider_role_pbs_other"
    t.string   "transaction_type",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "psu_code",                                                        :null => false
    t.string   "person_id",                      :limit => 36,                    :null => false
    t.integer  "prefix_code",                                                     :null => false
    t.string   "first_name",                     :limit => 30
    t.string   "last_name",                      :limit => 30
    t.string   "middle_name",                    :limit => 30
    t.string   "maiden_name",                    :limit => 30
    t.integer  "suffix_code",                                                     :null => false
    t.string   "title",                          :limit => 5
    t.integer  "sex_code",                                                        :null => false
    t.integer  "age"
    t.integer  "age_range_code",                                                  :null => false
    t.string   "person_dob",                     :limit => 10
    t.date     "person_dob_date"
    t.integer  "deceased_code",                                                   :null => false
    t.integer  "ethnic_group_code",                                               :null => false
    t.integer  "language_code",                                                   :null => false
    t.string   "language_other"
    t.integer  "marital_status_code",                                             :null => false
    t.string   "marital_status_other"
    t.integer  "preferred_contact_method_code",                                   :null => false
    t.string   "preferred_contact_method_other"
    t.integer  "planned_move_code",                                               :null => false
    t.integer  "move_info_code",                                                  :null => false
    t.integer  "when_move_code",                                                  :null => false
    t.date     "date_move_date"
    t.string   "date_move",                      :limit => 7
    t.integer  "p_tracing_code",                                                  :null => false
    t.integer  "p_info_source_code",                                              :null => false
    t.string   "p_info_source_other"
    t.date     "p_info_date"
    t.date     "p_info_update"
    t.text     "person_comment"
    t.string   "transaction_type",               :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                              :default => false
    t.integer  "response_set_id"
    t.string   "role"
    t.integer  "language_new_code",                                               :null => false
    t.string   "language_new_other"
    t.integer  "lock_version",                                 :default => 0
  end

  create_table "person_provider_links", :force => true do |t|
    t.integer  "psu_code",                                   :null => false
    t.string   "person_provider_id",           :limit => 36, :null => false
    t.integer  "provider_id"
    t.integer  "person_id"
    t.integer  "is_active_code",                             :null => false
    t.integer  "provider_intro_outcome_code",                :null => false
    t.string   "provider_intro_outcome_other"
    t.string   "transaction_type",             :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sampled_person_code",                        :null => false
    t.integer  "pre_screening_status_code",                  :null => false
    t.string   "date_first_visit"
    t.date     "date_first_visit_date"
  end

  create_table "person_races", :force => true do |t|
    t.integer  "psu_code",                       :null => false
    t.string   "person_race_id",   :limit => 36, :null => false
    t.integer  "person_id",                      :null => false
    t.integer  "race_code",                      :null => false
    t.string   "race_other"
    t.string   "transaction_type", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "personnel_provider_links", :force => true do |t|
    t.integer  "provider_id"
    t.integer  "person_id"
    t.boolean  "primary_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ppg_details", :force => true do |t|
    t.integer  "psu_code",                                         :null => false
    t.string   "ppg_details_id",      :limit => 36,                :null => false
    t.integer  "participant_id"
    t.integer  "ppg_pid_status_code",                              :null => false
    t.integer  "ppg_first_code",                                   :null => false
    t.string   "orig_due_date",       :limit => 10
    t.string   "due_date_2",          :limit => 10
    t.string   "due_date_3",          :limit => 10
    t.string   "transaction_type",    :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.integer  "lock_version",                      :default => 0
  end

  create_table "ppg_status_histories", :force => true do |t|
    t.integer  "psu_code",                            :null => false
    t.string   "ppg_history_id",        :limit => 36, :null => false
    t.integer  "participant_id"
    t.integer  "ppg_status_code",                     :null => false
    t.string   "ppg_status_date",       :limit => 10
    t.integer  "ppg_info_source_code",                :null => false
    t.string   "ppg_info_source_other"
    t.integer  "ppg_info_mode_code",                  :null => false
    t.string   "ppg_info_mode_other"
    t.text     "ppg_comment"
    t.string   "transaction_type",      :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.date     "ppg_status_date_date"
  end

  add_index "ppg_status_histories", ["created_at"], :name => "index_ppg_status_histories_on_created_at"
  add_index "ppg_status_histories", ["updated_at"], :name => "index_ppg_status_histories_on_updated_at"

  create_table "provider_logistics", :force => true do |t|
    t.integer  "psu_code",                               :null => false
    t.string   "provider_logistics_id",    :limit => 36, :null => false
    t.integer  "provider_id"
    t.integer  "provider_logistics_code",                :null => false
    t.string   "provider_logistics_other"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "completion_date"
    t.text     "comment"
    t.boolean  "refusal"
  end

  create_table "provider_roles", :force => true do |t|
    t.integer  "psu_code",                              :null => false
    t.string   "provider_role_id",        :limit => 36, :null => false
    t.integer  "provider_id"
    t.integer  "provider_ncs_role_code",                :null => false
    t.string   "provider_ncs_role_other"
    t.string   "transaction_type",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "providers", :force => true do |t|
    t.integer  "psu_code",                                   :null => false
    t.string   "provider_id",                :limit => 36,   :null => false
    t.integer  "provider_type_code",                         :null => false
    t.string   "provider_type_other"
    t.integer  "provider_ncs_role_code",                     :null => false
    t.string   "provider_ncs_role_other"
    t.integer  "practice_info_code",                         :null => false
    t.integer  "practice_patient_load_code",                 :null => false
    t.integer  "practice_size_code",                         :null => false
    t.integer  "public_practice_code",                       :null => false
    t.integer  "provider_info_source_code",                  :null => false
    t.string   "provider_info_source_other"
    t.date     "provider_info_date"
    t.date     "provider_info_update"
    t.text     "provider_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_practice",              :limit => 100
    t.integer  "list_subsampling_code"
    t.integer  "proportion_weeks_sampled"
    t.integer  "proportion_days_sampled"
    t.string   "sampling_notes",             :limit => 1000
    t.integer  "institution_id"
  end

  create_table "question_groups", :force => true do |t|
    t.text     "text"
    t.text     "help_text"
    t.string   "reference_identifier"
    t.string   "data_export_identifier"
    t.string   "common_namespace"
    t.string   "common_identifier"
    t.string   "display_type"
    t.string   "custom_class"
    t.string   "custom_renderer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "api_id"
  end

  add_index "question_groups", ["api_id"], :name => "uq_question_groups_api_id", :unique => true

  create_table "questions", :force => true do |t|
    t.integer  "survey_section_id"
    t.integer  "question_group_id"
    t.text     "text"
    t.text     "short_text"
    t.text     "help_text"
    t.string   "pick"
    t.string   "reference_identifier"
    t.string   "data_export_identifier"
    t.string   "common_namespace"
    t.string   "common_identifier"
    t.integer  "display_order"
    t.string   "display_type"
    t.boolean  "is_mandatory"
    t.integer  "display_width"
    t.string   "custom_class"
    t.string   "custom_renderer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "correct_answer_id"
    t.string   "api_id"
  end

  add_index "questions", ["api_id"], :name => "uq_questions_api_id", :unique => true
  add_index "questions", ["display_order"], :name => "idx_questions_display_order"
  add_index "questions", ["question_group_id"], :name => "idx_questions_question_group_id"
  add_index "questions", ["reference_identifier"], :name => "idx_questions_reference_identifier"
  add_index "questions", ["survey_section_id"], :name => "idx_questions_survey_section_id"

  create_table "refusal_non_interview_reports", :force => true do |t|
    t.integer  "psu_code",                              :null => false
    t.string   "nir_refusal_id",          :limit => 36, :null => false
    t.integer  "non_interview_report_id"
    t.integer  "refusal_reason_code",                   :null => false
    t.string   "refusal_reason_other"
    t.string   "transaction_type",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "response_sets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.string   "access_code"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "processed_for_operational_data_extraction"
    t.integer  "instrument_id"
    t.string   "api_id"
    t.integer  "participant_id"
    t.integer  "participant_consent_id"
    t.integer  "non_interview_report_id"
  end

  add_index "response_sets", ["access_code"], :name => "response_sets_ac_idx", :unique => true
  add_index "response_sets", ["api_id"], :name => "uq_response_sets_api_id", :unique => true
  add_index "response_sets", ["instrument_id"], :name => "idx_response_sets_instrument_id"
  add_index "response_sets", ["participant_id"], :name => "idx_response_sets_participant_id"
  add_index "response_sets", ["survey_id"], :name => "idx_response_sets_survey_id"
  add_index "response_sets", ["user_id"], :name => "idx_response_sets_user_id"

  create_table "responses", :force => true do |t|
    t.integer  "response_set_id",                                 :null => false
    t.integer  "question_id"
    t.integer  "answer_id"
    t.datetime "datetime_value"
    t.integer  "integer_value"
    t.float    "float_value"
    t.string   "unit"
    t.text     "text_value"
    t.string   "string_value"
    t.string   "response_other"
    t.string   "response_group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_section_id"
    t.string   "source_mdes_table", :limit => 100
    t.string   "source_mdes_id",    :limit => 36
    t.string   "api_id"
    t.integer  "lock_version",                     :default => 0
  end

  add_index "responses", ["answer_id"], :name => "idx_responses_answer_id"
  add_index "responses", ["api_id"], :name => "uq_responses_api_id", :unique => true
  add_index "responses", ["question_id"], :name => "idx_responses_question_id"
  add_index "responses", ["response_set_id"], :name => "idx_responses_response_set_id"
  add_index "responses", ["survey_section_id"], :name => "index_responses_on_survey_section_id"

  create_table "sample_receipt_confirmations", :force => true do |t|
    t.integer  "psu_code",                                                                      :null => false
    t.integer  "sample_receipt_shipping_center_id"
    t.integer  "shipment_receipt_confirmed_code",                                               :null => false
    t.string   "shipper_id",                                                                    :null => false
    t.integer  "sample_shipping_id",                                                            :null => false
    t.datetime "shipment_receipt_datetime",                                                     :null => false
    t.integer  "shipment_condition_code",                                                       :null => false
    t.string   "shipment_damaged_reason"
    t.integer  "sample_id",                                                                     :null => false
    t.decimal  "sample_receipt_temp",                             :precision => 6, :scale => 2, :null => false
    t.integer  "sample_condition_code",                                                         :null => false
    t.string   "shipment_received_by",                                                          :null => false
    t.string   "transaction_type",                  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "staff_id",                                                                      :null => false
  end

  create_table "sample_receipt_shipping_centers", :force => true do |t|
    t.integer  "psu_code",                                        :null => false
    t.string   "sample_receipt_shipping_center_id", :limit => 36, :null => false
    t.string   "transaction_type",                  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "address_id"
  end

  create_table "sample_receipt_stores", :force => true do |t|
    t.integer  "psu_code",                                        :null => false
    t.integer  "sample_id",                                       :null => false
    t.integer  "sample_receipt_shipping_center_id"
    t.string   "staff_id",                          :limit => 36, :null => false
    t.integer  "sample_condition_code",                           :null => false
    t.string   "receipt_comment_other"
    t.datetime "receipt_datetime",                                :null => false
    t.integer  "cooler_temp_condition_code",                      :null => false
    t.integer  "environmental_equipment_id"
    t.datetime "placed_in_storage_datetime",                      :null => false
    t.integer  "storage_compartment_area_code",                   :null => false
    t.string   "storage_comment_other"
    t.datetime "removed_from_storage_datetime"
    t.integer  "temp_event_occurred_code",                        :null => false
    t.integer  "temp_event_action_code",                          :null => false
    t.string   "temp_event_action_other"
    t.string   "transaction_type",                  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_shippings", :force => true do |t|
    t.integer  "psu_code",                                        :null => false
    t.integer  "sample_receipt_shipping_center_id"
    t.string   "staff_id",                          :limit => 36, :null => false
    t.string   "shipper_id",                        :limit => 36, :null => false
    t.integer  "shipper_destination_code",                        :null => false
    t.string   "shipment_date",                     :limit => 10, :null => false
    t.integer  "shipment_coolant_code",                           :null => false
    t.string   "shipment_tracking_number",          :limit => 36, :null => false
    t.string   "shipment_issues_other"
    t.string   "staff_id_track",                    :limit => 36, :null => false
    t.integer  "sample_shipped_by_code",                          :null => false
    t.string   "transaction_type",                  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.string   "contact_phone",                     :limit => 30
    t.string   "carrier"
    t.string   "shipment_time",                     :limit => 5
  end

  create_table "sampled_persons_ineligibilities", :force => true do |t|
    t.integer  "provider_id"
    t.integer  "person_id"
    t.string   "sampled_persons_inelig_id", :limit => 36, :null => false
    t.string   "transaction_type",          :limit => 36
    t.integer  "psu_code",                                :null => false
    t.integer  "age_eligible_code"
    t.integer  "county_of_residence_code"
    t.integer  "pregnancy_eligible_code"
    t.integer  "first_prenatal_visit_code"
    t.integer  "ineligible_by_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "samples", :force => true do |t|
    t.string   "sample_id",              :limit => 36,                               :null => false
    t.integer  "instrument_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.string   "data_export_identifier"
    t.integer  "sample_shipping_id"
    t.decimal  "volume_amount",                        :precision => 6, :scale => 2
    t.string   "volume_unit",            :limit => 36
  end

  create_table "ship_specimens", :force => true do |t|
    t.integer  "specimen_id"
    t.integer  "specimen_shipping_id"
    t.decimal  "volume_amount",                      :precision => 6, :scale => 2
    t.string   "volume_unit",          :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specimen_equipments", :force => true do |t|
    t.integer  "psu_code",                                             :null => false
    t.integer  "specimen_processing_shipping_center_id"
    t.string   "equipment_id",                           :limit => 36, :null => false
    t.integer  "equipment_type_code",                                  :null => false
    t.string   "equipment_type_other"
    t.string   "serial_number",                          :limit => 50, :null => false
    t.string   "government_asset_tag_number",            :limit => 36
    t.string   "retired_date",                           :limit => 10
    t.integer  "retired_reason_code",                                  :null => false
    t.string   "retired_reason_other"
    t.string   "transaction_type",                       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specimen_pickups", :force => true do |t|
    t.integer  "psu_code",                                                                           :null => false
    t.integer  "specimen_processing_shipping_center_id"
    t.integer  "event_id"
    t.string   "staff_id",                               :limit => 50,                               :null => false
    t.datetime "specimen_pickup_datetime",                                                           :null => false
    t.integer  "specimen_pickup_comment_code",                                                       :null => false
    t.string   "specimen_pickup_comment_other"
    t.decimal  "specimen_transport_temperature",                       :precision => 6, :scale => 2
    t.string   "transaction_type",                       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "specimen_id",                            :limit => 36,                               :null => false
  end

  create_table "specimen_processing_shipping_centers", :force => true do |t|
    t.integer  "psu_code",                                             :null => false
    t.string   "specimen_processing_shipping_center_id", :limit => 36, :null => false
    t.string   "transaction_type",                       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "address_id"
  end

  create_table "specimen_receipt_confirmations", :force => true do |t|
    t.integer  "psu_code",                                                                           :null => false
    t.integer  "specimen_processing_shipping_center_id"
    t.integer  "shipment_receipt_confirmed_code",                                                    :null => false
    t.string   "shipper_id",                                                                         :null => false
    t.integer  "specimen_shipping_id",                                                               :null => false
    t.datetime "shipment_receipt_datetime",                                                          :null => false
    t.integer  "shipment_condition_code",                                                            :null => false
    t.string   "shipment_damaged_reason"
    t.integer  "specimen_id",                                                                        :null => false
    t.decimal  "specimen_receipt_temp",                                :precision => 6, :scale => 2, :null => false
    t.string   "specimen_condition"
    t.string   "shipment_received_by",                                                               :null => false
    t.string   "transaction_type",                       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "staff_id",                                                                           :null => false
  end

  create_table "specimen_receipts", :force => true do |t|
    t.integer  "psu_code",                                                                           :null => false
    t.integer  "specimen_id",                                                                        :null => false
    t.integer  "specimen_processing_shipping_center_id"
    t.string   "staff_id",                               :limit => 36,                               :null => false
    t.integer  "receipt_comment_code",                                                               :null => false
    t.string   "receipt_comment_other"
    t.datetime "receipt_datetime",                                                                   :null => false
    t.decimal  "cooler_temp",                                          :precision => 6, :scale => 2
    t.integer  "monitor_status_code"
    t.integer  "upper_trigger_code"
    t.integer  "upper_trigger_level_code"
    t.integer  "lower_trigger_cold_code"
    t.integer  "lower_trigger_ambient_code"
    t.integer  "specimen_storage_container_id",                                                      :null => false
    t.integer  "centrifuge_comment_code"
    t.string   "centrifuge_comment_other"
    t.string   "centrifuge_starttime",                   :limit => 5
    t.string   "centrifuge_endtime",                     :limit => 5
    t.string   "centrifuge_staff_id",                    :limit => 36
    t.integer  "specimen_equipment_id"
    t.string   "transaction_type",                       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "centrifuge_temp",                                      :precision => 6, :scale => 2
  end

  create_table "specimen_shippings", :force => true do |t|
    t.integer  "psu_code",                                             :null => false
    t.integer  "specimen_processing_shipping_center_id"
    t.string   "staff_id",                               :limit => 36, :null => false
    t.string   "shipper_id",                             :limit => 36, :null => false
    t.string   "shipper_destination",                    :limit => 3,  :null => false
    t.string   "shipment_date",                          :limit => 10, :null => false
    t.integer  "shipment_temperature_code",                            :null => false
    t.string   "shipment_tracking_number",               :limit => 36, :null => false
    t.integer  "shipment_receipt_confirmed_code",                      :null => false
    t.datetime "shipment_receipt_datetime"
    t.integer  "shipment_issues_code",                                 :null => false
    t.string   "shipment_issues_other"
    t.string   "transaction_type",                       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.string   "contact_phone",                          :limit => 30
    t.string   "carrier"
    t.string   "shipment_time",                          :limit => 5
  end

  create_table "specimen_storage_containers", :force => true do |t|
    t.string   "storage_container_id", :limit => 36, :null => false
    t.integer  "specimen_shipping_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specimen_storages", :force => true do |t|
    t.integer  "psu_code",                                                                           :null => false
    t.integer  "specimen_processing_shipping_center_id"
    t.integer  "specimen_storage_container_id",                                                      :null => false
    t.datetime "placed_in_storage_datetime"
    t.string   "staff_id",                               :limit => 36,                               :null => false
    t.integer  "specimen_equipment_id"
    t.integer  "master_storage_unit_code",                                                           :null => false
    t.string   "storage_comment",                                                                    :null => false
    t.string   "storage_comment_other"
    t.datetime "removed_from_storage_datetime"
    t.string   "temp_event_starttime",                   :limit => 5
    t.string   "temp_event_endtime",                     :limit => 5
    t.decimal  "temp_event_low_temp",                                  :precision => 6, :scale => 2
    t.decimal  "temp_event_high_temp",                                 :precision => 6, :scale => 2
    t.string   "transaction_type",                       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "master_storage_unit_id"
  end

  create_table "specimens", :force => true do |t|
    t.string   "specimen_id",            :limit => 36, :null => false
    t.integer  "specimen_pickup_id"
    t.integer  "instrument_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.string   "data_export_identifier"
  end

  create_table "survey_sections", :force => true do |t|
    t.integer  "survey_id"
    t.string   "title"
    t.text     "description"
    t.string   "reference_identifier"
    t.string   "data_export_identifier"
    t.string   "common_namespace"
    t.string   "common_identifier"
    t.integer  "display_order"
    t.string   "custom_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_sections", ["display_order"], :name => "idx_survey_sections_display_order"

  create_table "surveys", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "access_code"
    t.string   "reference_identifier"
    t.string   "data_export_identifier"
    t.string   "common_namespace"
    t.string   "common_identifier"
    t.datetime "active_at"
    t.datetime "inactive_at"
    t.string   "css_url"
    t.string   "custom_class"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
    t.string   "api_id"
    t.integer  "survey_version",                       :default => 0
    t.string   "instrument_version",     :limit => 36
    t.integer  "instrument_type"
  end

  add_index "surveys", ["access_code", "survey_version"], :name => "surveys_access_code_survey_version_idx", :unique => true
  add_index "surveys", ["api_id"], :name => "uq_surveys_api_id", :unique => true
  add_index "surveys", ["display_order"], :name => "idx_surveys_display_order"
  add_index "surveys", ["title"], :name => "index_surveys_on_title"

  create_table "telephones", :force => true do |t|
    t.integer  "psu_code",                                             :null => false
    t.string   "phone_id",                :limit => 36,                :null => false
    t.integer  "person_id"
    t.integer  "phone_info_source_code",                               :null => false
    t.string   "phone_info_source_other"
    t.date     "phone_info_date"
    t.date     "phone_info_update"
    t.string   "phone_nbr",               :limit => 10
    t.string   "phone_ext",               :limit => 5
    t.integer  "phone_type_code",                                      :null => false
    t.string   "phone_type_other"
    t.integer  "phone_rank_code",                                      :null => false
    t.string   "phone_rank_other"
    t.integer  "phone_landline_code",                                  :null => false
    t.integer  "phone_share_code",                                     :null => false
    t.integer  "cell_permission_code",                                 :null => false
    t.integer  "text_permission_code",                                 :null => false
    t.text     "phone_comment"
    t.string   "phone_start_date",        :limit => 10
    t.date     "phone_start_date_date"
    t.string   "phone_end_date",          :limit => 10
    t.date     "phone_end_date_date"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_set_id"
    t.integer  "provider_id"
    t.integer  "institute_id"
    t.integer  "lock_version",                          :default => 0
  end

  create_table "vacant_non_interview_reports", :force => true do |t|
    t.integer  "psu_code",                              :null => false
    t.string   "nir_vacant_id",           :limit => 36, :null => false
    t.integer  "non_interview_report_id"
    t.integer  "nir_vacant_code",                       :null => false
    t.string   "nir_vacant_other"
    t.string   "transaction_type",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "validation_conditions", :force => true do |t|
    t.integer  "validation_id"
    t.string   "rule_key"
    t.string   "operator"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.datetime "datetime_value"
    t.integer  "integer_value"
    t.float    "float_value"
    t.string   "unit"
    t.text     "text_value"
    t.string   "string_value"
    t.string   "response_other"
    t.string   "regexp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "validations", :force => true do |t|
    t.integer  "answer_id"
    t.string   "rule"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  add_foreign_key "addresses", "dwelling_units", :name => "addresses_dwelling_units_fk"
  add_foreign_key "addresses", "people", :name => "addresses_people_fk"

  add_foreign_key "contact_links", "contacts", :name => "contact_links_contact_fk"
  add_foreign_key "contact_links", "events", :name => "contact_links_events_fk"
  add_foreign_key "contact_links", "instruments", :name => "contact_links_instruments_fk"
  add_foreign_key "contact_links", "people", :name => "contact_links_people_fk"

  add_foreign_key "dwelling_household_links", "dwelling_units", :name => "dwelling_household_links_dwelling_units_fk"
  add_foreign_key "dwelling_household_links", "household_units", :name => "dwelling_household_links_household_units_fk"

  add_foreign_key "dwelling_units", "listing_units", :name => "dwelling_units_listing_units_fk"

  add_foreign_key "emails", "people", :name => "emails_people_fk"

  add_foreign_key "events", "participants", :name => "events_participants_fk"

  add_foreign_key "household_person_links", "household_units", :name => "household_person_links_household_units_fk"
  add_foreign_key "household_person_links", "people", :name => "household_person_links_people_fk"

  add_foreign_key "instruments", "events", :name => "instruments_events_fk"
  add_foreign_key "instruments", "people", :name => "instruments_people_fk"
  add_foreign_key "instruments", "surveys", :name => "instruments_surveys_fk"

  add_foreign_key "legacy_instrument_data_records", "instruments", :name => "fk_legacy_instrument_data_record_instrument"
  add_foreign_key "legacy_instrument_data_records", "legacy_instrument_data_records", :name => "fk_legacy_instrument_data_record_parent_record", :column => "parent_record_id"

  add_foreign_key "legacy_instrument_data_values", "legacy_instrument_data_records", :name => "fk_legacy_instrument_data_value_record"

  add_foreign_key "merges", "fieldworks", :name => "merges_fieldworks_fk"

  add_foreign_key "participant_authorization_forms", "contacts", :name => "participant_authorization_forms_contacts_fk"
  add_foreign_key "participant_authorization_forms", "participants", :name => "participant_authorization_forms_participants_fk"

  add_foreign_key "participant_consent_samples", "participant_consents", :name => "participant_consent_samples_participant_consents_fk"
  add_foreign_key "participant_consent_samples", "participants", :name => "participant_consent_samples_participants_fk"

  add_foreign_key "participant_consents", "contacts", :name => "participant_consents_contacts_fk"
  add_foreign_key "participant_consents", "participants", :name => "participant_consents_participants_fk"
  add_foreign_key "participant_consents", "people", :name => "participant_consents_person_consented_fk", :column => "person_who_consented_id"
  add_foreign_key "participant_consents", "people", :name => "participant_consents_person_withdrew_fk", :column => "person_wthdrw_consent_id"

  add_foreign_key "participant_high_intensity_state_transitions", "participants", :name => "participant_high_intensity_state_transitions_participants_fk"

  add_foreign_key "participant_low_intensity_state_transitions", "participants", :name => "participant_low_intensity_state_transitions_participants_fk"

  add_foreign_key "participant_person_links", "participants", :name => "participant_person_links_participants_fk"
  add_foreign_key "participant_person_links", "people", :name => "participant_person_links_people_fk"

  add_foreign_key "participant_staff_relationships", "participants", :name => "participant_staff_relationships_participants_fk"

  add_foreign_key "participant_visit_consents", "contacts", :name => "participant_visit_consents_contacts_fk"
  add_foreign_key "participant_visit_consents", "participants", :name => "participant_visit_consents_participants_fk"
  add_foreign_key "participant_visit_consents", "people", :name => "participant_visit_consents_people_fk", :column => "vis_person_who_consented_id"

  add_foreign_key "participant_visit_records", "contacts", :name => "participant_visit_records_contacts_fk"
  add_foreign_key "participant_visit_records", "participants", :name => "participant_visit_records_participants_fk"
  add_foreign_key "participant_visit_records", "people", :name => "participant_visit_records_people_fk", :column => "rvis_person_id"

  add_foreign_key "person_races", "people", :name => "person_races_people_fk"

  add_foreign_key "ppg_details", "participants", :name => "ppg_details_participants_fk"

  add_foreign_key "ppg_status_histories", "participants", :name => "ppg_status_histories_participants_fk"

  add_foreign_key "response_sets", "instruments", :name => "response_sets_instruments_fk"
  add_foreign_key "response_sets", "people", :name => "response_sets_people_fk", :column => "user_id"

  add_foreign_key "responses", "response_sets", :name => "response_set_id_to_response_sets_fk"

  add_foreign_key "sample_receipt_confirmations", "sample_shippings", :name => "sample_receipt_confirmations_sample_shippings_fk"
  add_foreign_key "sample_receipt_confirmations", "samples", :name => "sample_receipt_confirmations_samples_fk"

  add_foreign_key "sample_receipt_shipping_centers", "addresses", :name => "sample_receipt_shipping_centers_addresses_fk"

  add_foreign_key "sample_receipt_stores", "samples", :name => "sample_receipt_stores_samples_fk"

  add_foreign_key "samples", "sample_shippings", :name => "samples_sample_shippings_fk"

  add_foreign_key "specimen_processing_shipping_centers", "addresses", :name => "specimen_processing_shipping_centers_addresses_fk"

  add_foreign_key "specimen_receipt_confirmations", "specimen_shippings", :name => "specimen_receipt_confirmations_specimen_shippings_fk"
  add_foreign_key "specimen_receipt_confirmations", "specimens", :name => "specimen_receipt_confirmations_specimens_fk"

  add_foreign_key "specimen_receipts", "specimen_storage_containers", :name => "specimen_receipts_specimen_storage_containers_fk"
  add_foreign_key "specimen_receipts", "specimens", :name => "specimen_receipts_specimens_fk"

  add_foreign_key "specimen_storage_containers", "specimen_shippings", :name => "specimen_storage_containers_specimen_shippings_fk"

  add_foreign_key "specimen_storages", "specimen_storage_containers", :name => "specimen_storages_specimen_storage_containers_fk"

  add_foreign_key "telephones", "people", :name => "telephones_people_fk"

end
