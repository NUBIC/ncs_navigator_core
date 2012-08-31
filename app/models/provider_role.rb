# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: provider_roles
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  provider_id             :integer
#  provider_ncs_role_code  :integer          not null
#  provider_ncs_role_other :string(255)
#  provider_role_id        :string(36)       not null
#  psu_code                :integer          not null
#  transaction_type        :string(36)
#  updated_at              :datetime
#

class ProviderRole < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :provider_role_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_ncs_role,     'PROVIDER_STUDY_ROLE_CL1'
  belongs_to :provider
end

