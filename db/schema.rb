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

ActiveRecord::Schema.define(:version => 20110613210555) do

  create_table "dwelling_household_links", :force => true do |t|
    t.integer  "psu_code"
    t.integer  "is_active_code"
    t.integer  "dwelling_unit_id"
    t.integer  "household_unit_id"
    t.integer  "du_rank_code"
    t.string   "du_rank_other"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dwelling_units", :force => true do |t|
    t.integer  "psu_code"
    t.integer  "duplicate_du_code"
    t.integer  "missed_du_code"
    t.integer  "du_type_code"
    t.string   "du_type_other"
    t.integer  "du_ineligible_code"
    t.integer  "du_access_code"
    t.text     "duid_comment"
    t.string   "transaction_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "household_units", :force => true do |t|
    t.integer  "psu_code"
    t.integer  "hh_status_code"
    t.integer  "hh_eligibilty_code"
    t.integer  "number_of_age_eligible_women"
    t.integer  "number_of_pregnant_women"
    t.integer  "number_of_pregnant_minors"
    t.integer  "number_of_pregnant_adults"
    t.integer  "number_of_pregnant_over49"
    t.integer  "hh_structure_code"
    t.string   "hh_structure_other"
    t.text     "hh_comment"
    t.string   "transaction_type"
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

end
