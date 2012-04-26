# encoding: utf-8

# == Schema Information
# Schema version: 20120404205955
#
# Table name: vacant_non_interview_reports
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  nir_vacant_id           :string(36)      not null
#  non_interview_report_id :integer
#  nir_vacant_code         :integer         not null
#  nir_vacant_other        :string(255)
#  transaction_type        :string(36)
#  created_at              :datetime
#  updated_at              :datetime
#

class VacantNonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_vacant_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,          'PSU_CL1'
  ncs_coded_attribute :nir_vacant,   'DU_VACANCY_INDICATOR_CL1'

end