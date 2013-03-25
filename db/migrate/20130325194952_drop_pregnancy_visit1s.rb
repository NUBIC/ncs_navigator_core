class DropPregnancyVisit1s < ActiveRecord::Migration
  def up
    drop_table :pregnancy_visit1s
  end

  def down
    create_table :pregnancy_visit1s do |t|
      t.string :psu_code,                 :null => false, :limit => 36
      t.binary :pv1_id,                   :null => false
      t.integer :recruit_type_code,       :null => false
      t.references :dwelling_unit
      t.references :participant
      t.references :event
      t.integer :event_type_code,         :null => false
      t.integer :event_repeat_key
      t.references :instrument
      t.integer :instrument_type_code,    :null => false
      t.decimal :instrument_version,      :precision => 3, :scale => 1
      t.integer :instrument_repeat_key
      t.integer :name_confirm_code,       :null => false
      t.string :r_fname,                  :limit => 30
      t.string :r_lname,                  :limit => 30
      t.integer :dob_confirm_code,        :null => false
      t.string :person_dob,               :limit => 10
      t.integer :age_eligibility_code,    :null => false
      t.integer :pregnant_code,           :null => false
      t.integer :loss_info_code,          :null => false
      t.string :due_date,                 :limit => 10
      t.integer :know_date_code,          :null => false
      t.string :date_period,              :limit => 10
      t.integer :knew_date_code,          :null => false
      t.integer :home_test_code,          :null => false
      t.integer :multiple_gestation_code, :null => false
      t.integer :birth_plan_code,         :null => false
      t.string :birth_place_code,         :limit => 100
      t.integer :b_address_id
      t.string :b_address_1,              :limit => 100
      t.string :b_address_2,              :limit => 100
      t.string :b_city,                   :limit => 50
      t.integer :b_state_code,            :null => false
      t.string :b_zipcode,                :limit => 5
      t.integer :pn_vitamin_code,         :null => false
      t.integer :preg_vitamin_code,       :null => false
      t.string :date_visit,               :limit => 10
      t.integer :diabetes_1_code,         :null => false
      t.integer :highbp_preg_code,        :null => false
      t.integer :urine_code,              :null => false
      t.integer :preeclamp_code,          :null => false
      t.integer :early_labor_code,        :null => false
      t.integer :anemia_code,             :null => false
      t.integer :nausea_code,             :null => false
      t.integer :kidney_code,             :null => false
      t.integer :rh_disease_code,         :null => false
      t.integer :group_b_code,            :null => false
      t.integer :herpes_code,             :null => false
      t.integer :vaginosis_code,          :null => false
      t.integer :oth_condition_code,      :null => false
      t.string :condition_oth
      t.integer :health_code,             :null => false
      t.integer :height_ft
      t.integer :ht_inch
      t.integer :weight
      t.integer :asthma_code,             :null => false
      t.integer :highbp_notpreg_code,     :null => false
      t.integer :diabetes_notpreg_code,   :null => false
      t.integer :diabetes_2_code,         :null => false
      t.integer :diabetes_3_code,         :null => false
      t.integer :thyroid_1_code,          :null => false
      t.integer :thyroid_2_code,          :null => false
      t.integer :hlth_care_code,          :null => false
      t.integer :insure_code,             :null => false
      t.integer :ins_employ_code,         :null => false
      t.integer :ins_medicaid_code,       :null => false
      t.integer :ins_tricare_code,        :null => false
      t.integer :ins_ihs_code,            :null => false
      t.integer :ins_medicare_code,       :null => false
      t.integer :ins_oth_code,            :null => false
      t.integer :recent_move_code,        :null => false
      t.integer :own_home_code,           :null => false
      t.string :own_home_oth
      t.integer :age_home_code,           :null => false
      t.integer :length_reside
      t.integer :length_reside_unit_code, :null => false
      t.integer :main_heat_code,          :null => false
      t.string :main_heat_oth
      t.string :heat2_oth
      t.integer :cooling_code,            :null => false
      t.string :cool_oth
      t.integer :water_drink_code,        :null => false
      t.string :water_drink_oth
      t.integer :water_cook_code,         :null => false
      t.string :water_cook_oth
      t.integer :water_code,              :null => false
      t.integer :mold_code,               :null => false
      t.string :room_mold_oth
      t.integer :prenovate_code,          :null => false
      t.string :prenovate_room_oth
      t.integer :pdecorate_code,          :null => false
      t.string :pdecorate_room_oth
      t.integer :pets_code,               :null => false
      t.string :pet_type_oth
      t.integer :educ_code,               :null => false
      t.integer :working_code,            :null => false
      t.integer :hours
      t.integer :shift_work_code,         :null => false
      t.string :commute_oth
      t.integer :commute_time
      t.string :local_trav_oth
      t.integer :pump_gas_code,           :null => false
      t.integer :maristat_code,           :null => false
      t.integer :sp_educ_code,            :null => false
      t.integer :sp_ethnicity_code,       :null => false
      t.string :sp_race_oth
      t.integer :hh_members
      t.integer :num_child
      t.integer :income_code,             :null => false
      t.integer :comm_email_code,         :null => false
      t.integer :have_email_code,         :null => false
      t.integer :email_2_code,            :null => false
      t.integer :email_3_code,            :null => false
      t.string :email,                    :limit => 100
      t.integer :comm_cell_code,          :null => false
      t.integer :cell_phone_1_code,       :null => false
      t.integer :cell_phone_2_code,       :null => false
      t.integer :cell_phone_3_code,       :null => false
      t.integer :cell_phone_4_code,       :null => false
      t.string :cell_phone,               :limit => 10
      t.integer :comm_contact_code,       :null => false
      t.integer :contact_1_code,          :null => false
      t.string :contact_fname_1,          :limit => 30
      t.string :contact_lname_1,          :limit => 30
      t.integer :contact_relate_1_code,   :null => false
      t.string :contact_relate1_oth
      t.string :contact_addr_1,           :limit => 100
      t.integer :c_addr1_id
      t.string :c_addr1_1,                :limit => 100
      t.string :c_addr2_1,                :limit => 100
      t.string :c_unit_1,                 :limit => 10
      t.string :c_city_1,                 :limit => 50
      t.integer :c_state_1_code,          :null => false
      t.string :c_zipcode_1,              :limit => 5
      t.string :c_zip4_1,                 :limit => 4
      t.string :contact_phone_1,          :limit => 10
      t.string :contact_2,                :limit => 60
      t.string :contact_fname_2,          :limit => 30
      t.string :contact_lname_2,          :limit => 30
      t.integer :contact_relate_2_code,   :null => false
      t.string :contact_relate2_oth
      t.string :contact_addr_2,           :limit => 100

      t.integer :c_addr2_id
      t.string :c_addr2_1,                :limit => 100
      t.string :c_addr2_2,                :limit => 100
      t.string :c_unit_2,                 :limit => 10
      t.string :c_city_2,                 :limit => 50
      t.integer :c_state_2_code,          :null => false
      t.string :c_zipcode_2,              :limit => 5
      t.string :c_zip4_2,                 :limit => 4
      t.string :contact_phone_2,          :limit => 10
      t.string :transaction_type,         :limit => 36

      t.datetime :time_stamp_1
      t.datetime :time_stamp_2
      t.datetime :time_stamp_3
      t.datetime :time_stamp_4
      t.datetime :time_stamp_5
      t.datetime :time_stamp_6
      t.datetime :time_stamp_7
      t.datetime :time_stamp_8
      t.datetime :time_stamp_9
      t.datetime :time_stamp_10
      t.datetime :time_stamp_11
      t.datetime :time_stamp_12
      t.datetime :time_stamp_13

      t.timestamps
    end
  end
end
