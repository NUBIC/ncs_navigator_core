# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: person_provider_links
#
#  created_at                   :datetime
#  id                           :integer          not null, primary key
#  is_active_code               :integer          not null
#  person_id                    :integer
#  person_provider_id           :string(36)       not null
#  provider_id                  :integer
#  provider_intro_outcome_code  :integer          not null
#  provider_intro_outcome_other :string(255)
#  psu_code                     :integer          not null
#  transaction_type             :string(36)
#  updated_at                   :datetime
#

class PersonProviderLink < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :person_provider_id

  ncs_coded_attribute :psu,                     'PSU_CL1'
  ncs_coded_attribute :is_active,               'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :provider_intro_outcome,  'STUDY_INTRODCTN_OUTCOME_CL1'
  belongs_to :provider
  belongs_to :person
  
  validates_presence_of :provider
  validates_presence_of :person
end

