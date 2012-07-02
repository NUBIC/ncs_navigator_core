# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: dwelling_unit_type_non_interview_reports
#
#  created_at                   :datetime
#  id                           :integer          not null, primary key
#  nir_dutype_id                :string(36)       not null
#  nir_dwelling_unit_type_code  :integer          not null
#  nir_dwelling_unit_type_other :string(255)
#  non_interview_report_id      :integer
#  psu_code                     :integer          not null
#  transaction_type             :string(36)
#  updated_at                   :datetime
#



class DwellingUnitTypeNonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_dutype_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,                     'PSU_CL1'
  ncs_coded_attribute :nir_dwelling_unit_type,  'DU_NIR_REASON_CL1'
end

