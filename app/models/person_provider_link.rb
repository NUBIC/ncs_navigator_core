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

