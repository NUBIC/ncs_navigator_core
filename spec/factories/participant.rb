# -*- coding: utf-8 -*-


FactoryGirl.define do

  factory :participant do
    psu_code                  20000030
    p_type_code               1
    p_type_other              nil
    status_info_source_code   1
    status_info_source_other  nil
    status_info_mode_code     1
    status_info_mode_other    nil
    status_info_date          Date.today
    enroll_status_code        1
    enroll_date               Date.today
    pid_entry_code            1
    pid_entry_other           nil
    pid_age_eligibility_code  1
    pid_comment               nil
    transaction_type          nil
    high_intensity            nil
    low_intensity_state       "pending"
    high_intensity_state      "in_high_intensity_arm"
    p_id                      nil
    being_followed            true

    trait :in_high_intensity_arm do
      high_intensity          true
      low_intensity_state     "moved_to_high_intensity_arm"
    end

    ## Pregnancy Probability Groups

    trait :in_ppg1 do
      ppg_status_histories { |ppg| [ppg.association(:ppg1_status)] }
    end

    trait :in_ppg2 do
      ppg_status_histories { |ppg| [ppg.association(:ppg2_status)] }
    end

    trait :in_ppg3 do
      ppg_status_histories { |ppg| [ppg.association(:ppg3_status)] }
    end

    trait :in_ppg4 do
      ppg_status_histories { |ppg| [ppg.association(:ppg4_status)] }
    end

    trait :in_ppg5 do
      ppg_status_histories { |ppg| [ppg.association(:ppg5_status)] }
    end

    trait :in_ppg6 do
      ppg_status_histories { |ppg| [ppg.association(:ppg6_status)] }
    end

    ## Low Intesity States

    trait :registered do
      low_intensity_state "registered"
    end

    trait :in_pregnancy_probability_group do
      low_intensity_state "in_pregnancy_probability_group"
    end

    trait :consented_low_intensity do
      low_intensity_state "consented_low_intensity"
    end

    trait :pregnant_low do
      low_intensity_state "pregnant_low"
    end

    trait :moved_to_high_intensity_arm do
      low_intensity_state "moved_to_high_intensity_arm"
    end

    trait :birth_low do
      low_intensity_state "birth_low"
    end

    ## High Intensity States

    trait :converted_high_intensity do
      high_intensity        true
      low_intensity_state   "moved_to_high_intensity_arm"
      high_intensity_state  "converted_high_intensity"
    end

    trait :pre_pregnancy do
      high_intensity        true
      low_intensity_state   "moved_to_high_intensity_arm"
      high_intensity_state  "pre_pregnancy"
    end

    trait :pregnancy_one do
      high_intensity        true
      low_intensity_state   "moved_to_high_intensity_arm"
      high_intensity_state  "pregnancy_one"
    end

    trait :pregnancy_two do
      high_intensity        true
      low_intensity_state   "moved_to_high_intensity_arm"
      high_intensity_state  "pregnancy_two"
    end

    trait :child do
      high_intensity        true
      low_intensity_state   "moved_to_high_intensity_arm"
      high_intensity_state  "parenthood"
    end

    ## Low Intensity Participants

    factory :low_intensity_ppg1_participant, :traits => [:in_ppg1, :in_pregnancy_probability_group]
    factory :low_intensity_ppg2_participant, :traits => [:in_ppg2, :in_pregnancy_probability_group]
    factory :low_intensity_ppg3_participant, :traits => [:in_ppg3, :in_pregnancy_probability_group]
    factory :low_intensity_ppg4_participant, :traits => [:in_ppg4, :in_pregnancy_probability_group]
    factory :low_intensity_ppg5_participant, :traits => [:in_ppg5, :in_pregnancy_probability_group]
    factory :low_intensity_ppg6_participant, :traits => [:in_ppg6, :in_pregnancy_probability_group]

    ## High Intensity Participants

    factory :high_intensity_ppg1_participant, :traits => [:in_high_intensity_arm, :in_ppg1]
    factory :high_intensity_ppg2_participant, :traits => [:in_high_intensity_arm, :in_ppg2]
    factory :high_intensity_ppg3_participant, :traits => [:in_high_intensity_arm, :in_ppg3]
    factory :high_intensity_ppg4_participant, :traits => [:in_high_intensity_arm, :in_ppg4]
    factory :high_intensity_ppg5_participant, :traits => [:in_high_intensity_arm, :in_ppg5]
    factory :high_intensity_ppg6_participant, :traits => [:in_high_intensity_arm, :in_ppg6]

    factory :high_intensity_pregnancy_one_participant, :traits => [:in_high_intensity_arm, :in_ppg1, :pregnancy_one]
    factory :high_intensity_pregnancy_two_participant, :traits => [:in_high_intensity_arm, :in_ppg1, :pregnancy_two]
    factory :high_intensity_postnatal_participant,     :traits => [:in_high_intensity_arm, :in_ppg4, :child]
  end

end

Factory.define :participant_person_link do |link|
  link.association :participant,  :factory => :participant
  link.association :person,  :factory => :person
  link.psu_code                20000030
  link.relationship_code       1
  link.relationship_other nil
  link.is_active_code          1
  link.transaction_type   nil
end

Factory.define :participant_staff_relationship do |rel|
  rel.association :participant,  :factory => :participant
  rel.staff_id    "staff_id"
  rel.primary     true
end

Factory.define :scheduled_activity do |sa|
  sa.study_segment "study_segment"
  sa.activity_id "activity_id"
  sa.current_state "scheduled"
  sa.ideal_date "2525-12-25"
  sa.date "2525-12-25"
  sa.activity_name "activity_name"
  sa.activity_type "activity_type"
  sa.labels "labels"
  sa.person_id "id"
  sa.event "event_type"
  sa.references_collection ["references"]
  sa.references "references"
  sa.instruments ["instrument"]
  sa.instrument "instrument"
  sa.order "00_00"
  sa.participant_type "p_type"
  sa.collection "collection"
  sa.mode "mode"
end
