

Factory.define :non_interview_report do |nir|

  nir.association :person, :factory => :person
  nir.association :contact, :factory => :contact
  nir.association :dwelling_unit, :factory => :dwelling_unit

  nir.psu_code                       2000030

  nir.nir_vacancy_information_code   1
  nir.nir_vacancy_information_other nil
  nir.nir_no_access_code             1
  nir.nir_no_access_other       nil
  nir.nir_access_attempt_code        1
  nir.nir_access_attempt_other  nil
  nir.nir_type_person_code           1
  nir.nir_type_person_other     nil
  nir.cog_inform_relation_code       1
  nir.cog_inform_relation_other nil
  nir.permanent_disability_code      1
  nir.cog_disability_description  nil
  nir.deceased_inform_relation_code  1
  nir.deceased_inform_relation_other  nil
  nir.year_of_death             nil
  nir.state_of_death_code            1
  nir.who_refused_code               1
  nir.who_refused_other         nil
  nir.refuser_strength_code          1
  nir.refusal_action_code            1
  nir.permanent_long_term_code       1
  nir.long_term_illness_description nil
  nir.reason_unavailable_code        1
  nir.reason_unavailable_other  nil
  nir.moved_length_time         nil
  nir.moved_unit_code                1
  nir.moved_inform_relation_code     1
  nir.moved_inform_relation_other nil
  nir.date_available            nil
  nir.date_moved                nil
  nir.nir_other                 nil
  nir.transaction_type          nil

  nir.nir "reason"

end

Factory.define :vacant_non_interview_report do |vnir|

  vnir.association :non_interview_report, :factory => :non_interview_report

  vnir.psu_code               2000030
  vnir.nir_vacant_code        1
  vnir.nir_vacant_other       nil
  vnir.transaction_type       nil

end

Factory.define :no_access_non_interview_report do |nanir|

  nanir.association :non_interview_report, :factory => :non_interview_report

  nanir.psu_code              2000030
  nanir.nir_no_access_code    1
  nanir.nir_no_access_other   nil
  nanir.transaction_type      nil

end

Factory.define :refusal_non_interview_report do |rnir|

  rnir.association :non_interview_report, :factory => :non_interview_report

  rnir.psu_code                2000030
  rnir.refusal_reason_code     1
  rnir.refusal_reason_other    nil
  rnir.transaction_type        nil

end

Factory.define :dwelling_unit_type_non_interview_report do |dutnir|

  dutnir.association :non_interview_report, :factory => :non_interview_report

  dutnir.psu_code                      2000030
  dutnir.nir_dwelling_unit_type_code   1
  dutnir.nir_dwelling_unit_type_other nil
  dutnir.transaction_type        nil

end
