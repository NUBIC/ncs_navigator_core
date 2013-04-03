# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: non_interview_reports
#
#  cog_disability_description     :text
#  cog_inform_relation_code       :integer          not null
#  cog_inform_relation_other      :string(255)
#  contact_id                     :integer
#  created_at                     :datetime
#  date_available                 :string(10)
#  date_available_date            :date
#  date_moved                     :string(10)
#  date_moved_date                :date
#  deceased_inform_relation_code  :integer          not null
#  deceased_inform_relation_other :string(255)
#  dwelling_unit_id               :integer
#  id                             :integer          not null, primary key
#  long_term_illness_description  :text
#  moved_inform_relation_code     :integer          not null
#  moved_inform_relation_other    :string(255)
#  moved_length_time              :decimal(6, 2)
#  moved_unit_code                :integer          not null
#  nir                            :text
#  nir_access_attempt_code        :integer          not null
#  nir_access_attempt_other       :string(255)
#  nir_id                         :string(36)       not null
#  nir_no_access_code             :integer          not null
#  nir_no_access_other            :string(255)
#  nir_other                      :text
#  nir_type_person_code           :integer          not null
#  nir_type_person_other          :string(255)
#  nir_vacancy_information_code   :integer          not null
#  nir_vacancy_information_other  :string(255)
#  permanent_disability_code      :integer          not null
#  permanent_long_term_code       :integer          not null
#  person_id                      :integer
#  psu_code                       :integer          not null
#  reason_unavailable_code        :integer          not null
#  reason_unavailable_other       :string(255)
#  refusal_action_code            :integer          not null
#  refuser_strength_code          :integer          not null
#  state_of_death_code            :integer          not null
#  transaction_type               :string(36)
#  updated_at                     :datetime
#  who_refused_code               :integer          not null
#  who_refused_other              :string(255)
#  year_of_death                  :integer
#



class NonInterviewReport < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :nir_id, :date_fields => [:date_available, :date_moved]

  belongs_to :contact
  belongs_to :dwelling_unit
  belongs_to :person

  has_many :vacant_non_interview_reports
  has_many :no_access_non_interview_reports
  has_many :refusal_non_interview_reports
  has_many :dwelling_unit_type_non_interview_reports

  has_one :response_set, :inverse_of => :non_interview_report

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


  ##
  # Finds or creates a record to indicate that a person has begun taking a
  # survey for the NIR. The NonInterviewReport returned will also
  # have an associated ResponseSet.
  #
  # This method creates an association to the ResponseSet via the
  # ResponseSet belongs_to association.
  # DO NOT USE THIS METHOD UNLESS YOU KNOW WHAT THAT MEANS
  #
  # @see ResponseSet.instrument
  #
  # @param [Person] the person taking the survey
  # @param [Participant] the participant who the survey is about
  # @param [Survey] Survey with title matching PSC activity instrument label
  # @param [Contact]
  # @return[NonInterviewReport]
  def self.start!(person, participant, survey, contact)
    where_clause = "response_sets.survey_id = ? AND response_sets.user_id = ? and non_interview_reports.contact_id = ?"
    rs = ResponseSet.includes(:non_interview_report).where(where_clause, survey.id, person.id, contact.id).first
    rs.nil? ? create_nir(person, participant, survey, contact) : rs.non_interview_report
  end

  def self.create_nir(person, participant, survey, contact)
    nir = person.non_interview_reports.build(:contact => contact, :psu => participant.psu)
    nir.build_response_set(:survey_id => survey.id, :user_id => person.id, :participant_id => participant.id)
    nir.save!
    nir
  end


end

