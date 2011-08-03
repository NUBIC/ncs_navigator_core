# == Schema Information
# Schema version: 20110727185512
#
# Table name: ncs_codes
#
#  id               :integer         not null, primary key
#  list_name        :string(255)
#  list_description :string(255)
#  display_text     :string(255)
#  local_code       :integer
#  global_code      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class NcsCode < ActiveRecord::Base

  validates_presence_of :list_name, :display_text, :local_code
  
  ATTRIBUTE_MAPPING = { 
    
    ### person
    :psu_code                       => "PSU_CL1",
    :prefix_code                    => "NAME_PREFIX_CL1",
    :suffix_code                    => "NAME_SUFFIX_CL1",
    :sex_code                       => "GENDER_CL1",
    :age_range_code                 => "AGE_RANGE_CL1",
    :deceased_code                  => "CONFIRM_TYPE_CL2",
    :ethnic_group_code              => "ETHNICITY_CL1",
    :language_code                  => "LANGUAGE_CL2",
    :marital_status_code            => "MARITAL_STATUS_CL1",
    :preferred_contact_method_code  => "CONTACT_TYPE_CL1",
    :planned_move_code              => "CONFIRM_TYPE_CL1",
    :move_info_code                 => "MOVING_PLAN_CL1",
    :when_move_code                 => "CONFIRM_TYPE_CL4",
    :p_tracing_code                 => "CONFIRM_TYPE_CL2",
    :p_info_source_code             => "INFORMATION_SOURCE_CL4",
    
    
    ### person_race
    # :psu_code               => "PSU_CL1",             # already referenced
    :race_code => "RACE_CL1",
    
    
    ### participant
    # :psu_code               => "PSU_CL1",             # already referenced
    :p_type_code              => "PARTICIPANT_TYPE_CL1",
    :status_info_source_code  => "INFORMATION_SOURCE_CL4",
    :status_info_mode_code    => "CONTACT_TYPE_CL1",
    :enroll_status_code       => "CONFIRM_TYPE_CL2",
    :pid_entry_code           => "STUDY_ENTRY_METHOD_CL1",
    :pid_age_eligibility_code => "AGE_ELIGIBLE_CL2",
    
    
    ### participant_person_link
    # :psu_code               => "PSU_CL1",             # already referenced
    :relationship_code => "PERSON_PARTCPNT_RELTNSHP_CL1",
    :is_active_code    => "CONFIRM_TYPE_CL2",
    
    
    ### listing_unit
    # :psu_code               => "PSU_CL1",             # already referenced
    :list_source_code  => "LISTING_SOURCE_CL1",
    
    
    ### dwelling_unit
    # :psu_code               => "PSU_CL1",             # already referenced
    :duplicate_du_code  => "CONFIRM_TYPE_CL2",
    :missed_du_code     => "CONFIRM_TYPE_CL2",
    :du_type_code       => "RESIDENCE_TYPE_CL2",
    :du_ineligible_code => "CONFIRM_TYPE_CL3",
    :du_access_code     => "CONFIRM_TYPE_CL2",
    
    
    ### household_unit
    # :psu_code               => "PSU_CL1",             # already referenced
    :hh_status_code      => "CONFIRM_TYPE_CL2",
    :hh_eligibility_code => "HOUSEHOLD_ELIGIBILITY_CL2",
    :hh_structure_code   => "RESIDENCE_TYPE_CL2",
    
    
    ### dwelling_household_link
    # :psu_code               => "PSU_CL1",             # already referenced
    # :is_active_code         => "CONFIRM_TYPE_CL2",    # already referenced
    :du_rank_code   => "COMMUNICATION_RANK_CL1",
    
    
    ### household_person_link
    # :psu_code               => "PSU_CL1",             # already referenced
    # :is_active_code         => "CONFIRM_TYPE_CL2",
    :hh_rank_code   => "COMMUNICATION_RANK_CL1",
    
    
    ### address
    # :psu_code               => "PSU_CL1",             # already referenced
    :address_rank_code        => 'COMMUNICATION_RANK_CL1',
    :address_info_source_code => 'INFORMATION_SOURCE_CL1',
    :address_info_mode_code   => 'CONTACT_TYPE_CL1',
    :address_type_code        => 'ADDRESS_CATEGORY_CL1',
    :address_description_code => 'RESIDENCE_TYPE_CL1',
    :state_code               => 'STATE_CL1',
    
    
    ### telephone
    # :psu_code               => "PSU_CL1",             # already referenced
    :phone_info_source        => 'INFORMATION_SOURCE_CL2',
    :phone_type               => 'PHONE_TYPE_CL1',
    :phone_rank               => 'COMMUNICATION_RANK_CL1',
    :phone_landline           => 'CONFIRM_TYPE_CL2',
    :phone_share              => 'CONFIRM_TYPE_CL2',
    :cell_permission          => 'CONFIRM_TYPE_CL2',
    :text_permission          => 'CONFIRM_TYPE_CL2',
    
    
    ### email
    # :psu_code               => "PSU_CL1",             # already referenced
    :email_info_source        => 'INFORMATION_SOURCE_CL2',
    :email_type               => 'EMAIL_TYPE_CL1',
    :email_rank               => 'COMMUNICATION_RANK_CL1',
    :email_share              => 'CONFIRM_TYPE_CL2',
    :email_active             => 'CONFIRM_TYPE_CL2',
    
    
    ### instrument 
    # :psu_code               => "PSU_CL1",             # already referenced
    :instrument_type          => 'INSTRUMENT_TYPE_CL1',
    :instrument_breakoff      => 'CONFIRM_TYPE_CL2',
    :instrument_status        => 'INSTRUMENT_STATUS_CL1',
    :instrument_mode          => 'INSTRUMENT_ADMIN_MODE_CL1',
    :instrument_method        => 'INSTRUMENT_ADMIN_METHOD_CL1',
    :supervisor_review        => 'CONFIRM_TYPE_CL2',
    :data_problem             => 'CONFIRM_TYPE_CL2',

    
    ### event
    # :psu_code                   => "PSU_CL1",             # already referenced
    :event_type                   => 'EVENT_TYPE_CL1',
    :event_disposition_category   => 'EVENT_DSPSTN_CAT_CL1',
    :event_breakoff               => 'CONFIRM_TYPE_CL2',
    :event_incentive_type         => 'INCENTIVE_TYPE_CL1',
    
    
    ### contact_link
    # :psu_code               => "PSU_CL1",             # already referenced
    
    
    ### contact 
    # :psu_code               => "PSU_CL1",             # already referenced
    :contact_type             => 'CONTACT_TYPE_CL1',
    :contact_language         => 'LANGUAGE_CL2',
    :contact_interpret        => 'TRANSLATION_METHOD_CL3',
    :contact_location         => 'CONTACT_LOCATION_CL1',
    :contact_private          => 'CONFIRM_TYPE_CL2',
    :who_contacted            => 'CONTACTED_PERSON_CL1',
    
    
    ###             ###
    #   Instruments   #
    ###             ###
    
    
    ### pregnancy_visit_1
    :recruit_type             => 'RECRUIT_TYPE_CL1',
    :event_type               => 'EVENT_TYPE_CL1',
    :instrument_type          => 'INSTRUMENT_TYPE_CL1',
    :name_confirm             => 'CONFIRM_TYPE_CL8',
    :dob_confirm              => 'CONFIRM_TYPE_CL8',
    :age_eligibility          => 'AGE_ELIGIBLE_CL1',
    :pregnant                 => 'PREGNANCY_STATUS_CL1',
    :loss_info                => 'CONFIRM_TYPE_CL6',
    :know_date                => 'DUE_DATE_SOURCE_CL2',
    :knew_date                => 'DATE_GIVEN_CL1',
    :home_test                => 'CONFIRM_TYPE_CL7',
    :multiple_gestation       => 'GESTATION_TYPE_CL1',
    :birth_plan               => 'BIRTH_PLACE_PLAN_CL1',
    :b_state                  => 'STATE_CL2',
    :pn_vitamin               => 'CONFIRM_TYPE_CL7',
    :preg_vitamin             => 'CONFIRM_TYPE_CL7',
    :diabetes_1               => 'CONFIRM_TYPE_CL7',
    :highbp_preg              => 'CONFIRM_TYPE_CL7',
    :urine                    => 'CONFIRM_TYPE_CL7',
    :preeclamp                => 'CONFIRM_TYPE_CL7',
    :early_labor              => 'CONFIRM_TYPE_CL7',
    :anemia                   => 'CONFIRM_TYPE_CL7',
    :nausea                   => 'CONFIRM_TYPE_CL7',
    :kidney                   => 'CONFIRM_TYPE_CL7',
    :rh_disease               => 'CONFIRM_TYPE_CL7',
    :group_b                  => 'CONFIRM_TYPE_CL7',
    :herpes                   => 'CONFIRM_TYPE_CL7',
    :vaginosis                => 'CONFIRM_TYPE_CL7',
    :oth_condition            => 'CONFIRM_TYPE_CL7',
    :health                   => 'HEALTH_STATUS_CL2',
    :asthma                   => 'CONFIRM_TYPE_CL7',
    :highbp_notpreg           => 'CONFIRM_TYPE_CL7',
    :diabetes_notpreg         => 'CONFIRM_TYPE_CL7',
    :diabetes_2               => 'CONFIRM_TYPE_CL7',
    :diabetes_3               => 'CONFIRM_TYPE_CL7',
    :thyroid_1                => 'CONFIRM_TYPE_CL7',
    :thyroid_2                => 'CONFIRM_TYPE_CL7',
    :hlth_care                => 'PREVENTATIVE_CARE_PLACE_CL2',
    :insure                   => 'CONFIRM_TYPE_CL7',
    :ins_employ               => 'CONFIRM_TYPE_CL7',
    :ins_medicaid             => 'CONFIRM_TYPE_CL7',
    :ins_tricare              => 'CONFIRM_TYPE_CL7',
    :ins_ihs                  => 'CONFIRM_TYPE_CL7',
    :ins_medicare             => 'CONFIRM_TYPE_CL7',
    :ins_oth                  => 'CONFIRM_TYPE_CL7',
    :recent_move              => 'CONFIRM_TYPE_CL7',
    :own_home                 => 'HOME_OWNERSHIP_CL1',
    :age_home                 => 'AGE_HOME_CL1',
    :length_reside_unit       => 'TIME_UNIT_CL2',
    :main_heat                => 'HEAT_TYPE_CL2',
    :cooling                  => 'CONFIRM_TYPE_CL7',
    :water_drink              => 'WATER_TYPE_CL2',
    :water_cook               => 'WATER_TYPE_CL2',
    :water                    => 'CONFIRM_TYPE_CL7',
    :mold                     => 'CONFIRM_TYPE_CL7',
    :prenovate                => 'CONFIRM_TYPE_CL7',
    :pdecorate                => 'CONFIRM_TYPE_CL7',
    :pets                     => 'CONFIRM_TYPE_CL7',
    :educ                     => 'EDUCATION_LEVEL_CL1',
    :working                  => 'CONFIRM_TYPE_CL7',
    :shift_work               => 'CONFIRM_TYPE_CL13',
    :pump_gas                 => 'PUMP_GAS_FREQUENCY_CL1',
    :maristat                 => 'MARITAL_STATUS_CL2',
    :sp_educ                  => 'EDUCATION_LEVEL_CL1',
    :sp_ethnicity             => 'CONFIRM_TYPE_CL7',
    :income                   => 'INCOME_RANGE_CL1',
    :comm_email               => 'CONFIRM_TYPE_CL12',
    :have_email               => 'CONFIRM_TYPE_CL7',
    :email_2                  => 'CONFIRM_TYPE_CL7',
    :email_3                  => 'CONFIRM_TYPE_CL7',
    :comm_cell                => 'CONFIRM_TYPE_CL12',
    :cell_phone_1             => 'CONFIRM_TYPE_CL7',
    :cell_phone_2             => 'CONFIRM_TYPE_CL7',
    :cell_phone_3             => 'CONFIRM_TYPE_CL7',
    :cell_phone_4             => 'CONFIRM_TYPE_CL7',
    :comm_contact             => 'CONFIRM_TYPE_CL12',
    :contact_1                => 'CONFIRM_TYPE_CL7',
    :contact_relate_1         => 'CONTACT_RELATIONSHIP_CL2',
    :c_state_1                => 'STATE_CL2',
    :contact_relate_2         => 'CONTACT_RELATIONSHIP_CL2',
    :c_state_2                => 'STATE_CL2',
    
  }

  def self.ncs_code_lookup(attribute_name, show_missing_in_error = false)
    list_name = attribute_lookup(attribute_name)
    where_clause = "list_name = ?"
    where_clause += " AND display_text <> 'Missing in Error'" unless show_missing_in_error
    NcsCode.where(where_clause, list_name).map do |n| 
      [n.display_text, n.local_code]
    end    
  end
  
  def self.attribute_lookup(attribute_name)
     ATTRIBUTE_MAPPING[attribute_name]
  end
  
  def to_s
    display_text
  end
  
  def code
    local_code
  end
end
