# == Schema Information
# Schema version: 20110920210459
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
    :phone_info_source_code        => 'INFORMATION_SOURCE_CL2',
    :phone_type_code               => 'PHONE_TYPE_CL1',
    :phone_rank_code               => 'COMMUNICATION_RANK_CL1',
    :phone_landline_code           => 'CONFIRM_TYPE_CL2',
    :phone_share_code              => 'CONFIRM_TYPE_CL2',
    :cell_permission_code          => 'CONFIRM_TYPE_CL2',
    :text_permission_code          => 'CONFIRM_TYPE_CL2',
    
    
    ### email
    # :psu_code               => "PSU_CL1",             # already referenced
    :email_info_source_code        => 'INFORMATION_SOURCE_CL2',
    :email_type_code               => 'EMAIL_TYPE_CL1',
    :email_rank_code               => 'COMMUNICATION_RANK_CL1',
    :email_share_code              => 'CONFIRM_TYPE_CL2',
    :email_active_code             => 'CONFIRM_TYPE_CL2',
    
    
    ### instrument 
    # :psu_code               => "PSU_CL1",             # already referenced
    :instrument_type_code          => 'INSTRUMENT_TYPE_CL1',
    :instrument_breakoff_code      => 'CONFIRM_TYPE_CL2',
    :instrument_status_code        => 'INSTRUMENT_STATUS_CL1',
    :instrument_mode_code          => 'INSTRUMENT_ADMIN_MODE_CL1',
    :instrument_method_code        => 'INSTRUMENT_ADMIN_METHOD_CL1',
    :supervisor_review_code        => 'CONFIRM_TYPE_CL2',
    :data_problem_code             => 'CONFIRM_TYPE_CL2',

    
    ### event
    # :psu_code                   => "PSU_CL1",             # already referenced
    :event_type_code                   => 'EVENT_TYPE_CL1',
    :event_disposition_category_code   => 'EVENT_DSPSTN_CAT_CL1',
    :event_breakoff_code               => 'CONFIRM_TYPE_CL2',
    :event_incentive_type_code         => 'INCENTIVE_TYPE_CL1',
    
    
    ### contact_link
    # :psu_code               => "PSU_CL1",             # already referenced
    
    
    ### contact 
    # :psu_code               => "PSU_CL1",             # already referenced
    :contact_type_code             => 'CONTACT_TYPE_CL1',
    :contact_language_code         => 'LANGUAGE_CL2',
    :contact_interpret_code        => 'TRANSLATION_METHOD_CL3',
    :contact_location_code         => 'CONTACT_LOCATION_CL1',
    :contact_private_code          => 'CONFIRM_TYPE_CL2',
    :who_contacted_code            => 'CONTACTED_PERSON_CL1',
    
    
    ### ppg_details
    # :psu_code               => "PSU_CL1",             # already referenced
    :ppg_pid_status_code           => 'PARTICIPANT_STATUS_CL1',
    :ppg_first_code                => 'PPG_STATUS_CL1',

    
    ### ppg_status_history
    # :psu_code               => "PSU_CL1",             # already referenced
    :ppg_status_code               => 'PPG_STATUS_CL2',
    :ppg_info_source_code          => 'INFORMATION_SOURCE_CL3',
    :ppg_info_mode_code            => 'CONTACT_TYPE_CL1',


    ### participant_consent
    # :psu_code               => "PSU_CL1",             # already referenced
    :consent_type_code              => 'CONSENT_TYPE_CL1',
    :consent_form_type_code         => 'CONSENT_TYPE_CL1',
    :consent_given_code             => 'CONFIRM_TYPE_CL2',
    :consent_withdraw_code          => 'CONFIRM_TYPE_CL2',
    :consent_withdraw_type_code     => 'CONSENT_WITHDRAW_REASON_CL1',
    :consent_withdraw_reason_code   => 'CONSENT_WITHDRAW_REASON_CL2',
    :consent_language_code          => 'LANGUAGE_CL2',
    :who_consented_code             => 'AGE_STATUS_CL1',
    :who_wthdrw_consent_code        => 'AGE_STATUS_CL3',
    :consent_translate_code         => 'TRANSLATION_METHOD_CL1',
    :reconsideration_script_use_code => 'CONFIRM_TYPE_CL21',


    ### participant_visit_consent
    # :psu_code               => "PSU_CL1",             # already referenced
    :vis_consent_type_code      => 'VISIT_TYPE_CL1',
    :vis_consent_response_code  => 'CONFIRM_TYPE_CL2',
    :vis_language_code          => 'LANGUAGE_CL2',
    :vis_who_consented_code     => 'AGE_STATUS_CL1',
    :vis_translate_code         => 'TRANSLATION_METHOD_CL1',
    

    ### participant_authorization_form
    # :psu_code               => "PSU_CL1",             # already referenced
    :auth_form_type_code        => 'AUTH_FORM_TYPE_CL1',
    :auth_status_code           =>'AUTH_STATUS_CL1',
    
    
    ### participant_consent_sample
    # :psu_code               => "PSU_CL1",             # already referenced
    :sample_consent_type_code   => 'CONSENT_TYPE_CL2',
    :sample_consent_given_code  => 'CONFIRM_TYPE_CL2',
    
    
    ### participant_visit_record
    # :psu_code               => "PSU_CL1",             # already referenced
    :rvis_language_code        => 'LANGUAGE_CL2',
    :rvis_who_consented_code   => 'AGE_STATUS_CL1',
    :rvis_translate_code       => 'TRANSLATION_METHOD_CL1',
    :rvis_sections_code        => 'CONFIRM_TYPE_CL21',
    :rvis_during_interv_code   => 'CONFIRM_TYPE_CL21',
    :rvis_during_bio_code      => 'CONFIRM_TYPE_CL21',
    :rvis_bio_cord_code        => 'CONFIRM_TYPE_CL21',
    :rvis_during_env_code      => 'CONFIRM_TYPE_CL21',
    :rvis_during_thanks_code   => 'CONFIRM_TYPE_CL21',
    :rvis_after_saq_code       => 'CONFIRM_TYPE_CL21',
    :rvis_reconsideration_code => 'CONFIRM_TYPE_CL21',
    
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
