# -*- coding: utf-8 -*-
FactoryGirl.define do

  factory :provider do |prov|
    prov.psu_code                   20000030
    prov.provider_type_code         1
    prov.provider_info_source_code  1
    prov.provider_ncs_role_code     1
    prov.practice_info_code         1
    prov.practice_patient_load_code 1
    prov.practice_size_code         1
    prov.public_practice_code       1
    prov.provider_info_date         Date.today
    prov.provider_info_update       Date.today
    prov.provider_comment           'provider comment'
    prov.name_practice              'name of provider'
  end

  factory :provider_role do |pr|
    pr.psu_code                   20000030
    pr.association :provider, :factory => :provider
    pr.provider_ncs_role_code     1
  end

  factory :pbs_provider_role do |pr|
    pr.psu_code                   20000030
    pr.association :provider, :factory => :provider
    pr.provider_role_pbs_code     1
  end

  factory :person_provider_link do |ppl|
    ppl.psu_code                   20000030
    ppl.association :provider, :factory => :provider
    ppl.association :person, :factory => :person
    ppl.provider_intro_outcome_code     1
    ppl.sampled_person_code             1
    ppl.pre_screening_status_code       1
    ppl.ineligible_batch_identifier  nil
  end

  factory :personnel_provider_link do |ppl|
    ppl.association :provider, :factory => :provider
    ppl.association :person, :factory => :person
    ppl.primary_contact :false
  end

  factory :pbs_list do |pbsl|
    pbsl.psu_code                       20000030
    pbsl.association :provider, :factory => :provider
    pbsl.association :substitute_provider, :factory => :provider
    pbsl.practice_num                   1
    pbsl.in_out_frame_code              nil
    pbsl.in_sample_code                 nil
    pbsl.in_out_psu_code                nil
    pbsl.mos                            1
    pbsl.cert_flag_code                 nil
    pbsl.stratum                        "1"
    pbsl.sort_var1                      1
    pbsl.sort_var2                      2
    pbsl.sort_var3                      3
    pbsl.frame_order                    1

    pbsl.selection_probability_location 1.0
    pbsl.sampling_interval_woman        1.0
    pbsl.selection_probability_woman    1.0
    pbsl.selection_probability_overall  1.0

    pbsl.frame_completion_req_code      1
    pbsl.pr_recruitment_status_code     nil

    pbsl.pr_recruitment_start_date      3.weeks.ago.to_date
    pbsl.pr_cooperation_date            2.weeks.ago.to_date
    pbsl.pr_recruitment_end_date        Date.today
  end

  factory :provider_logistic do |pl|
    pl.psu_code                 20000030
    pl.association :provider,   :factory => :provider
    pl.provider_logistics_code  1
    pl.provider_logistics_other nil
    pl.completion_date          nil
  end

  factory :non_interview_provider do |nir|
    nir.psu_code                      20000030
    nir.association :contact,         :factory => :contact
    nir.association :provider,        :factory => :provider
    nir.nir_type_provider_code        1
    nir.nir_type_provider_other       nil
    nir.nir_closed_info_code          -4
    nir.nir_closed_info_other         nil
    nir.when_closure                  nil
    nir.perm_closure_code             -4
    nir.who_refused_code              -4
    nir.who_refused_other             nil
    nir.refuser_strength_code         -4
    nir.ref_action_provider_code      -4
    nir.who_confirm_noprenatal_code   -4
    nir.who_confirm_noprenatal_other  nil
    nir.nir_moved_info_code           -4
    nir.nir_moved_info_other          nil
    nir.when_moved                    nil
    nir.perm_moved_code               -4
    nir.nir_pbs_comment               nil
  end

  factory :non_interview_provider_refusal do |nipr|
    nipr.psu_code                      20000030
    nipr.association :non_interview_provider, :factory => :non_interview_provider
    nipr.refusal_reason_pbs_code       1
    nipr.refusal_reason_pbs_other      nil
  end
end
