class ProviderLogistic < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :provider_logistics_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_logistics,    'PROVIDER_LOGISTICS_CL1'

  belongs_to :provider
end
