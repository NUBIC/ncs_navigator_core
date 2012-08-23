# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: vacant_non_interview_reports
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  nir_vacant_code         :integer          not null
#  nir_vacant_id           :string(36)       not null
#  nir_vacant_other        :string(255)
#  non_interview_report_id :integer
#  psu_code                :integer          not null
#  transaction_type        :string(36)
#  updated_at              :datetime
#



class VacantNonInterviewReport < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :nir_vacant_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,          'PSU_CL1'
  ncs_coded_attribute :nir_vacant,   'DU_VACANCY_INDICATOR_CL1'

end

