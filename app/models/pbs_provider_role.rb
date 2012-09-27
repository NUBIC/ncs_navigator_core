# == Schema Information
#
# Table name: pbs_provider_roles
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  provider_id             :integer
#  provider_role_pbs_code  :integer          not null
#  provider_role_pbs_id    :string(36)       not null
#  provider_role_pbs_other :string(255)
#  psu_code                :integer          not null
#  transaction_type        :string(36)
#  updated_at              :datetime
#

class PbsProviderRole < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :provider_role_pbs_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_role_pbs,     'PROVIDER_STUDY_ROLE_CL2'
  belongs_to :provider
end
