# == Schema Information
# Schema version: 20120222225559
#
# Table name: no_access_non_interview_reports
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  nir_no_access_id        :string(36)      not null
#  non_interview_report_id :integer
#  nir_no_access_code      :integer         not null
#  nir_no_access_other     :string(255)
#  transaction_type        :string(36)
#  created_at              :datetime
#  updated_at              :datetime
#

class NoAccessNonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_no_access_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,           'PSU_CL1'
  ncs_coded_attribute :nir_no_access, 'NO_ACCESS_DESCR_CL1'
end
