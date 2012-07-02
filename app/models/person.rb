

# A Person is an individual who may provide information on a participant.
# All individuals contacted are Persons, including those who may also be Participants.
require 'ncs_navigator/configuration'
class Person < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_id, :date_fields => [:date_move, :person_dob]

  ncs_coded_attribute :psu,                      'PSU_CL1'
  ncs_coded_attribute :prefix,                   'NAME_PREFIX_CL1'
  ncs_coded_attribute :suffix,                   'NAME_SUFFIX_CL1'
  ncs_coded_attribute :sex,                      'GENDER_CL1'
  ncs_coded_attribute :age_range,                'AGE_RANGE_CL1'
  ncs_coded_attribute :deceased,                 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :ethnic_group,             'ETHNICITY_CL1'
  ncs_coded_attribute :language,                 'LANGUAGE_CL2'
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

  has_many :household_person_links
  has_many :household_units, :through => :household_person_links

  has_many :participant_person_links
  has_many :participants, :through => :participant_person_links
  # validates_presence_of :first_name
  # validates_presence_of :last_name

  validates_length_of :title, :maximum => 5, :allow_blank => true

  accepts_nested_attributes_for :addresses, :allow_destroy => true
  accepts_nested_attributes_for :telephones, :allow_destroy => true
  accepts_nested_attributes_for :emails, :allow_destroy => true

  before_save do
    self.age = self.computed_age if self.age.blank?
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
  # aliased as :name and :full_name
  # @return [String]
  def to_s
    "#{first_name} #{last_name}".strip
  end
  alias :name :to_s
  alias :full_name :to_s

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
  # The Participant ppg_status local_code (cf. NcsCode) if applicable
  # @return [Integer]
  def ppg_status
    participant.ppg_status.local_code if participant && participant.ppg_status
  end

  ##
  # Based on the current state, pregnancy probability group, and
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
  # Builds a new ResponseSet for the Person associated with the given Survey
  # and pre-populates questions to which we have previous data.
  #
  # @param [Survey]
  # @return [ResponseSet]
  def start_instrument(survey)
    # TODO: raise Exception if survey is nil
    return if survey.nil?

    build_instrument(survey).tap do |instr|
      instr.build_response_set(:survey => survey, :user_id => self.id)

      prepopulate_response_set(instr.response_set, survey)
    end
  end

  def prepopulate_response_set(response_set, survey)
    # TODO: determine way to know about initializing data for each survey
    reference_identifiers = ["prepopulated_name", "prepopulated_date_of_birth", "prepopulated_ppg_status", "prepopulated_local_sc", "prepopulated_sc_phone_number", "prepopulated_baby_name", "prepopulated_childs_birth_date"]

    response_type = "string_value"

    reference_identifiers.each do |reference_identifier|
      question = nil
      survey.sections_with_questions.each do |section|
        section.questions.each do |q|
          question = q if q.reference_identifier == reference_identifier
          break unless question.nil?
        end
        break unless question.nil?
      end
      if question
        answer = question.answers.first
        value = case reference_identifier
                when "prepopulated_name"
                  response_type = "string_value"
                  name
                when "prepopulated_date_of_birth"
                  response_type = "string_value"
                  dob.to_s
                when "prepopulated_ppg_status"
                  response_type = "integer_value"
                  ppg_status
                when "prepopulated_local_sc"
                  response_type = "string_value"
                  NcsNavigatorCore.study_center_name
                when "prepopulated_sc_phone_number"
                  response_type = "string_value"
                  NcsNavigatorCore.study_center_phone_number
                else
                  # TODO: handle other prepopulated fields
                  nil
                end

        response_set.responses.build(:question => question, :answer => answer, response_type.to_sym => value)
      end
    end
    response_set
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
  # Return the currently active ContactLink, if a person is associated with a Contact through
  # a ContactLink and that ContactLink has not been closed (cf. Event#closed? and Contact#closed?)
  #
  # @return [ContactLink]
  def current_contact_link
    open_contact_links = contact_links.select { |link| !link.complete? }
    return nil if open_contact_links.blank?
    return open_contact_links.first if open_contact_links.size == 1
    # TODO: what to do if there is more than one open contact?
  end
  
  ##
  # Create a new Instrument for the Person associated with the given Survey.
  #
  # @param [Survey]
  # @return [ResponseSet]
  def build_instrument(survey)
    Instrument.new(:psu_code => NcsNavigatorCore.psu,
      :instrument_version => Instrument.determine_version(survey.title),
      :instrument_type => InstrumentEventMap.instrument_type(survey.title),
      :instrument_repeat_key => instrument_repeat_key(survey),
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
      "response_sets.user_id = ? AND questions.data_export_identifier = ?", self.id, data_export_identifier).all
  end

  ##
  # Returns all DwellingUnits associated with the person's household units
  # @return[Array<DwellingUnit]
  def dwelling_units
    household_units.collect(&:dwelling_units).flatten
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
  # Returns the primary cell phone number for this person, or nil if no such
  # phone record exists.
  def primary_home_phone
    home_code = Telephone.home_phone_type.to_i

    primary_contacts(telephones, :phone_rank_code) do |ts|
      ts.detect { |t| t.phone_type_code == home_code }
    end
  end

  ##
  # Returns the primary address for this person, or nil if no such address
  # record exists.
  def primary_address
    primary_contacts(addresses, :address_rank_code, &:first)
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

