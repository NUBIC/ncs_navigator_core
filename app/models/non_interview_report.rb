class NonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_id, :date_fields => [:date_unavailable, :date_moved]

  belongs_to :contact
  belongs_to :dwelling_unit
  belongs_to :person

  has_many :vacant_non_interview_reports
  has_many :no_access_non_interview_reports
  has_many :refusal_non_interview_reports
  has_many :dwelling_unit_type_non_interview_reports

  ncs_coded_attribute :psu,                       'PSU_CL1'
  ncs_coded_attribute :nir_vacancy_information,   'DU_VACANCY_INFO_SOURCE_CL1'
  ncs_coded_attribute :nir_no_access,             'NO_ACCESS_DESCR_CL1'
  ncs_coded_attribute :nir_access_attempt,        'ACCESS_ATTEMPT_CL1'
  ncs_coded_attribute :nir_type_person,           'NIR_REASON_PERSON_CL1'
  ncs_coded_attribute :cog_inform_relation,       'NIR_INFORM_RELATION_CL1'
  ncs_coded_attribute :permanent_disability,      'CONFIRM_TYPE_CL10'
  ncs_coded_attribute :deceased_inform_relation,  'NIR_INFORM_RELATION_CL1'
  ncs_coded_attribute :state_of_death,            'STATE_CL3'
  ncs_coded_attribute :who_refused,               'NIR_INFORM_RELATION_CL2'
  ncs_coded_attribute :refuser_strength,          'REFUSAL_INTENSITY_CL1'
  ncs_coded_attribute :refusal_action,            'REFUSAL_ACTION_CL1'
  ncs_coded_attribute :permanent_long_term,       'CONFIRM_TYPE_CL10'
  ncs_coded_attribute :reason_unavailable,        'UNAVAILABLE_REASON_CL1'
  ncs_coded_attribute :moved_unit,                'TIME_UNIT_PAST_CL1'
  ncs_coded_attribute :moved_inform_relation,     'MOVED_INFORM_RELATION_CL1'

end
