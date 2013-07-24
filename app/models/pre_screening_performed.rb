# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130723163540
#
# Table name: pre_screening_performeds
#
#  created_at                   :datetime         not null
#  id                           :integer          not null, primary key
#  pr_age_eligible_code         :integer          not null
#  pr_county_of_residence_code  :integer          not null
#  pr_first_provider_visit_code :integer          not null
#  pr_pregnancy_eligible_code   :integer          not null
#  pre_screening_performed_id   :string(36)       not null
#  provider_id                  :integer          not null
#  psu_code                     :string(36)       not null
#  transaction_type             :string(36)
#  updated_at                   :datetime         not null
#


class PreScreeningPerformed < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :pre_screening_performed_id

  belongs_to :provider

  ncs_coded_attribute :psu,                      'PSU_CL1'
  ncs_coded_attribute :pr_pregnancy_eligible,    'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :pr_age_eligible,          'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :pr_first_provider_visit,  'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :pr_county_of_residence,   'CONFIRM_TYPE_CL3'

end
