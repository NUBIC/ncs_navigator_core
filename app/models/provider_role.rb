class ProviderRole < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :provider_role_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_ncs_role,     'PROVIDER_STUDY_ROLE_CL1'
  belongs_to :provider
end
