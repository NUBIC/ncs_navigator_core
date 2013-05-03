# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130502152819
#
# Table name: participant_person_links
#
#  created_at                  :datetime
#  id                          :integer          not null, primary key
#  is_active_code              :integer          not null
#  multi_birth_id              :string(36)
#  participant_id              :integer          not null
#  person_id                   :integer          not null
#  person_pid_id               :string(36)       not null
#  primary_caregiver_flag_code :integer          default(-4), not null
#  psu_code                    :integer          not null
#  relationship_code           :integer          not null
#  relationship_other          :string(255)
#  response_set_id             :integer
#  transaction_type            :string(36)
#  updated_at                  :datetime
#



# The same Person can be a respondent or informant for many Participants.
# One Participant can have many respondents or informants who provide
# information about him/her. As a consequence, there is a many to many
# relationship between Participant and Person. The link that defines this
# relationship contains specific information about the relationship.
class ParticipantPersonLink < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :person_pid_id

  belongs_to :person
  belongs_to :participant
  belongs_to :response_set
  ncs_coded_attribute :psu,                       'PSU_CL1'
  ncs_coded_attribute :relationship,              'PERSON_PARTCPNT_RELTNSHP_CL1'
  ncs_coded_attribute :is_active,                 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :primary_caregiver_flag,    'CONFIRM_TYPE_CL2'

  # Validating :person_id instead of :person prevents a reload of the
  # associated object when creating an instance alone. This provides a
  # huge speedup in the importer; if validating the associated
  # instance is necessary, we should provide a scoped validation so it
  # can be excluded in the importer context.
  validates_presence_of :person_id
  validates_presence_of :participant_id

  def initialize(*args)
    super
    if self.is_active_code.blank?
      self.is_active_code = NcsCode::YES
    end
  end

  def active?
    self.is_active_code == NcsCode::YES
  end

  def self_relationship?
    self.relationship_code == ParticipantPersonLink.person_self_code
  end

  ##
  # PERSON_PARTCPNT_RELTNSHP_CL1
  def self.person_self_code
    1
  end
end

