class Provider < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :provider_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_type,         'PROVIDER_TYPE_CL1'
  ncs_coded_attribute :provider_ncs_role,     'PROVIDER_STUDY_ROLE_CL1'
  ncs_coded_attribute :practice_info,         'PRACTICE_CHARACTERISTIC_CL1'
  ncs_coded_attribute :practice_patient_load, 'PRACTICE_LOAD_RANGE_CL1'
  ncs_coded_attribute :practice_size,         'PRACTICE_SIZE_RANGE_CL1'
  ncs_coded_attribute :public_practice,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :provider_info_source,  'INFORMATION_SOURCE_CL2'
end
