# == Schema Information
# Schema version: 20120222225559
#
# Table name: dwelling_unit_type_non_interview_reports
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  nir_dutype_id                :string(36)      not null
#  non_interview_report_id      :integer
#  nir_dwelling_unit_type_code  :integer         not null
#  nir_dwelling_unit_type_other :string(255)
#  transaction_type             :string(36)
#  created_at                   :datetime
#  updated_at                   :datetime
#

class DwellingUnitTypeNonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_dutype_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,                     'PSU_CL1'
  ncs_coded_attribute :nir_dwelling_unit_type,  'DU_NIR_REASON_CL1'
end
