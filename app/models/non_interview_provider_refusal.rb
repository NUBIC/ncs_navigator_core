# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: non_interview_provider_refusals
#
#  created_at                :datetime
#  id                        :integer          not null, primary key
#  nir_provider_refusal_id   :string(36)       not null
#  non_interview_provider_id :integer
#  psu_code                  :integer          not null
#  refusal_reason_pbs_code   :integer          not null
#  refusal_reason_pbs_other  :string(255)
#  transaction_type          :string(255)
#  updated_at                :datetime
#

class NonInterviewProviderRefusal < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_provider_refusal_id

  belongs_to :non_interview_provider

  ncs_coded_attribute :psu,                 'PSU_CL1'
  ncs_coded_attribute :refusal_reason_pbs,  'REFUSAL_REASON_CL2'

end
