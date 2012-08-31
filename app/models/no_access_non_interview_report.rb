# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: no_access_non_interview_reports
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  nir_no_access_code      :integer          not null
#  nir_no_access_id        :string(36)       not null
#  nir_no_access_other     :string(255)
#  non_interview_report_id :integer
#  psu_code                :integer          not null
#  transaction_type        :string(36)
#  updated_at              :datetime
#



class NoAccessNonInterviewReport < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :nir_no_access_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,           'PSU_CL1'
  ncs_coded_attribute :nir_no_access, 'NO_ACCESS_DESCR_CL1'
end

