# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130614142954
#
# Table name: ineligible_batches
#
#  age_eligible_code            :integer
#  batch_id                     :string(36)       not null
#  county_of_residence_code     :integer
#  created_at                   :date             not null
#  date_first_visit             :string(255)      not null
#  date_first_visit_date        :date             not null
#  first_prenatal_visit_code    :integer
#  id                           :integer          not null, primary key
#  ineligible_by_code           :integer
#  people_count                 :integer          not null
#  pre_screening_status_code    :integer          not null
#  pregnancy_eligible_code      :integer
#  provider_id                  :string(36)       not null
#  provider_intro_outcome_code  :integer          not null
#  provider_intro_outcome_other :string(255)
#  psu_code                     :integer          not null
#  sampled_person_code          :integer          not null
#  updated_at                   :datetime         not null
#

class IneligibleBatch < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :batch_id,
                      :date_fields => [:date_first_visit],
                      :public_id_generator => NcsNavigator::Core::Mdes::HumanReadablePublicIdGenerator.new(:pattern => [4, 4, 4])

  ncs_coded_attribute :psu,                    'PSU_CL1'
  ncs_coded_attribute :age_eligible,           'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :county_of_residence,    'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :first_prenatal_visit,   'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :pregnancy_eligible,     'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :ineligible_by,          'INELIG_SOURCE_CL1'
  ncs_coded_attribute :provider_intro_outcome, 'STUDY_INTRODCTN_OUTCOME_CL1'
  ncs_coded_attribute :sampled_person,         'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :pre_screening_status,   'SCREENING_STATUS_CL1'

  belongs_to :provider
end
