Factory.define :non_interview_report do |nir|

  nir.association :person, :factory => :person
  nir.association :contact, :factory => :contact
  nir.association :dwelling_unit, :factory => :dwelling_unit

  nir.psu                       { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }

  nir.nir_vacancy_information   { |a| a.association(:ncs_code, :list_name => 'DU_VACANCY_INFO_SOURCE_CL1', :local_code => 1) }
  nir.nir_vacancy_information_other nil
  nir.nir_no_access             { |a| a.association(:ncs_code, :list_name => 'NO_ACCESS_DESCR_CL1', :local_code => 1) }
  nir.nir_no_access_other       nil
  nir.nir_access_attempt        { |a| a.association(:ncs_code, :list_name => 'ACCESS_ATTEMPT_CL1', :local_code => 1) }
  nir.nir_access_attempt_other  nil
  nir.nir_type_person           { |a| a.association(:ncs_code, :list_name => 'NIR_REASON_PERSON_CL1', :local_code => 1) }
  nir.nir_type_person_other     nil
  nir.cog_inform_relation       { |a| a.association(:ncs_code, :list_name => 'NIR_INFORM_RELATION_CL1', :local_code => 1) }
  nir.cog_inform_relation_other nil
  nir.permanent_disability      { |a| a.association(:ncs_code, :list_name => 'CONFIRM_TYPE_CL10', :local_code => 1) }
  nir.cog_disability_description  nil
  nir.deceased_inform_relation  { |a| a.association(:ncs_code, :list_name => 'NIR_INFORM_RELATION_CL1', :local_code => 1) }
  nir.deceased_inform_relation_other  nil
  nir.year_of_death             nil
  nir.state_of_death            { |a| a.association(:ncs_code, :list_name => 'STATE_CL3', :local_code => 1) }
  nir.who_refused               { |a| a.association(:ncs_code, :list_name => 'NIR_INFORM_RELATION_CL2', :local_code => 1) }
  nir.who_refused_other         nil
  nir.refuser_strength          { |a| a.association(:ncs_code, :list_name => 'REFUSAL_INTENSITY_CL1', :local_code => 1) }
  nir.refusal_action            { |a| a.association(:ncs_code, :list_name => 'REFUSAL_ACTION_CL1', :local_code => 1) }
  nir.permanent_long_term       { |a| a.association(:ncs_code, :list_name => 'CONFIRM_TYPE_CL10', :local_code => 1) }
  nir.long_term_illness_description nil
  nir.reason_unavailable        { |a| a.association(:ncs_code, :list_name => 'UNAVAILABLE_REASON_CL1', :local_code => 1) }
  nir.reason_unavailable_other  nil
  nir.moved_length_time         nil
  nir.moved_unit                { |a| a.association(:ncs_code, :list_name => 'TIME_UNIT_PAST_CL1', :local_code => 1) }
  nir.moved_inform_relation     { |a| a.association(:ncs_code, :list_name => 'MOVED_INFORM_RELATION_CL1', :local_code => 1) }
  nir.moved_inform_relation_other nil
  nir.date_available            nil
  nir.date_moved                nil
  nir.nir_other                 nil
  nir.transaction_type          nil

  nir.nir "reason"

end

Factory.define :vacant_non_interview_report do |vnir|

  vnir.association :non_interview_report, :factory => :non_interview_report

  vnir.psu                    { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  vnir.nir_vacant             { |a| a.association(:ncs_code, :list_name => 'DU_VACANCY_INDICATOR_CL1', :local_code => 1) }
  vnir.nir_vacant_other       nil
  vnir.transaction_type       nil

end

Factory.define :no_access_non_interview_report do |nanir|

  nanir.association :non_interview_report, :factory => :non_interview_report

  nanir.psu                   { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  nanir.nir_no_access         { |a| a.association(:ncs_code, :list_name => 'NO_ACCESS_DESCR_CL1', :local_code => 1) }
  nanir.nir_no_access_other   nil
  nanir.transaction_type      nil

end

Factory.define :refusal_non_interview_report do |rnir|

  rnir.association :non_interview_report, :factory => :non_interview_report

  rnir.psu                     { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  rnir.refusal_reason          { |a| a.association(:ncs_code, :list_name => 'REFUSAL_REASON_CL1', :local_code => 1) }
  rnir.refusal_reason_other    nil
  rnir.transaction_type        nil

end

Factory.define :dwelling_unit_type_non_interview_report do |dutnir|

  dutnir.association :non_interview_report, :factory => :non_interview_report

  dutnir.psu                      { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  dutnir.nir_dwelling_unit_type   { |a| a.association(:ncs_code, :list_name => 'DU_NIR_REASON_CL1', :local_code => 1) }
  dutnir.nir_dwelling_unit_type_other nil
  dutnir.transaction_type        nil

end
