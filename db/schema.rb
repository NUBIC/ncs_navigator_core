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

ActiveRecord::Schema.define(:version => 20110714212419) do

  create_table "dwelling_household_links", :force => true do |t|
    t.integer  "psu_code",                        :null => false
    t.integer  "is_active_code",                  :null => false
    t.integer  "dwelling_unit_id",                :null => false
    t.integer  "household_unit_id",               :null => false
    t.integer  "du_rank_code",                    :null => false
    t.string   "du_rank_other"
    t.string   "transaction_type",  :limit => 36
    t.binary   "hh_du_id",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dwelling_units", :force => true do |t|
    t.integer  "psu_code",                         :null => false
    t.integer  "duplicate_du_code",                :null => false
    t.integer  "missed_du_code",                   :null => false
    t.integer  "du_type_code",                     :null => false
    t.string   "du_type_other"
    t.integer  "du_ineligible_code",               :null => false
    t.integer  "du_access_code",                   :null => false
    t.text     "duid_comment"
    t.string   "transaction_type",   :limit => 36
    t.binary   "du_id",                            :null => false
    t.integer  "listing_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "household_person_links", :force => true do |t|
    t.string   "psu_code",          :limit => 36, :null => false
    t.integer  "person_id",                       :null => false
    t.integer  "household_unit_id",               :null => false
    t.integer  "is_active_code",                  :null => false
    t.integer  "hh_rank_code",                    :null => false
    t.string   "hh_rank_other"
    t.binary   "person_hh_id",                    :null => false
    t.string   "transaction_type",  :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "household_units", :force => true do |t|
    t.integer  "psu_code",                                   :null => false
    t.integer  "hh_status_code",                             :null => false
    t.integer  "hh_eligibility_code",                        :null => false
    t.integer  "hh_structure_code",                          :null => false
    t.string   "hh_structure_other"
    t.text     "hh_comment"
    t.integer  "number_of_age_eligible_women"
    t.integer  "number_of_pregnant_women"
    t.integer  "number_of_pregnant_minors"
    t.integer  "number_of_pregnant_adults"
    t.integer  "number_of_pregnant_over49"
    t.string   "transaction_type",             :limit => 36
    t.binary   "hh_id",                                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_units", :force => true do |t|
    t.integer  "psu_code",                       :null => false
    t.integer  "list_line"
    t.integer  "list_source_code",               :null => false
    t.text     "list_comment"
    t.string   "transaction_type", :limit => 36
    t.binary   "list_id",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "psu_code",                 :limit => 36, :null => false
    t.integer  "person_id",                              :null => false
    t.integer  "p_type_code",                            :null => false
    t.string   "p_type_other"
    t.integer  "status_info_source_code",                :null => false
    t.string   "status_info_source_other"
    t.integer  "status_info_mode_code",                  :null => false
    t.string   "status_info_mode_other"
    t.date     "status_info_date"
    t.integer  "enroll_status_code",                     :null => false
    t.date     "enroll_date"
    t.integer  "pid_entry_code",                         :null => false
    t.string   "pid_entry_other"
    t.integer  "pid_age_eligibility_code",               :null => false
    t.text     "pid_comment"
    t.string   "transaction_type",         :limit => 36
    t.binary   "p_id",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "psu_code",                       :limit => 36, :null => false
    t.integer  "prefix_code",                                  :null => false
    t.string   "first_name",                     :limit => 30
    t.string   "last_name",                      :limit => 30
    t.string   "middle_name",                    :limit => 30
    t.string   "maiden_name",                    :limit => 30
    t.integer  "suffix_code",                                  :null => false
    t.string   "title",                          :limit => 5
    t.integer  "sex_code",                                     :null => false
    t.integer  "age"
    t.integer  "age_range_code",                               :null => false
    t.string   "person_dob",                     :limit => 10
    t.date     "date_of_birth"
    t.integer  "deceased_code",                                :null => false
    t.integer  "ethnic_group_code",                            :null => false
    t.integer  "language_code",                                :null => false
    t.string   "language_other"
    t.integer  "marital_status_code",                          :null => false
    t.string   "marital_status_other"
    t.integer  "preferred_contact_method_code",                :null => false
    t.string   "preferred_contact_method_other"
    t.integer  "planned_move_code",                            :null => false
    t.integer  "move_info_code",                               :null => false
    t.integer  "when_move_code",                               :null => false
    t.date     "moving_date"
    t.string   "date_move"
    t.integer  "p_tracing_code",                               :null => false
    t.integer  "p_info_source_code",                           :null => false
    t.string   "p_info_source_other"
    t.date     "p_info_date"
    t.date     "p_info_update"
    t.text     "person_comment"
    t.string   "transaction_type",               :limit => 36
    t.binary   "person_id",                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "person_races", :force => true do |t|
    t.string   "psu_code",         :limit => 36, :null => false
    t.integer  "person_id",                      :null => false
    t.integer  "race_code",                      :null => false
    t.string   "race_other"
    t.string   "transaction_type", :limit => 36
    t.binary   "person_race_id",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
