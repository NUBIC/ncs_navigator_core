# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: participant_authorization_forms
#
#  auth_form_id        :string(36)       not null
#  auth_form_type_code :integer          not null
#  auth_status_code    :integer          not null
#  auth_status_other   :string(255)
#  auth_type_other     :string(255)
#  contact_id          :integer
#  created_at          :datetime
#  id                  :integer          not null, primary key
#  participant_id      :integer
#  provider_id         :integer
#  psu_code            :integer          not null
#  transaction_type    :string(36)
#  updated_at          :datetime
#



# Table for types of forms used to obtain authorizations from the Participant.
class ParticipantAuthorizationForm < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :auth_form_id

  belongs_to :participant
  belongs_to :contact
  # belongs_to :provider

  ncs_coded_attribute :psu,            'PSU_CL1'
  ncs_coded_attribute :auth_form_type, 'AUTH_FORM_TYPE_CL1'
  ncs_coded_attribute :auth_status,    'AUTH_STATUS_CL1'

end

