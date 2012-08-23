# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: refusal_non_interview_reports
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  nir_refusal_id          :string(36)       not null
#  non_interview_report_id :integer
#  psu_code                :integer          not null
#  refusal_reason_code     :integer          not null
#  refusal_reason_other    :string(255)
#  transaction_type        :string(36)
#  updated_at              :datetime
#



class RefusalNonInterviewReport < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :nir_refusal_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,             'PSU_CL1'
  ncs_coded_attribute :refusal_reason,  'REFUSAL_REASON_CL1'
end

