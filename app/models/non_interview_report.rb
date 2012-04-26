# encoding: utf-8

# == Schema Information
# Schema version: 20120404205955
#
# Table name: non_interview_reports
#
#  id                             :integer         not null, primary key
#  psu_code                       :integer         not null
#  nir_id                         :string(36)      not null
#  contact_id                     :integer
#  nir                            :text
#  dwelling_unit_id               :integer
#  person_id                      :integer
#  nir_vacancy_information_code   :integer         not null
#  nir_vacancy_information_other  :string(255)
#  nir_no_access_code             :integer         not null
#  nir_no_access_other            :string(255)
#  nir_access_attempt_code        :integer         not null
#  nir_access_attempt_other       :string(255)
#  nir_type_person_code           :integer         not null
#  nir_type_person_other          :string(255)
#  cog_inform_relation_code       :integer         not null
#  cog_inform_relation_other      :string(255)
#  cog_disability_description     :text
#  permanent_disability_code      :integer         not null
#  deceased_inform_relation_code  :integer         not null
#  deceased_inform_relation_other :string(255)
#  year_of_death                  :integer
#  state_of_death_code            :integer         not null
#  who_refused_code               :integer         not null
#  who_refused_other              :string(255)
#  refuser_strength_code          :integer         not null
#  refusal_action_code            :integer         not null
#  long_term_illness_description  :text
#  permanent_long_term_code       :integer         not null
#  reason_unavailable_code        :integer         not null
#  reason_unavailable_other       :string(255)
#  date_available_date            :date
#  date_available                 :string(10)
#  date_moved_date                :date
#  date_moved                     :string(10)
#  moved_length_time              :decimal(6, 2)
#  moved_unit_code                :integer         not null
#  moved_inform_relation_code     :integer         not null
#  moved_inform_relation_other    :string(255)
#  nir_other                      :text
#  transaction_type               :string(36)
#  created_at                     :datetime
#  updated_at                     :datetime
#

class NonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_id, :date_fields => [:date_available, :date_moved]

  belongs_to :contact
  belongs_to :dwelling_unit
  belongs_to :person

  has_many :vacant_non_interview_reports
  has_many :no_access_non_interview_reports
  has_many :refusal_non_interview_reports
  has_many :dwelling_unit_type_non_interview_reports

  accepts_nested_attributes_for :vacant_non_interview_reports, :allow_destroy => true
  accepts_nested_attributes_for :no_access_non_interview_reports, :allow_destroy => true
  accepts_nested_attributes_for :refusal_non_interview_reports, :allow_destroy => true
  accepts_nested_attributes_for :dwelling_unit_type_non_interview_reports, :allow_destroy => true

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