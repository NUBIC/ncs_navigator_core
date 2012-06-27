# == Schema Information
# Schema version: 20120626221317
#
# Table name: provider_roles
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  provider_role_id        :string(36)      not null
#  provider_id             :integer
#  provider_ncs_role_code  :integer         not null
#  provider_ncs_role_other :string(255)
#  transaction_type        :string(36)
#  created_at              :datetime
#  updated_at              :datetime
#

class ProviderRole < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :provider_role_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_ncs_role,     'PROVIDER_STUDY_ROLE_CL1'
  belongs_to :provider
end
