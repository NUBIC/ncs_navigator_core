# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: pbs_lists
#
#  cert_flag_code                 :integer
#  created_at                     :datetime
#  frame_completion_req_code      :integer          not null
#  frame_order                    :integer
#  id                             :integer          not null, primary key
#  in_out_frame_code              :integer
#  in_out_psu_code                :integer
#  in_sample_code                 :integer
#  mos                            :integer
#  pbs_list_id                    :string(36)       not null
#  pr_cooperation_date            :date
#  pr_recruitment_end_date        :date
#  pr_recruitment_start_date      :date
#  pr_recruitment_status_code     :integer
#  practice_num                   :integer
#  provider_id                    :integer
#  psu_code                       :integer          not null
#  sampling_interval_woman        :decimal(4, 2)
#  selection_probability_location :decimal(7, 6)
#  selection_probability_overall  :decimal(7, 6)
#  selection_probability_woman    :decimal(7, 6)
#  sort_var1                      :integer
#  sort_var2                      :integer
#  sort_var3                      :integer
#  stratum                        :string(255)
#  substitute_provider_id         :integer
#  transaction_type               :string(255)
#  updated_at                     :datetime
#

class PbsList < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
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

  # RECRUIT_STATUS_CL1
  # 1 (Provider Recruited)
  # 2 (Provider Not Recruited)
  # 3 (Provider Recruitment In Progress)
  # 4 (Recruitment Not Started)
  # 5 (Out of scope)
  # -7 (Not Applicable)
  # -4 (Missing in Error)

  SEARCH_LOCATIONS = ["Original location", "Substitute location"]

  def recruitment_started?
    !self.pr_recruitment_start_date.blank? && self.pr_recruitment_status_code == 3
  end

  def recruitment_ended?
    !self.pr_recruitment_end_date.blank? && ([1,2,5].include?(self.pr_recruitment_status_code))
  end

  def refused_to_participate?
    !self.pr_recruitment_end_date.blank? && self.pr_recruitment_status_code == 2
  end

  def has_substitute_provider?
    !self.substitute_provider_id.blank?
  end

end

