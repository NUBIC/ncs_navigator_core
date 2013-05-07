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
  include NcsNavigator::Core::Surveyor::SurveyTaker
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

  HIGH_INTENSITY_CONSENT_TYPES = [GENERAL]

  HIGH_INTENSITY_CONSENT_FORM_TYPES = [
    PREGNANT_WOMAN_CONSENT,
    NON_PREGNANT_WOMAN_CONSENT,
    NEW_ADULT_CONSENT
  ]

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

  def high_intensity?
    HIGH_INTENSITY_CONSENT_TYPES.include?(consent_type_code) ||
      HIGH_INTENSITY_CONSENT_FORM_TYPES.include?(consent_form_type_code)
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
  # For legacy participant consents, create an associated response_set
  # from the existing data for the internal_survey
  # cf. internal_surveys/IRB_CON_Informed_Consent.rb
  def associate_response_set
    return unless response_set.nil?

    survey = Survey.most_recent_for_access_code('IRB_CON_Informed_Consent')
    return if survey.nil? || self.participant.nil? || self.participant.person.nil?

    rs = self.build_response_set(:survey => survey,
      :user_id => self.participant.person.id, :participant_id => self.participant_id)

    respond(rs) do |r|
      r.using_data_export_identifiers do |ra|
        set_answer(ra, 'consent_type', withdrawn? ? '3' : '1')
        set_answer(ra, 'consent_form_type_code')
        set_answer(ra, 'consent_given_code')
        set_answer_value(ra, 'consent_date')
        set_answer_value(ra, 'consent_version')
        set_answer_value(ra, 'consent_expiration')
        set_answer(ra, 'who_consented_code')
        set_answer(ra, 'consent_reconsent_code')
        set_answer(ra, 'consent_reconsent_reason_code')
        set_answer_value(ra, 'consent_reconsent_reason_other')
        set_answer(ra, 'consent_withdraw_code')
        set_answer(ra, 'consent_withdraw_reason_code')
        set_answer_value(ra, 'consent_withdraw_date')
        set_answer(ra, 'who_wthdrw_consent_code')

        unless self.phase_one?
          set_answer(ra, 'collect_specimen_consent', (participant_consent_samples.count > 0) ? '1' : '2')

          self.participant_consent_samples.each do |s|
            if s.sample_consent_given_code && s.sample_consent_given_code != NcsCode::MISSING_IN_ERROR
              a = "sample_consent_given_code_#{s.sample_consent_type_code}"
              v = s.sample_consent_given_code.to_s
              ra.answer a, v
            end
          end
        end

        set_answer(ra, 'consent_language_code')
        set_answer(ra, 'consent_translate_code')
        set_answer(ra, 'reconsideration_script_use_code')

        set_answer_value(ra, 'consent_comments')
      end
    end

    self.save
    rs
  end

  def set_answer(r, a, v = nil)
    answer_value = v.nil? ? self.send(a) : v
    if !answer_value.nil? && answer_value.to_i != NcsCode::MISSING_IN_ERROR
      value = answer_value.to_s
      if answer_value.to_i < 0
        value = value.gsub("-", "neg_")
      end
      r.answer a, value
    end
  end
  private :set_answer

  def set_answer_value(r, a, v = nil)
    value = v.nil? ? self.send(a) : v.to_s
    unless value.blank?
      r.answer a, a, :value => value
    end
  end

  ##
  # Finds or creates a record to indicate that a person has begun taking a
  # survey for the Informed Consent. The ParticipantConsent returned will also
  # have an associated ResponseSet and ParticipantConsentSample records of each
  # sample_consent_type.
  #
  # This method creates an association to the ResponseSet via the
  # ResponseSet belongs_to association.
  # DO NOT USE THIS METHOD UNLESS YOU KNOW WHAT THAT MEANS
  #
  # @see ResponseSet.instrument
  #
  # @param [Person] the person taking the survey
  # @param [Participant] the participant who the survey is about
  # @param [Survey] Survey with title matching PSC activity instrument label
  # @param [Contact]
  # @return[ParticipantConsent]
  def self.start!(person, participant, survey, contact, contact_link)
    where_clause =  "response_sets.survey_id = ? AND "
    where_clause << "response_sets.user_id = ? AND "
    where_clause << "response_sets.participant_id = ? AND "
    where_clause << "participant_consents.contact_id = ?"
    rs = ResponseSet.includes(:participant_consent).where(
            where_clause, survey.id, person.id, participant.id, contact.id).first
    rs.nil? ? create_consent(person, participant, survey, contact, contact_link) : rs.participant_consent
  end

  def self.create_consent(person, participant, survey, contact, contact_link)
    pc = participant.participant_consents.build(:contact => contact, :psu => participant.psu)
    pc.build_response_set(:survey_id => survey.id, :user_id => person.id, :participant_id => participant.id)

    ParticipantConsentSample::SAMPLE_CONSENT_TYPE_CODES.each do |code|
      pc.participant_consent_samples.build(:sample_consent_type_code => code, :participant => @participant)
    end

    create_informed_consent_event(participant, contact, contact_link)

    pc.save!
    pc
  end

  ##
  # Creates an Informed Consent Event for the given participant,
  # contact, and contact_link
  # @param[Participant]
  # @param[Contact]
  # @param[ContactLink]
  def self.create_informed_consent_event(participant, contact, contact_link)
    if should_create_informed_consent_record?(participant, contact, contact_link)
      ActiveRecord::Base.transaction do
        comment = "Informed Consent Event record created from ParticipantConsent record"
        event = Event.create(:participant => participant,
                             :event_type_code => Event.informed_consent_code,
                             :event_breakoff_code => NcsCode::NO,
                             :event_comment => comment,
                             :event_start_date => determine_informed_consent_event_date(contact_link),
                             :event_repeat_key => 0)
        ContactLink.create(:event => event, :contact => contact,
                           :person => contact_link.person, :staff_id => contact_link.staff_id)
      end
    end
  end
  private_class_method :create_informed_consent_event

  ##
  # Determine a default start date for this event
  # First check associated event, then check associated contact, then use today
  # @param[ContactLink]
  # @return[Date]
  def self.determine_informed_consent_event_date(contact_link)
    dt = Date.today
    if !contact_link.contact.try(:contact_date).blank?
      dt = contact_link.contact.try(:contact_date)
    elsif !contact_link.event.try(:event_start_date).blank?
      dt = contact_link.event.try(:event_start_date)
    end
    dt
  end
  private_class_method :determine_informed_consent_event_date

  ##
  # Returns false if the contact_link.event is an informed consent event.
  #
  # Return true if there are no Informed Consent Events associated with
  # the given Participant.
  #
  # If there are Informed Consent Events associated with the participant
  # return true if none are associated with the given Contact.
  #
  # @param[Participant]
  # @param[Contact]
  # @param[ContactLink]
  # @return[Boolean]
  def self.should_create_informed_consent_record?(participant, contact, contact_link)
    return false if contact_link.event.try(:informed_consent?)

    rel = Event.where(:participant_id => participant.id, :event_type_code => Event.informed_consent_code)
    rel.count == 0 || !rel.joins(:contacts).exists?('contacts.id' => contact.id)
  end
  private_class_method :should_create_informed_consent_record?

end
