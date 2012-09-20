# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: provider_logistics
#
#  completion_date          :date
#  created_at               :datetime
#  id                       :integer          not null, primary key
#  provider_id              :integer
#  provider_logistics_code  :integer          not null
#  provider_logistics_id    :string(36)       not null
#  provider_logistics_other :string(255)
#  psu_code                 :integer          not null
#  transaction_type         :string(255)
#  updated_at               :datetime
#

class ProviderLogistic < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :provider_logistics_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_logistics,    'PROVIDER_LOGISTICS_CL1'

  belongs_to :provider

  ##
  # True if completion date exists
  def complete?
    !self.completion_date.blank?
  end
end
