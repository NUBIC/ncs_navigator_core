# == Schema Information
# Schema version: 20120607203203
#
# Table name: ncs_codes
#
#  id           :integer         not null, primary key
#  list_name    :string(255)
#  display_text :string(255)
#  local_code   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

# -*- coding: utf-8 -*-

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
    :ppg_first_code                => 'PPG_STATUS_CL2',

    ### ppg_status_history
    # :psu_code               => "PSU_CL1",             # already referenced
    :ppg_status_code               => 'PPG_STATUS_CL1',
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
    :spec_shipment_temperature_code  => 'SHIPMENT_TEMPERATURE_CL1',
    :shipment_receipt_confirmed_code => 'CONFIRM_TYPE_CL2',
    :shipment_issues_code            => 'SHIPMENT_ISSUES_CL1',

    ### sample_shipping
    :sample_shipment_temperature_code  => 'SHIPMENT_TEMPERATURE_CL2',
    :sample_shipper_destination_code   => 'SHIPPER_DESTINATION_CL1',
    :sample_shipped_by_code            => 'SAMPLES_SHIPPED_BY_CL1',

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

  }

  def self.ncs_code_lookup(attribute_name, show_missing_in_error = false)
    list_name = attribute_lookup(attribute_name)
    where_clause = "list_name = ?"
    where_clause += " AND display_text <> 'Missing in Error'" unless show_missing_in_error
    list = NcsCode.where(where_clause, list_name).map { |n| [n.display_text, n.local_code] }

    NcsCode.sort_list(list, list_name)
  end

  def self.sort_list(list, list_name)
    positives = list.select{ |pos| pos[1] >= 0 }
    negatives = list.select{ |neg| neg[1] < 0 }

    sk = NcsCode.sort_key(list_name)
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
    NcsCode.for_list_name_and_local_code(NcsCode.attribute_lookup(attribute_name), local_code)
  end

  def self.for_list_name_and_local_code(list_name, local_code)
    NcsCode.where(:list_name => list_name).where(:local_code => local_code.to_i).first
  end

  def self.for_list_name_and_display_text(list_name, display_text)
    NcsCode.where(:list_name => list_name).where(:display_text => display_text).first
  end

  def self.find_event_by_lbl(lbl)
    # handle dash condition
    dash_idx = lbl.index "-"
    txt = lbl.gsub("_", " ").titleize
    txt = txt.insert(dash_idx, "-").gsub("- ", "-") if dash_idx

    # handle lowercase condition
    [" To ", " In "].each do |should_downcase|
      lc_idx = txt.index should_downcase
      txt = txt.gsub(should_downcase, should_downcase.downcase) if lc_idx
    end

    NcsCode.for_list_name_and_display_text('EVENT_TYPE_CL1', txt)
  end

  # Special case helper method to get EVENT_TYPE_CL1 for Low Intensity Data Collection
  # Used to determine if participant is eligible for conversion to High Intensity Arm
  def self.low_intensity_data_collection
    NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33)
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
