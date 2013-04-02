# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: participant_consent_samples
#
#  created_at                    :datetime
#  id                            :integer          not null, primary key
#  participant_consent_id        :integer
#  participant_consent_sample_id :string(36)       not null
#  participant_id                :integer
#  psu_code                      :integer          not null
#  sample_consent_given_code     :integer          not null
#  sample_consent_type_code      :integer          not null
#  transaction_type              :string(36)
#  updated_at                    :datetime
#



# Table for types of samples (e.g. Biospecimen, Genetic, etc.) that require Participant consent for collection.
class ParticipantConsentSample < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :participant_consent_sample_id

  belongs_to :participant
  belongs_to :participant_consent

  ncs_coded_attribute :psu,                  'PSU_CL1'
  ncs_coded_attribute :sample_consent_type,  'CONSENT_TYPE_CL2'
  ncs_coded_attribute :sample_consent_given, 'CONFIRM_TYPE_CL2'

  ENVIRONMENTAL = 1
  BIOSPECIMEN   = 2
  GENETIC       = 3
  SAMPLE_CONSENT_TYPE_CODES = [ENVIRONMENTAL, BIOSPECIMEN, GENETIC]

  def self.consent_types
    NcsNavigatorCore.mdes.types.find { |t| t.name == 'consent_type_cl2' }.
      code_list.collect { |cl| [cl.value, cl.label.to_s.strip] }.
      select { |ct| SAMPLE_CONSENT_TYPE_CODES.include? ct[0].to_i }
  end

  def self.environmental_consent_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL2", ENVIRONMENTAL)
  end

  def self.biospecimen_consent_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL2", BIOSPECIMEN)
  end

  def self.genetic_consent_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL2", GENETIC)
  end

  def consented?
    sample_consent_given_code == NcsCode::YES
  end

end

