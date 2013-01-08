# == Schema Information
# Schema version: 20121220214234
#
# Table name: institutions
#
#  created_at                  :datetime
#  id                          :integer          not null, primary key
#  institute_comment           :text
#  institute_id                :string(255)      not null
#  institute_info_date         :date
#  institute_info_source_code  :integer          not null
#  institute_info_source_other :string(255)
#  institute_info_update       :date
#  institute_name              :string(255)
#  institute_owner_code        :integer          not null
#  institute_owner_other       :string(255)
#  institute_relation_code     :integer          not null
#  institute_relation_other    :string(255)
#  institute_size              :integer
#  institute_type_code         :integer          not null
#  institute_type_other        :string(255)
#  institute_unit_code         :integer          not null
#  institute_unit_other        :string(255)
#  psu_code                    :string(36)       not null
#  response_set_id             :integer
#  transaction_type            :string(36)
#  updated_at                  :datetime
#

class Institution < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :institute_id

  ncs_coded_attribute :psu,                      'PSU_CL1'
  ncs_coded_attribute :institute_type,           'ORGANIZATION_TYPE_CL1'
  ncs_coded_attribute :institute_relation,       'PERSON_ORGNZTN_FUNCTION_CL1'
  ncs_coded_attribute :institute_owner,          'ORGANIZATION_OWNERSHIP_CL1'
  ncs_coded_attribute :institute_unit,           'ORGANIZATION_SIZE_UNIT_CL1'
  ncs_coded_attribute :institute_info_source,    'INFORMATION_SOURCE_CL2'

  has_many :addresses, :foreign_key => 'institute_id'

end
