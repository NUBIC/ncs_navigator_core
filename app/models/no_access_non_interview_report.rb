

class NoAccessNonInterviewReport < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :nir_no_access_id

  belongs_to :non_interview_report

  ncs_coded_attribute :psu,           'PSU_CL1'
  ncs_coded_attribute :nir_no_access, 'NO_ACCESS_DESCR_CL1'
end

