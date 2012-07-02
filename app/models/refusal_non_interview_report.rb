# -*- coding: utf-8 -*-


class RefusalNonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_refusal_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,             'PSU_CL1'
  ncs_coded_attribute :refusal_reason,  'REFUSAL_REASON_CL1'
end

