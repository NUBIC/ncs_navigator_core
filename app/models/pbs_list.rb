class PbsList < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :pbs_list_id

  belongs_to :provider
  belongs_to :substitute_provider, :class_name => 'Provider', :foreign_key => 'substitute_provider_id'

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :in_out_frame,          'INOUT_FRAME_CL1'                 # MDES 3.0
  ncs_coded_attribute :in_sample,             'ORIGINAL_SUBSTITUTE_SAMPLE_CL1'  # MDES 3.0
  ncs_coded_attribute :in_out_psu,            'INOUT_PSU_CL1'                   # MDES 3.0
  ncs_coded_attribute :cert_flag,             'CERT_UNIT_CL1'                   # MDES 3.0
  ncs_coded_attribute :frame_completion_req,  'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :pr_recruitment_status, 'RECRUIT_STATUS_CL1'              # MDES 3.0

end
