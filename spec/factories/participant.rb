FactoryGirl.define do
  
  factory :participant do
    association :person,  :factory => :person
    psu                       { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
    p_type                    { |a| a.association(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "Age-eligible woman", :local_code => 1) }
    p_type_other              nil
    status_info_source        { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL4", :display_text => "Person/Self", :local_code => 1) }
    status_info_source_other  nil
    status_info_mode          { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
    status_info_mode_other    nil
    status_info_date          Date.today
    enroll_status             { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
    enroll_date               Date.today
    pid_entry                 { |a| a.association(:ncs_code, :list_name => "STUDY_ENTRY_METHOD_CL1", :display_text => "Advance letter mailed by NCS.", :local_code => 1) }
    pid_entry_other           nil
    pid_age_eligibility       { |a| a.association(:ncs_code, :list_name => "AGE_ELIGIBLE_CL2", :display_text => "Age-Eligible", :local_code => 1) }
    pid_comment               nil
    transaction_type          nil
    high_intensity            nil
    low_intensity_state       "pending"
    high_intensity_state      "in_high_intensity_arm"
    
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
    
    trait :pregnant_and_consented do
      low_intensity_state "pregnant_and_consented"
    end
    
    trait :moved_to_high_intensity_arm do
      low_intensity_state "moved_to_high_intensity_arm"
    end
    
    trait :birth_low do
      low_intensity_state "birth_low"
    end
    
    ## High Intensity States
    
    trait :consented_high_intensity do
      high_intensity        true
      low_intensity_state   "moved_to_high_intensity_arm"
      high_intensity_state  "consented_high_intensity"
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
  end
  
end

Factory.define :participant_person_link do |link|
  link.association :participant,  :factory => :participant
  link.association :person,  :factory => :person
  link.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  link.relationship       { |a| a.association(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Participant/Self", :local_code => 1) }
  link.relationship_other nil
  link.is_active          { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  link.transaction_type   nil
end