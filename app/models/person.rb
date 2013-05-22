# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130108201329
#
# Table name: people
#
#  age                            :integer
#  age_range_code                 :integer          not null
#  being_processed                :boolean          default(FALSE)
#  created_at                     :datetime
#  date_move                      :string(7)
#  date_move_date                 :date
#  deceased_code                  :integer          not null
#  ethnic_group_code              :integer          not null
#  first_name                     :string(30)
#  id                             :integer          not null, primary key
#  language_code                  :integer          not null
#  language_new_code              :integer          not null
#  language_new_other             :string(255)
#  language_other                 :string(255)
#  last_name                      :string(30)
#  lock_version                   :integer          default(0)
#  maiden_name                    :string(30)
#  marital_status_code            :integer          not null
#  marital_status_other           :string(255)
#  middle_name                    :string(30)
#  move_info_code                 :integer          not null
#  p_info_date                    :date
#  p_info_source_code             :integer          not null
#  p_info_source_other            :string(255)
#  p_info_update                  :date
#  p_tracing_code                 :integer          not null
#  person_comment                 :text
#  person_dob                     :string(10)
#  person_dob_date                :date
#  person_id                      :string(36)       not null
#  planned_move_code              :integer          not null
#  preferred_contact_method_code  :integer          not null
#  preferred_contact_method_other :string(255)
#  prefix_code                    :integer          not null
#  psu_code                       :integer          not null
#  response_set_id                :integer
#  role                           :string(255)
#  sex_code                       :integer          not null
#  suffix_code                    :integer          not null
#  title                          :string(5)
#  transaction_type               :string(36)
#  updated_at                     :datetime
#  when_move_code                 :integer          not null
#

