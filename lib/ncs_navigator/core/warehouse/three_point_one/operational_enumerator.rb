# -*- coding: utf-8 -*-


require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse::ThreePointOne
  ##
  # Converts the contents of a core instance into appropriate MDES 3.1
  # model instances for MDES Warehouse.
  class OperationalEnumerator

    include NcsNavigator::Warehouse::Transformers::Database

    extend NcsNavigator::Core::Warehouse::DatabaseEnumeratorHelpers

    bcdatabase :name => 'ncs_navigator_core'

    on_unused_columns :fail
    ignored_columns :id, :transaction_type, :updated_at, :created_at, :being_processed

    produce_one_for_one(:listing_units, :ListingUnit)

    produce_one_for_one(:dwelling_units, :DwellingUnit,
      :public_ids => [
        { :table => :listing_units, :public_id => :list_id }
      ]
    )

    produce_one_for_one(:household_units, :HouseholdUnit,
      :column_map => {
        :hh_eligibility_code => :hh_elig,
        :number_of_age_eligible_women => :num_age_elig,
        :number_of_pregnant_women => :num_preg,
        :number_of_pregnant_minors => :num_preg_minor,
        :number_of_pregnant_adults => :num_preg_adult,
        :number_of_pregnant_over49 => :num_preg_over49
      }
    )

    produce_one_for_one(:dwelling_household_links, :LinkHouseholdDwelling,
      :public_ids => [
        { :table => :dwelling_units, :public_id => :du_id },
        { :table => :household_units, :public_id => :hh_id }
      ]
    )

    produce_one_for_one(:people, :Person,
      :column_map => {
        :language_code => :person_lang,
        :language_other => :person_lang_oth,
        :language_new_code => :person_lang_new,
        :language_new_other => :person_lang_new_oth,
        :marital_status_code => :maristat,
        :marital_status_other => :maristat_oth,
        :preferred_contact_method_code => :pref_contact,
        :preferred_contact_method_other => :pref_contact_oth,
        :planned_move_code => :plan_move
      },
      :ignored_columns => %w(
        person_dob_date date_move_date response_set_id role lock_version
      )
    )

    produce_one_for_one(:household_person_links, :LinkPersonHousehold,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        { :table => :household_units, :public_id => :hh_id }
      ]
    )

    produce_one_for_one(:person_races, :PersonRace,
      :public_ids => [
        { :table => :people, :join_column => :person_id }
      ]
    )

    produce_one_for_one(:participants, :Participant,
      :column_map => {
        :pid_age_eligibility_code => :pid_age_elig
      },
      :ignored_columns => %w(
        person_id high_intensity low_intensity_state high_intensity_state
        enrollment_status_comment being_followed lock_version
      )
    )

    produce_one_for_one(:participant_person_links, :LinkPersonParticipant,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        :participants
      ],
      :column_map => {
        :relationship_code => :relation,
        :relationship_other => :relation_oth,
      },
      :ignored_columns => %w(response_set_id)
    )

    produce_one_for_one(:ppg_details, :PpgDetails,
      :public_ids => %w(participants),
      :ignored_columns => %w(response_set_id lock_version)
    )

    produce_one_for_one(:ppg_status_histories, :PpgStatusHistory,
      :public_ids => %w(participants),
      :ignored_columns => %w(response_set_id ppg_status_date_date)
    )

    produce_one_for_one(:contacts, :Contact,
      :selects => [
        "(t.contact_disposition % 500 + 500) normalized_contact_disposition"
      ],
      :column_map => {
        :normalized_contact_disposition => :contact_disp,
        :contact_language_code => :contact_lang,
        :contact_language_other => :contact_lang_oth,
        :who_contacted_other => :who_contact_oth
      },
      :ignored_columns => %w(contact_date_date contact_disposition lock_version)
    )

    produce_one_for_one(:events, :Event,
      :public_ids => [
        { :table => :participants, :public_id => :p_id, :public_ref => :participant_id }
      ],
      :selects => [
        %q{(CASE
            WHEN t.event_end_date IS NULL
                 THEN t.event_disposition % 500
            ELSE t.event_disposition % 500 + 500
            END) normalized_event_disposition}
      ],
      :where => %q{
        t.event_disposition IS NOT NULL OR
        EXISTS(SELECT 'x' FROM contact_links cl WHERE cl.event_id=t.id) OR
        EXISTS(SELECT 'x' FROM instruments ins WHERE ins.event_id=t.id)
      },
      :column_map => {
        :normalized_event_disposition => :event_disp,
        :event_disposition_category_code => :event_disp_cat,
        :event_incentive_cash => :event_incent_cash,
        :event_incentive_noncash => :event_incent_noncash
      },
      :ignored_columns => %w(event_disposition scheduled_study_segment_identifier
        psc_ideal_date lock_version imported_invalid)
    )

    produce_one_for_one(:instruments, :Instrument,
      :public_ids => %w(events),
      :column_map => {
        :instrument_start_date => :ins_date_start,
        :instrument_start_time => :ins_start_time,
        :instrument_end_date => :ins_date_end,
        :instrument_end_time => :ins_end_time,
        :instrument_breakoff_code => :ins_breakoff,
        :instrument_status_code => :ins_status,
        :instrument_mode_code => :ins_mode,
        :instrument_mode_other => :ins_mode_oth,
        :instrument_comment => :instru_comment,
        :instrument_method_code => :ins_method,
        :supervisor_review_code => :sup_review
      },
      :ignored_columns => %w(person_id survey_id lock_version)
    )

    produce_one_for_one(:institutions, :Institution,
      :ignored_columns => %w(response_set_id)
    )

    produce_one_for_one(:institution_person_links, :LinkPersonInstitute,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        { :table => :institutions, :public_id => :institute_id }
      ]
    )

    produce_one_for_one(:providers, :Provider,
      :ignored_columns => %w(institution_id)
    )

    produce_one_for_one(:person_provider_links, :LinkPersonProvider,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        { :table => :providers, :public_id => :provider_id }
      ],
      :column_map => {
        :provider_intro_outcome_code  => :prov_intro_outcome,
        :provider_intro_outcome_other => :prov_intro_outcome_oth
      },
      :ignored_columns => %w(date_first_visit_date)
    )

    produce_one_for_one(:provider_roles, :ProviderRole,
      :public_ids => %w(providers)
    )

    produce_one_for_one(:pbs_provider_roles, :ProviderRolePbs,
      :public_ids => %w(providers)
    )

    produce_one_for_one(:provider_logistics, :ProviderLogistics,
      :public_ids => %w(providers),
      :column_map => {
        :provider_logistics_code  => :provider_logistics,
        :provider_logistics_other => :provider_logistics_oth
      },
      :ignored_columns => %w(completion_date comment refusal)
    )

    produce_one_for_one(:pbs_lists, :PbsList,
      :public_ids => %w(providers)
    )

    produce_one_for_one(:contact_links, :LinkContact,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        :providers,
        :events,
        :contacts,
        :instruments
      ]
    )

    produce_one_for_one(:addresses, :Address,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        { :table => :dwelling_units, :public_id => :du_id },
        { :table => :providers, :join_column => :provider_id },
        { :table => :institutions, :join_column => :institute_id },
      ],
      :column_map => {
        :address_one => :address_1,
        :address_two => :address_2
      },
      :ignored_columns => %w(
        address_start_date_date address_end_date_date
        response_set_id specimen_processing_shipping_center_id sample_receipt_shipping_center_id
        lock_version
      )
    )

    produce_one_for_one(:emails, :Email,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        { :table => :providers, :join_column => :provider_id },
        { :table => :institutions, :join_column => :institute_id },
      ],
      :ignored_columns => %w(
        email_start_date_date email_end_date_date response_set_id lock_version
      )
    )

    produce_one_for_one(:telephones, :Telephone,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        { :table => :providers, :join_column => :provider_id },
        { :table => :institutions, :join_column => :institute_id },
      ],
      :ignored_columns => %w(
        phone_start_date_date phone_end_date_date response_set_id lock_version
      )
    )

    produce_one_for_one(:participant_consents, :ParticipantConsent,
      :public_ids => [
        :participants,
        :contacts,
        { :table => :people,
          :public_id => :person_id,
          :public_ref => :person_who_consented_id },
        { :table => :people,
          :public_id => :person_id,
          :public_ref => :person_wthdrw_consent_id }
      ],
      :column_map => {
        :consent_reconsent_code => :consent_reconsent,
        :consent_reconsent_reason_other => :consent_reconsent_reason_oth
      }
    )

    produce_one_for_one(:participant_consent_samples, :ParticipantConsentSample,
      :public_ids => %w(participants participant_consents)
    )

    produce_one_for_one(:participant_authorization_forms, :ParticipantAuth,
      :public_ids => %w(participants contacts providers)
    )

    produce_one_for_one(:participant_visit_consents, :ParticipantVisConsent,
      :public_ids => [
        :participants,
        :contacts,
        { :table => :people,
          :public_id => :person_id,
          :public_ref => :vis_person_who_consented_id }
      ]
    )

    produce_one_for_one(:participant_visit_records, :ParticipantRvis,
      :selects => [
        mdes_formatted_datetime_query('time_stamp_1'),
        mdes_formatted_datetime_query('time_stamp_2'),
      ],
      :public_ids => [
        :participants,
        :contacts,
        { :table => :people,
          :public_id => :person_id,
          :join_column => :rvis_person_id,
          :public_ref => :rvis_person }
      ],
      :column_map => {
        mdes_datetime_column_alias('time_stamp_1').to_sym => :time_stamp_1,
        mdes_datetime_column_alias('time_stamp_2').to_sym => :time_stamp_2,
      },
      :ignored_columns => %w(time_stamp_1 time_stamp_2)
    )

    produce_one_for_one(:non_interview_reports, :NonInterviewRpt,
      :public_ids => [
        :contacts,
        { :table => :people, :join_column => :person_id },
        { :table => :dwelling_units, :public_id => :du_id }
      ],
      :column_map => {
        :nir_vacancy_information_code  => :nir_vac_info,
        :nir_vacancy_information_other => :nir_vac_info_oth,
        :nir_no_access_code => :nir_noaccess,
        :nir_no_access_other => :nir_noaccess_oth,
        :cog_disability_description => :cog_dis_desc,
        :permanent_disability_code => :perm_disability,
        :deceased_inform_relation_other => :deceased_inform_oth,
        :year_of_death => :yod,
        :state_of_death_code => :state_death,
        :refusal_action_code => :ref_action,
        :long_term_illness_description => :lt_illness_desc,
        :permanent_long_term_code => :perm_ltr,
        :reason_unavailable_code => :reason_unavail,
        :reason_unavailable_other => :reason_unavail_oth,
        :moved_inform_relation_other => :moved_relation_oth
      },
      :ignored_columns => %w(date_available_date date_moved_date)
    )

    produce_one_for_one(:dwelling_unit_type_non_interview_reports, :NonInterviewRptDutype,
      :public_ids => [
        { :table => :non_interview_reports, :public_id => :nir_id }
      ],
      :column_map => {
        :nir_dwelling_unit_type_code => :nir_type_du,
        :nir_dwelling_unit_type_other => :nir_type_du_oth
      }
    )

    produce_one_for_one(:no_access_non_interview_reports, :NonInterviewRptNoaccess,
      :public_ids => [
        { :table => :non_interview_reports, :public_id => :nir_id }
      ],
      :column_map => {
        :nir_no_access_id => :nir_noaccess_id,
        :nir_no_access_code  => :nir_noaccess,
        :nir_no_access_other => :nir_noaccess_oth
      }
    )

    produce_one_for_one(:refusal_non_interview_reports, :NonInterviewRptRefusal,
      :public_ids => [
        { :table => :non_interview_reports, :public_id => :nir_id }
      ]
    )

    produce_one_for_one(:vacant_non_interview_reports, :NonInterviewRptVacant,
      :public_ids => [
        { :table => :non_interview_reports, :public_id => :nir_id }
      ]
    )

    produce_one_for_one(:non_interview_providers, :NonInterviewProvider,
      :public_ids => [
        { :table => :providers, :join_column => :provider_id },
        { :table => :contacts, :join_column => :contact_id },
      ],
      :column_map => {
        :nir_type_provider_code       => :nir_type_provider,
        :nir_type_provider_other      => :nir_type_provider_oth,
        :nir_closed_info_code         => :nir_closed_info,
        :nir_closed_info_other        => :nir_closed_info_oth,
        :perm_closure_code            => :perm_closure,
        :who_refused_code             => :who_refused,
        :who_refused_other            => :who_refused_oth,
        :refuser_strength_code        => :refuser_strength,
        :ref_action_provider_code     => :ref_action_provider,
        :who_confirm_noprenatal_code  => :who_confirm_noprenatal,
        :who_confirm_noprenatal_other => :who_confirm_noprenatal_oth,
        :nir_moved_info_code          => :nir_moved_info,
        :nir_moved_info_other         => :nir_moved_info_oth,
        :perm_moved_code              => :perm_moved,
      }
    )

    produce_one_for_one(:sampled_persons_ineligibilities, :SampledPersonsIneligibility,
      :public_ids => [
        { :table => :people, :join_column => :person_id },
        { :table => :providers, :public_id => :provider_id }
      ]
    )

    # TODO: Task #3069
    #       This model has a problem because the alias column is too long for postgres.
    #       cf. http://www.postgresql.org/docs/current/static/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS
    #       says that the max length for a column name is 63 bytes, the column
    #       created by the column map in the Database Enumerator Struct is
    #       'public_id_for_non_interview_providers_as_non_interview_provider_id' 67 characters long
    #
    # produce_one_for_one(:non_interview_provider_refusals, :NonInterviewProviderRefusal,
    #   :public_ids => [
    #     { :table => :non_interview_providers, :join_column => :non_interview_provider_id },
    #   ],
    #   :column_map => {
    #     :refusal_reason_pbs_code  => :refusal_reason_pbs,
    #     :refusal_reason_pbs_other => :refusal_reason_pbs_oth,
    #   }
    # )
  end
end