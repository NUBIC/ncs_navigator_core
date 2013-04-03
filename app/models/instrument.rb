# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: instruments
#
#  created_at               :datetime
#  data_problem_code        :integer          not null
#  event_id                 :integer
#  id                       :integer          not null, primary key
#  instrument_breakoff_code :integer          not null
#  instrument_comment       :text
#  instrument_end_date      :date
#  instrument_end_time      :string(255)
#  instrument_id            :string(36)       not null
#  instrument_method_code   :integer          not null
#  instrument_mode_code     :integer          not null
#  instrument_mode_other    :string(255)
#  instrument_repeat_key    :integer          default(0), not null
#  instrument_start_date    :date
#  instrument_start_time    :string(255)
#  instrument_status_code   :integer          not null
#  instrument_type_code     :integer          not null
#  instrument_type_other    :string(255)
#  instrument_version       :string(36)       not null
#  lock_version             :integer          default(0)
#  person_id                :integer
#  psu_code                 :integer          not null
#  supervisor_review_code   :integer          not null
#  survey_id                :integer
#  transaction_type         :string(255)
#  updated_at               :datetime
#

# An Instrument is a scheduled, partially executed or
# completely executed questionnaire or paper form. An
# Instrument can also be an Electronic Health Record or
# a Personal Health Record.
class Instrument < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
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
  has_one :contact_link, :inverse_of => :instrument
  has_many :response_sets, :inverse_of => :instrument, :order => 'created_at ASC'
  has_many :legacy_instrument_data_records, :inverse_of => :instrument

  has_many :samples, :inverse_of => :instrument, :order => 'created_at ASC'
  has_many :specimens, :inverse_of => :instrument, :order => 'created_at ASC'

  validates_presence_of :instrument_version
  validates_presence_of :instrument_repeat_key

  before_create :set_default_codes

  INSTRUMENT_LABEL_MARKER = "instrument:"
  COLLECTION_LABEL_MARKER = "collection:"

  ##
  # Finds or builds a record to indicate that a person has begun taking a
  # survey on an event. The Instrument returned will also have an
  # unpersisted associated ResponseSet and potentially pre-populated
  # Responses if the current_survey should have responses set prior
  # to Instrument administration.
  #
  # This method creates an association to the ResponseSet via the
  # ResponseSet belongs_to association.
  # DO NOT USE THIS METHOD UNLESS YOU KNOW WHAT THAT MEANS
  #
  # @see ResponseSet.instrument
  # @see Person.start_instrument
  # @see ResponseSet#prepopulate
  #
  # @param [Person]  - person
  #                  - the person taking the survey
  # @param [Participant] - participant
  #                  - the participant who the survey is about
  # @param [Survey]  - instrument_survey
  #                  - the one associated with the first of multi-part sequence or singleton survey
  #                  - i.e. Survey with title matching PSC activity references label
  # @param [Survey]  - current_survey
  #                  - the one part of the multi-part survey or singleton
  #                  - i.e. Survey with title matching PSC activity instrument label
  # @param [Event]   - the event associated with the Instrument
  # @param [Integer] - mode of Instrument administration - cf. INSTRUMENT_ADMIN_MODE_CL1
  #                  - defaults to CAPI
  # @return[Instrument]
  def self.start(person, participant, instrument_survey, current_survey, event, mode = Instrument.capi)
    build_instrument_from_survey(person, participant, instrument_survey, current_survey, event, mode)
  end

  ##
  # Builds a non-persistent Instrument record.
  #
  # If there is no referenced initial instrument_survey (that is if there is no first part of a multi-part
  # survey) or if the first part of a multi-part survey is the same as the current survey to be administered
  # build the first Instrument for the current_survey.
  # Otherwise, build a new ResponseSet and associate that ResponseSet with the Instrument associated with
  # the instrument_survey
  #
  # @return[Instrument]
  def self.build_instrument_from_survey(person, participant, instrument_survey, current_survey, event, mode)
    if (instrument_survey.blank? || instrument_survey == current_survey)
      start_initial_instrument(person, participant, current_survey, event, mode)
    else
      continue_instrument_associated_with_survey(person, participant, instrument_survey, current_survey, event, mode)
    end
  end

  ##
  # This is the entry point for creating a new Instrument record for the person, survey, and event
  #
  # cf. Person.start_instrument
  #
  # @return[Instrument]
  def self.start_initial_instrument(person, participant, survey, event, mode)
    where_clause = "response_sets.survey_id = ? AND response_sets.user_id = ? AND instruments.event_id = ?"
    rs = ResponseSet.includes(:instrument).where(where_clause, survey.id, person.id, event.id).first

    if !rs || event.closed?
      person.start_instrument(survey, participant, mode, event)
    else
      rs.instrument
    end
  end

  ##
  # Find the Instrument record associated with the instrument_survey (the first part of
  # a multi-part survey) and then associate the ResponseSet for the
  # current_survey (the subsequent part of a multi-part survey) with that Instrument record.
  #
  # @return[Instrument]
  def self.continue_instrument_associated_with_survey(person, participant, instrument_survey, current_survey, event, mode)
    instrument = find_instrument_to_continue(person, instrument_survey, event)
    person.start_instrument(current_survey, participant, mode, event, instrument)
  end

  def self.find_instrument_to_continue(person, instrument_survey, event)
    ins = Instrument.where(:person_id => person.id,
                            :survey_id => instrument_survey.id,
                            :event_id => event.id).order("created_at DESC").first
    # In case the instrument_survey record has been updated/redeployed while user was
    # in middle of entering multi-part survey - this check is also brittle in the case
    # where a survey.title has been changed
    # Task #3400 should remove the need for this method.
    if ins.nil?
      ins = event.instruments.detect { |i| i.survey.title == instrument_survey.title }
    end
    ins
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
      cl.contact_id == contact.id && cl.event_id == event.id && cl.staff_id == staff_id && (cl.instrument_id.blank? || cl.instrument_id == id)
    end

    link.instrument = self if link

    link or person.contact_links.build(:contact => contact, :event => event, :instrument => self,
                                       :staff_id => staff_id, :psu_code => ::NcsNavigatorCore.psu_code)
  end

  ##
  # Given a {PscParticipant}, returns the participant's scheduled activities
  # that match this instrument.  If no activities match, returns [].
  #
  # The PscParticipant passed here MUST reference the same Participant as this
  # instrument's event.
  #
  # This method will load the following associations:
  #
  # * event.participant
  # * survey
  #
  # You SHOULD eager load these associations when checking activity IDs across
  # multiple instruments.
  #
  #
  # Match criteria
  # ==============
  #
  # Let:
  #
  # * SAC(I) be the access code for the survey on instrument I, and
  # * L(A) the set of labels on activity A.
  #
  # SAC(I) can be computed as Survey.to_normalized_string(self.survey.title)
  #
  # 1. If SAC(I) matches a references label in L(A), add A as an activity for I.
  # 2. If SAC(I) matches an instrument label in L(A) and L(A) has no references
  #    labels, add A as an activity for I.
  #
  # Instruments form a tree one level deep.  In the below diagram, each I is an
  # instrument, and a, b, and c are activities.
  #
  #           Ia
  #          _|_
  #         |   |
  #         Ib  Ic
  #
  # This situation can be set up if b and c have references labels pointing to
  # the instrument implied by a.  Under the above model, completing Ia will
  # close activities a, b, and c; however, completing just Ib or Ic will not
  # result in any changes to PSC schedules.
  def scheduled_activities(psc_participant)
    if psc_participant.participant.id != participant.try(:id)
      raise "Participant mismatch (psc_participant: #{psc_participant.participant.id}, self: #{participant.try(:id)})"
    end

    activities = psc_participant.scheduled_activities
    survey_code = survey.access_code

    activities.select do |id, sa|
      instr = sa.instrument_label.try(:content)
      ref = sa.references_label.try(:content)

      code = if instr && !ref
               Survey.to_normalized_string(instr)
             elsif ref
               Survey.to_normalized_string(ref)
             end

      survey_code == code
    end.map { |id, sa| sa }
  end

  ##
  # The desired state for the scheduled activities backing this Instrument.
  # This SHOULD be one of the values defined on Psc::ScheduledActivity.
  #
  # Here's how instruments and their backing activities match up:
  #
  # | Instrument status | Desired activity state |
  # | Complete          | Occurred               |
  # | Missing in Error  | Scheduled              |
  # | Not started       | Scheduled              |
  # | Partial           | Scheduled              |
  # | Refused           | Canceled               |
  def desired_sa_state
    sa = Psc::ScheduledActivity

    case instrument_status.to_s
    when 'Complete' then sa::OCCURRED
    when 'Missing in Error', 'Not started', 'Partial' then sa::SCHEDULED
    when 'Refused' then sa::CANCELED
    else raise "Cannot map #{instrument_status.to_s.inspect} to a scheduled activity state"
    end
  end

  ##
  # The end date for this instrument's scheduled activities.  Returns a string
  # in YYYY-MM-DD format or nil if no end date is set.
  #
  # @return [String, nil]
  def sa_end_date
    instrument_end_date.try(:strftime, '%Y-%m-%d')
  end

  ##
  # When the scheduled activity states for this instrument are synced, the
  # string from this method is supplied as the reason.
  def sa_state_change_reason
    'Synchronized from Cases'
  end

  ##
  # Display text from the NcsCode list INSTRUMENT_TYPE_CL1
  # cf. instrument_type belongs_to association
  # @return [String]
  def to_s
    instrument_type.to_s
  end

  def participant
    event.try(:participant)
  end

  ##
  # The Instrument is considered complete
  # if there is an end_date, an end_time, and the instrument status is 'Complete'
  #
  # @return [Boolean]
  def complete?
    !instrument_end_date.blank? && !instrument_end_time.blank? && instrument_status.to_s == "Complete"
  end

  def set_instrument_breakoff
    local_code = NcsCode::NO
    response_sets.each do |rs|
      if !rs.has_responses_in_each_section_with_questions?
        local_code = NcsCode::YES
        break
      end
    end
    self.instrument_breakoff_code = local_code
  end

  ##
  # From INSTRUMENT_ADMIN_MODE_CL1
  # @return[Integer]
  def self.capi
    1
  end

  ##
  # From INSTRUMENT_ADMIN_MODE_CL1
  # @return[Integer]
  def self.cati
    2
  end

  ##
  # From INSTRUMENT_ADMIN_MODE_CL1
  # @return[Integer]
  def self.papi
    3
  end

  ##
  # From INSTRUMENT_TYPE_CL1
  # @return[Integer]
  def self.pbs_eligibility_screener_code
    44
  end

  ##
  # From INSTRUMENT_TYPE_CL1
  # @return[Integer]
  def self.pregnancy_screener_eh_code
    3
  end

  ##
  # From INSTRUMENT_TYPE_CL1
  # @return[Integer]
  def self.pregnancy_screener_pb_code
    4
  end

  ##
  # From INSTRUMENT_TYPE_CL1
  # @return[Integer]
  def self.pregnancy_screener_hilo_code
    5
  end

  ##
  # Given a label from PSC or surveyor access code determine the instrument version
  # Defaults to 1.0 if there is no label or access code
  # @param [String] - e.g. ins_que_xxx_int_ehpbhi_p2_v1.0
  # @return [String]
  def self.determine_version(lbl)
    result = "1.0"
    lbl = Instrument.surveyor_access_code(lbl.to_s)
    if ind = lbl.to_s.rindex("-v")
      result = lbl[ind + 2, 3].sub("-", ".")
    end
    result
  end

  ##
  # Given a label from PSC get the part that references the instrument
  # @param[String]
  # @return[String]
  def self.parse_label(lbl)
    lbl = Instrument.instrument_label(lbl)
    lbl.to_s.include?(':') ? lbl.split(':').last : lbl
  end

  def self.surveyor_access_code(lbl)
    lbl = Instrument.parse_label(lbl) if lbl.include? INSTRUMENT_LABEL_MARKER
    Survey.to_normalized_string(lbl)
  end

  def self.collection?(lbl)
    lbl.include? COLLECTION_LABEL_MARKER
  end

  def self.mdes_version(lbl)
    return nil unless lbl.include?(INSTRUMENT_LABEL_MARKER)
    lbl = lbl.to_s.split(':')
    lbl.size == 3 ? lbl[1] : nil
  end

  def self.matches_mdes_version?(lbl, version)
    mdes_version(lbl) == version
  end

  def self.instrument_label(lbl)
    return nil if lbl.blank?
    lbl.split.select { |s| s.include?(INSTRUMENT_LABEL_MARKER) }
      .select { |s| Instrument.matches_mdes_version?(s, NcsNavigatorCore.mdes.version) }
      .first
  end

  def most_recent_response_set
    response_sets.last
  end

  def enumerable_to_warehouse?
    return false unless event_id

    self.class.connection.select_value(<<-QUERY).to_i > 0
      SELECT COUNT(*)
      FROM events e
      WHERE e.id=#{event_id} AND e.event_disposition IS NOT NULL
    QUERY
  end

  def set_instrument_repeat_key(person)
    lowest = response_sets.min_by { |r_set|  person.instrument_repeat_key(r_set.survey) }
    self.instrument_repeat_key = person.instrument_repeat_key(lowest.survey)
  end

  def set_instrument_type(surveys)
    if instrument_type.blank? || instrument_type_code <= 0
      self.instrument_type_code = surveys.first.instrument_type
    end
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
