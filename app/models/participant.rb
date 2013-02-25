# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: participants
#
#  being_followed            :boolean          default(FALSE)
#  being_processed           :boolean          default(FALSE)
#  created_at                :datetime
#  enroll_date               :date
#  enroll_status_code        :integer          not null
#  enrollment_status_comment :text
#  high_intensity            :boolean          default(FALSE)
#  high_intensity_state      :string(255)
#  id                        :integer          not null, primary key
#  lock_version              :integer          default(0)
#  low_intensity_state       :string(255)
#  p_id                      :string(36)       not null
#  p_type_code               :integer          not null
#  p_type_other              :string(255)
#  pid_age_eligibility_code  :integer          not null
#  pid_comment               :text
#  pid_entry_code            :integer          not null
#  pid_entry_other           :string(255)
#  psu_code                  :integer          not null
#  status_info_date          :date
#  status_info_mode_code     :integer          not null
#  status_info_mode_other    :string(255)
#  status_info_source_code   :integer          not null
#  status_info_source_other  :string(255)
#  transaction_type          :string(36)
#  updated_at                :datetime
#



# A Participant is a living Person who has provided Study data about her/himself or a NCS Child.
# S/he may have been administered a variety of questionnaires or assessments, including household enumeration,
# pregnancy screener, pregnancy questionnaire, etc. Once born, NCS-eligible babies are assigned Participant IDs.
# Every Participant is also a Person. People do not become Participants until they are determined eligible for a pregnancy screener.
class Participant < ActiveRecord::Base
  class << self; attr_accessor :importer_mode_on; end

  include NcsNavigator::Core::Mdes::MdesRecord

  acts_as_mdes_record :public_id_field => :p_id,
    :public_id_generator => NcsNavigator::Core::Mdes::HumanReadablePublicIdGenerator.new

  ncs_coded_attribute :psu,                 'PSU_CL1'
  ncs_coded_attribute :p_type,              'PARTICIPANT_TYPE_CL1'
  ncs_coded_attribute :status_info_source,  'INFORMATION_SOURCE_CL4'
  ncs_coded_attribute :status_info_mode,    'CONTACT_TYPE_CL1'
  ncs_coded_attribute :enroll_status,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :pid_entry,           'STUDY_ENTRY_METHOD_CL1'
  ncs_coded_attribute :pid_age_eligibility, 'AGE_ELIGIBLE_CL2'

  has_many :ppg_details, :order => "created_at DESC"
  has_many :ppg_status_histories, :order => "ppg_status_date DESC"

  has_many :low_intensity_state_transition_audits,  :class_name => "ParticipantLowIntensityStateTransition",  :foreign_key => "participant_id", :dependent => :destroy
  has_many :high_intensity_state_transition_audits, :class_name => "ParticipantHighIntensityStateTransition", :foreign_key => "participant_id", :dependent => :destroy

  has_many :participant_person_links, :order => 'participant_person_links.created_at'
  has_many :people, :through => :participant_person_links
  has_many :participant_staff_relationships
  has_many :participant_consents
  has_many :participant_consent_samples
  has_many :events
  has_many :response_sets, :inverse_of => :participant

  has_many :providers, :through => :people
  has_many :pbs_lists, :through => :providers

  def self.has_self_link
    where('participant_person_links.relationship_code' => 1)
  end

  def self.from_hospital_type_provider
    hospitals = PbsList.is_hospital_type

    has_self_link.joins(:pbs_lists).merge(PbsList.is_hospital_type)
  end

  def hospital?
    self.class.from_hospital_type_provider.exists?(self)
  end

  # validates_presence_of :person

  accepts_nested_attributes_for :ppg_details, :allow_destroy => true
  accepts_nested_attributes_for :ppg_status_histories, :allow_destroy => true

  scope :in_low_intensity, where("high_intensity is null or high_intensity is false")
  scope :in_high_intensity, where("high_intensity is true")

  scope :all_for_staff, lambda { |staff_id| joins(:participant_staff_relationships).where("participant_staff_relationships.staff_id = ?", staff_id) }
  scope :primary_for_staff, lambda { |staff_id| all_for_staff(staff_id).where("participant_staff_relationships.primary = ?", true) }
  scope :all_people_for_self, lambda { |person_id| joins(:participant_person_links).where("participant_person_links.person_id = ? AND participant_person_links.relationship_code = 1", person_id) }

  scope :upcoming_births, joins(:ppg_details).where("ppg_details.orig_due_date > '#{Date.today.to_s(:db)}' or ppg_details.due_date_2 > '#{Date.today.to_s(:db)}' or ppg_details.due_date_3 > '#{Date.today.to_s(:db)}'")

  delegate :age, :first_name, :last_name, :person_dob, :gender, :upcoming_events, :contact_links, :instruments, :start_instrument, :started_survey, :instrument_for, :to => :person

  after_create :set_initial_state_for_recruitment_strategy

  def after_initialize
    self.class.importer_mode_on = false;
  end

  ##
  # Only Hi/Lo strategy uses the low_intensity_state machine.
  # If the recruitment_strategy is not Hi/Lo (two_tier_knowledgable)
  # then set the participant firmly in the high_intensity_state machine.
  def set_initial_state_for_recruitment_strategy
    unless NcsNavigatorCore.recruitment_strategy.two_tier_knowledgable?
      self.high_intensity = true
      self.start_in_high_intensity_arm!
      self.high_intensity_conversion! if can_high_intensity_conversion?
    end
  end

  ##
  # State Machine used to manage relationship with Patient Study Calendar
  # for the Low Intensity protocol
  state_machine :low_intensity_state, :initial => :pending do
    store_audit_trail
    before_transition :log_state_change
    after_transition :on => :enroll_in_high_intensity_arm, :do => :add_to_high_intensity_protocol
    after_transition :on => :birth_event_low, :do => :update_ppg_status_after_birth
    after_transition :on => :lose_child, :do => :update_ppg_status_after_child_loss

    event :register do
      transition :pending => :registered
    end

    event :assign_to_pregnancy_probability_group do
      transition :registered => :in_pregnancy_probability_group
    end

    event :low_intensity_consent do
      transition [:in_pregnancy_probability_group, :registered] => :consented_low_intensity
    end

    event :follow_low_intensity do
      transition [:in_pregnancy_probability_group, :consented_low_intensity, :following_low_intensity] => :following_low_intensity
    end

    event :impregnate_low do
      transition [:in_pregnancy_probability_group, :consented_low_intensity, :following_low_intensity, :moved_to_high_intensity_arm] => :pregnant_low
    end

    event :lose_child do
      transition [:pregnant_low, :in_pregnancy_probability_group, :consented_low_intensity, :following_low_intensity] => :following_low_intensity
    end

    event :birth_event_low do
      transition [:in_pregnancy_probability_group, :consented_low_intensity, :pregnant_low, :following_low_intensity] => :postnatal
    end

    event :enroll_in_high_intensity_arm do
      transition [:in_pregnancy_probability_group, :pregnant_low, :following_low_intensity, :consented_low_intensity] => :moved_to_high_intensity_arm
    end

    event :start_in_high_intensity_arm do
      transition [:pending, :in_pregnancy_probability_group] => :started_in_high_intensity_arm
    end

    event :move_back_to_low_intensity do
      transition [:moved_to_high_intensity_arm] => :following_low_intensity
    end

  end

  ##
  # State Machine used to manage relationship with Patient Study Calendar
  # for the High Intensity, Enhanced Household, Provider Based, and Provider Based Subsample protocols
  state_machine :high_intensity_state, :initial => :in_high_intensity_arm do
    store_audit_trail
    before_transition :log_state_change
    after_transition :on => :high_intensity_conversion, :do => :process_high_intensity_conversion!
    after_transition :on => :pregnancy_one_visit, :do => :process_pregnancy_visit_one!
    after_transition :on => :birth_event, :do => :update_ppg_status_after_birth
    # TODO: probably need a PPG update trigger for :lose_pregnancy

    event :high_intensity_conversion do
      transition :in_high_intensity_arm => :converted_high_intensity
    end

    event :completed_pbs_eligibility_screener do
      transition :converted_high_intensity => :pregnancy_one
    end

    event :non_pregnant_informed_consent do
      transition [:converted_high_intensity, :in_high_intensity_arm] => :pre_pregnancy
    end

    event :pregnant_informed_consent do
      transition [:converted_high_intensity, :in_high_intensity_arm] => :pregnancy_one
    end

    event :late_pregnant_informed_consent do
      transition [:converted_high_intensity, :in_high_intensity_arm] => :pregnancy_two
    end

    event :follow do
      transition [:converted_high_intensity, :in_high_intensity_arm, :pre_pregnancy, :following_high_intensity] => :following_high_intensity
    end

    event :impregnate do
      transition [:following_high_intensity, :pre_pregnancy, :converted_high_intensity] => :pregnancy_one
    end

    event :pregnancy_one_visit do
      transition :pregnancy_one => :pregnancy_two
    end

    event :pregnancy_two_visit do
      transition :pregnancy_two => :ready_for_birth
    end

    event :late_pregnancy_one_visit do
      transition [:pregnancy_one, :pregnancy_two] => :ready_for_birth
    end

    event :lose_pregnancy do
      transition [:pregnancy_one, :pregnancy_two, :ready_for_birth] => :following_high_intensity
    end

    event :birth_event do
      transition [:pregnancy_one, :pregnancy_two, :ready_for_birth] => :parenthood
    end

    event :birth_cohort do
      transition :converted_high_intensity => :ready_for_birth
    end

  end

  ##
  # Log each time the Participant changes state
  # cf. state_machine above
  def log_state_change(transition)
    event, from, to = transition.event, transition.from_name, transition.to_name
    Rails.logger.info("Participant State Change #{id}: #{from} => #{to} on #{event}")
  end

  ##
  # Helper method to get the current state of the Participant
  # Since there are two state_machines (one for Low Intensity and one for High (or PB or EH))
  # this will return the current state based on which arm the Participant is enrolled in
  # @return [String]
  def state
    if low_intensity?
      low_intensity_state
    else
      high_intensity_state
    end
  end

  ##
  # Helper method to set the current state of the Participant
  # Since there are two state_machines (one for Low Intensity and one for High (or PB or EH))
  # this will update the state based on which arm the Participant is enrolled in
  # @param [String]
  def state=(state)
    if low_intensity? && (state != high_intensity_state)
      self.low_intensity_state = state
    else
      self.high_intensity_state = state
    end
  end

  ##
  # After a survey has been completed the participant would move through the states as
  # defined in the state machine
  # @param [ResponseSet] - used to determine survey taken
  # @param [PatientStudyCalendar] - cf. ApplicationController#psc
  def update_state_after_survey(response_set, psc)

    # TODO: ensure that the response_set has been completed

    survey_title = response_set.survey.title

    if /_PregScreen_/ =~ survey_title
      psc.update_subject(self)
      assign_to_pregnancy_probability_group! if can_assign_to_pregnancy_probability_group?
    end

    if /_PBSamplingScreen_/ =~ survey_title
      psc.update_subject(self)
      assign_to_pregnancy_probability_group! if can_assign_to_pregnancy_probability_group?
    end

    if /_PBSampScreenHosp_/ =~ survey_title
      psc.update_subject(self)
      assign_to_pregnancy_probability_group! if can_assign_to_pregnancy_probability_group?
      birth_cohort!
    end

    if /_LIPregNotPreg_/ =~ survey_title && can_follow_low_intensity?
      follow_low_intensity!
    end

    if /_LIHIConversion_/ =~ survey_title
      enroll_in_high_intensity_arm! if can_enroll_in_high_intensity_arm?
      high_intensity_conversion!
    end

    if /_PPGFollUp_/ =~ survey_title
      follow! if can_follow? && high_intensity?
    end

    if known_to_be_pregnant?
      if low_intensity? &&
         can_impregnate_low? &&
         !due_date_is_greater_than_follow_up_interval(most_recent_contact.contact_date_date)
         impregnate_low!
      end

      if high_intensity? &&
         can_impregnate?
         impregnate!
      end
    end

    if /_PrePreg_/ =~ survey_title
      non_pregnant_informed_consent! if can_non_pregnant_informed_consent?
      follow! if can_follow?
    end

    if /_PregVisit1_/ =~ survey_title && can_pregnancy_one_visit?
      pregnancy_one_visit!
    end

    if /_PregVisit2_/ =~ survey_title && can_pregnancy_two_visit?
      pregnancy_two_visit!
    end

    if /_Birth_/ =~ survey_title
      if low_intensity?
        birth_event_low! if can_birth_event_low?
      else
        birth_event! if can_birth_event?
      end
    end

    # TODO: move this to a method that can be called after Contact or Event
    #       has been updated cf. #2524
    if known_to_have_experienced_child_loss? && can_lose_child?
      lose_child!
    end

    self.update_attribute(:being_followed, true) unless self.being_followed?
  end

  ##
  # After a participant has consented to the high intensity arm
  # this method determines the next state for the participant based
  # on the ppg status
  def process_high_intensity_conversion!
    return unless converted_high_intensity?
    return if ppg_status.blank?

    case ppg_status.local_code
    when 1
      pregnant_informed_consent!
    when 2
      non_pregnant_informed_consent!
    else
      follow!
    end
  end

  ##
  # After a pregnancy visit one this method
  # determines if the due date is before the next scheduled event date
  # in which case moves the participant to the ready for birth state
  def process_pregnancy_visit_one!
    if due_date && due_date <= next_scheduled_event_date
      late_pregnancy_one_visit!
    end
  end

  def self_link
    participant_person_links.detect { |ppl| ppl.relationship_code == 1 }
  end
  private :self_link

  ##
  # The person record associated with this participant, if any, whose
  # relationship is self
  def person
    self_link.try(:person)
  end

  ##
  # Create or update the person record associated with this participant whose
  # relationship is self
  def person=(person)
    ppl = self_link
    if ppl
      ppl.person = person
    else
      participant_person_links.build(:relationship_code => 1, :person_id => person.id, :participant_id => self.id, :psu => self.psu)
    end
  end

  ##
  # Convenience method to retrieve the single Participant record for the given person
  def self.for_person(person_id)
    Participant.all_people_for_self(person_id).first
  end

   ##
   # Given attributes for the child person record
   # create the child Person record, the child Participant record
   # and associate it with this Participant
   # @param[Hash]
   # @return[Participant]
   def create_child_person_and_participant!(person_attrs)
     create_child_participant!(Person.create(person_attrs))
   end

   ##
   # Given the child person record
   # create the child Participant record
   # and associate it with this Participant through ParticipantPersonLink
   # @param[Hash]
   # @return[Participant]
   def create_child_participant!(child)
     # 6 - NCS Child - Participant Type
     child_participant = Participant.create(:psu_code => NcsNavigatorCore.psu, :p_type_code => 6)
     child_participant.person = child
     child_participant.save!
     # 2 - Mother, associating child participant with its mother - ParticipantPersonRelationship
     ParticipantPersonLink.create(:participant_id => child_participant.id, :person_id => self.person.id, :relationship_code => 2)
     # 8 - Child, associating mother participant with its child - ParticipantPersonRelationship
     ParticipantPersonLink.create(:participant_id => self.id, :person_id => child.id, :relationship_code => 8)
     child_participant
  end

  ##
  # True if the participant has children
  # @return[Boolean]
  def has_children?
    !self.children.blank?
  end

  def advance(psc, event = events.chronological.last)
    if self.pending_events.blank?
      update_state_to_next_event(event)
      Event.schedule_and_create_placeholder(psc, self)
    end
  end

  ##
  # The current pregnancy probability group status for this participant.
  #
  # This is determined either by the first assigned status from the ppg_details relationship
  # or from the most recent ppg_status_histories record.
  # Each participant will be associated with a ppg_details record when first screened and
  # will have a ppg_status_histories association after the first follow-up. There is a good
  # chance that the ppg_status_histories record will be created in tandem with the ppg_details
  # when first screened, but this cannot be assured.
  #
  # The big difference between the two is that the ppg_detail status comes from the PPG_STATUS_CL2
  # code list whereas the ppg_status_history status comes from the PPG_STATUS_CL1 code list.
  #
  # 1 - PPG Group 1: Pregnant and Eligible
  # 2 - PPG Group 2: High Probability – Trying to Conceive
  # 3 - PPG Group 3: High Probability – Recent Pregnancy Loss
  # 4 - PPG Group 4: Other Probability – Not Pregnancy and not Trying
  # 5 - PPG Group 5: Ineligible (Unable to Conceive, age-ineligible)
  # 6 or nil - PPG: Group 6: Withdrawn
  # 6 or 7 - Ineligible Dwelling Unit
  #
  # @return [NcsCode]
  def ppg_status(date = Date.today)
    ppg_status_histories.blank? ? ppg_status_from_ppg_details : ppg_status_from_ppg_status_histories(date)
  end

  def ppg_status_from_ppg_details
    ppg_details.blank? ? nil : ppg_details.first.ppg_first
  end
  private :ppg_status_from_ppg_details

  def ppg_status_from_ppg_status_histories(date = Date.today)
    psh = ppg_status_histories.where(['ppg_status_date_date <= ?', date]).order("ppg_status_date_date DESC").all
    psh.blank? ? ppg_status_histories.first.ppg_status : psh.first.ppg_status
  end
  private :ppg_status_from_ppg_status_histories

  ##
  # The next segment in PSC for the participant
  # based on the current state, pregnancy probability group, and protocol arm
  #
  # @return [String]
  def next_study_segment
    return nil if !has_eligible_ppg_status?
    low_intensity? ? next_low_intensity_study_segment : next_high_intensity_study_segment
  end

  ##
  # The next event for the participant with the date and the event name.
  # Returns nil if Participant does not have a next_study_segment (i.e. Not Registered with PSC)
  # or if the Participant has no contacts.
  #
  # (Note that contacts returns an ActiveRecord::Relation and here we all .empty? on that relation
  #  to determine if there are any contacts for this participant)
  #
  # @return [ScheduledEvent]
  def next_scheduled_event
    return nil if next_study_segment.blank? || contacts.empty?
    ScheduledEvent.new(:date => next_scheduled_event_date, :event => upcoming_events.first)
  end

  ##
  # Based on the current state, pregnancy probability group, and
  # the intensity group (hi/lo) determine the next event
  # @return [String]
  def upcoming_events
    events = []
    events << next_study_segment if next_study_segment
    events
  end

  ##
  # Returns all events where event_end_date is null
  # @return [Array<Event>]
  def pending_events
    events.where("event_end_date IS NULL").chronological
  end

  ##
  # Returns all events where event_end_date is not null
  # @return [Array<Event>]
  def completed_events(event_type = nil)
    result = events.select { |e| e.closed? }
    result = result.select { |e| e.event_type == event_type } if event_type
    result
  end

  ##
  # True if completed events has event of given type
  # @param [NcsCode] - Event Type
  # @return [Boolean]
  def completed_event?(event_type)
    completed_events(event_type).count > 0
  end

  ##
  # If an event is missed this method will do the following:
  # 1. Closed the current pending event (i.e. set the event_end_date to now)
  # 2. Set the disposition for that event to 'Out if Window'
  # 3. Cancel scheduled activity in PSC with reason of 'Out of Window'
  # 4. If there are no remaining pending events, schedule and create placeholder for the next event
  def mark_event_out_of_window(psc, event)
    resp = nil

    if event
      event.mark_out_of_window
      event.close!
      event.cancel_activities(psc, "Missed Event - Out of Window")

      resp = advance(psc, event)
    end

    resp
  end

  ##
  def update_state_to_next_event(event)
    case event.event_type.local_code
    when 4, 5, 6, 9, 29, 34
      # Pregnancy Screener Events or PBS Eligibility Screener
      if NcsNavigatorCore.recruitment_strategy.pbs?
        completed_pbs_eligibility_screener!
      elsif can_assign_to_pregnancy_probability_group?
        assign_to_pregnancy_probability_group!
      end
    when 10
      # Informed Consent
      low_intensity_consent! if can_low_intensity_consent?

    when 33
      # Lo I Quex
      follow_low_intensity! if can_follow_low_intensity?

    when 7,8
      # Pregnancy Probability
      follow! if can_follow? && high_intensity?

      if known_to_be_pregnant?
        date = event.event_end_date.blank? ? event.event_start_date : event.event_end_date
        if low_intensity? &&
         can_impregnate_low? &&
         !due_date_is_greater_than_follow_up_interval(date)
         impregnate_low!
        end

        if high_intensity? &&
         can_impregnate?
         impregnate!
        end
      end

    when 11, 12
      # Pre-Pregnancy
      non_pregnant_informed_consent! if can_non_pregnant_informed_consent?
      follow! if can_follow?

    when 13, 14
      # Pregnancy Visit 1
      pregnancy_one_visit! if can_pregnancy_one_visit?

    when 15, 16
      # Pregnancy Visit 2
      pregnancy_two_visit! if can_pregnancy_two_visit?

    when 18, 23, 24, 25, 26, 27, 28, 30, 31, 36, 37, 38
      # Birth and Post-natal
      if low_intensity?
        birth_event_low! if can_birth_event_low?
      else
        birth_event! if can_birth_event?
      end
    end

  end

  ##
  # Display text from the NcsCode list PARTICIPANT_TYPE_CL1
  # cf. p_type belongs_to association
  # @return [String]
  def participant_type
    p_type.to_s
  end

  ##
  # The number of months to wait before the next event
  # @return [Date]
  def interval
    case
    when pending?, registered?, newly_moved_to_high_intensity_arm?, pre_pregnancy?, (can_consent? && eligible_for_low_intensity_follow_up?), pregnancy_one?
      0
    when pregnancy_two?
      60.days
    when followed?, in_pregnancy_probability_group?, following_low_intensity?, postnatal?
      follow_up_interval
    when in_pregnant_state?
      due_date ? 1.day : 0
    else
      0
    end
  end

  ##
  # The number of months to wait before the next Follow-Up event
  # @return [Date]
  def follow_up_interval
    if should_take_low_intensity_questionnaire?
      0
    elsif low_intensity? or recent_loss?
      6.months
    else
      3.months
    end
  end

  def due_date_is_greater_than_follow_up_interval(date)
    due_date && due_date > follow_up_interval.since(date)
  end

  ##
  # The known due date for the pregnant participant, used to schedule the Birth Visit
  # @return [Date]
  def due_date
    dt = nil
    if ppg_details.first && ppg_details.first.due_date
      begin
        dt = Date.parse(ppg_details.first.due_date)
      rescue
        # NOOP - date is unparseable
      end
    end
    dt
  end

   def child_participant?
     self.p_type_code == 6
   end

  ##
  # Only Participants who are Pregnant or Trying to become pregnant
  # should be presented with the consent form, otherwise they should be ineligible
  # or simply following
  def can_consent?
    pregnant_or_trying?
  end

  ##
  # Returns true if the participant is in PPG 1 or 2 (pregnant_or_trying) and
  # has not given consent (or has withdrawn)
  def requires_consent
    !consented?
  end

  ##
  # Returns true if a participant_consent record exists for the given consent type
  # and consent_given_code is true and consent_withdraw_code is not true.
  # If no consent type is given, then check if any consent record exists
  # @param [NcsCode]
  # @return [Boolean]
  def consented?(consent_type = nil)
    return false if participant_consents.empty?
    if consent_type.nil?
      consent_type = low_intensity? ? ParticipantConsent.low_intensity_consent_type_code : ParticipantConsent.general_consent_type_code
    end
    consents = consents_for_type(consent_type)
    consents.select { |c| c.consent_given_code == 1 }.size > 0 && !withdrawn?
  end

  def consents_for_type(consent_type)
    participant_consents.where(
      "consent_type_code = ? OR consent_form_type_code = ?",
        consent_type.local_code, consent_type.local_code).all
  end

  def consent_for_type(consent_type)
    current_consent = nil
    cs = consents_for_type(consent_type)
    current_consent = cs.first
    if cs.size > 1
      cs.each { |c| current_consent = c if c.phase_two? }
    end
    current_consent
  end

  ##
  # Returns true if a participant_consent record exists for the given consent type
  # and consent_withdraw_code is true.
  # If no consent type is given, then check if any consent record exists that was withdrawn
  # @param [NcsCode]
  # @return [Boolean]
  def withdrawn?(consent_type = nil)
    return false if participant_consents.empty?
    consents = consent_type.nil? ? participant_consents : consents_for_type(consent_type)
    consents.select { |c| c.consent_withdraw_code == 1 }.size > 0
  end

  ##
  # Returns true if participant enroll status is 'Yes' (i.e. local_code == 1)
  # @return [Boolean]
  def enrolled?
    enroll_status.try(:local_code) == NcsCode::YES
  end

  ##
  # Returns true if participant enroll status is 'No' (i.e. local_code == 2)
  # @return [Boolean]
  def unenrolled?
    enroll_status.try(:local_code) == NcsCode::NO
  end

  ##
  # Unenrolling does the following:
  # 1. Withdraws the participant from the Study
  # 2. Sets the participant enroll status to No
  # 3. Cancels all scheduled activities in PSC
  # 4. Closes or Deletes all pending events
  # @param [PatientStudyCalendar]
  def unenroll(psc, reason = "Participant has been un-enrolled from the study.")
    self.enrollment_status_comment = reason
    self.participant_consents.each { |c| c.withdraw! if c.consented? }
    self.enroll_status = NcsCode.for_attribute_name_and_local_code(:enroll_status_code, NcsCode::NO)
    self.pending_events.each { |e| e.cancel_and_close_or_delete!(psc, reason) }
    self.being_followed = false
  end

  ##
  # Unenroll and save!
  # @param [PatientStudyCalendar]
  def unenroll!(psc, reason)
    self.unenroll(psc, reason)
    self.save!
  end

  ##
  # Sets the enroll status to Yes (i.e. local_code = 1)
  # and the enroll_date to the given date
  # @param enroll_date [Date]
  def enroll(enroll_date)
    self.enroll_status = NcsCode.for_attribute_name_and_local_code(:enroll_status_code, NcsCode::YES)
    self.enroll_date = enroll_date
    self.being_followed = true
  end

  ##
  # Enroll and save!
  # @param enroll_date [Date]
  def enroll!(enroll_date)
    self.enroll(enroll_date)
    self.save!
  end

  ##
  # Removing from active followup does the following:
  # 1. Sets the participant being_followed flag to false
  # 2. Cancels all scheduled activities in PSC
  # 3. Closes or Deletes all pending events
  # @param [PatientStudyCalendar]
  def remove_from_active_followup(psc, reason = "Participant is not actively being followed in the study.")
    self.enrollment_status_comment = reason
    self.pending_events.each do |e|
      e.cancel_and_close_or_delete!(psc, reason)
    end
    self.being_followed = false
  end

  def remove_from_active_followup!(psc, reason)
    self.remove_from_active_followup(psc, reason)
    self.save!
  end

  ##
  # Only Participants who are in a state of pending and have not yet registered with PSC can register
  def can_register_with_psc?(psc)
    can_register? && !psc.is_registered?(self)
  end

  ##
  # Participants who are eligible for the protocol but not actively trying nor pregnant
  # should be followed to see if they ever move to the 'can_consent' state
  def following?
    eligible_for_ppg_follow_up?
  end
  alias :followed? :following?

  ##
  # Participants are known to be pregnant if in the proper Pregnancy Probability Group
  def known_to_be_pregnant?(date = Date.today)
    pregnant?(date)
  end

  ##
  # Participants are known to have experienced child loss if in the proper Pregnancy Probability Group
  def known_to_have_experienced_child_loss?(date = Date.today)
    recent_loss?(date)
  end

  ##
  # Any low intensity participant who has been consented and is in PPG 1 or 2 should
  # take the Lo I Quex before taking the ppg follow up every six months.
  # A pregnant woman whose due_date is > 6 months out should take this Lo I Quex too
  def should_take_low_intensity_questionnaire?
    # TODO: determine if due date is > 6 mos
    low_intensity? && pregnant_or_trying? && !completed_event?(NcsCode.low_intensity_data_collection)
  end

  ##
  # Participant should be screened if they have not completed either
  # the Pregnancy Screener or PBS Eligibility Screener event
  def should_be_screened?
    new_participant_in_study? &&
    !completed_event?(NcsNavigatorCore.recruitment_strategy.pbs? ?
                      NcsCode.pbs_eligibility_screener :
                      NcsCode.pregnancy_screener)
  end

  ##
  # True if the participant state is in one of the initial states
  # i.e. not updated from an action in the study
  def new_participant_in_study?
    (converted_high_intensity? || pending? || registered?)
  end

  ##
  # @return [true,false]
  def low_intensity?
    !high_intensity
  end

  ##
  # @return [:high, :low]
  def intensity
    high_intensity ? :high : :low
  end

  def add_to_high_intensity_protocol
    switch_arm(true)
  end

  ##
  # Change the Participant status from Pregnant to Other Probability after having given birth
  def update_ppg_status_after_birth
    post_transition_ppg_status_update(4) unless self.class.importer_mode_on
  end

  ##
  # Change the Participant status to PPG 3 after child loss
  def update_ppg_status_after_child_loss
    post_transition_ppg_status_update(3) unless self.class.importer_mode_on
  end

  def last_contact
    contacts.order("contact_date desc").first
  end
  alias :most_recent_contact :last_contact

  ##
  # Returns the contacts for this participant
  # Participant -> Event -> ContactLink -> Contact
  #
  # @return[ActiveRecord::Relation]
  def contacts
    Contact.joins(:contact_links).
      joins("left outer join events on events.id = contact_links.event_id").
      where("events.participant_id = ?", self.id)
  end

  ##
  # True if participant is known to live in Tertiary Sampling Unit
  # Delegate to Person model
  # @return [true,false]
  def in_tsu?
    person && person.in_tsu?
  end

  ##
  # True if a participant in the low_intensity arm has a ppg status of pregnant or trying and is in tsu
  def eligible_for_high_intensity_invitation?
    low_intensity? && pregnant_or_trying? && in_tsu? && completed_event?(NcsCode.low_intensity_data_collection)
  end

  ##
  # Helper method to switch from lo intensity to hi intensity protocol and vice-versa
  # @return [true, false]
  def switch_arm(ensure_high_intensity = false)
    val = ensure_high_intensity ? true : !self.high_intensity
    self.high_intensity = val
    self.save!

    set_switch_arm_state(val)
    close_pending_events
  end

  def father
    # TODO: do not hard code NcsCode local code here
    relationships(4).first
  end

  def children
    # TODO: do not hard code NcsCode local code here
    relationships(8)
  end

  def mother
    # TODO: do not hard code NcsCode local code here
    relationships(2).first
  end

  def partner
    # TODO: do not hard code NcsCode local code here
    relationships(7).first
  end

  def grandparents
    # TODO: do not hard code NcsCode local code here
    relationships(10)
  end

  def other_relatives
    # TODO: do not hard code NcsCode local code here
    relationships(11)
  end

  def friends
    # TODO: do not hard code NcsCode local code here
    relationships(12)
  end

  def neighbors
    # TODO: do not hard code NcsCode local code here
    relationships(13)
  end

  ##
  # Find all Participants for the given pregnancy probability group
  # @param local_code for NcsCode
  # @return[Array<Participant>]
  def self.in_ppg_group(local_code)
    results = []
    results << Participant.joins(:ppg_status_histories).where("ppg_status_histories.ppg_status_code = ?", local_code).all.select { |par| par.ppg_status.local_code == local_code }
    results << Participant.joins(:ppg_details).where("ppg_details.ppg_first_code = ?", local_code).all.select { |par| par.ppg_status.local_code == local_code }
    results.flatten.uniq
  end

  ##
  # Temporary helper method to assist in reverting state during development
  # TODO: delete me
  def unregister
    self.state = "pending"
    self.save!
  end

  ##
  # Temporary helper method to assist in reverting state during development
  # TODO: delete me
  def remove_from_pregnancy_probability_group
    self.state = "registered"
    self.save!
  end

  def primary_staff_relationships
    participant_staff_relationships.where(:primary => true).all
  end

  # [1, "Household Enumeration"],
  # [2, "Two Tier Enumeration"],
  # [3, "Ongoing Tracking of Dwelling Units"],
  # [4, "Pregnancy Screening - Provider Group"],
  # [5, "Pregnancy Screening – High Intensity  Group"],
  # [6, "Pregnancy Screening – Low Intensity Group "],
  # [7, "Pregnancy Probability"],
  # [8, "PPG Follow-Up by Mailed SAQ"],
  # [9, "Pregnancy Screening - Household Enumeration Group"],
  # [10, "Informed Consent"],
  # [11, "Pre-Pregnancy Visit"],
  # [12, "Pre-Pregnancy Visit SAQ"],
  # [13, "Pregnancy Visit  1"],
  # [14, "Pregnancy Visit #1 SAQ"],
  # [15, "Pregnancy Visit  2"],
  # [16, "Pregnancy Visit #2 SAQ"],
  # [17, "Pregnancy Visit - Low Intensity Group"],
  # [18, "Birth"],
  # [19, "Father"],
  # [20, "Father Visit SAQ"],
  # [21, "Validation"],
  # [22, "Provider-Based Recruitment"],
  # [23, "3 Month"],
  # [24, "6 Month"],
  # [25, "6-Month Infant Feeding SAQ"],
  # [26, "9 Month"],
  # [27, "12 Month"],
  # [28, "12 Month Mother Interview SAQ"],
  # [29, "Pregnancy Screener"],
  # [30, "18 Month"],
  # [31, "24 Month"],
  # [32, "Low to High Conversion"],
  # [33, "Low Intensity Data Collection"],
  # [34, "PBS Participant Eligibility Screening"],
  # [35, "PBS Frame SAQ"],
  # [-5, "Other"],
  # [-4, "Missing in Error"]
  #
  # This method is reactive and cannot know the outcome of the event
  # so it simply will set the state to the most probable given the
  # event type and the current state
  # @param [Event]
  def set_state_for_event_type(event)
    register! if can_register?  # assume known to PSC

    case event.event_type.local_code
    when 4, 5, 6, 29, 34
      # Pregnancy Screener Events or PBS Eligibility Screener
      assign_to_pregnancy_probability_group! if can_assign_to_pregnancy_probability_group?
    when 10
      # Informed Consent
      if low_intensity?
        granting_consents = event.match_consents_by_date(participant_consents).select { |c| c.consent_given_code == NcsCode::YES }
        has_any_consent = !granting_consents.empty?
        has_hi_consent = granting_consents.any? { |c| [1].include?(c.consent_type_code) || [1, 2, 6].include?(c.consent_form_type_code) }

        Rails.logger.debug("Applying informed consent event #{event.event_id} to lo participant #{p_id}'s state.")
        Rails.logger.debug("  has_any_consent=#{has_any_consent.inspect} has_hi_consent=#{has_hi_consent.inspect} granting_consents=#{granting_consents.collect(&:public_id).inspect}")

        # Have to have consented to low first
        if has_any_consent
          low_intensity_consent! if can_low_intensity_consent?
        end

        if has_hi_consent
          move_to_high_intensity_if_required
        end
      end
      # if already hi, do nothing
    when 7, 8
      # Pregnancy Probability
      follow_low_intensity! if can_follow_low_intensity?
      follow! if can_follow? && high_intensity?
      impregnate_low! if can_impregnate_low? && known_to_be_pregnant?(event.import_sort_date)
    when 33
      # Lo I Quex
      follow_low_intensity if can_follow_low_intensity?
      impregnate_low! if can_impregnate_low? && known_to_be_pregnant?(event.import_sort_date)
    when 11, 12
      # Pre-Pregnancy
      move_to_high_intensity_if_required
      non_pregnant_informed_consent! if can_non_pregnant_informed_consent?
      lose_pregnancy! if can_lose_pregnancy?
      follow!
    when 13, 14
      # Pregnancy Visit 1
      move_to_high_intensity_if_required
      pregnant_informed_consent! if can_pregnant_informed_consent?
      impregnate! if can_impregnate?
      # pregnancy_one_visit!
    when 15, 16
      # Pregnancy Visit 2
      move_to_high_intensity_if_required
      late_pregnant_informed_consent! if can_late_pregnant_informed_consent?
      pregnancy_one_visit! if can_pregnancy_one_visit?
    when 18, 23, 24, 25, 26, 27, 28, 30, 31, 36, 37, 38
      # Birth and Post-natal
      if low_intensity?
        birth_event_low! if can_birth_event_low?
      else
        birth_event! if can_birth_event?
      end
    when 32
      # The Low-High conversion event itself does not indicate that the person
      # was converted. Conversion is handled in 10 "Informed Consent".
    when 17, 19, 21, 1, -5
      # Do not correspond to states in state machine
    else
      fail "Unhandled event type for participant state #{event.event_type.local_code.inspect}"
    end
  end

  def self.importer_mode
    self.importer_mode_on = true
    yield
    self.importer_mode_on = false
  end

  comma do

    p_id 'Participant ID'
    person :prefix => 'Prefix'
    person :first_name => 'First Name'
    person :middle_name => 'Middle Name'
    person :last_name => 'Last Name'
    person :maiden_name => 'Maiden Name'
    person :suffix => 'Suffix'
    person :title => 'Title'
    ppg_status 'PPG Status'
    person_dob 'Date of Birth'
    person :gender => 'Gender'
    person :age => 'Age'
    person :age_range => 'Age Range'
    person :deceased => 'Deceased'
    person :ethnic_group => 'Ethnic Group'
    person :language => 'Language'
    person :language_other => 'Other Language'
    person :marital_status => 'Marital Status'
    person :marital_status_other => 'Other Marital Status'
    pending_events :to_sentence => 'Pending Events'
    due_date
    high_intensity { |hi| hi ? 'High' : 'Low' }
    enroll_status
    enroll_date

  end

  def eligible?
    NcsNavigatorCore.recruitment_strategy.pbs? ? eligible_for_pbs? : has_eligible_ppg_status?
  end

  def eligible?
    if NcsNavigatorCore.recruitment_strategy.pbs? && !hospital?
      eligible_for_pbs?
    elsif NcsNavigatorCore.recruitment_strategy.pbs? && hospital?
      eligible_for_birth_cohort?
    else
      has_eligible_ppg_status?
    end
  end

  def eligible_for_pbs?
    eligible = []
    person = ParticipantPersonLink.where(:participant_id => self.id, :relationship_code => 1).first.person
    providers_in_frame_prefix = "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX_PROVIDER_OFFICE}"

    eligibility_determination = [:age_eligible?,
                                 :psu_county_eligible?,
                                 :pbs_pregnant?,
                                 :first_visit?]
    eligibility_determination.all? { |ed| self.send(ed, person) } &&
    self.send(:no_preceding_providers_in_frame?, person, providers_in_frame_prefix)
  end

  def eligible_for_birth_cohort?
    eligible = []
    person = ParticipantPersonLink.where(:participant_id => self.id, :relationship_code => 1).first.person
    providers_in_frame_prefix = "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX_PROVIDER_OFFICE}"

    eligibility_determination = [:age_eligible?,
                                 :psu_county_eligible?]
    eligibility_determination.all? { |ed| self.send(ed, person) } &&
    self.send(:no_preceding_providers_in_frame?, person, providers_in_frame_prefix)
  end

  def pbs_eligbility_prefix
    hospital? ? "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}" : "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}"
  end

  def age_eligible?(person)
    eligible_for?(person, "AGE_ELIG")
  end

  def psu_county_eligible?(person)
    eligible_for?(person, "PSU_ELIG_CONFIRM")
  end

  def pbs_pregnant?(person)
    eligible_for?(person, "PREGNANT")
  end

  def first_visit?(person)
    eligible_for?(person, "FIRST_VISIT")
  end

  ##
  # If the reference_identifier for the response associated with the
  # given data_export_identifier is "1" (true) then return true
  # otherwise false
  # @param[Person, nil] Person the person associated with the participant
  # @param[String] data_export_identifier for question
  # @return[Boolean]
  def eligible_for?(person, reference_identifier)
    data_export_identifier = pbs_eligbility_prefix + "." + reference_identifier
    most_recent_response = person.responses_for(data_export_identifier).last
    most_recent_response.try(:answer).try(:reference_identifier) == "1"
  end
  private :eligible_for?

  def no_preceding_providers_in_frame?(person, prefix)
    answers = []
    reference_identifier ="PROVIDER_OFFICE_ON_FRAME"
    data_export_identifier = prefix + "." + reference_identifier
    rsps = person.responses_for(data_export_identifier).all
    rsps.each { |rsp| answers << rsp.answer.reference_identifier } if rsps != nil
    return true if rsps == nil
    answers.any? { |a| a == "1" } ? false : true
  end

  def has_eligible_ppg_status?(date = Date.today)
    ppg_status(date).try(:local_code).to_i < 5
  end

  private

    def relationships(code)
      participant_person_links.
        select  { |ppl| ppl.relationship.local_code == code }.
        collect { |ppl| ppl.person }
    end

    def next_low_intensity_study_segment
      if pending? || registered? || should_be_screened?
        screener_instrument
      elsif should_take_low_intensity_questionnaire?
        PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
      elsif postnatal?
        PatientStudyCalendar::LOW_INTENSITY_POSTNATAL
      elsif pregnant?
        if due_date && !due_date_is_greater_than_follow_up_interval(most_recent_contact.contact_date_date)
          PatientStudyCalendar::LOW_INTENSITY_BIRTH_VISIT_INTERVIEW
        else
          lo_intensity_follow_up
        end
      elsif following_low_intensity?
        lo_intensity_follow_up
      elsif eligible_for_low_intensity_follow_up?
        lo_intensity_follow_up
      else
        nil
      end
    end

    def next_high_intensity_study_segment
      if should_be_screened?
        screener_instrument
      elsif registered?
        switch_arm if high_intensity? # Participant should not be in the high intensity arm if now just registering
        screener_instrument
      elsif in_high_intensity_arm?
        PatientStudyCalendar::HIGH_INTENSITY_HI_LO_CONVERSION
      elsif following_high_intensity? || converted_high_intensity?
        PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
      elsif pre_pregnancy?
        PatientStudyCalendar::HIGH_INTENSITY_PRE_PREGNANCY
      elsif pregnancy_one?
        PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1
      elsif pregnancy_two?
        PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_2
      elsif ready_for_birth?
        PatientStudyCalendar::CHILD_CHILD
      elsif parenthood?
        PatientStudyCalendar::CHILD_CHILD
      else
        nil
      end
    end

    def screener_instrument
      if NcsNavigatorCore.recruitment_strategy.pbs?
        self.hospital? ? PatientStudyCalendar::BIRTH_COHORT_SCREENING : PatientStudyCalendar::PBS_ELIGIBILITY_SCREENER
      else
        PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
      end
    end

    def eligible_for_low_intensity_follow_up?
      low_intensity? && (in_pregnancy_probability_group? || consented_low_intensity?)
    end

    def lo_intensity_follow_up
      return nil if !has_eligible_ppg_status?
      if can_consent?
        if has_completed_low_intensity_data_collection?
          PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
        else
          PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2
        end
      else
        PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
      end
    end

    def has_completed_low_intensity_data_collection?
      events.select { |e| e.event_type_code == 33 && !e.event_end_date.blank? }.size > 0
    end

    def eligible_for_ppg_follow_up?
      return false if ppg_status.nil?
      status_codes = [3,4]
      status_codes << 2 if consented_to_high_intensity_arm? || following_high_intensity? || pre_pregnancy?
      status_codes.include?(ppg_status.local_code)
    end

    def pregnant_or_trying?(date = Date.today)
      pregnant?(date) || trying?(date)
    end

    def pregnant?(date = Date.today)
      ppg_status(date).try(:local_code) == 1
    end

    def trying?(date = Date.today)
      ppg_status(date).try(:local_code) == 2
    end

    def recent_loss?(date = Date.today)
      ppg_status(date).try(:local_code) == 3
    end

    def consented_to_high_intensity_arm?
      high_intensity && ["converted_high_intensity", "pre_pregnancy", "pregnancy_one", "pregnancy_two"].include?(state)
    end

    def newly_moved_to_high_intensity_arm?
      high_intensity && ["in_high_intensity_arm"].include?(state)
    end

    ##
    # If we should not wait anytime before the next
    # event return the most recent contact date,
    # otherwise determine from which date to schedule
    # the next event and add the amount of time to wait
    # to that
    #
    # @return[Date]
    def next_scheduled_event_date
      (interval == 0) ? get_date_to_schedule_next_event_from_contact_link : (date_used_to_schedule_next_event.to_date + interval)
    end

    ##
    # Determine the date from which to scheduled the next event.
    #
    # @return[Date]
    def date_used_to_schedule_next_event
      if due_date && next_event_is_birth?
        due_date
      elsif contact_links.blank?
        self.created_at.to_date
      else
        get_date_to_schedule_next_event_from_contact_link
      end
    end

    ##
    # The date from the most_recent_contact/last_contact.
    # @return[Date]
    def get_date_to_schedule_next_event_from_contact_link
      if last_contact
        last_contact.contact_date_date
      else
        fail 'Could not decide the next scheduled event date without the contact.'
      end
    end

    def next_event_is_birth?
      pregnant_low? || ready_for_birth?
    end

    def in_pregnant_state?
      pregnancy_one? || pregnancy_two? || pregnant_low? || ready_for_birth?
    end

    def post_transition_ppg_status_update(ppg_status_local_code)
      new_ppg_status  = NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => ppg_status_local_code).first
      ppg_info_source = NcsCode.where(:list_name => "INFORMATION_SOURCE_CL3").where(:local_code => -5).first
      ppg_info_mode   = NcsCode.where(:list_name => "CONTACT_TYPE_CL1").where(:local_code => -5).first
      PpgStatusHistory.create(:psu => self.psu, :ppg_status => new_ppg_status, :ppg_info_source => ppg_info_source, :ppg_info_mode => ppg_info_mode, :participant_id => self.id)
    end

    def move_to_high_intensity_if_required
      enroll_in_high_intensity_arm! if can_enroll_in_high_intensity_arm?
      high_intensity_conversion! if can_high_intensity_conversion?
    end

    ##
    # Sets the end date of all pending events
    # to the start date for the event (or today)
    def close_pending_events
      pending_events.each do |e|
        end_date = e.event_start_date.blank? ? Date.today : e.event_start_date
        e.update_attribute(:event_end_date, end_date)
      end
    end

    def set_switch_arm_state(hi_intensity)
      case hi_intensity
      when true
        enroll_in_high_intensity_arm! if can_enroll_in_high_intensity_arm?
      when false
        move_back_to_low_intensity! if can_move_back_to_low_intensity?
      end
    end
end

