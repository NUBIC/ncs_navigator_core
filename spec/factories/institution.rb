Factory.define :institution do |i|
  i.psu_code         20000030
  i.institute_comment           nil
  i.institute_info_date         Date.today
  i.institute_info_source_code  1
  i.institute_info_source_other nil
  i.institute_info_update       Date.today
  i.institute_name              'The Institute'
  i.institute_owner_code        1
  i.institute_owner_other       nil
  i.institute_relation_code     1
  i.institute_relation_other    nil
  i.institute_size              1
  i.institute_type_code         1
  i.institute_type_other        nil
  i.institute_unit_code         1
  i.institute_unit_other        nil
end

Factory.define :institution_person_link do |link|
  link.association :person,  :factory => :person
  link.association :institution, :factory => :institution
  link.psu_code                   20000030
  link.is_active_code             1
  link.institute_relation_code    1
end
