# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: ncs_codes
#
#  created_at   :datetime
#  display_text :string(255)
#  id           :integer          not null, primary key
#  list_name    :string(255)
#  local_code   :integer
#  updated_at   :datetime
#

class NcsCode < ActiveRecord::Base

  validates_presence_of :list_name, :display_text, :local_code

  YES = 1
  NO  = 2
  MISSING_IN_ERROR = -4
  OTHER = -5
  UNKNOWN = -6

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
    :ppg_first_code                => 'PPG_STATUS_CL2',

    ### ppg_status_history
    # :psu_code               => "PSU_CL1",             # already referenced
    :ppg_status_code               => 'PPG_STATUS_CL1',
    :ppg_info_source_code          => 'INFORMATION_SOURCE_CL3',
    :ppg_info_mode_code            => 'CONTACT_TYPE_CL1',

    ### participant_consent
    # :psu_code               => "PSU_CL1",             # already referenced
    :consent_type_code              => 'CONSENT_TYPE_CL1',
    :consent_form_type_code         => 'CONSENT_TYPE_CL3',
    :consent_given_code             => 'CONFIRM_TYPE_CL2',
    :consent_withdraw_code          => 'CONFIRM_TYPE_CL2',
    :consent_withdraw_type_code     => 'CONSENT_WITHDRAW_REASON_CL1',
    :consent_withdraw_reason_code   => 'CONSENT_WITHDRAW_REASON_CL2',
    :consent_language_code          => 'LANGUAGE_CL2',
    :who_consented_code             => 'AGE_STATUS_CL1',
    :who_wthdrw_consent_code        => 'AGE_STATUS_CL3',
    :consent_translate_code         => 'TRANSLATION_METHOD_CL1',
    :reconsideration_script_use_code => 'CONFIRM_TYPE_CL21',
    :consent_reconsent_code         => 'CONFIRM_TYPE_CL2',
    :consent_reconsent_reason_code  => 'CONSENT_RECONSENT_REASON_CL1',

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

    ### non_interview_report
    # :psu_code               => "PSU_CL1",             # already referenced
    :nir_vacancy_information_code   => 'DU_VACANCY_INFO_SOURCE_CL1',
    :nir_no_access_code             => 'NO_ACCESS_DESCR_CL1',
    :nir_access_attempt_code        => 'ACCESS_ATTEMPT_CL1',
    :nir_type_person_code           => 'NIR_REASON_PERSON_CL1',
    :cog_inform_relation_code       => 'NIR_INFORM_RELATION_CL1',
    :permanent_disability_code      => 'CONFIRM_TYPE_CL10',
    :deceased_inform_relation_code  => 'NIR_INFORM_RELATION_CL1',
    :state_of_death_code            => 'STATE_CL3',
    :who_refused_code               => 'NIR_INFORM_RELATION_CL2',
    :nir_who_refused_code           => 'NIR_INFORM_RELATION_CL2', # not to be confused with non_interview_report_provider
    :refuser_strength_code          => 'REFUSAL_INTENSITY_CL1',
    :refusal_action_code            => 'REFUSAL_ACTION_CL1',
    :permanent_long_term_code       => 'CONFIRM_TYPE_CL10',
    :reason_unavailable_code        => 'UNAVAILABLE_REASON_CL1',
    :moved_unit_code                => 'TIME_UNIT_PAST_CL1',
    :moved_inform_relation_code     => 'MOVED_INFORM_RELATION_CL1',

    ### no_access_nir
    # :nir_no_access                => 'NO_ACCESS_DESCR_CL1' # already referenced

    ### dwelling_unit_type_nir
    :nir_dwelling_unit_type_code    => 'DU_NIR_REASON_CL1',

    ### vacant_nir
    :nir_vacant_code                => 'DU_VACANCY_INDICATOR_CL1',

    ### refusal nir
    :refusal_reason_code            => 'REFUSAL_REASON_CL1',

    ### spec_shipping
    :shipment_temperature_code       => 'SHIPMENT_TEMPERATURE_CL1',
    :shipment_receipt_confirmed_code => 'CONFIRM_TYPE_CL2',
    :shipment_issues_code            => 'SHIPMENT_ISSUES_CL1',

    ### sample_shipping
    :shipment_coolant_code          => 'SHIPMENT_TEMPERATURE_CL2',
    :shipper_destination_code       => 'SHIPPER_DESTINATION_CL1',
    :sample_shipped_by_code         => 'SAMPLES_SHIPPED_BY_CL1',

    ### spec_pickup_form
    :spec_pickup_comment_code       => 'SPECIMEN_STATUS_CL5',

    ### spec_receipt
    :receipt_comment_code         => 'SPECIMEN_STATUS_CL3',
    :monitor_status_code          => 'TRIGGER_STATUS_CL1',
    :upper_trigger_code           => 'TRIGGER_STATUS_CL1',
    :upper_trigger_level_code     => 'TRIGGER_STATUS_CL2',
    :lower_trigger_cold_code      => 'TRIGGER_STATUS_CL1',
    :lower_trigger_ambient_code   => 'TRIGGER_STATUS_CL1',
    :centrifuge_comment_code      => 'SPECIMEN_STATUS_CL4',

    ### specimen_storage
    :master_storage_unit_code     => 'STORAGE_AREA_CL1',

    ### sample_receipt_store
    :sample_condition_code        => 'SPECIMEN_STATUS_CL7',
    :cooler_temp_condition_code   => 'COOLER_TEMP_CL1',
    :storage_compartment_area_code => 'STORAGE_AREA_CL2',
    :temp_event_occurred_code     => 'CONFIRM_TYPE_CL20',
    :temp_event_action_code       => 'SPECIMEN_STATUS_CL6',

    ### sample_receipt_confirmation
    :shipment_receipt_confirmed_code    =>     'CONFIRM_TYPE_CL21',
    :shipment_condition_code            =>     'SHIPMENT_CONDITION_CL1',
    :sample_condition_code              =>     'SPECIMEN_STATUS_CL7',

    ### institution
    # :psu_code                         => 'PSU_CL1',
    :institute_type_code                => 'ORGANIZATION_TYPE_CL1',
    :institute_relation_code            => 'PERSON_ORGNZTN_FUNCTION_CL1',
    :institute_owner_code               => 'ORGANIZATION_OWNERSHIP_CL1',
    :institute_unit_code                => 'ORGANIZATION_SIZE_UNIT_CL1',
    :institute_info_source_code         => 'INFORMATION_SOURCE_CL2',

    ### provider
    # :psu_code                         => 'PSU_CL1',
    :provider_type_code               => 'PROVIDER_TYPE_CL1',
    :provider_ncs_role_code           => 'PROVIDER_STUDY_ROLE_CL1',
    :practice_info_code               => 'PRACTICE_CHARACTERISTIC_CL1',
    :practice_patient_load_code       => 'PRACTICE_LOAD_RANGE_CL1',
    :practice_size_code               => 'PRACTICE_SIZE_RANGE_CL1',
    :public_practice_code             => 'CONFIRM_TYPE_CL2',
    :provider_info_source_code        => 'INFORMATION_SOURCE_CL2',
    :list_subsampling_code            => 'CONFIRM_TYPE_CL2',

    ### pbs_provider_role
    :provider_role_pbs_code           => 'PROVIDER_STUDY_ROLE_CL2',

    ### pbs_list
    # :psu_code                         => 'PSU_CL1',
    :in_out_frame_code                => 'INOUT_FRAME_CL1',                 # MDES 3.0
    :in_sample_code                   => 'ORIGINAL_SUBSTITUTE_SAMPLE_CL1',  # MDES 3.0
    :in_out_psu_code                  => 'INOUT_PSU_CL1',                   # MDES 3.0
    :cert_flag_code                   => 'CERT_UNIT_CL1',                   # MDES 3.0
    :frame_completion_req_code        => 'CONFIRM_TYPE_CL21',
    :pr_recruitment_status_code       => 'RECRUIT_STATUS_CL1',              # MDES 3.0

    ### provider_logistics
    # :psu_code                       => 'PSU_CL1',
    :provider_logistics_code          => 'PROVIDER_LOGISTICS_CL1',

    ### non-interview provider
    :nir_type_provider_code =>         'NON_INTERVIEW_CL1',
    :nir_closed_info_code =>           'INFORMATION_SOURCE_CL8',
    :perm_closure_code =>              'CONFIRM_TYPE_CL10',
    :who_refused_code =>               'REFUSAL_PROVIDER_CL1',
    :refuser_strength_code =>          'REFUSAL_INTENSITY_CL2',
    :ref_action_provider_code =>       'REFUSAL_ACTION_CL1',
    :who_confirm_noprenatal_code =>    'REFUSAL_PROVIDER_CL1',
    :nir_moved_info_code =>            'INFORMATION_SOURCE_CL8',
    :perm_moved_code =>                'CONFIRM_TYPE_CL10',

    ### person_provider_link
    # :psu,                     'PSU_CL1'
    :is_active_code                 => 'CONFIRM_TYPE_CL2',
    :provider_intro_outcome_code    => 'STUDY_INTRODCTN_OUTCOME_CL1',
    :sampled_person_code            => 'CONFIRM_TYPE_CL2',
    :pre_screening_status_code      => 'SCREENING_STATUS_CL1',

    ### sampled_person_ineligibility
    :age_eligible_code              => 'CONFIRM_TYPE_CL3',
    :county_of_residence_code       => 'CONFIRM_TYPE_CL3',
    :pregnancy_eligible_code        => 'CONFIRM_TYPE_CL3',
    :first_prenatal_visit_code      => 'CONFIRM_TYPE_CL3',
    :ineligible_by_code             => 'INELIG_SOURCE_CL1'

  }.with_indifferent_access

  ##
  # Given a list of attributes, returns all NCS codes for those attributes.
  # You can use either symbols or strings for the attributes.  Attributes that
  # do not correspond to an NCS code list will be ignored.
  #
  # The returned object responds to #where, #each (and all other Enumerable
  # methods), and contains some additional helpers for e.g. accessing a subset
  # of returned NCS codes by list name.  See {NcsCodeCollection} for more
  # details.
  #
  # Example
  # =======
  #
  #     NcsCode.for_attributes('who_refused_code', 'perm_closure_code')
  #
  #     # => [#<NcsCode ...>, ...]
  def self.for_attributes(*attrs)
    query = where(:list_name => attrs.map { |c| attribute_lookup(c) }.compact)

    NcsCodeCollection.new(query)
  end

  def self.last_modified
    maximum(:updated_at)
  end

  def self.ncs_code_lookup(attribute_name, show_missing_in_error = false)
    list_name = attribute_lookup(attribute_name)
    codes = for_list_name(list_name)

    unless show_missing_in_error
      codes = codes.reject { |ncs_code| ncs_code.local_code == MISSING_IN_ERROR }
    end

    list = codes.map { |n| [n.display_text, n.local_code] }
    sort_list(list, list_name)
  end

  def self.sort_list(list, list_name)
    positives = list.select{ |pos| pos[1] >= 0 }
    negatives = list.select{ |neg| neg[1] < 0 }

    sk = sort_key(list_name)
    positives.sort { |a, b| a[sk] <=> b[sk] } + negatives.sort { |a, b| a[sk] <=> b[sk] }
  end

  def self.sort_key(list_name)
    codelists_keep_default_order = ['LANGUAGE_' ,'CONFIRM_', 'RANGE_']
    keep_default_order = false
    codelists_keep_default_order.each { |cl| keep_default_order = true if list_name.to_s.include?(cl) }
    keep_default_order ? 1 : 0
  end

  def self.attribute_lookup(attribute_name)
     ATTRIBUTE_MAPPING[attribute_name]
  end

  def self.for_attribute_name_and_local_code(attribute_name, local_code)
    for_list_name_and_local_code(attribute_lookup(attribute_name), local_code)
  end

  def self.for_list_name(list_name)
    Rails.application.code_list_cache.code_list(list_name)
  end

  def self.for_list_name_and_local_code(list_name, local_code)
    Rails.application.code_list_cache.code_value(list_name, local_code.to_i)
  end

  def self.for_list_name_and_display_text(list_name, display_text)
    cl = for_list_name(list_name)
    return nil unless cl
    cl.find { |ncs_code| ncs_code.display_text == display_text }
  end

  def self.find_event_by_lbl(lbl)
    EventLabel.new(lbl).ncs_code
  end

  # Special case helper method to get EVENT_TYPE_CL1 for Low Intensity Data Collection
  # Used to determine if participant is eligible for conversion to High Intensity Arm
  def self.low_intensity_data_collection
    for_list_name_and_local_code('EVENT_TYPE_CL1', Event.low_intensity_data_collection_code)
  end

  # Special case helper method to get EVENT_TYPE_CL1 for Pregnancy Screener
  # Used to determine if participant should be screened
  def self.pregnancy_screener
    for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_screener_code)
  end

  # Special case helper method to get EVENT_TYPE_CL1 for PBS Eligibility Screener
  # Used to determine if participant should be screened
  def self.pbs_eligibility_screener
    for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pbs_eligibility_screener_code)
  end

  ##
  # Override to reset cache when called. Should only be used in tests.
  def self.create!(*args)
    Rails.application.code_list_cache.reset
    super
  end

  def to_s
    display_text
  end

  def to_i
    local_code
  end

  def code
    local_code
  end

  def ==(comparison_object)
    comparison_object.equal?(self) ||
      (comparison_object.instance_of?(self.class) &&
      comparison_object.list_name == self.list_name &&
      comparison_object.local_code == self.local_code)
  end
end
