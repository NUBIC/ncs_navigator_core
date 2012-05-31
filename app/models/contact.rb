# == Schema Information
# Schema version: 20120515181518
#
# Table name: contacts
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  contact_id              :string(36)      not null
#  contact_disposition     :integer
#  contact_type_code       :integer         not null
#  contact_type_other      :string(255)
#  contact_date            :string(10)
#  contact_date_date       :date
#  contact_start_time      :string(255)
#  contact_end_time        :string(255)
#  contact_language_code   :integer         not null
#  contact_language_other  :string(255)
#  contact_interpret_code  :integer         not null
#  contact_interpret_other :string(255)
#  contact_location_code   :integer         not null
#  contact_location_other  :string(255)
#  contact_private_code    :integer         not null
#  contact_private_detail  :string(255)
#  contact_distance        :decimal(6, 2)
#  who_contacted_code      :integer         not null
#  who_contacted_other     :string(255)
#  contact_comment         :text
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  lock_version            :integer         default(0)
#

# -*- coding: utf-8 -*-

# Staff makes Contact with a Person pursuant to a protocol – either one
# of the recruitment schemas or a Study assessment protocol.
# The scope of a Contact may include one or more Events, one or more
# Instruments in an Event and one or more Specimens that some Instruments collect.
class Contact < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :contact_id, :date_fields => [:contact_date]

  TELEPHONE_CONTACT_CODE = 3
  MAILING_CONTACT_CODE   = 2

  ncs_coded_attribute :psu,               'PSU_CL1'
  ncs_coded_attribute :contact_type,      'CONTACT_TYPE_CL1'
  ncs_coded_attribute :contact_language,  'LANGUAGE_CL2'
  ncs_coded_attribute :contact_interpret, 'TRANSLATION_METHOD_CL3'
  ncs_coded_attribute :contact_location,  'CONTACT_LOCATION_CL1'
  ncs_coded_attribute :contact_private,   'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :who_contacted,     'CONTACTED_PERSON_CL1'

  has_many :contact_links
  has_many :instruments, :through => :contact_links
  has_many :non_interview_reports
  has_one :participant_visit_record
  has_many :participant_visit_consents

  validates_format_of :contact_start_time, :with => /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, :allow_blank => true
  validates_format_of :contact_end_time,   :with => /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, :allow_blank => true

  before_validation :strip_time_whitespace

  def strip_time_whitespace
    self.contact_start_time.strip! if self.contact_start_time
    self.contact_end_time.strip! if self.contact_end_time
  end
  private :strip_time_whitespace


  ##
  # An event is 'closed' or 'completed' if the disposition has been set.
  # @return [true, false]
  def closed?
    contact_disposition.to_i > 0
  end
  alias completed? closed?
  alias complete? closed?

  ##
  # Given a person, determine the langugage and interpreter value used during the
  # instruments taken.
  # This method assumes that the contact took place in the same language/interpreter
  # as the initial instrument taken
  # @param [Person]
  def set_language_and_interpreter_data(person)
    if person
      set_language(person)
      set_interpreter(person)
    end
  end

  ##
  # Given an instrument, presumably after the instrument has been administered, set attributes on the
  # contact that can be inferred based on the instrument and type of contact
  # @param [Instrument]
  # @param [ResponseSet]
  def populate_post_survey_attributes(instrument = nil, response_set = nil)

    # TODO: determine if the response_set for the instrument has been completed
    if instrument
      self.who_contacted = NcsCode.for_attribute_name_and_local_code(:who_contacted_code, 1)
    end

    case contact_type.to_i
    when TELEPHONE_CONTACT_CODE, MAILING_CONTACT_CODE
      self.contact_location = NcsCode.for_attribute_name_and_local_code(:contact_location_code, 2)
      self.contact_private  = NcsCode.for_attribute_name_and_local_code(:contact_private_code, 2)
      self.contact_distance = 0.0
    else
      # NOOP
    end
  end

  ##
  # @return [Array<Instrument>] where the instrument has an associated Survey
  def instruments_with_surveys
    instruments.select { |i| !i.survey.nil? }
  end

  ##
  # @return [Array<String>] Instrument Survey titles
  def instrument_survey_titles
    instruments_with_surveys.collect {|i| i.survey.title}
  end

  ##
  # @return [Boolean] true if the contact has a participant_visit_consent of given vis_consent_type_code
  def has_participant_visit_consent?(vis_consent_type_code)
    participant_visit_consents.where(:vis_consent_type_code => vis_consent_type_code).count > 0
  end

  ##
  # Given a collection of participant ids return the last contact for events
  # associated with these participants
  # @param[Array<Integer>]
  # @result[Array[Contact]]
  def self.last_contact(participant_ids)
    return nil if participant_ids.blank?
    inner_select = "select max(c1.contact_date) from contacts c1
    	              left outer join contact_links cl1 on cl1.contact_id = c1.id
                    left outer join events e1 on e1.id = cl1.event_id
                    where e1.participant_id = events.participant_id"
    Contact.select("events.participant_id, contacts.contact_date, contact_disposition, contact_start_time, contact_end_time").
            joins("left outer join contact_links on contact_links.contact_id = contacts.id
                   left outer join events on events.id = contact_links.event_id").
            where("contact_date = (#{inner_select}) and events.participant_id in (?)", participant_ids).all
  end

  private

    def set_language(person)
      english_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::ENGLISH).last

      if english_response && english_response.to_s == "Yes"
        self.contact_language = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', english_response.answer.reference_identifier)
        return
      end

      language_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_LANG).last
      if language_response && language_response.answer.reference_identifier.to_i > 0
        language_response_value = NcsCode.for_list_name_and_local_code('LANGUAGE_CL5', language_response.answer.reference_identifier)
        self.contact_language = NcsCode.for_list_name_and_display_text('LANGUAGE_CL2', language_response_value.to_s)
        return
      end

      other_language_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_LANG_OTH).last
      self.contact_language_other = other_language_response.to_s if other_language_response

    end

    def set_interpreter(person)
      interpreter_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::INTERPRET).last

      if interpreter_response && interpreter_response.to_s == "No"
        self.contact_interpret = NcsCode.for_list_name_and_local_code('TRANSLATION_METHOD_CL3', -3)
        return
      end

      interpreter_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_INTERPRET).last
      if interpreter_response && interpreter_response.answer.reference_identifier.to_i > 0
        self.contact_interpret = NcsCode.for_list_name_and_local_code('TRANSLATION_METHOD_CL3', interpreter_response.answer.reference_identifier)
        return
      end

      other_interpreter_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_INTERPRET_OTH).last
      self.contact_interpret_other = other_interpreter_response.to_s if other_interpreter_response

    end
end
