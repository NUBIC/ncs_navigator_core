# == Schema Information
# Schema version: 20120607203203
#
# Table name: pbs_lists
#
#  id                             :integer         not null, primary key
#  psu_code                       :integer         not null
#  pbs_list_id                    :string(36)      not null
#  provider_id                    :integer
#  practice_num                   :integer
#  in_out_frame_code              :integer
#  in_sample_code                 :integer
#  substitute_provider_id         :integer
#  in_out_psu_code                :integer
#  mos                            :integer
#  cert_flag_code                 :integer
#  stratum                        :string(255)
#  sort_var1                      :integer
#  sort_var2                      :integer
#  sort_var3                      :integer
#  frame_order                    :integer
#  selection_probability_location :decimal(7, 6)
#  sampling_interval_woman        :decimal(4, 2)
#  selection_probability_woman    :decimal(7, 6)
#  selection_probability_overall  :decimal(7, 6)
#  frame_completion_req_code      :integer         not null
#  pr_recruitment_status_code     :integer
#  pr_recruitment_start_date      :date
#  pr_cooperation_date            :date
#  pr_recruitment_end_date        :date
#  transaction_type               :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#

class PbsList < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :pbs_list_id

  belongs_to :provider
  belongs_to :substitute_provider, :class_name => 'Provider', :foreign_key => 'substitute_provider_id'

  validates_presence_of :provider

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :in_out_frame,          'INOUT_FRAME_CL1'                 # MDES 3.0
  ncs_coded_attribute :in_sample,             'ORIGINAL_SUBSTITUTE_SAMPLE_CL1'  # MDES 3.0
  ncs_coded_attribute :in_out_psu,            'INOUT_PSU_CL1'                   # MDES 3.0
  ncs_coded_attribute :cert_flag,             'CERT_UNIT_CL1'                   # MDES 3.0
  ncs_coded_attribute :frame_completion_req,  'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :pr_recruitment_status, 'RECRUIT_STATUS_CL1'              # MDES 3.0

end
