# -*- coding: utf-8 -*-


class InstitutionPersonLink < ActiveRecord::Base

  include NcsNavigator::Core::Mdes::MdesRecord

  acts_as_mdes_record :public_id_field => :person_institute_id

  belongs_to :institution
  belongs_to :person

  ncs_coded_attribute :psu,                       'PSU_CL1'
  ncs_coded_attribute :is_active,                 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :institute_relation,        'PERSON_ORGNZTN_FUNCTION_CL1'
end
