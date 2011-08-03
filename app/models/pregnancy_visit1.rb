class PregnancyVisit1 < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :pv1_id

  belongs_to :dwelling_unit
  belongs_to :participant
  belongs_to :event
  belongs_to :instrument
  
  belongs_to :psu,                      :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :recruit_type,             :conditions => "list_name = 'RECRUIT_TYPE_CL1'",        :foreign_key => :recruit_type_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_type,               :conditions => "list_name = 'EVENT_TYPE_CL1'",          :foreign_key => :event_type_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_type,          :conditions => "list_name = 'INSTRUMENT_TYPE_CL1'",     :foreign_key => :instrument_type_code,          :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :name_confirm,             :conditions => "list_name = 'CONFIRM_TYPE_CL8'",        :foreign_key => :name_confirm_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :dob_confirm,              :conditions => "list_name = 'CONFIRM_TYPE_CL8'",        :foreign_key => :dob_confirm_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :age_eligibility,          :conditions => "list_name = 'AGE_ELIGIBLE_CL1'",        :foreign_key => :age_eligibility_code,          :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pregnant,                 :conditions => "list_name = 'PREGNANCY_STATUS_CL1'",    :foreign_key => :pregnant_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :loss_info,                :conditions => "list_name = 'CONFIRM_TYPE_CL6'",        :foreign_key => :loss_info_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :know_date,                :conditions => "list_name = 'DUE_DATE_SOURCE_CL2'",     :foreign_key => :know_date_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :knew_date,                :conditions => "list_name = 'DATE_GIVEN_CL1'",          :foreign_key => :knew_date_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :home_test,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :home_test_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :multiple_gestation,       :conditions => "list_name = 'GESTATION_TYPE_CL1'",      :foreign_key => :multiple_gestation_code,       :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :birth_plan,               :conditions => "list_name = 'BIRTH_PLACE_PLAN_CL1'",    :foreign_key => :birth_plan_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :b_state,                  :conditions => "list_name = 'STATE_CL2'",               :foreign_key => :b_state_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pn_vitamin,               :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :pn_vitamin_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :preg_vitamin,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :preg_vitamin_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :diabetes_1,               :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :diabetes_1_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :highbp_preg,              :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :highbp_preg_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :urine,                    :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :urine_code,                    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :preeclamp,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :preeclamp_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :early_labor,              :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :early_labor_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :anemia,                   :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :anemia_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :nausea,                   :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :nausea_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :kidney,                   :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :kidney_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rh_disease,               :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :rh_disease_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :group_b,                  :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :group_b_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :herpes,                   :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :herpes_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :vaginosis,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :vaginosis_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :oth_condition,            :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :oth_condition_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :health,                   :conditions => "list_name = 'HEALTH_STATUS_CL2'",       :foreign_key => :health_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :asthma,                   :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :asthma_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :highbp_notpreg,           :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :highbp_notpreg_code,           :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :diabetes_notpreg,         :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :diabetes_notpreg_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :diabetes_2,               :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :diabetes_2_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :diabetes_3,               :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :diabetes_3_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :thyroid_1,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :thyroid_1_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :thyroid_2,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :thyroid_2_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hlth_care,                :conditions => "list_name = 'PREVENTATIVE_CARE_PLACE_CL2'",  :foreign_key => :hlth_care_code,           :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :insure,                   :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :insure_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ins_employ,               :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :ins_employ_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ins_medicaid,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :ins_medicaid_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ins_tricare,              :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :ins_tricare_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ins_ihs,                  :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :ins_ihs_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ins_medicare,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :ins_medicare_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ins_oth,                  :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :ins_oth_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :recent_move,              :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :recent_move_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :own_home,                 :conditions => "list_name = 'HOME_OWNERSHIP_CL1'",      :foreign_key => :own_home_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :age_home,                 :conditions => "list_name = 'AGE_HOME_CL1'",            :foreign_key => :age_home_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :length_reside_unit,       :conditions => "list_name = 'TIME_UNIT_CL2'",           :foreign_key => :length_reside_unit_code,       :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :main_heat,                :conditions => "list_name = 'HEAT_TYPE_CL2'",           :foreign_key => :main_heat_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :cooling,                  :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :cooling_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :water_drink,              :conditions => "list_name = 'WATER_TYPE_CL2'",          :foreign_key => :water_drink_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :water_cook,               :conditions => "list_name = 'WATER_TYPE_CL2'",          :foreign_key => :water_cook_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :water,                    :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :water_code,                    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :mold,                     :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :mold_code,                     :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :prenovate,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :prenovate_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pdecorate,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :pdecorate_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pets,                     :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :pets_code,                     :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :educ,                     :conditions => "list_name = 'EDUCATION_LEVEL_CL1'",     :foreign_key => :educ_code,                     :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :working,                  :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :working_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :shift_work,               :conditions => "list_name = 'CONFIRM_TYPE_CL13'",       :foreign_key => :shift_work_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pump_gas,                 :conditions => "list_name = 'PUMP_GAS_FREQUENCY_CL1'",  :foreign_key => :pump_gas_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :maristat,                 :conditions => "list_name = 'MARITAL_STATUS_CL2'",      :foreign_key => :maristat_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :sp_educ,                  :conditions => "list_name = 'EDUCATION_LEVEL_CL1'",     :foreign_key => :sp_educ_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :sp_ethnicity,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :sp_ethnicity_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :income,                   :conditions => "list_name = 'INCOME_RANGE_CL1'",        :foreign_key => :income_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :comm_email,               :conditions => "list_name = 'CONFIRM_TYPE_CL12'",       :foreign_key => :comm_email_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :have_email,               :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :have_email_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :email_2,                  :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :email_2_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :email_3,                  :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :email_3_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :comm_cell,                :conditions => "list_name = 'CONFIRM_TYPE_CL12'",       :foreign_key => :comm_cell_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :cell_phone_1,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :cell_phone_1_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :cell_phone_2,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :cell_phone_2_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :cell_phone_3,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :cell_phone_3_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :cell_phone_4,             :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :cell_phone_4_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :comm_contact,             :conditions => "list_name = 'CONFIRM_TYPE_CL12'",       :foreign_key => :comm_contact_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_1,                :conditions => "list_name = 'CONFIRM_TYPE_CL7'",        :foreign_key => :contact_1_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_relate_1,         :conditions => "list_name = 'CONTACT_RELATIONSHIP_CL2'",:foreign_key => :contact_relate_1_code,       :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :c_state_1,                :conditions => "list_name = 'STATE_CL2'",               :foreign_key => :c_state_1_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_relate_2,         :conditions => "list_name = 'CONTACT_RELATIONSHIP_CL2'",:foreign_key => :contact_relate_2_code,       :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :c_state_2,                :conditions => "list_name = 'STATE_CL2'",               :foreign_key => :c_state_2_code,                :class_name => 'NcsCode', :primary_key => :local_code

  
  
end
