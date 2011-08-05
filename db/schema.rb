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

ActiveRecord::Schema.define(:version => 20110805151543) do

  create_table "addresses", :force => true do |t|
    t.integer  "psu_code",                                 :null => false
    t.binary   "address_id",                               :null => false
    t.integer  "person_id"
    t.integer  "dwelling_unit_id",                         :null => false
    t.integer  "address_rank_code",                        :null => false
    t.string   "address_rank_other"
    t.integer  "address_info_source_code",                 :null => false
    t.string   "address_info_source_other"
    t.integer  "address_info_mode_code",                   :null => false
    t.string   "address_info_mode_other"
    t.date     "address_info_date"
    t.date     "address_info_update"
    t.string   "address_start_date",        :limit => 10
    t.date     "address_start_date_date"
    t.string   "address_end_date",          :limit => 10
    t.date     "address_end_date_date"
    t.integer  "address_type_code",                        :null => false
    t.string   "address_type_other"
    t.integer  "address_description_code",                 :null => false
    t.string   "address_description_other"
    t.string   "address_one",               :limit => 100
    t.string   "address_two",               :limit => 100
    t.string   "unit",                      :limit => 10
    t.string   "city",                      :limit => 50
    t.integer  "state_code",                               :null => false
    t.string   "zip",                       :limit => 5
    t.string   "zip4",                      :limit => 4
    t.text     "address_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "contact_links", :force => true do |t|
    t.integer  "psu_code",                       :null => false
    t.binary   "contact_link_id",                :null => false
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
    t.integer  "psu_code",                                                            :null => false
    t.binary   "contact_id",                                                          :null => false
    t.integer  "contact_disposition"
    t.integer  "contact_type_code",                                                   :null => false
    t.string   "contact_type_other"
    t.string   "contact_date",            :limit => 10
    t.date     "contact_date_date"
    t.string   "contact_start_time"
    t.string   "contact_end_time"
    t.integer  "contact_language_code",                                               :null => false
    t.string   "contact_language_other"
    t.integer  "contact_interpret_code",                                              :null => false
    t.string   "contact_interpret_other"
    t.integer  "contact_location_code",                                               :null => false
    t.string   "contact_location_other"
    t.integer  "contact_private_code",                                                :null => false
    t.string   "contact_private_detail"
    t.decimal  "contact_distance",                      :precision => 6, :scale => 2
    t.integer  "who_contacted_code",                                                  :null => false
    t.string   "who_contacted_other"
    t.text     "contact_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dependencies", :force => true do |t|
    t.integer  "question_id"
    t.integer  "question_group_id"
    t.string   "rule"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "dwelling_household_links", :force => true do |t|
    t.integer  "psu_code",                        :null => false
    t.binary   "hh_du_id",                        :null => false
    t.integer  "dwelling_unit_id",                :null => false
    t.integer  "household_unit_id",               :null => false
    t.integer  "is_active_code",                  :null => false
    t.integer  "du_rank_code",                    :null => false
    t.string   "du_rank_other"
    t.string   "transaction_type",  :limit => 36
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
    t.binary   "du_id",                                               :null => false
    t.integer  "listing_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                  :default => false
  end

  create_table "emails", :force => true do |t|
    t.integer  "psu_code",                               :null => false
    t.binary   "email_id",                               :null => false
    t.integer  "person_id"
    t.string   "email",                   :limit => 100
    t.integer  "email_rank_code",                        :null => false
    t.string   "email_rank_other"
    t.integer  "email_info_source_code",                 :null => false
    t.string   "email_info_source_other"
    t.date     "email_info_date"
    t.date     "email_info_update"
    t.integer  "email_type_code",                        :null => false
    t.string   "email_type_other"
    t.integer  "email_share_code",                       :null => false
    t.integer  "email_active_code",                      :null => false
    t.text     "email_comment"
    t.string   "email_start_date",        :limit => 10
    t.date     "email_start_date_date"
    t.string   "email_end_date",          :limit => 10
    t.date     "email_end_date_date"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "psu_code",                                                      :null => false
    t.binary   "event_id",                                                      :null => false
    t.integer  "participant_id"
    t.integer  "event_type_code",                                               :null => false
    t.string   "event_type_other"
    t.integer  "event_repeat_key"
    t.integer  "event_disposition"
    t.integer  "event_disposition_category_code",                               :null => false
    t.date     "event_start_date"
    t.string   "event_start_time"
    t.date     "event_end_date"
    t.string   "event_end_time"
    t.integer  "event_breakoff_code",                                           :null => false
    t.integer  "event_incentive_type_code",                                     :null => false
    t.decimal  "event_incentive_cash",            :precision => 3, :scale => 2
    t.string   "event_incentive_noncash"
    t.text     "event_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "household_person_links", :force => true do |t|
    t.string   "psu_code",          :limit => 36, :null => false
    t.binary   "person_hh_id",                    :null => false
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
    t.binary   "hh_id",                                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                            :default => false
  end

  create_table "instruments", :force => true do |t|
    t.integer  "psu_code",                               :null => false
    t.binary   "instrument_id",                          :null => false
    t.integer  "event_id"
    t.integer  "instrument_type_code",                   :null => false
    t.string   "instrument_type_other"
    t.string   "instrument_version",       :limit => 36, :null => false
    t.integer  "instrument_repeat_key"
    t.date     "instrument_start_date"
    t.string   "instrument_start_time"
    t.date     "instrument_end_date"
    t.string   "instrument_end_time"
    t.integer  "instrument_breakoff_code",               :null => false
    t.integer  "instrument_status_code",                 :null => false
    t.integer  "instrument_mode_code",                   :null => false
    t.string   "instrument_mode_other"
    t.integer  "instrument_method_code",                 :null => false
    t.integer  "supervisor_review_code",                 :null => false
    t.integer  "data_problem_code",                      :null => false
    t.text     "instrument_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_units", :force => true do |t|
    t.integer  "psu_code",                                          :null => false
    t.binary   "list_id",                                           :null => false
    t.integer  "list_line"
    t.integer  "list_source_code",                                  :null => false
    t.text     "list_comment"
    t.string   "transaction_type", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                :default => false
  end

  create_table "ncs_codes", :force => true do |t|
    t.string   "list_name"
    t.string   "list_description"
    t.string   "display_text"
    t.integer  "local_code"
    t.string   "global_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_person_links", :force => true do |t|
    t.string   "psu_code",           :limit => 36, :null => false
    t.integer  "person_id",                        :null => false
    t.integer  "participant_id",                   :null => false
    t.integer  "relationship_code",                :null => false
    t.string   "relationship_other"
    t.integer  "is_active_code",                   :null => false
    t.string   "transaction_type",   :limit => 36
    t.binary   "person_pid_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", :force => true do |t|
    t.string   "psu_code",                 :limit => 36,                    :null => false
    t.binary   "p_id",                                                      :null => false
    t.integer  "person_id",                                                 :null => false
    t.integer  "p_type_code",                                               :null => false
    t.string   "p_type_other"
    t.integer  "status_info_source_code",                                   :null => false
    t.string   "status_info_source_other"
    t.integer  "status_info_mode_code",                                     :null => false
    t.string   "status_info_mode_other"
    t.date     "status_info_date"
    t.integer  "enroll_status_code",                                        :null => false
    t.date     "enroll_date"
    t.integer  "pid_entry_code",                                            :null => false
    t.string   "pid_entry_other"
    t.integer  "pid_age_eligibility_code",                                  :null => false
    t.text     "pid_comment"
    t.string   "transaction_type",         :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "being_processed",                        :default => false
  end

  create_table "people", :force => true do |t|
    t.string   "psu_code",                       :limit => 36,                    :null => false
    t.binary   "person_id",                                                       :null => false
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
  end

  create_table "person_races", :force => true do |t|
    t.string   "psu_code",         :limit => 36, :null => false
    t.binary   "person_race_id",                 :null => false
    t.integer  "person_id",                      :null => false
    t.integer  "race_code",                      :null => false
    t.string   "race_other"
    t.string   "transaction_type", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ppg_details", :force => true do |t|
    t.string   "psu_code",            :limit => 36, :null => false
    t.binary   "ppg_details_id",                    :null => false
    t.integer  "participant_id"
    t.integer  "ppg_pid_status_code",               :null => false
    t.integer  "ppg_first_code",                    :null => false
    t.string   "orig_due_date",       :limit => 10
    t.string   "due_date_2",          :limit => 10
    t.string   "due_date_3",          :limit => 10
    t.string   "transaction_type",    :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ppg_status_histories", :force => true do |t|
    t.string   "psu_code",              :limit => 36, :null => false
    t.binary   "ppg_history_id",                      :null => false
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
  end

  create_table "pregnancy_visit1s", :force => true do |t|
    t.string   "psu_code",                :limit => 36,                                :null => false
    t.binary   "pv1_id",                                                               :null => false
    t.integer  "recruit_type_code",                                                    :null => false
    t.integer  "dwelling_unit_id"
    t.integer  "participant_id"
    t.integer  "event_id"
    t.integer  "event_type_code",                                                      :null => false
    t.integer  "event_repeat_key"
    t.integer  "instrument_id"
    t.integer  "instrument_type_code",                                                 :null => false
    t.decimal  "instrument_version",                     :precision => 3, :scale => 1
    t.integer  "instrument_repeat_key"
    t.integer  "name_confirm_code",                                                    :null => false
    t.string   "r_fname",                 :limit => 30
    t.string   "r_lname",                 :limit => 30
    t.integer  "dob_confirm_code",                                                     :null => false
    t.string   "person_dob",              :limit => 10
    t.integer  "age_eligibility_code",                                                 :null => false
    t.integer  "pregnant_code",                                                        :null => false
    t.integer  "loss_info_code",                                                       :null => false
    t.string   "due_date",                :limit => 10
    t.integer  "know_date_code",                                                       :null => false
    t.string   "date_period",             :limit => 10
    t.integer  "knew_date_code",                                                       :null => false
    t.integer  "home_test_code",                                                       :null => false
    t.integer  "multiple_gestation_code",                                              :null => false
    t.integer  "birth_plan_code",                                                      :null => false
    t.string   "birth_place_code",        :limit => 100
    t.integer  "b_address_id"
    t.string   "b_address_1",             :limit => 100
    t.string   "b_address_2",             :limit => 100
    t.string   "b_city",                  :limit => 50
    t.integer  "b_state_code",                                                         :null => false
    t.string   "b_zipcode",               :limit => 5
    t.integer  "pn_vitamin_code",                                                      :null => false
    t.integer  "preg_vitamin_code",                                                    :null => false
    t.string   "date_visit",              :limit => 10
    t.integer  "diabetes_1_code",                                                      :null => false
    t.integer  "highbp_preg_code",                                                     :null => false
    t.integer  "urine_code",                                                           :null => false
    t.integer  "preeclamp_code",                                                       :null => false
    t.integer  "early_labor_code",                                                     :null => false
    t.integer  "anemia_code",                                                          :null => false
    t.integer  "nausea_code",                                                          :null => false
    t.integer  "kidney_code",                                                          :null => false
    t.integer  "rh_disease_code",                                                      :null => false
    t.integer  "group_b_code",                                                         :null => false
    t.integer  "herpes_code",                                                          :null => false
    t.integer  "vaginosis_code",                                                       :null => false
    t.integer  "oth_condition_code",                                                   :null => false
    t.string   "condition_oth"
    t.integer  "health_code",                                                          :null => false
    t.integer  "height_ft"
    t.integer  "ht_inch"
    t.integer  "weight"
    t.integer  "asthma_code",                                                          :null => false
    t.integer  "highbp_notpreg_code",                                                  :null => false
    t.integer  "diabetes_notpreg_code",                                                :null => false
    t.integer  "diabetes_2_code",                                                      :null => false
    t.integer  "diabetes_3_code",                                                      :null => false
    t.integer  "thyroid_1_code",                                                       :null => false
    t.integer  "thyroid_2_code",                                                       :null => false
    t.integer  "hlth_care_code",                                                       :null => false
    t.integer  "insure_code",                                                          :null => false
    t.integer  "ins_employ_code",                                                      :null => false
    t.integer  "ins_medicaid_code",                                                    :null => false
    t.integer  "ins_tricare_code",                                                     :null => false
    t.integer  "ins_ihs_code",                                                         :null => false
    t.integer  "ins_medicare_code",                                                    :null => false
    t.integer  "ins_oth_code",                                                         :null => false
    t.integer  "recent_move_code",                                                     :null => false
    t.integer  "own_home_code",                                                        :null => false
    t.string   "own_home_oth"
    t.integer  "age_home_code",                                                        :null => false
    t.integer  "length_reside"
    t.integer  "length_reside_unit_code",                                              :null => false
    t.integer  "main_heat_code",                                                       :null => false
    t.string   "main_heat_oth"
    t.string   "heat2_oth"
    t.integer  "cooling_code",                                                         :null => false
    t.string   "cool_oth"
    t.integer  "water_drink_code",                                                     :null => false
    t.string   "water_drink_oth"
    t.integer  "water_cook_code",                                                      :null => false
    t.string   "water_cook_oth"
    t.integer  "water_code",                                                           :null => false
    t.integer  "mold_code",                                                            :null => false
    t.string   "room_mold_oth"
    t.integer  "prenovate_code",                                                       :null => false
    t.string   "prenovate_room_oth"
    t.integer  "pdecorate_code",                                                       :null => false
    t.string   "pdecorate_room_oth"
    t.integer  "pets_code",                                                            :null => false
    t.string   "pet_type_oth"
    t.integer  "educ_code",                                                            :null => false
    t.integer  "working_code",                                                         :null => false
    t.integer  "hours"
    t.integer  "shift_work_code",                                                      :null => false
    t.string   "commute_oth"
    t.integer  "commute_time"
    t.string   "local_trav_oth"
    t.integer  "pump_gas_code",                                                        :null => false
    t.integer  "maristat_code",                                                        :null => false
    t.integer  "sp_educ_code",                                                         :null => false
    t.integer  "sp_ethnicity_code",                                                    :null => false
    t.string   "sp_race_oth"
    t.integer  "hh_members"
    t.integer  "num_child"
    t.integer  "income_code",                                                          :null => false
    t.integer  "comm_email_code",                                                      :null => false
    t.integer  "have_email_code",                                                      :null => false
    t.integer  "email_2_code",                                                         :null => false
    t.integer  "email_3_code",                                                         :null => false
    t.string   "email",                   :limit => 100
    t.integer  "comm_cell_code",                                                       :null => false
    t.integer  "cell_phone_1_code",                                                    :null => false
    t.integer  "cell_phone_2_code",                                                    :null => false
    t.integer  "cell_phone_3_code",                                                    :null => false
    t.integer  "cell_phone_4_code",                                                    :null => false
    t.string   "cell_phone",              :limit => 10
    t.integer  "comm_contact_code",                                                    :null => false
    t.integer  "contact_1_code",                                                       :null => false
    t.string   "contact_fname_1",         :limit => 30
    t.string   "contact_lname_1",         :limit => 30
    t.integer  "contact_relate_1_code",                                                :null => false
    t.string   "contact_relate1_oth"
    t.string   "contact_addr_1",          :limit => 100
    t.integer  "c_addr1_id"
    t.string   "c_addr1_1",               :limit => 100
    t.string   "c_addr2_1",               :limit => 100
    t.string   "c_unit_1",                :limit => 10
    t.string   "c_city_1",                :limit => 50
    t.integer  "c_state_1_code",                                                       :null => false
    t.string   "c_zipcode_1",             :limit => 5
    t.string   "c_zip4_1",                :limit => 4
    t.string   "contact_phone_1",         :limit => 10
    t.string   "contact_2",               :limit => 60
    t.string   "contact_fname_2",         :limit => 30
    t.string   "contact_lname_2",         :limit => 30
    t.integer  "contact_relate_2_code",                                                :null => false
    t.string   "contact_relate2_oth"
    t.string   "contact_addr_2",          :limit => 100
    t.integer  "c_addr2_id"
    t.string   "c_addr2_2",               :limit => 100
    t.string   "c_unit_2",                :limit => 10
    t.string   "c_city_2",                :limit => 50
    t.integer  "c_state_2_code",                                                       :null => false
    t.string   "c_zipcode_2",             :limit => 5
    t.string   "c_zip4_2",                :limit => 4
    t.string   "contact_phone_2",         :limit => 10
    t.string   "transaction_type",        :limit => 36
    t.datetime "time_stamp_1"
    t.datetime "time_stamp_2"
    t.datetime "time_stamp_3"
    t.datetime "time_stamp_4"
    t.datetime "time_stamp_5"
    t.datetime "time_stamp_6"
    t.datetime "time_stamp_7"
    t.datetime "time_stamp_8"
    t.datetime "time_stamp_9"
    t.datetime "time_stamp_10"
    t.datetime "time_stamp_11"
    t.datetime "time_stamp_12"
    t.datetime "time_stamp_13"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

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

  create_table "response_sets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.string   "access_code"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "response_sets", ["access_code"], :name => "response_sets_ac_idx", :unique => true

  create_table "responses", :force => true do |t|
    t.integer  "response_set_id"
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
  end

  add_index "responses", ["survey_section_id"], :name => "index_responses_on_survey_section_id"

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
  end

  add_index "surveys", ["access_code"], :name => "surveys_ac_idx", :unique => true

  create_table "telephones", :force => true do |t|
    t.integer  "psu_code",                              :null => false
    t.binary   "phone_id",                              :null => false
    t.integer  "person_id"
    t.integer  "phone_info_source_code",                :null => false
    t.string   "phone_info_source_other"
    t.date     "phone_info_date"
    t.date     "phone_info_update"
    t.string   "phone_nbr",               :limit => 10
    t.string   "phone_ext",               :limit => 5
    t.integer  "phone_type_code",                       :null => false
    t.string   "phone_type_other"
    t.integer  "phone_rank_code",                       :null => false
    t.string   "phone_rank_other"
    t.integer  "phone_landline_code",                   :null => false
    t.integer  "phone_share_code",                      :null => false
    t.integer  "cell_permission_code",                  :null => false
    t.integer  "text_permission_code",                  :null => false
    t.text     "phone_comment"
    t.string   "phone_start_date",        :limit => 10
    t.date     "phone_start_date_date"
    t.string   "phone_end_date",          :limit => 10
    t.date     "phone_end_date_date"
    t.string   "transaction_type"
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

end
