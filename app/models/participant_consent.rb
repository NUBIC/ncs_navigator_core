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
  has_one :response_set, :inverse_of => :participant_consent

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

  PREGNANT_WOMAN_CONSENT = 1
  NON_PREGNANT_WOMAN_CONSENT = 2
  FATHER_CONSENT = 3
  CHILD_CONSENT_BIRTH_TO_6_MONTHS = 4
  CHILD_CONSENT_6_MONTHS_TO_AGE_OF_MAJORITY = 5
  NEW_ADULT_CONSENT = 6

  def self.consent_types
    NcsNavigatorCore.mdes.types.find { |t| t.name == 'consent_type_cl1' }.
      code_list.collect { |cl| [cl.value, cl.label.to_s.strip] }
  end

  def self.consent_form_types
    NcsNavigatorCore.mdes.types.find { |t| t.name == 'consent_type_cl3' }.
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
  # Returns the consent_type_code for the "Child Consent Birth to 6 Months" - 4
  # @return [NcsCode]
  def self.child_consent_birth_to_6_months_form_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL3", CHILD_CONSENT_BIRTH_TO_6_MONTHS)
  end

  ##
  # Returns the consent_type_code for the "Child Consent 6 Months to Age of Majority" - 5
  # @return [NcsCode]
  def self.child_consent_6_months_to_age_of_majority_form_type_code
    NcsCode.for_list_name_and_local_code("CONSENT_TYPE_CL3", CHILD_CONSENT_6_MONTHS_TO_AGE_OF_MAJORITY)
  end

  ##
  # True if the participant gave consent in the affirmative
  # and has not withdrawn that consent
  # @return [Boolean]
  def consented?
    consent_given_code == NcsCode::YES
  end

  ##
  # True if this consent is a reconsent
  # @return [Boolean]
  def reconsent?
    consent_reconsent_code == NcsCode::YES
  end

  ##
  # True if this consent is a withdrawal
  # If the consent_withdraw_code was answered.
  # @return [Boolean]
  def withdrawal?
    consent_withdraw_code > NcsCode::MISSING_IN_ERROR
  end

  def child_consent_birth_to_six_months?
    consent_form_type_code == CHILD_CONSENT_BIRTH_TO_6_MONTHS
  end

  def child_consent_six_month_to_age_of_majority?
    consent_form_type_code == CHILD_CONSENT_6_MONTHS_TO_AGE_OF_MAJORITY
  end

  ##
  # True if this consent is a reconsent and the
  # participant gave consent in the affirmative
  # @return [Boolean]
  def reconsented?
    reconsent? && consented?
  end

  ##
  # True if the participant withdrew consent in the affirmative
  # @return [Boolean]
  def withdrawn?
    consent_withdraw_code == NcsCode::YES
  end

  def phase_one?
    consent_type_code && consent_type_code != NcsCode::MISSING_IN_ERROR
  end

  def phase_two?
    !phase_one?
  end

  def description
    if withdrawn?
      "Withdrawal"
    elsif phase_one?
      consent_type.display_text
    else
      consent_form_type.display_text
    end
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

  ##
  # Finds or creates a record to indicate that a person has begun taking a
  # survey for the Informed Consent. The ParticipantConsent returned will also
  # have an associated ResponseSet and ParticipantConsentSample records of each
  # sample_consent_type.
  #
  # @param [Person] the person taking the survey
  # @param [Participant] the participant who the survey is about
  # @param [Survey] Survey with title matching PSC activity instrument label
  # @param [Contact]
  # @return[ParticipantConsent]
  def self.start!(person, participant, survey, contact)
    where_clause = "response_sets.survey_id = ? AND response_sets.user_id = ? and participant_consents.contact_id = ?"
    rs = ResponseSet.includes(:participant_consent).where(where_clause, survey.id, person.id, contact.id).first
    rs.nil? ? create_consent(person, participant, survey, contact) : rs.participant_consent
  end

  def self.create_consent(person, participant, survey, contact)
    pc = participant.participant_consents.build(:contact => contact, :psu => participant.psu)
    pc.build_response_set(:survey_id => survey.id, :user_id => person.id, :participant_id => participant.id)

    ParticipantConsentSample::SAMPLE_CONSENT_TYPE_CODES.each do |code|
      pc.participant_consent_samples.build(:sample_consent_type_code => code, :participant => @participant)
    end

    pc.save!
    pc
  end

end
