# == Schema Information
# Schema version: 20111212224350
#
# Table name: participants
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  p_id                     :string(36)      not null
#  p_type_code              :integer         not null
#  p_type_other             :string(255)
#  status_info_source_code  :integer         not null
#  status_info_source_other :string(255)
#  status_info_mode_code    :integer         not null
#  status_info_mode_other   :string(255)
#  status_info_date         :date
#  enroll_status_code       :integer         not null
#  enroll_date              :date
#  pid_entry_code           :integer         not null
#  pid_entry_other          :string(255)
#  pid_age_eligibility_code :integer         not null
#  pid_comment              :text
#  transaction_type         :string(36)
#  created_at               :datetime
#  updated_at               :datetime
#  being_processed          :boolean
#  high_intensity           :boolean
#  low_intensity_state      :string(255)
#  high_intensity_state     :string(255)
#

# A Participant is a living Person who has provided Study data about her/himself or a NCS Child.
# S/he may have been administered a variety of questionnaires or assessments, including household enumeration,
# pregnancy screener, pregnancy questionnaire, etc. Once born, NCS-eligible babies are assigned Participant IDs.
# Every Participant is also a Person. People do not become Participants until they are determined eligible for a pregnancy screener.
class Participant < ActiveRecord::Base
  include MdesRecord
  include ActiveModel::Dirty
  include ActiveModel::Validations
  include ActiveModel::Observing

  acts_as_mdes_record :public_id_field => :p_id

  ncs_coded_attribute :psu,                 'PSU_CL1'
  ncs_coded_attribute :p_type,              'PARTICIPANT_TYPE_CL1'
  ncs_coded_attribute :status_info_source,  'INFORMATION_SOURCE_CL4'
  ncs_coded_attribute :status_info_mode,    'CONTACT_TYPE_CL1'
  ncs_coded_attribute :enroll_status,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :pid_entry,           'STUDY_ENTRY_METHOD_CL1'
  ncs_coded_attribute :pid_age_eligibility, 'AGE_ELIGIBLE_CL2'

  has_many :ppg_details, :order => "created_at DESC"
  has_many :ppg_status_histories, :order => "created_at DESC"

  has_many :low_intensity_state_transition_audits,  :class_name => "ParticipantLowIntensityStateTransition",  :foreign_key => "participant_id"
  has_many :high_intensity_state_transition_audits, :class_name => "ParticipantHighIntensityStateTransition", :foreign_key => "participant_id"

  has_many :participant_person_links
  has_many :participant_staff_relationships
  has_many :participant_consents
  has_many :events

  # validates_presence_of :person

  accepts_nested_attributes_for :ppg_details, :allow_destroy => true
  accepts_nested_attributes_for :ppg_status_histories, :allow_destroy => true

  scope :in_low_intensity, where("high_intensity is null or high_intensity is false")
  scope :in_high_intensity, where("high_intensity is true")

  scope :all_for_staff, lambda { |staff_id| joins(:participant_staff_relationships).where("participant_staff_relationships.staff_id = ?", staff_id) }
  scope :primary_for_staff, lambda { |staff_id| all_for_staff(staff_id).where("participant_staff_relationships.primary = ?", true) }
  scope :all_people_for_self, lambda { |person_id| joins(:participant_person_links).where("participant_person_links.person_id = ? AND participant_person_links.relationship_code = 1", person_id) }

  delegate :age, :first_name, :last_name, :person_dob, :gender, :upcoming_events, :contact_links, :current_contact_link, :instruments, :start_instrument, :started_survey, :instrument_for, :to => :person

  ##
  # State Machine used to manage relationship with Patient Study Calendar
  state_machine :low_intensity_state, :initial => :pending do
    store_audit_trail
    before_transition :log_state_change
    after_transition :on => :enroll_in_high_intensity_arm, :do => :add_to_high_intensity_protocol
    after_transition :on => :parenthood, :do => :update_ppg_status_after_birth
    after_transition :on => :lose_child, :do => :update_ppg_status_after_child_loss

    event :register do
      transition :pending => :registered
    end

    # TODO: determine if this is necessary
    # state :in_pregnancy_probability_group do
    #   validates_presence_of :ppg_status
    # end

    event :assign_to_pregnancy_probability_group do
      transition :registered => :in_pregnancy_probability_group
    end

    event :low_intensity_consent do
      transition [:in_pregnancy_probability_group, :registered] => :consented_low_intensity
    end

    event :follow_low_intensity do
      transition [:in_pregnancy_probability_group, :consented_low_intensity] => :following_low_intensity
    end

    event :impregnate_low do
      transition [:in_pregnancy_probability_group, :consented_low_intensity, :following_low_intensity, :moved_to_high_intensity_arm] => :pregnant_low
    end

    event :lose_child do
      transition [:pregnant_low, :in_pregnancy_probability_group, :consented_low_intensity, :following_low_intensity] => :following_low_intensity
    end

    event :birth_event_low do
      transition [:consented_low_intensity, :pregnant_low, :following_low_intensity] => :following_low_intensity
    end

    event :enroll_in_high_intensity_arm do
      transition [:in_pregnancy_probability_group, :pregnant_low, :following_low_intensity, :consented_low_intensity] => :moved_to_high_intensity_arm
    end

  end

  state_machine :high_intensity_state, :initial => :in_high_intensity_arm do
    store_audit_trail
    before_transition :log_state_change
    after_transition :on => :high_intensity_conversion, :do => :process_high_intensity_consent!

    event :high_intensity_conversion do
      transition :in_high_intensity_arm => :converted_high_intensity
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
      transition [:converted_high_intensity, :in_high_intensity_arm, :pre_pregnancy, :pregnancy_one] => :following_high_intensity
    end

    event :impregnate do
      transition [:following_high_intensity, :pre_pregnancy] => :pregnancy_one
    end

    event :pregnancy_one_visit do
      transition :pregnancy_one => :pregnancy_two
    end

    event :pregnancy_two_visit do
      transition :pregnancy_two => :ready_for_birth
    end

    event :late_pregnancy_one_visit do
      transition :pregnancy_one => :ready_for_birth
    end

    event :birth_event do
      transition [:pregnancy_one, :pregnancy_two, :ready_for_birth] => :parenthood
    end

    # event :three_months_after_birth do
    #   transition :birth => :three_month
    # end
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

    if /_LIPregNotPreg_/ =~ survey_title && can_follow_low_intensity?
      follow_low_intensity!
    end

    if /_LIHIConversion_/ =~ survey_title && can_enroll_in_high_intensity_arm?
      enroll_in_high_intensity_arm!
      high_intensity_conversion!
      process_high_intensity_consent!
    end

    if known_to_be_pregnant? && can_impregnate_low?
      if low_intensity? && following_low_intensity? && !due_date_is_greater_than_follow_up_interval
        impregnate_low!
      end
    end

    if /_PregVisit1_/ =~ survey_title && can_pregnancy_one_visit?
      pregnancy_one_visit!
    end

    if known_to_have_experienced_child_loss? && can_lose_child?
      lose_child!
    end

    # TODO: update participant state for each survey
    #       e.g. participant.assign_to_pregnancy_probability_group! after completing PregScreen
  end

  ##
  # After a participant has consented to the high intensity arm
  # this method determines the next state for the participant based
  # on the ppg status
  def process_high_intensity_consent!
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
  def ppg_status
    if ppg_status_histories.blank?
      ppg_details.blank? ? nil : ppg_details.first.ppg_first
    else
      ppg_status_histories.first.ppg_status
    end
  end

  ##
  # The next segment in PSC for the participant
  # based on the current state, pregnancy probability group, and protocol arm
  #
  # @return [String]
  def next_study_segment
    return nil if ineligible?
    low_intensity? ? next_low_intensity_study_segment : next_high_intensity_study_segment
  end

  ##
  # The next event for the participant with the date and the event name.
  # Returns nil if Participant does not have a next_study_segment (i.e. Not Registered with PSC)
  #
  # @return [ScheduledEvent]
  def next_scheduled_event
    return nil if next_study_segment.blank?
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
    events.select { |e| e.event_end_date.blank? }
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
    return 1.week unless pending_events.blank?

    case
    when pending?, registered?, newly_moved_to_high_intensity_arm?, pre_pregnancy?, (can_consent? && eligible_for_low_intensity_follow_up?)
      0
    when pregnancy_two?
      60.days
    when followed?, in_pregnancy_probability_group?, following_low_intensity?
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
    if low_intensity? or recent_loss?
      6.months
    else
      3.months
    end
  end

  def due_date_is_greater_than_follow_up_interval
    due_date && due_date > follow_up_interval.from_now.to_date
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
    if consent_type
      consent_type_codes = [consent_type.local_code]
    else
      if low_intensity?
        consent_type_codes = ParticipantConsent.low_intensity_consent_types.collect { |ct| ct[0] }
      else
        consent_type_codes = ParticipantConsent.high_intensity_consent_types.collect { |ct| ct[0] }
      end
    end
    consents = participant_consents.where("consent_type_code in (?)", consent_type_codes).all
    consents.select { |c| c.consent_given.local_code == 1 }.size > 0 && !withdrawn?
  end

  ##
  # Returns true if a participant_consent record exists for the given consent type
  # and consent_withdraw_code is true.
  # If no consent type is given, then check if any consent record exists that was withdrawn
  # @param [NcsCode]
  # @return [Boolean]
  def withdrawn?(consent_type = nil)
    return false if participant_consents.empty?
    if consent_type
      consents = participant_consents.where(:consent_type_code => consent_type.local_code).all
    else
      consents = participant_consents
    end
    consents.select { |c| c.consent_withdraw.local_code == 1 }.size > 0
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
  def known_to_be_pregnant?
    pregnant?
  end

  ##
  # Participants are known to have experienced child loss if in the proper Pregnancy Probability Group
  def known_to_have_experienced_child_loss?
    recent_loss?
  end

  ##
  # Any low intensity participant who has been consented and is in PPG 1 or 2 should
  # take the Lo I Quex every six months.
  # A pregnant woman whose due_date is > 6 months out should take this Lo I Quex too
  def should_take_low_intensity_questionnaire?
    # TODO: determine if due date is > 6 mos
    low_intensity? && consented_low_intensity? && pregnant_or_trying?
  end

  ##
  # @return [true,false]
  def low_intensity?
    !high_intensity
  end

  def add_to_high_intensity_protocol
    switch_arm(true)
  end

  ##
  # Change the Participant status from Pregnant to Other Probability after having given birth
  def update_ppg_status_after_birth
    post_transition_ppg_status_update(4)
  end

  ##
  # Change the Participant status to PPG 3 after child loss
  def update_ppg_status_after_child_loss
    post_transition_ppg_status_update(3)
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
    low_intensity? && pregnant_or_trying? && in_tsu?
  end

  ##
  # Helper method to switch from lo intensity to hi intensity protocol and vice-versa
  # @return [true, false]
  def switch_arm(ensure_high_intensity = false)
    val = ensure_high_intensity ? true : !self.high_intensity
    self.high_intensity = val
    self.save!
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
  # [-5, "Other"],
  # [-4, "Missing in Error"]
  #
  # This method is reactive and cannot know the outcome of the event
  # so it simply will set the state to the most probable given the
  # event type and the current state
  # @param [NcsCode]
  def set_state_for_event_type(event_type)
    register! if can_register?  # assume known to PSC

    case event_type.local_code
    when 4, 5, 6, 29
      # Pregnancy Screener Events
      assign_to_pregnancy_probability_group! if can_assign_to_pregnancy_probability_group?
    when 10
      # Informed Consent
      low_intensity_consent! if can_low_intensity_consent?
    when 7, 8
      # Pregnancy Probability
      follow_low_intensity! if can_follow_low_intensity?
      follow! if can_follow?
    when 33
      # Lo I Quex
      follow_low_intensity if can_follow_low_intensity?
    when 11, 12
      # Pre-Pregnancy
      move_to_high_intensity_if_required
      non_pregnant_informed_consent! if can_non_pregnant_informed_consent?
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
    when 18
      # Birth
      if low_intensity?
        birth_event_low! if can_birth_event_low?
      else
        birth_event! if can_birth_event?
      end
    when 32
      enroll_in_high_intensity_arm! if can_enroll_in_high_intensity_arm?
    else
      fail "Unhandled event type for participant state #{event_type.local_code.inspect}"
    end
  end

  private

    def relationships(code)
      participant_person_links.select { |ppl| ppl.relationship.local_code == code }.collect { |ppl| ppl.person }
    end

    def next_low_intensity_study_segment
      if pending? || registered?
        PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
      elsif following_low_intensity?
        lo_intensity_follow_up
      elsif eligible_for_low_intensity_follow_up?
        lo_intensity_follow_up
      elsif pregnant?
        PatientStudyCalendar::LOW_INTENSITY_BIRTH_VISIT_INTERVIEW
      else
        nil
      end
    end

    def next_high_intensity_study_segment
      if registered?
        switch_arm if high_intensity? # Participant should not be in the high intensity arm if now just registering
        PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
      elsif in_high_intensity_arm?
        PatientStudyCalendar::LOW_INTENSITY_HI_LO_CONVERSION
      elsif following_high_intensity? || converted_high_intensity?
        PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
      elsif pre_pregnancy?
        PatientStudyCalendar::HIGH_INTENSITY_PRE_PREGNANCY
      elsif pregnancy_one?
        PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1
      elsif pregnancy_two?
        PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_2
      elsif ready_for_birth?
        PatientStudyCalendar::HIGH_INTENSITY_BIRTH_VISIT_INTERVIEW
      else
        nil
      end
    end

    def eligible_for_low_intensity_follow_up?
      low_intensity? && (in_pregnancy_probability_group? || consented_low_intensity?)
    end

    def lo_intensity_follow_up
      return nil if ineligible?
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

    def ineligible?
      ppg_status && ppg_status.local_code > 4
    end

    def pregnant_or_trying?
      pregnant? || trying?
    end

    def pregnant?
      ppg_status && ppg_status.local_code == 1
    end

    def trying?
      ppg_status && ppg_status.local_code == 2
    end

    def recent_loss?
      ppg_status && ppg_status.local_code == 3
    end

    def consented_to_high_intensity_arm?
      high_intensity && ["converted_high_intensity", "pre_pregnancy", "pregnancy_one", "pregnancy_two"].include?(state)
    end

    def newly_moved_to_high_intensity_arm?
      high_intensity && ["in_high_intensity_arm"].include?(state)
    end

    def next_scheduled_event_date
      (interval == 0) ? Date.today : (date_used_to_schedule_next_event.to_date + interval)
    end

    def date_used_to_schedule_next_event
      if due_date && in_pregnant_state?
        due_date
      elsif contact_links.blank?
        self.created_at.to_date
      else
        contact_links.first.created_at.to_date
      end
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
      if consented_low_intensity?
        # if consented to low intensity - assume that this was a consent to high since the
        # given event is in the high intensity arm
        enroll_in_high_intensity_arm! if can_enroll_in_high_intensity_arm?
        high_intensity_conversion! if can_high_intensity_conversion?
      end
    end
end
