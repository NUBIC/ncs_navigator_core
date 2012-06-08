# == Schema Information
# Schema version: 20120607203203
#
# Table name: person_provider_links
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  person_provider_id           :string(36)      not null
#  provider_id                  :integer
#  person_id                    :integer
#  is_active_code               :integer         not null
#  provider_intro_outcome_code  :integer         not null
#  provider_intro_outcome_other :string(255)
#  transaction_type             :string(36)
#  created_at                   :datetime
#  updated_at                   :datetime
#

class PersonProviderLink < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_provider_id

  ncs_coded_attribute :psu,                     'PSU_CL1'
  ncs_coded_attribute :is_active,               'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :provider_intro_outcome,  'STUDY_INTRODCTN_OUTCOME_CL1'
  belongs_to :provider
  belongs_to :person
  
  validates_presence_of :provider
  validates_presence_of :person
end
