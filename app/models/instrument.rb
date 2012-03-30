# == Schema Information
# Schema version: 20120321181032
#
# Table name: instruments
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  instrument_id            :string(36)      not null
#  event_id                 :integer
#  instrument_type_code     :integer         not null
#  instrument_type_other    :string(255)
#  instrument_version       :string(36)      not null
#  instrument_repeat_key    :integer
#  instrument_start_date    :date
#  instrument_start_time    :string(255)
#  instrument_end_date      :date
#  instrument_end_time      :string(255)
#  instrument_breakoff_code :integer         not null
#  instrument_status_code   :integer         not null
#  instrument_mode_code     :integer         not null
#  instrument_mode_other    :string(255)
#  instrument_method_code   :integer         not null
#  supervisor_review_code   :integer         not null
#  data_problem_code        :integer         not null
#  instrument_comment       :text
#  transaction_type         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  person_id                :integer
#  survey_id                :integer
#

# An Instrument is a scheduled, partially executed or
# completely executed questionnaire or paper form. An
# Instrument can also be an Electronic Health Record or
# a Personal Health Record.
class Instrument < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :instrument_id

  belongs_to :event
  ncs_coded_attribute :psu,                 'PSU_CL1'
  ncs_coded_attribute :instrument_type,     'INSTRUMENT_TYPE_CL1'
  ncs_coded_attribute :instrument_breakoff, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :instrument_status,   'INSTRUMENT_STATUS_CL1'
  ncs_coded_attribute :instrument_mode,     'INSTRUMENT_ADMIN_MODE_CL1'
  ncs_coded_attribute :instrument_method,   'INSTRUMENT_ADMIN_METHOD_CL1'
  ncs_coded_attribute :supervisor_review,   'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :data_problem,        'CONFIRM_TYPE_CL2'

  belongs_to :person
  belongs_to :survey
  has_one :response_set, :inverse_of => :instrument

  validates_presence_of :instrument_version

  before_create :set_default_codes

  INSTRUMENT_LABEL_MARKER = "instrument:"
  COLLECTION_LABEL_MARKER = "collection:"

  ##
  # Finds or builds a record to indicate that a person has begun taking a
  # survey on an event.
  def self.start(person, survey, event)
    rs = ResponseSet.includes(:instrument).where(:survey_id => survey.id, :user_id => person.id).first

    if !rs || event.closed?
      person.start_instrument(survey)
    else
      rs.instrument
    end.tap { |i| i.event = event }
  end

  ##
  # Begins administration of this instrument to a person.
  #
  #
  # An explanation of this method's parameters
  # ------------------------------------------
  #
  # Instruments are administered to a Person by a staff member; a record of the
  # staff member contacting a Person is created as a Contact, which in turn
  # exists in the context of one or more Events.
  #
  #
  # Optimization
  # ------------
  #
  # When running link_to on many persons, it is recommended that you eager-load
  # Person#contact_links.
  def link_to(person, contact, event, staff_id)
    link = person.contact_links.detect do |cl|
      cl.contact_id == contact.id && cl.event_id == event.id && cl.instrument_id == id
    end

    link or person.contact_links.build(:contact => contact, :event => event, :instrument => self,
                                       :staff_id => staff_id, :psu_code => ::NcsNavigatorCore.psu_code)
  end

  ##
  # Display text from the NcsCode list INSTRUMENT_TYPE_CL1
  # cf. instrument_type belongs_to association
  # @return [String]
  def to_s
    instrument_type.to_s
  end

  def complete?
    !instrument_end_date.blank? && !instrument_end_time.blank? && instrument_status.to_s == "Complete"
  end

  def set_instrument_breakoff(response_set)
    if response_set
      local_code = response_set.has_responses_in_each_section_with_questions? ? 2 : 1
      self.instrument_breakoff = NcsCode.for_attribute_name_and_local_code(:instrument_breakoff_code, local_code)
    end
  end

  ##
  # Given a label from PSC or surveyor access code determine the instrument version
  # @param [String] - e.g. ins_que_xxx_int_ehpbhi_p2_v1.0
  # @return [String]
  def self.determine_version(lbl)
    lbl = Instrument.surveyor_access_code(lbl)
    ind = lbl.to_s.rindex("-v")
    lbl[ind + 2, lbl.length].sub("-", ".")
  end

  ##
  # Given a label from PSC get the part that references the instrument
  # @param[String]
  # @return[String]
  def self.parse_label(lbl)
    return nil if lbl.blank?
    part = lbl.split.select{ |s| s.include?(INSTRUMENT_LABEL_MARKER) }.first.to_s
    return nil if part.blank?
    part.gsub(INSTRUMENT_LABEL_MARKER, "")
  end

  def self.surveyor_access_code(lbl)
    lbl = Instrument.parse_label(lbl) if lbl.include? INSTRUMENT_LABEL_MARKER
    Survey.to_normalized_string(lbl)
  end

  def self.collection?(lbl)
    lbl.include? COLLECTION_LABEL_MARKER
  end

  private

    ##
    # Currently this sets the supervisor review and data problem code to No
    # These values can and should be updated by the user/interviewer in case these are not the correct
    # values
    def set_default_codes
      [:supervisor_review, :data_problem, :instrument_mode, :instrument_method].each do |asso|
        current_value = self.send(asso)
        if current_value.nil? || current_value.local_code == -4
          val = NcsCode.for_attribute_name_and_local_code("#{asso}_code".to_sym, 2)
          self.send("#{asso}=", val) if val
        end
      end
    end

end
