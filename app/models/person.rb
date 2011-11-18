# == Schema Information
# Schema version: 20111110015749
#
# Table name: people
#
#  id                             :integer         not null, primary key
#  psu_code                       :string(36)      not null
#  person_id                      :string(36)      not null
#  prefix_code                    :integer         not null
#  first_name                     :string(30)
#  last_name                      :string(30)
#  middle_name                    :string(30)
#  maiden_name                    :string(30)
#  suffix_code                    :integer         not null
#  title                          :string(5)
#  sex_code                       :integer         not null
#  age                            :integer
#  age_range_code                 :integer         not null
#  person_dob                     :string(10)
#  person_dob_date                :date
#  deceased_code                  :integer         not null
#  ethnic_group_code              :integer         not null
#  language_code                  :integer         not null
#  language_other                 :string(255)
#  marital_status_code            :integer         not null
#  marital_status_other           :string(255)
#  preferred_contact_method_code  :integer         not null
#  preferred_contact_method_other :string(255)
#  planned_move_code              :integer         not null
#  move_info_code                 :integer         not null
#  when_move_code                 :integer         not null
#  date_move_date                 :date
#  date_move                      :string(7)
#  p_tracing_code                 :integer         not null
#  p_info_source_code             :integer         not null
#  p_info_source_other            :string(255)
#  p_info_date                    :date
#  p_info_update                  :date
#  person_comment                 :text
#  transaction_type               :string(36)
#  created_at                     :datetime
#  updated_at                     :datetime
#  being_processed                :boolean
#

# A Person is an individual who may provide information on a participant.
# All individuals contacted are Persons, including those who may also be Participants.
require 'ncs_navigator/configuration'
class Person < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_id, :date_fields => [:date_move, :person_dob]

  belongs_to :psu,                      :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :prefix,                   :conditions => "list_name = 'NAME_PREFIX_CL1'",         :foreign_key => :prefix_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :suffix,                   :conditions => "list_name = 'NAME_SUFFIX_CL1'",         :foreign_key => :suffix_code,                   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :sex,                      :conditions => "list_name = 'GENDER_CL1'",              :foreign_key => :sex_code,                      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :age_range,                :conditions => "list_name = 'AGE_RANGE_CL1'",           :foreign_key => :age_range_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :deceased,                 :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :deceased_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ethnic_group,             :conditions => "list_name = 'ETHNICITY_CL1'",           :foreign_key => :ethnic_group_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :language,                 :conditions => "list_name = 'LANGUAGE_CL2'",            :foreign_key => :language_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :marital_status,           :conditions => "list_name = 'MARITAL_STATUS_CL1'",      :foreign_key => :marital_status_code,           :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :preferred_contact_method, :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :preferred_contact_method_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :planned_move,             :conditions => "list_name = 'CONFIRM_TYPE_CL1'",        :foreign_key => :planned_move_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :move_info,                :conditions => "list_name = 'MOVING_PLAN_CL1'",         :foreign_key => :move_info_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :when_move,                :conditions => "list_name = 'CONFIRM_TYPE_CL4'",        :foreign_key => :when_move_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :p_tracing,                :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :p_tracing_code,                :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :p_info_source,            :conditions => "list_name = 'INFORMATION_SOURCE_CL4'",  :foreign_key => :p_info_source_code,            :class_name => 'NcsCode', :primary_key => :local_code

  # surveyor
  has_many :response_sets, :class_name => "ResponseSet", :foreign_key => "user_id"
  has_many :contact_links, :order => "created_at DESC"
  has_many :instruments, :through => :contact_links
  has_many :addresses
  has_many :telephones
  has_many :emails

  has_many :household_person_links
  has_many :household_units, :through => :household_person_links

  has_many :participant_person_links
  # validates_presence_of :first_name
  # validates_presence_of :last_name

  validates_length_of :title, :maximum => 5, :allow_blank => true

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
  def age
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
  # @param [String]
  def full_name=(full_name)
    full_name = full_name.split
    if full_name.size >= 2
      self.last_name = full_name.last
      self.first_name = full_name[0, (full_name.size - 1) ].join(" ")
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
  # Create a new ResponseSet for the Person associated with the given Survey
  # and pre-populate questions to which we have previous data.
  #
  # @param [Survey]
  # @return [ResponseSet]
  def start_instrument(survey)
    # TODO: raise Exception if survey is nil
    return if survey.nil?
    instrument = create_instrument(survey)
    response_set = ResponseSet.create(:survey => survey, :user_id => self.id)

    response_set = prepopulate_response_set(survey, response_set)
    [response_set, instrument]
  end

  def prepopulate_response_set(survey, response_set)
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

        Response.create(:response_set => response_set, :question => question, :answer => answer, response_type.to_sym => value)
      end
    end
    response_set
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
  def create_instrument(survey)
    Instrument.create!(:psu_code => NcsNavigatorCore.psu,
      :instrument_version => InstrumentEventMap.version(survey.title),
      :instrument_type => InstrumentEventMap.instrument_type(survey.title),
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
    rs.complete? ? nil : rs
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
    # TODO: when dwelling units can and cannot have a tsu id - use the logic
    true
    # dwelling_units.map(&:tsu_id).compact.size > 0
  end

  private

    def dob
      return person_dob_date unless person_dob_date.blank?
      return Date.parse(person_dob) if person_dob.to_i > 0 && !person_dob.blank? && person_dob.chars.first != '9'
      return nil
    end

end

class PersonResponse
  attr_accessor :response_class, :text, :short_text, :reference_identifier
  attr_accessor :datetime_value, :integer_value, :float_value, :text_value, :string_value
end
