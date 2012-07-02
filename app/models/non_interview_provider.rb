# -*- coding: utf-8 -*-
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
