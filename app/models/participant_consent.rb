# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130108204723
#
# Table name: participant_consents
#
#  consent_comments                :text
#  consent_date                    :date
#  consent_expiration              :date
#  consent_form_type_code          :integer          not null
#  consent_given_code              :integer          not null
#  consent_language_code           :integer          not null
#  consent_language_other          :string(255)
#  consent_reconsent_code          :integer          default(-4), not null
#  consent_reconsent_reason_code   :integer          default(-4), not null
#  consent_reconsent_reason_other  :string(255)
#  consent_translate_code          :integer          not null
#  consent_type_code               :integer          not null
#  consent_version                 :string(9)
#  consent_withdraw_code           :integer          not null
#  consent_withdraw_date           :date
#  consent_withdraw_reason_code    :integer          not null
#  consent_withdraw_type_code      :integer          not null
#  contact_id                      :integer
#  created_at                      :datetime
#  id                              :integer          not null, primary key
#  participant_consent_id          :string(36)       not null
#  participant_id                  :integer
#  person_who_consented_id         :integer
#  person_wthdrw_consent_id        :integer
#  psu_code                        :integer          not null
#  reconsideration_script_use_code :integer          not null
#  transaction_type                :string(36)
#  updated_at                      :datetime
#  who_consented_code              :integer          not null
#  who_wthdrw_consent_code         :integer          not null
#



# Tracks the history of Participants consents and withdrawals.
class ParticipantConsent < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :participant_consent_id

  belongs_to :participant
  belongs_to :contact
  belongs_to :person_who_consented,  :class_name => "Person", :foreign_key => :person_who_consented_id
  belongs_to :person_wthdrw_consent, :class_name => "Person", :foreign_key => :person_wthdrw_consent_id

  has_many :participant_consent_samples, :order => "sample_consent_type_code"

  accepts_nested_attributes_for :participant_consent_samples, :allow_destroy => false

  ncs_coded_attribute :psu,                        'PSU_CL1'
  ncs_coded_attribute :consent_type,               'CONSENT_TYPE_CL1'
  ncs_coded_attribute :consent_form_type,          'CONSENT_TYPE_CL3'
  ncs_coded_attribute :consent_given,              'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :consent_withdraw,           'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :consent_withdraw_type,      'CONSENT_WITHDRAW_REASON_CL1'
  ncs_coded_attribute :consent_withdraw_reason,    'CONSENT_WITHDRAW_REASON_CL2'
  ncs_coded_attribute :consent_language,           'LANGUAGE_CL2'
  ncs_coded_attribute :who_consented,              'AGE_STATUS_CL1'
  ncs_coded_attribute :who_wthdrw_consent,         'AGE_STATUS_CL3'
  ncs_coded_attribute :consent_translate,          'TRANSLATION_METHOD_CL1'

  ncs_coded_attribute :reconsideration_script_use, 'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :consent_reconsent,          'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :consent_reconsent_reason,   'CONSENT_RECONSENT_REASON_CL1'

  validates_length_of :consent_version, :maximum => 9

  GENERAL          = 1
  CHILD            = 6
  LOW_INTENSITY    = 7
  MISSING_IN_ERROR = -4

  def self.consent_types
    NcsNavigatorCore.mdes.types.find { |t| t.name == 'consent_type_cl1' }.
      code_list.collect { |cl| [cl.value, cl.label.to_s.strip] }
  end

  def self.low_intensity_consent_types
    consent_types.select { |c| c[0] == "#{LOW_INTENSITY}" } # low intensity consent code
  end

  def self.child_consent_types
    consent_types.select { |c| c[0] == "#{CHILD}" } # child participation consent code
  end

  def self.high_intensity_consent_types
    ParticipantConsent.general_consent_type_code
    consent_types.select { |c| c[0] == "#{GENERAL}" } # high intensity consent codes
  end

  ##
  # Returns the consent_type_code for the "General Consent" - 1
  # @return [NcsCode]
  def self.general_consent_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", GENERAL)
  end

  ##
  # Returns the consent_type_code for the "Low Intensity Consent" - 7
  # @return [NcsCode]
  def self.low_intensity_consent_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", LOW_INTENSITY)
  end

  ##
  # Returns the consent_type_code for the "Child Consent" - 6
  # @return [NcsCode]
  def self.child_consent_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL1", CHILD)
  end

  ##
  # True if the participant gave consent in the affirmative
  # and has not withdrawn that consent
  # @return [Boolean]
  def consented?
    consent_given_code == 1 && consent_withdraw_code != 1
  end

  ##
  # Sets the consent_withdraw to Yes (1)
  # and sets the withdraw type code to the given
  # (defaulting to Involuntary withdrawal initiated by the Study)
  # @param [Integer] cf. CONSENT_WITHDRAW_REASON_CL1
  def withdraw(withdraw_type_code = 2)
    self.consent_withdraw_code = 1
    self.consent_withdraw_type_code = withdraw_type_code
  end

  def withdraw!(withdraw_type_code = 2)
    self.withdraw
    self.save!
  end

  def phase_one?
    consent_type_code && consent_type_code != -4
  end

  def phase_two?
    !phase_one?
  end

  ##
  # Finds the first associated Informed Consent Event
  # through the ParticipantConsent.contact
  # @return [Event]
  def consent_event
    return nil unless contact

    events = contact.contact_links.map(&:event).sort_by do |e|
      e.try(:event_start_date)
    end

    return events.first if events.size == 1

    events.detect do |e|
      e.event_type_code == Event.informed_consent_code
    end
  end

end

