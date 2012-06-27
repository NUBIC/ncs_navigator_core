# == Schema Information
# Schema version: 20120626221317
#
# Table name: non_interview_providers
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  non_interview_provider_id    :string(36)      not null
#  contact_id                   :integer
#  provider_id                  :integer
#  nir_type_provider_code       :integer         not null
#  nir_type_provider_other      :string(255)
#  nir_closed_info_code         :integer         not null
#  nir_closed_info_other        :string(255)
#  when_closure                 :date
#  perm_closure_code            :integer         not null
#  who_refused_code             :integer         not null
#  who_refused_other            :string(255)
#  refuser_strength_code        :integer         not null
#  ref_action_provider_code     :integer         not null
#  who_confirm_noprenatal_code  :integer         not null
#  who_confirm_noprenatal_other :string(255)
#  nir_moved_info_code          :integer         not null
#  nir_moved_info_other         :string(255)
#  when_moved                   :date
#  perm_moved_code              :integer         not null
#  nir_pbs_comment              :text
#  transaction_type             :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#

class NonInterviewProvider < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :non_interview_provider_id

  belongs_to :contact
  belongs_to :provider

  has_many :non_interview_provider_refusals

  ncs_coded_attribute :psu,                       'PSU_CL1'
  ncs_coded_attribute :nir_type_provider,         'NON_INTERVIEW_CL1'
  ncs_coded_attribute :nir_closed_info,           'INFORMATION_SOURCE_CL8'
  ncs_coded_attribute :perm_closure,              'CONFIRM_TYPE_CL10'
  ncs_coded_attribute :who_refused,               'REFUSAL_PROVIDER_CL1'
  ncs_coded_attribute :refuser_strength,          'REFUSAL_INTENSITY_CL2'
  ncs_coded_attribute :ref_action_provider,       'REFUSAL_ACTION_CL1'
  ncs_coded_attribute :who_confirm_noprenatal,    'REFUSAL_PROVIDER_CL1'
  ncs_coded_attribute :nir_moved_info,            'INFORMATION_SOURCE_CL8'
  ncs_coded_attribute :perm_moved,                'CONFIRM_TYPE_CL10'

end
