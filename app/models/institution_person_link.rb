# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130129202515
#
# Table name: institution_person_links
#
#  created_at               :datetime         not null
#  id                       :integer          not null, primary key
#  institute_relation_code  :integer          not null
#  institute_relation_other :string(255)
#  institution_id           :integer          not null
#  is_active_code           :integer          not null
#  person_id                :integer          not null
#  person_institute_id      :string(36)       not null
#  psu_code                 :string(36)       not null
#  transaction_type         :string(36)
#  updated_at               :datetime         not null
#



class InstitutionPersonLink < ActiveRecord::Base

  include NcsNavigator::Core::Mdes::MdesRecord

  acts_as_mdes_record :public_id_field => :person_institute_id

  belongs_to :institution
  belongs_to :person

  ncs_coded_attribute :psu,                       'PSU_CL1'
  ncs_coded_attribute :is_active,                 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :institute_relation,        'PERSON_ORGNZTN_FUNCTION_CL1'
end