# A Person is an individual who may provide information on a participant.
# All individuals contacted are Persons, including those who may also be Participants.
require 'ncs_navigator/configuration'
class Person < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :person_id, :date_fields => [:date_move, :person_dob],
    :public_id_generator => NcsNavigator::Core::Mdes::HumanReadablePublicIdGenerator.new(:pattern => [4, 4, 4])

  ncs_coded_attribute :psu,                      'PSU_CL1'
  ncs_coded_attribute :prefix,                   'NAME_PREFIX_CL1'
  ncs_coded_attribute :suffix,                   'NAME_SUFFIX_CL1'
  ncs_coded_attribute :sex,                      'GENDER_CL1'
  ncs_coded_attribute :age_range,                'AGE_RANGE_CL1'
  ncs_coded_attribute :deceased,                 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :ethnic_group,             'ETHNICITY_CL1'
  ncs_coded_attribute :language,                 'LANGUAGE_CL2'
  ncs_coded_attribute :language_new,             'LANGUAGE_CL8'
  ncs_coded_attribute :marital_status,           'MARITAL_STATUS_CL1'
  ncs_coded_attribute :preferred_contact_method, 'CONTACT_TYPE_CL1'
  ncs_coded_attribute :planned_move,             'CONFIRM_TYPE_CL1'
  ncs_coded_attribute :move_info,                'MOVING_PLAN_CL1'
  ncs_coded_attribute :when_move,                'CONFIRM_TYPE_CL4'
  ncs_coded_attribute :p_tracing,                'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :p_info_source,            'INFORMATION_SOURCE_CL4'

  belongs_to :response_set
  # surveyor
  has_many :response_sets, :class_name => "ResponseSet", :foreign_key => "user_id"
  has_many :contact_links, :order => "created_at DESC"
  has_many :contacts, :through => :contact_links, :order => "created_at DESC"
  has_many :instruments, :through => :contact_links
  has_many :events, :through => :contact_links
  has_many :addresses
  has_many :telephones
  has_many :emails
  has_many :races, :class_name => "PersonRace", :foreign_key => "person_id"

  has_many :household_person_links
  has_many :household_units, :through => :household_person_links

  has_many :participant_person_links
  has_many :participants, :through => :participant_person_links

  has_many :institution_person_links
  has_many :institutions, :through => :institution_person_links

  has_many :person_provider_links
  has_many :providers, :through => :person_provider_links
  has_many :sampled_persons_ineligibilities

  has_many :non_interview_reports

  validates :title,       :length => { :maximum => 5 },  :allow_blank => true
  validates :person_dob,  :length => { :is => 10 },      :allow_blank => true
  validates :date_move,   :length => { :is => 7 },       :allow_blank => true

  validates :first_name,  :length => { :maximum => 30 }, :allow_blank => true
  validates :last_name,   :length => { :maximum => 30 }, :allow_blank => true
  validates :maiden_name, :length => { :maximum => 30 }, :allow_blank => true
  validates :middle_name, :length => { :maximum => 30 }, :allow_blank => true

  accepts_nested_attributes_for :addresses, :allow_destroy => true
  accepts_nested_attributes_for :telephones, :allow_destroy => true
  accepts_nested_attributes_for :emails, :allow_destroy => true

  accepts_nested_attributes_for :person_provider_links, :allow_destroy => true
  accepts_nested_attributes_for :sampled_persons_ineligibilities, :allow_destroy => true

  delegate :mother, :children, :to => :participant

  before_save do
    self.age = self.computed_age if self.age.blank?
  end

  def self.associated_with_provider_by_provider_id(provider_id)
    joins(:person_provider_links).
      where("person_provider_links.provider_id = ?", provider_id)
  end

  ##
  # How to format the date_move attribute
  # cf. MdesRecord
  # @return [String]
  def date_move_formatter
    '%Y-%m'
  end

  ##
  # Determine the age of the Person based on the date of birth
  # @return [Integer]
  def computed_age
    return nil if dob.blank?
    now = Time.now.utc.to_date
    offset = ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    now.year - dob.year - offset
  end

  ##
  # Display text from the NcsCode list GENDER_CL1
  # cf. sex belongs_to association
  # @return [String]
  def gender
    sex.to_s
  end

  ##
  # Override to_s to return the full name of the Person
  # @return [String]
  def to_s
    full_name
  end

  ##
  # Return the full name (first_name + last_name) of the Person
  # aliased also as :name
  # @see #first_name
  # @see #last_name
  # @return [String]
  def full_name
    "#{first_name} #{last_name}".strip
  end
  alias :name :full_name

  ##
  # Helper method to set first and last name from full name
  # Sets first name if there is no space in the name
  # @param [String]
  def full_name=(full_name)
    full_name = full_name.split
    if full_name.size >= 2
      self.last_name = full_name.last
      self.first_name = full_name[0, (full_name.size - 1) ].join(" ")
    else
      self.first_name = full_name
    end
  end

  def full_name_exists?
    !first_name.blank? && !middle_name.blank? && !last_name.blank?
  end

  def only_middle_name_missing?
    !first_name.blank? && middle_name.blank? && !last_name.blank?
  end

  ##
  # Override default setter to also set Date value for use in calculations
  def person_dob=(dob)
    self[:person_dob] = dob
    begin
      self.person_dob_date = Date.parse(dob)
    rescue
      # Date entered is unparseable
    end
  end

  def self_link
    participant_person_links.detect { |ppl| ppl.relationship_code == 1 }
  end
  private :self_link

  ##
  # The participant record associated with this person if any whose
  # relationship is self
  def participant
    self_link.try(:participant)
  end

  ##
  # Create or update the participant record associated with this person whose
  # relationship is self
  def participant=(participant)
    ppl = self_link
    if ppl
      ppl.participant = participant
    else
      participant_person_links.build(:relationship_code => 1, :person => self, :participant => participant, :psu => self.psu)
    end
  end

  ##
  # A Person is a Participant if there is an association on the participant table
  # @return [Boolean]
  def participant?
    !participant.nil?
  end

  ##
  # Helper method to return the first known provider associated with the person
  # @return [Provider]
  def provider
    providers.first
  end

  ##
  # The Participant ppg_status local_code (cf. NcsCode) if applicable
  # @return [Integer]
  def ppg_status
    participant.ppg_status.local_code if participant && participant.ppg_status
  end

  ##
  # Based on the current state, pregnancy probability group, and
  #
  # the intensity group (hi/lo) determine the next event
  # cf. Participant.upcoming_events
  # @return [String]
  def upcoming_events
    events = []
    if participant?
      participant.upcoming_events.each { |e| events << e }
    else
      events << "Pregnancy Screener"
    end
    events
  end

  ##
  # Builds a new ResponseSet for the Person taking the given Survey about the
  # given Participant and pre-populates questions to which we have previous data.
  #
  # @param [Survey]
  # @param [Participant] - The participant the Survey is regarding
  # @param mode [Integer] Instrument mode code
  # @param [Instrument] - The instrument associated with the Survey (or Survey part)
  # @return [Instrument]
  #
  # event has to be set for some prepopopulation questions to work properly.
  def start_instrument(survey, participant, mode, event, instrument = nil)
    # TODO: raise Exception if survey is nil
    return if survey.nil?
    instrument = build_instrument(survey, mode) if instrument.nil?
    instrument.tap do |instr|
      instr.event = event
      rs = instr.response_sets.build(:survey => survey, :user_id => self.id)
      rs.participant = participant
      rs.prepopulate
    end
  end

  ##
  # Returns the number of times (0 based) this instrument has been taken for the given survey
  # @param [Survey]
  # @return [Fixnum]
  def instrument_repeat_key(survey)
    response_sets_for_survey = response_sets.select { |rs| rs.survey.title == survey.title }
    response_sets_for_survey.blank? ? 0 : response_sets_for_survey.size - 1
  end

  ##
  # Create a new Instrument for the Person associated with the given Survey.
  #
  # @param survey [Survey] the survey to associate with the instrument
  # @param mode [Integer] the mode of contact for the instrument
  # @return [ResponseSet]
  def build_instrument(survey, mode)
    Instrument.new(:psu_code => NcsNavigatorCore.psu,
      :instrument_version => survey.instrument_version,
      :instrument_type => NcsCode.for_list_name_and_local_code('INSTRUMENT_TYPE_CL1', survey.instrument_type),
      :instrument_repeat_key => instrument_repeat_key(survey),
      :instrument_mode_code => mode,
      :person => self,
      :survey => survey)
  end

  ##
  # Determine if this Person has started this Survey
  # @param [Survey]
  # @return [true, false]
  def started_survey(survey)
    ResponseSet.where(:survey_id => survey.id).where(:user_id => self.id).count > 0
  end

  ##
  # Get the most recent instrument for this survey
  # @param [Survey]
  # @return [Instrument]
  def instrument_for(survey)
    ins = Instrument.where(:survey_id => survey.id).where(:person_id => self.id).order("created_at DESC")
    ins.first
  end

  ##
  # Convenience method to get the last incomplete response set
  # @return [ResponseSet]
  def last_incomplete_response_set
    rs = response_sets.last
    rs.blank? ? nil : (rs.complete? ? nil : rs)
  end

  ##
  # Convenience method to get the last completed survey
  # @return [ResponseSet]
  def last_completed_survey
    rs = response_sets.last
    rs.complete? ? rs.survey : nil
  end

  ##
  # Given a data export identifier, return the responses this person made for that question
  # @return [Array<Response>]
  def responses_for(data_export_identifier)
    Response.includes([:answer, :question, :response_set]).where(
      "response_sets.user_id = ? AND questions.data_export_identifier = ?", self.id, data_export_identifier).
      order("responses.created_at")
  end

  ##
  # Returns true if sampled_persons_ineligibilities
  # exist for this person
  def sampled_ineligible?
    sampled_persons_ineligibilities.count > 0
  end

  ##
  # Returns all DwellingUnits associated with the person's household units
  # @return[Array<DwellingUnit]
  def dwelling_units
    household_units.collect(&:dwelling_units).flatten
  end

  ##
  # Returns the highest ranked HouseholdPersonLink associated with the person or nil
  # @return[HouseholdPersonLink]
  def highest_ranked_household_person_link
    HouseholdPersonLink.order_by_rank(household_person_links).first
  end

  ##
  # Returns true if a dwelling_unit has a tsu_is and this person has an association to the
  # tsu dwelling unit through their household
  # @return [true,false]
  def in_tsu?
    dwelling_units.map(&:tsu_id).compact.size > 0
  end

  ##
  # Returns the primary cell phone number for this person, or nil if no such
  # phone record exists.
  def primary_cell_phone
    cell_code = Telephone.cell_phone_type.to_i

    primary_contacts(telephones, :phone_rank_code) do |ts|
      ts.detect { |t| t.phone_type_code == cell_code }
    end
  end

  ##
  # Returns the primary home phone number for this person, or nil if no such
  # phone record exists.
  def primary_home_phone
    home_code = Telephone.home_phone_type.to_i

    primary_contacts(telephones, :phone_rank_code) do |ts|
      ts.detect { |t| t.phone_type_code == home_code }
    end
  end

  ##
  # Returns the primary work phone number for this person, or nil if no such
  # phone record exists.
  def primary_work_phone
    work_code = Telephone.work_phone_type.to_i

    primary_contacts(telephones, :phone_rank_code) do |ts|
      ts.detect { |t| t.phone_type_code == work_code }
    end
  end

  ##
  # Returns the secondary phone for this person, or nil if no such phone
  # record exists.
  def secondary_phone
    telephones.select{ |t| t.phone_rank_code == 2 }.first
  end

  ##
  # Returns the primary work address for this person, or nil if no such
  # phone record exists.
  def primary_work_address
    work_address_type_code = Address.work_address_type.to_i

    primary_contacts(addresses, :address_rank_code) do |ts|
      ts.detect { |t| t.address_type_code == work_address_type_code }
    end
  end

  ##
  # Returns the primary mailing address for this person, or nil if no such
  # phone record exists.
  def primary_mailing_address
    mailing_address_type_code = Address.mailing_address_type.to_i

    primary_contacts(addresses, :address_rank_code) do |ts|
      ts.detect { |t| t.address_type_code == mailing_address_type_code }
    end
  end

  ##
  # Returns the primary address for this person, or nil if no such address
  # record exists.
  def primary_address
    primary_contacts(addresses, :address_rank_code, &:first)
  end

  ##
  # Returns the secondary address for this person, or nil if no such address
  # record exists.
  def secondary_address
    addresses.select{ |a| a.address_rank_code == 2 }.first
  end

  ##
  # Returns the primary email for this person, or nil if no such email record
  # exists.
  def primary_email
    primary_contacts(emails, :email_rank_code, &:first)
  end

  ##
  # @private
  def primary_contacts(collection, code_key)
    yield collection.select { |c| c.send(code_key) == 1 }
  end

  ##
  # Determine if this person is a child to another person
  # and if so if this is the first child
  # @return [Boolean]
  def first_child?
    if mother = participant.try(:mother)
      if mother.participant?
        return mother.children.first == self
      end
    end
    false
  end
  alias :is_first_child? :first_child?

  ##
  # Determine relationship to another person and return
  # the display_text of that NcsCode value for the
  # relationship in the ParticipantPersonLink record.
  # Returns 'N/A' if person param nil
  # Returns 'None' if relationship cannot be found
  # @see ParticipantPersonLink#relationship
  # @see NcsCode#display_text
  # @param [Person]
  # @return [String]
  def relationship_to_person_via_participant(person)
    return 'N/A' if person.nil?

    rel = person.participant_person_links.find { |ppl|
      ppl.participant == participant
    }.try(:relationship)

    rel.try(:display_text) || 'None'
  end

  ##
  # From INFORMATION_SOURCE_CL4, the code for Person/Self
  # @return[Integer]
  def self.person_self_code
    1
  end

  private

    def dob
      return person_dob_date unless person_dob_date.blank?
      return Date.parse(person_dob) if person_dob.to_i > 0 && !person_dob.blank? && (person_dob !~ /^9/ && person_dob !~ /-9/)
      return nil
    end

end

class PersonResponse
  attr_accessor :response_class, :text, :short_text, :reference_identifier
  attr_accessor :datetime_value, :integer_value, :float_value, :text_value, :string_value
end
