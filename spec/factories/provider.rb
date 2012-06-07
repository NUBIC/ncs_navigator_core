FactoryGirl.define do

  factory :provider do |prov|
    prov.psu_code                   2000030
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
  end

  factory :provider_role do |pr|
    pr.psu_code                   2000030
    pr.association :provider, :factory => :provider
    pr.provider_ncs_role_code     1
  end

  factory :person_provider_link do |ppl|
    ppl.psu_code                   2000030
    ppl.association :provider, :factory => :provider
    ppl.association :person, :factory => :person
    ppl.provider_intro_outcome_code     1
  end

  factory :pbs_list do |pbsl|
    pbsl.psu_code                       2000030
    pbsl.association :provider, :factory => :provider
    pbsl.association :substitute_provider, :factory => :provider
    pbsl.practice_num                   1
    pbsl.in_out_frame_code              nil
    pbsl.in_sample_code                 nil
    pbsl.in_out_psu_code                nil
    pbsl.mos                            1
    pbsl.cert_flag_code                 nil
    pbsl.stratum                        1
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

end