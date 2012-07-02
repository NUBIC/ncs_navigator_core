
# == Schema Information
# Schema version: 20120626221317
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

  validates_format_of :contact_start_time, :with => mdes_time_pattern, :allow_blank => true
  validates_format_of :contact_end_time,   :with => mdes_time_pattern, :allow_blank => true

  before_validation :strip_time_whitespace

  ##
  # Start a contact and prepopulate properties based on the person contacted
  # @param [Person]
  # @param [Hash]
  def self.start(person, attrs={})
    if person
      language = person.contacts.detect(&:contact_language_code)
      interpreter = person.contacts.detect(&:contact_interpret_code)
    end

    Contact.new({
      :contact_language_code => language.try(:contact_language_code),
      :contact_language_other => language.try(:contact_language_other),
      :contact_interpret_code => interpreter.try(:contact_interpret_code),
      :contact_interpret_other => interpreter.try(:contact_interpret_other)
    }.merge(attrs))
  end

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
  # Sets the time to now if the contact_end_time is empty
  # and the date is today.
  def set_default_end_time
    if self.contact_end_time.blank? && self.contact_date_date == Date.today
      self.contact_end_time = Time.now.strftime("%H:%M")
    end
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


end
