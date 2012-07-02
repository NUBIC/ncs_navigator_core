# -*- coding: utf-8 -*-
class NonInterviewProviderRefusal < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_provider_refusal_id

  belongs_to :non_interview_provider

  ncs_coded_attribute :psu,                 'PSU_CL1'
  ncs_coded_attribute :refusal_reason_pbs,  'REFUSAL_REASON_CL2'

end
