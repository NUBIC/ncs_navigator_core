# == Schema Information
# Schema version: 20120626221317
#
# Table name: provider_logistics
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  provider_logistics_id    :string(36)      not null
#  provider_id              :integer
#  provider_logistics_code  :integer         not null
#  provider_logistics_other :string(255)
#  transaction_type         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#

class ProviderLogistic < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :provider_logistics_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_logistics,    'PROVIDER_LOGISTICS_CL1'

  belongs_to :provider
end
