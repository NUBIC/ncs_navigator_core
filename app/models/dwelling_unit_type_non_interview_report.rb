# -*- coding: utf-8 -*-


class DwellingUnitTypeNonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_dutype_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,                     'PSU_CL1'
  ncs_coded_attribute :nir_dwelling_unit_type,  'DU_NIR_REASON_CL1'
end

