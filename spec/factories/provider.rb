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

end