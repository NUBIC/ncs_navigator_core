# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130415192041
#
# Table name: events
#
#  created_at                         :datetime
#  event_breakoff_code                :integer          not null
#  event_comment                      :text
#  event_disposition                  :integer
#  event_disposition_category_code    :integer          not null
#  event_end_date                     :date
#  event_end_time                     :string(255)
#  event_id                           :string(36)       not null
#  event_incentive_cash               :decimal(12, 2)
#  event_incentive_noncash            :string(255)
#  event_incentive_type_code          :integer          not null
#  event_repeat_key                   :integer
#  event_start_date                   :date
#  event_start_time                   :string(255)
#  event_type_code                    :integer          not null
#  event_type_other                   :string(255)
#  id                                 :integer          not null, primary key
#  imported_invalid                   :boolean          default(FALSE), not null
#  lock_version                       :integer          default(0)
#  participant_id                     :integer
#  psc_ideal_date                     :date
#  psu_code                           :integer          not null
#  scheduled_study_segment_identifier :string(255)
#  transaction_type                   :string(255)
#  updated_at                         :datetime
#


# An Event is a set of one or more scheduled or unscheduled, partially executed or completely executed
# data collection activities with a single subject. The subject may be a Household or a Participant.
# All activities in an Event have the same subject.
class Event < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  include NcsNavigator::Core::Mdes::InstrumentOwner
  acts_as_mdes_record :public_id_field => :event_id

  belongs_to :participant
  has_many :contact_links
  has_many :instruments, :through => :contact_links
  has_many :contacts, :through => :contact_links

  composed_of :disposition_code,
    :class_name => 'NcsNavigator::Mdes::DispositionCode',
    :mapping => [%w(event_disposition_category_code category_code), %w(event_disposition interim_code)],
    :constructor => lambda { |cc, ic| NcsNavigatorCore.mdes.disposition_for(cc, ic) }

  ncs_coded_attribute :psu,                        'PSU_CL1'
  ncs_coded_attribute :event_type,                 'EVENT_TYPE_CL1'
  ncs_coded_attribute :event_disposition_category, 'EVENT_DSPSTN_CAT_CL1'
  ncs_coded_attribute :event_breakoff,             'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :event_incentive_type,       'INCENTIVE_TYPE_CL1'

  validates_format_of :event_start_time, :with => mdes_time_pattern, :allow_blank => true
  validates_format_of :event_end_time,   :with => mdes_time_pattern, :allow_blank => true

  validate :disposition_code_is_in_disposition_category, :unless => :imported_invalid

  before_validation :strip_time_whitespace
  before_save :set_start_time
  before_save :set_psc_ideal_date

  ##
  # Scheduled activities for this event.  These are not persisted in Cases and
  # SHOULD be loaded from PSC.
  #
  # However, in some circumstances, it is convenient to associate a set of
  # scheduled activities with an Event.  This is an accessor to facilitate this
  # case; however, if your use case permits using {.with_psc_data} or
  # {#load_scheduled_activities}, you SHOULD use that.
  #
  # @see .with_psc_data
  # @see #load_scheduled_activities
  attr_accessor :scheduled_activities

  POSTNATAL_EVENTS = [
    18, # Birth
    23, # 3 Month
    24, # 6 Month
    25, # 6-Month Infant Feeding SAQ
    26, # 9 Month
    27, # 12 Month
    28, # 12 Month Mother Interview SAQ
    30, # 18 Month
    31, # 24 Month
    36, # 30 Month
    37, # 36 Month
    38, # 42 Month
  ]

  PRE_PARTICIPANT_EVENTS = [
     1, # Household Enumeration
     2, # Two Tier Enumeration
    22, # Provider-Based Recruitment
     3, # Ongoing Tracking of Dwelling Units
     4, # Pregnancy Screening - Provider Group
     5, # Pregnancy Screening – High Intensity  Group
     6, # Pregnancy Screening – Low Intensity Group
     9, # Pregnancy Screening - Household Enumeration Group
    29, # Pregnancy Screener
    34, # PBS Participant Eligibility Screening
    35, # PBS Frame SAQ
  ]

  PARTICIPANT_ONE_TIME_EVENTS = POSTNATAL_EVENTS + [
    13, # Pregnancy Visit  1
    14, # Pregnancy Visit #1 SAQ
    15, # Pregnancy Visit  2
    16, # Pregnancy Visit #2 SAQ
    17, # Pregnancy Visit - Low Intensity Group
  ]

  PARTICIPANT_REPEATABLE_EVENTS = [
    10, # Informed Consent
    33, # Low Intensity Data Collection
    32, # Low to High Conversion
     7, # Pregnancy Probability
     8, # PPG Follow-Up by Mailed SAQ
    11, # Pre-Pregnancy Visit
    12, # Pre-Pregnancy Visit SAQ
    19, # Father
    20, # Father Visit SAQ
    21, # Validation
  ]

  ##
  # Event type codes that can be sync'd to PSC.
  # psc_template_spec verifies that this list is in sync with the PSC template.
  EVENTS_FOR_PSC = [
    29, # Pregnancy Screener
    34, # PBS Participant Eligibility Screening
    10, # Informed Consent
    33, # Low Intensity Data Collection
     7, # Pregnancy Probability
    11, # Pre-Pregnancy Visit
    32, # Low to High Conversion
    13, # Pregnancy Visit  1
    15, # Pregnancy Visit  2
    18, # Birth
    19, # Father
    23, # 3 Month
    24, # 6 Month
    26, # 9 Month
    27, # 12 Month
    30, # 18 Month
    31, # 24 Month
    36, # 30 Month
  ]

  ##
  # A partial ordering of MDES event types. The ordering is such that,
  # if an event of type A and one of type B occur on the same day, A
  # precedes B IFF the event of type A would be executed before the
  # one of type B.
  TYPE_ORDER = [
     1, # Household Enumeration
     2, # Two Tier Enumeration
    22, # Provider-Based Recruitment
     3, # Ongoing Tracking of Dwelling Units
    34, # PBS Participant Eligibility Screening
    35, # PBS Frame SAQ
     4, # Pregnancy Screening - Provider Group
     5, # Pregnancy Screening – High Intensity  Group
     6, # Pregnancy Screening – Low Intensity Group
     9, # Pregnancy Screening - Household Enumeration Group
    29, # Pregnancy Screener
    10, # Informed Consent
    33, # Low Intensity Data Collection
    32, # Low to High Conversion
     7, # Pregnancy Probability
     8, # PPG Follow-Up by Mailed SAQ
    11, # Pre-Pregnancy Visit
    12, # Pre-Pregnancy Visit SAQ
    13, # Pregnancy Visit  1
    14, # Pregnancy Visit #1 SAQ
    15, # Pregnancy Visit  2
    16, # Pregnancy Visit #2 SAQ
    17, # Pregnancy Visit - Low Intensity Group
    18, # Birth
    19, # Father
    20, # Father Visit SAQ
    21, # Validation
    23, # 3 Month
    24, # 6 Month
    25, # 6-Month Infant Feeding SAQ
    26, # 9 Month
    27, # 12 Month
    28, # 12 Month Mother Interview SAQ
    30, # 18 Month
    31, # 24 Month
    36, # 30 Month
    37, # 36 Month
    38, # 42 Month
    -5, # Other
    -4  # Missing in Error
  ]

  NAMED_EVENT_CODES = {
    "household_enumeration" => 1,
    "two_tier_enumeration" => 2,
    "providerbased_recruitment" => 22,
    "provider_recruitment" => 22,
    "ongoing_tracking_of_dwelling_units" => 3,
    "pbs_eligibility_screener" => 34,
    "pbs_frame_saq" => 35,
    "pregnancy_screening_provider_group" => 4,
    "pregnancy_screening_high_intensity_group" => 5,
    "pregnancy_screening_low_intensity_group" => 6,
    "pregnancy_screening_household_enumeration_group" => 9,
    "pregnancy_screener" => 29,
    "informed_consent" => 10,
    "low_intensity_data_collection" => 33,
    "low_to_high_conversion" => 32,
    "pregnancy_probability" => 7,
    "ppg_followup_by_mailed_saq" => 8,
    "prepregnancy_visit" => 11,
    "prepregnancy_visit_saq" => 12,
    "pregnancy_visit_1" => 13,
    "pv1" => 13,
    "pregnancy_visit1" => 13,
    "pregnancy_visit_1_saq" => 14,
    "pv2saq" => 14,
    "pregnancy_visit_2" => 15,
    "pv2" => 15,
    "pregnancy_visit2" => 15,
    "pregnancy_visit_2_saq" => 16,
    "pv2saq" => 16,
    "pregnancy_visit_low_intensity_group" => 17,
    "birth" => 18,
    "father_visit" => 19,
    "father" => 19,
    "father_visit_saq" => 20,
    "father_saq" => 20,
    "validation_visit" => 21,
    "three_month_visit" => 23,
    "six_month_visit" => 24,
    "six_month_infant_feeding_saq_visit" => 25,
    "nine_month_visit" => 26,
    "twelve_month_visit" => 27,
    "twelve_month_mother_interview_saq_visit" => 28,
    "eighteen_month_visit" => 30,
    "twenty_four_month_visit" => 31,
    "thirty_month_visit" => 36,
    "thirty_six_month_visit" => 37,
    "forty_two_month_visit" => 38,
    "other" => -5,
    "missing_in_error" => -4
  }

  def self.method_missing(method_name, *args)
    m = method_name.to_s
    if m =~ /_code/
      return NAMED_EVENT_CODES[m.sub("_code", "")]
    end

    super
  end

  def method_missing(method_name, *args)
    m = method_name.to_s
    if m =~ /\?/
      super unless NAMED_EVENT_CODES[m.sub("\?", "")]
      return NAMED_EVENT_CODES[m.sub("\?", "")] == self.event_type_code
    end

    super
  end

  # An event that can take place during the same contact
  # as another event
  CONTINUABLE = [
    PatientStudyCalendar::PREGNANCY_SCREENER,
    PatientStudyCalendar::PBS_ELIGIBILITY_SCREENING,
    PatientStudyCalendar::BIRTH_VISIT_INTERVIEW,
    PatientStudyCalendar::HI_LO_CONVERSION,
    PatientStudyCalendar::INFORMED_CONSENT
  ]

  ##
  # Display text from the NcsCode list EVENT_TYPE_CL1
  # cf. event_type belongs_to association
  # @return [String]
  def to_s
    (event_type_code == -5 && !event_type_other.blank?) ? event_type.to_s << " - " << event_type_other : event_type.to_s
  end

  ##
  # The preferred ordering for events: by date and type order.
  def self.chronological
    by_event_start_date.by_type_order
  end

  def self.by_event_start_date
    order(:event_start_date)
  end

  ##
  # Loads PSC data for an ActiveRecord::Relation of events.
  #
  # This method forces evaluation of a relation, so you can only use it at the
  # end of a scope chain.
  #
  # This method does not implement any special error handling for PSC queries.
  #
  # @param [PatientStudyCalendar] psc a PatientStudyCalendar object
  # @return Array<Event>
  def self.with_psc_data(psc)
    result_set = includes(:participant => { :participant_person_links => :person }).to_a

    result_set.tap do |s|
      s.group_by(&:participant).each do |p, events|
        next unless p && p.person

        pscp = PscParticipant.new(psc, p)
        events.each { |e| e.load_scheduled_activities(pscp) }
      end
    end
  end

  def self.by_type_order
    joins(%q{
      LEFT OUTER JOIN event_type_order
      AS eto
      ON eto.event_type_code = events.event_type_code
    }).
    readonly(false).
    order('eto.id')
  end

  ##
  # The minimum activity date associated with this Event.  If this Event has no
  # scheduled activities or scheduled activities have not been loaded (see
  # {.with_psc_data}), returns nil.
  #
  # @return [String,nil]
  def scheduled_date
    return nil unless scheduled_activities

    scheduled_activities.map(&:activity_date).min
  end

  ##
  # Usernames of staff members associated with this Event.  If this Event has
  # no scheduled activities or scheduled activities have not been loaded,
  # returns [].
  def data_collectors
    return [] unless scheduled_activities

    scheduled_activities.map(&:responsible_user).uniq
  end

  ##
  # Format the event start date
  # @return [String]
  def event_start
    result = "#{event_start_date} #{event_start_time}"
    result = "N/A" if result.blank?
    result
  end

  ##
  # Format the event end date
  # @return [String]
  def event_end
    result = "#{event_end_date} #{event_end_time}"
    result = "N/A" if result.blank?
    result
  end

  # Tables 1,2 from FSM 2013-09
  EVENT_WINDOW = {
    :high =>{
      Event.birth_code                    => { :start => 0.days,    :end => 10.days},
      Event.three_month_visit_code        => { :start => 2.months,  :end => 5.months - 1.day},
      Event.six_month_visit_code          => { :start => 5.months,  :end => 8.months - 1.day},
      Event.nine_month_visit_code         => { :start => 8.months,  :end => 11.months - 1.day},
      Event.twelve_month_visit_code       => { :start => 11.months, :end => 16.months - 1.day},
      Event.eighteen_month_visit_code     => { :start => 16.months, :end => 23.months - 1.day},
      Event.twenty_four_month_visit_code  => { :start => 23.months, :end => 30.months - 1.day},
      Event.thirty_month_visit_code       => { :start => 30.months, :end => 36.months - 1.day},
      Event.thirty_six_month_visit_code   => { :start => 36.months, :end => 42.months - 1.day},
      Event.forty_two_month_visit_code    => { :start => 42.months, :end => 48.months - 1.day}},
    :low =>{
      Event.birth_code                    => { :start => 0.days,    :end => 2.months - 1.day},
      Event.three_month_visit_code        => { :start => 2.months,  :end => 7.months - 1.day},
      Event.nine_month_visit_code         => { :start => 7.months,  :end => 14.months - 1.day},
      Event.eighteen_month_visit_code     => { :start => 14.months, :end => 23.months - 1.day},
      Event.twenty_four_month_visit_code  => { :start => 23.months, :end => 30.months - 1.day},
      Event.thirty_month_visit_code       => { :start => 30.months, :end => 36.months - 1.day},
      Event.thirty_six_month_visit_code   => { :start => 36.months, :end => 42.months - 1.day},
      Event.forty_two_month_visit_code    => { :start => 42.months, :end => 48.months - 1.day}}
  }

  # @param at - :start || :end
  # @param birth_date [Date] - DOB of child participant
  # @param intensity [Date]  - :high or :low
  # @return nil or Date
  def window(at, birth_date = self.child_dob, intensity = self.try(:participant).try(:intensity))
    return nil if ![:start,:end].include?(at) || birth_date.nil? || ![:high,:low].include?(intensity)
    return nil if EVENT_WINDOW[intensity][self.event_type_code].nil?
    birth_date + EVENT_WINDOW[intensity][self.event_type_code][at]
  end


  # @return nil or Person
  def child_dob
    child_participant.try(:person).try(:person_dob_date)
  end

  # @todo this is a workaround since child events are being associated
  #        with the mother self.participant should be the child for
  #        child events. This method should be removed when the
  #        association is changed
  #
  #
  # @note when the participant is the mother and there are multiple
  #        children this will pick one
  #
  # The participant child this event relates to
  def child_participant
    case
    when participant.try(:child_participant?)
      participant
    when (c = participant.try(:children))
      c.find{|child| child.participant.try(:child_participant?)}.try(:participant)
    else
      nil
    end
  end

  def label
    event_type.to_s.downcase.squeeze(' ').gsub(' ', '_')
  end

  def strip_time_whitespace
    self.event_start_time.strip! if self.event_start_time
    self.event_end_time.strip! if self.event_end_time
  end
  private :strip_time_whitespace

  # Set event start time to now if blank and start date exists
  def set_start_time
    if self.event_start_time.blank? && !self.event_start_date.blank?
      self.event_start_time = Time.now
    end
  end
  private :set_start_time

  # Set event psc_ideal_date to the event start date if it is blank
  def set_psc_ideal_date
    self.psc_ideal_date = self.event_start_date if self.psc_ideal_date.blank?
  end
  private :set_psc_ideal_date

  def event_start_time=(t)
    self['event_start_time'] = format_event_time(t)
  end

  def event_end_time=(t)
    self['event_end_time'] = format_event_time(t)
  end

  def format_event_time(t)
    t.respond_to?(:strftime) ? t.strftime('%H:%M') : t
  end
  private :format_event_time

  ##
  # Returns the event_end_date if it exists and is a valid date
  # otherwise it returns the event_start_date
  def import_sort_date
    if event_end_date && event_end_date.to_s !~ /^9/
      event_end_date
    else
      event_start_date
    end
  end

  ##
  # An event is 'closed' if its end date is set.
  # @return [true, false]
  def closed?
    !open?
  end

  ##
  # An event is 'open' if its end date is NOT set.
  # @return [true, false]
  def open?
    event_end_date.blank?
  end

  ##
  # Sets the event_end_date and event_end_time
  # attributes and saves the record
  # @param [Time]
  def close!(now = Time.now)
    self.close(now)
    self.save!
  end

  ##
  # Sets the event_end_date and event_end_time
  # @param [Time]
  def close(now = Time.now)
    self.event_end_date = now.to_date
    self.event_end_time = now.strftime("%H:%M")
  end

  ##
  # Returns true if not closed and there is no association to a ContactLink
  # @return [Boolean]
  def can_delete?
    !closed? && contact_links.blank?
  end

  ##
  # True is there are any open contacts associated
  # with this event
  def open_contacts?
    self.contacts.select(&:open?).size > 0
  end

  ##
  # True if this event can occur before another event
  # during the same contact.
  def continuable?
    Event::CONTINUABLE.include?(self.to_s)
  end

  ##
  # Returns true for all pre-participant events
  # @return [Boolean]
  def enumeration_event?
    PRE_PARTICIPANT_EVENTS.include? event_type_code
  end

  ##
  # Returns true if event is Pregnancy Screener or
  # PBS Eligibility Screener
  # @return[Boolean]
  def screener_event?
    [Event.pregnancy_screener_code, Event.pbs_eligibility_screener_code].include? event_type_code
  end

  ##
  # Returns true if event is Informed Consent
  # @return[Boolean]
  def consent_event?
    self.event_type_code == Event.informed_consent_code
  end

  ##
  # True if this is a consent event and a standalone event
  # @see Event#consent_event?
  # @see Event#standalone_event?
  # @param[Contact]
  # @return[Boolean]
  def standalone_consent_event?(contact)
    consent_event? && stand_alone_event?(contact)
  end

  ##
  # A stand-alone Event is an event
  # that is not associated with another event during same contact
  # @param[Contact]
  # @return[Boolean]
  def stand_alone_event?(contact)
    ContactLink.select("distinct event_id").where("contact_id in (?)",
      ContactLink.select(:contact_id).where(:event_id => self.id).all.map(&:contact_id)
    ).count == 1
  end

  ##
  # Returns true for all post-natal events (includes Birth)
  # @return [Boolean]
  def postnatal?
    POSTNATAL_EVENTS.include? event_type_code
  end

  ##
  # Date and time of when the event was started
  # @return [Array<Date,String>]
  def started_at
    [event_start_date, event_start_time]
  end

  ##
  # @return [Array<Fixnum>] the event type codes for events which are not related
  #   to a specific participant
  def self.non_participant_event_type_codes
    PRE_PARTICIPANT_EVENTS
  end

  ##
  # @return [Array<Fixnum>] the event type codes for events which are expected
  #   to be executed at most once per participant.
  def self.participant_one_time_only_event_type_codes
    PARTICIPANT_ONE_TIME_EVENTS
  end

  ##
  # @return [Array<Fixnum>] the event type codes for events which may be
  #   executed more than once per participant.
  def self.participant_repeatable_event_type_codes
    PARTICIPANT_REPEATABLE_EVENTS
  end

  ##
  # Returns the (zero-based) number of times the event
  # participant has performed this event.
  # Return 0 if there is no participant associated with this event.
  # @return [Integer]
  def determine_repeat_key
    return 0 if self.participant.nil?
    self.participant.events.where(:event_type_code => self.event_type_code).count - 1
  end

  ##
  # Returns true for provider recruitment event
  # @return [Boolean]
  def provider_event?
    self.event_type_code == Provider::PROVIDER_RECRUIMENT_EVENT_TYPE_CODE
  end
  alias :provider_recruitment_event? :provider_event?

  ##
  # Helper method to set the disposition to Out of Window
  def mark_out_of_window
    update_disposition 48
  end

  def out_of_window?
    event_disposition == 48
  end

  ##
  # Helper method to set the disposition to Not Worked
  def mark_not_worked
    update_disposition 34
  end

  def not_worked?
    event_disposition == 34
  end

  # TODO: determine better way to get disposition out of NcsNavigatorCore.mdes.disposition_codes
  def update_disposition(code)
    self.event_disposition = code
    self.event_disposition_category = NcsCode.for_list_name_and_local_code("EVENT_DSPSTN_CAT_CL1", "3")
  end

  ##
  # Marks the activity associated with this event as canceled in PSC
  # @param[PatientStudyCalendar]
  # @param[String] - reason for cancellation (optional)
  def cancel_activities(psc, reason = nil)
    psc.activities_for_event(self).each do |a|
      if self.matches_activity(a)
        psc.update_activity_state(a.activity_id, participant,
                          Psc::ScheduledActivity::CANCELED,
                          a.date, reason)
      end
    end
  end

  ##
  # Cancels the activity in PSC and then either closes (and updates disposition) or deletes the event
  def cancel_and_close_or_delete!(psc, reason = nil)
    self.cancel_activities(psc, reason)
    if self.can_delete?
      self.destroy
    else
      self.mark_not_worked
      self.close
    end
    self.save!
  end

  ##
  # Returns true if this event was succesfully completed, false otherwise.
  def completed?
    disposition_code.try(:success?)
  end

  ##
  # Given an instrument and contact, presumably after the instrument has been administered, set attributes on the
  # event that can be inferred based on the instrument and type of contact
  # @param [Instrument]
  # @param [Contact]
  def populate_post_survey_attributes(contact = nil, response_set = nil)
    set_event_disposition_category(contact)
    set_event_breakoff(response_set)
  end

  ##
  # Given a {PscParticipant}, loads the participant's scheduled activities that
  # match this event.  The {PscParticipant} MUST reference the same participant
  # as this event; if it does not, an error will be raised.
  #
  # This method will load the {#participant} association.  If you're planning
  # on calling this method across multiple Events, you SHOULD eager-load
  # participants.
  #
  # When this method returns, the scheduled activities for this event will be
  # available in the {#scheduled_activities} reader.
  #
  # @return void
  def load_scheduled_activities(psc_participant)
    if psc_participant.participant.id != participant.id
      raise "Participant mismatch (psc_participant: #{psc_participant.participant.id}, self: #{participant.id})"
    end

    return @scheduled_activities if @scheduled_activities

    all_activities = psc_participant.scheduled_activities

    @scheduled_activities = all_activities.select { |_, sa| implied_by?(sa) }.values.freeze
  end

  def reload
    if instance_variable_defined?(:@scheduled_activities)
      remove_instance_variable(:@scheduled_activities)
    end

    super
  end

  ##
  # The desired state for the scheduled activities backing this Event.  This
  # SHOULD be one of the values defined on Psc::ScheduledActivity.
  #
  # Here's how events and their backing activities match up:
  #
  # | Event state | Disposition   | Desired activity state |
  # | Closed      | Unsuccessful  | Canceled               |
  # | Closed      | Successful    | Occurred               |
  # | Open        | (any)         | Scheduled              |
  #
  # Note: this method's behavior is independent of whether or not the Event is
  # actually backed by anything in PSC.  This method is intended to be used by
  # code that establishes those associations, i.e. {Field::PscSync}.
  def desired_sa_state
    sa = Psc::ScheduledActivity

    if closed?
      if disposition_code.try(:success?)
        sa::OCCURRED
      else
        sa::CANCELED
      end
    else
      sa::SCHEDULED
    end
  end

  ##
  # The end date for this event's scheduled activities.  Returns a string in
  # YYYY-MM-DD format or nil if no end date is set.
  #
  # @return [String, nil]
  def sa_end_date
    event_end_date.try(:strftime, '%Y-%m-%d')
  end

  ##
  # When the scheduled activity states for this event are synced, the string
  # from this method is supplied as the reason.
  def sa_state_change_reason
    'Synchronized from Cases'
  end

  ##
  # Checks that the event label and ideal date from PSC
  # matches the event_type and psc_ideal_date
  # @param[ScheduledActivity]
  # @return[boolean]
  def matches_activity(scheduled_activity)
    label = Event.parse_label(scheduled_activity.labels)
    implied_by?(label, scheduled_activity.ideal_date)
  end

  def implied_by?(*args)
    if args.length == 1
      activity = args.first
      self.label == activity.event_label.try(:content) && psc_ideal_date.to_s == activity.ideal_date
    elsif args.length == 2
      self.label == args.first && psc_ideal_date.to_s == args.second
    else
      raise ArgumentError, "wrong number of arguments (#{args.length} for 1 or 2)"
    end
  end

  def set_event_disposition_category(contact)
    if self.participant.try(:low_intensity?)
      # Telephone Disposition Category Local Code = 5
      self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 5)
    end

    case event_type.to_s
    when /PBS Participant Eligibility Screening/
      # Pregnancy Screener Disposition Category Local Code = 8
      self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 8)
    when /Pregnancy Screen/
      # Pregnancy Screener Disposition Category Local Code = 2
      self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 2)
    when /Household/
      # Household Event Disposition Category Local Code = 1
      self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 1)
    end

    if self.event_disposition_category.to_i <= 0
      case contact.contact_type.to_i
      when 1 # in person contact
        # General Study Visit Category Local Code = 3
        self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 3)
      when 2 # mail contact
        # Mail Disposition Category Local Code = 4
        self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 4)
      when 3, 5 # text or telephone contact
        # Telephone Disposition Category Local Code = 5
        self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 5)
      when 6 # website
        # Website Disposition Category Local Code = 6
        self.event_disposition_category = NcsCode.for_attribute_name_and_local_code(:event_disposition_category_code, 6)
      end
    end
  end

  def set_event_breakoff(resp_sets)
     return nil if resp_sets.nil?
     target = ResponseSet.where(:id => resp_sets.map(&:id))

     responded = SurveySection.scoped.joins('INNER JOIN response_sets ON response_sets.survey_id = survey_sections.survey_id
                                                   INNER JOIN responses ON responses.response_set_id = response_sets.id
                                                   INNER JOIN questions ON responses.question_id = questions.id
                                                   AND questions.survey_section_id = survey_sections.id')
                              .select("survey_sections.id, survey_sections.display_order")
                              .merge(target).uniq

     referenced = SurveySection.scoped.joins(:questions, :survey => :response_sets)
                              .select("survey_sections.id, survey_sections.display_order")
                              .merge(target).where("questions.display_type IS NULL OR questions.display_type != 'label'").uniq

    self.event_breakoff_code = (referenced - responded).empty? ? NcsCode::NO : NcsCode::YES
  end

  ##
  # Defer to the DispositionMapper for the disposition text for the given event_disposition.
  # If that returns blank, simply return the Integer value
  # @see DispositionMapper#disposition_text_for_event
  # @return[String]
  def event_disposition_text
    disp = DispositionMapper.disposition_text_for_event(self)
    disp.blank? ? event_disposition : disp
  end

  ##
  # Get the next scheduled event and date from the Participant, and schedule that Segment
  # in PSC. If successful, create a corresponding, pending Event record
  #
  # @see Participant#next_scheduled_event
  # @see PatientStudyCalendar#schedule_next_segment
  # @see Event#create_event_placeholder_and_cancel_activities
  #
  # @param[PatientStudyCalendar]
  # @param[Participant]
  # @param[Date] (optional)
  # @return[Response]
  def self.schedule_and_create_placeholder(psc, participant, date = nil)
    return nil unless participant.next_scheduled_event

    date ||= participant.next_scheduled_event.date.to_s

    resp = psc.schedule_next_segment(participant, date)
    create_event_placeholder_and_cancel_activities(psc, participant, date, resp)
    resp
  end

  ##
  # Schedule the Informed Consent General Consent Segment
  # in PSC. If successful, create a corresponding, pending Event record
  #
  # @see PatientStudyCalendar#schedule_general_informed_consent
  # @see Event#create_event_placeholder_and_cancel_activities
  #
  # @param[PatientStudyCalendar]
  # @param[Participant]
  # @param[Date] (optional)
  # @return[Response]
  def self.schedule_general_informed_consent(psc, participant, date = nil)
    resp = psc.schedule_general_informed_consent(participant, date)
    create_event_placeholder_and_cancel_activities(psc, participant, date, resp)
    resp
  end

  ##
  # Schedule the Reconsent Segment in PSC.
  # If successful, create a corresponding, pending Event record
  #
  # @see PatientStudyCalendar#schedule_reconsent
  # @see Event#create_event_placeholder_and_cancel_activities
  #
  # @param[PatientStudyCalendar]
  # @param[Participant]
  # @param[Date] (optional)
  # @return[Response]
  def self.schedule_reconsent(psc, participant, date = nil)
    resp = psc.schedule_reconsent(participant, date)
    create_event_placeholder_and_cancel_activities(psc, participant, date, resp)
    resp
  end

  ##
  # Schedule the Withdrawal Segment in PSC.
  # If successful, create a corresponding, pending Event record
  #
  # @see PatientStudyCalendar#schedule_withdrawal
  # @see Event#create_event_placeholder_and_cancel_activities
  #
  # @param[PatientStudyCalendar]
  # @param[Participant]
  # @param[Date] (optional)
  # @return[Response]
  def self.schedule_withdrawal(psc, participant, date = nil)
    resp = psc.schedule_withdrawal(participant, date)
    create_event_placeholder_and_cancel_activities(psc, participant, date, resp)
    resp
  end

  ##
  # Schedule the Parental Permission for Child Participation
  # Birth to 6 Months Segment in PSC.
  # If successful, create a corresponding, pending Event record
  #
  # @see PatientStudyCalendar#schedule_child_consent_birth_to_six_months
  # @see Event#create_event_placeholder_and_cancel_activities
  #
  # @param[PatientStudyCalendar]
  # @param[Participant]
  # @param[Date] (optional)
  # @return[Response]
  def self.schedule_child_consent_birth_to_six_months(psc, participant, date = nil)
    resp = psc.schedule_child_consent_birth_to_six_months(participant, date)
    create_event_placeholder_and_cancel_activities(psc, participant, date, resp)
    resp
  end

  ##
  # Schedule the Parental Permission for Child Participation
  # 6 Months to Age of Majority Segment in PSC.
  # If successful, create a corresponding, pending Event record
  #
  # @see PatientStudyCalendar#schedule_child_consent_six_months_to_age_of_majority
  # @see Event#create_event_placeholder_and_cancel_activities
  #
  # @param[PatientStudyCalendar]
  # @param[Participant]
  # @param[Date] (optional)
  # @return[Response]
  def self.schedule_child_consent_six_month_to_age_of_majority(psc, participant, date = nil)
    resp = psc.schedule_child_consent_six_months_to_age_of_majority(participant, date)
    create_event_placeholder_and_cancel_activities(psc, participant, date, resp)
    resp
  end

  ##
  # Schedule the Expanded Low Intensity Postnatal Segment in PSC.
  # If successful, create a corresponding, pending Event record
  #
  # @see PatientStudyCalendar#schedule_low_intensity_postnatal
  # @see Event#create_event_placeholder_and_cancel_activities
  #
  # @param psc [PatientStudyCalendar]
  # @param participant [Participant]
  # @param child_birth_date [Date]
  # @param data_collection_start_date [Date]
  # @return[Response]
  def self.schedule_low_intensity_postnatal(psc, participant, child_birth_date, data_collection_start_date)
    resp = psc.schedule_low_intensity_postnatal(participant, child_birth_date)
    create_event_placeholder_and_cancel_activities(psc, participant, child_birth_date, resp, data_collection_start_date)
    resp
  end

  ##
  # After successfully scheduling the next segment for the Participant
  # in PSC, create a corresponding Event using the scheduled ideal date as
  # the Event#start_date and the Ncs EVENT_TYPE_CL1 code matching the PSC activity
  # "event:" label as the event type.
  #
  # @see NcsCode#find_event_by_lbl
  # @see PatientStudyCalendar#schedule_next_segment
  # @param[PatientStudyCalendar]
  # @param[Participant]
  # @param[Date]
  # @param[Response]
  # @param data_collection_start_date [Date]
  def self.create_event_placeholder_and_cancel_activities(psc, participant, date, resp, data_collection_start_date = nil)
    should_cancel_consent = true
    if resp && resp.success?
      study_segment_identifier = PatientStudyCalendar.extract_scheduled_study_segment_identifier(resp.body)
      psc.unique_label_ideal_date_pairs_for_scheduled_segment(participant, study_segment_identifier).each do |lbl, dt|
        next if lbl.blank?
        code = NcsCode.find_event_by_lbl(lbl)
        if code
          create_placeholder_records_for_participant(psc, participant, dt, code.local_code, study_segment_identifier)
          # do not cancel consent activities if this is a standalone consent event
          should_cancel_consent = false if code.local_code == Event.informed_consent_code
        else
          Rails.logger.warn("Cannot find event for MDES version '#{NcsNavigatorCore.mdes.version}' for psc activity label '#{lbl}'")
        end
      end

      # cancel all specimen/sample collection actiivites unless configured to do so
      unless NcsNavigatorCore.expanded_phase_two?
        psc.cancel_collection_instruments(participant, study_segment_identifier, date,
          "Not configured to run expanded phase 2 instruments.")
      end

      # cancel all activities without a matching MDES version instrument
      unless NcsNavigatorCore.mdes.version.blank?
        psc.cancel_non_matching_mdes_version_instruments(participant, study_segment_identifier, date,
          "Does not include an instrument for MDES version #{NcsNavigatorCore.mdes.version}.")
      end

      # do not cancel consent activities if informed consent - 10
      if participant.consented? && should_cancel_consent
        psc.cancel_consent_activities(participant, study_segment_identifier, date,
          "Participant has already consented.")
      end

      # cancel activities prior to data_collection_start_date
      if data_collection_start_date
        psc.cancel_activities_prior_to_date(participant, study_segment_identifier, date,
          "Canceling activities prior to data collection start date #{data_collection_start_date}", data_collection_start_date)
        participant.pending_events.where("event_start_date < ?", data_collection_start_date).all.each do |e|
          e.mark_out_of_window
          e.event_end_date = data_collection_start_date
          e.save!
        end
      end
    end
  end

  ##
  # Check that the event does not already exist (or if it does that the Event is repeatable)
  # before creating the placeholder record.  If the event already does exist and is postnatal, cancel
  # the activity in PSC.
  # @param [PatientStudyCalendar]
  # @param [Participant]
  # @param [String] date
  # @param [Integer] event_type_code
  # @param [String] study_segment_identifier
  def self.create_placeholder_records_for_participant(psc, participant, date, event_type_code, study_segment_identifier)
    duplicate_event_codes = []
    existing_event = participant.events.where(:event_type_code => event_type_code).first
    if existing_event && !PARTICIPANT_REPEATABLE_EVENTS.include?(event_type_code)
      # do not create Event for existing non-repeatable events
      duplicate_event_codes << event_type_code
    else
      Event.create_placeholder_record(participant, date, event_type_code, study_segment_identifier)
    end
    Event.cancel_activities_for_duplicate_events(psc, duplicate_event_codes, participant, date) unless duplicate_event_codes.empty?
  end

  ##
  # For those event codes that have been determined to exist and should not be duplicated,
  # cancel those activities in PSC.
  def self.cancel_activities_for_duplicate_events(psc, duplicate_event_codes, participant, date)
    duplicate_event_codes.each do |code|
      e = Event.new(:participant => participant, :psc_ideal_date => date, :event_type_code => code)
      psc.activities_for_event(e).each do |a|
        if e.matches_activity(a)
          psc.update_activity_state(a.activity_id, participant,
                            Psc::ScheduledActivity::CANCELED,
                            a.date, "Event already exists for participant [#{participant.p_id}]")
        end
      end
    end
  end

  ##
  # Create an Event record for the participant with the given event_type_code.
  # @param [Participant]
  # @param [String] date
  # @param [Integer] event_type_code
  # @param [String] study_segment_identifier
  def self.create_placeholder_record(participant, date, event_type_code, study_segment_identifier)
    begin
      date = Date.parse(date)
    rescue
      # NOOP - do not set unparsable date
    end
    Event.create(:participant => participant,
                 :psu_code => participant.psu_code,
                 :event_type_code => event_type_code,
                 :event_start_date => date,
                 :psc_ideal_date => date,
                 :scheduled_study_segment_identifier => study_segment_identifier)
  end

  ##
  # Given a label from PSC get the part that references the event
  # @param[String]
  # @return[String]
  def self.parse_label(lbl)
    return nil if lbl.blank?
    label_marker = "event:"
    part = lbl.split.select{ |s| s.include?(label_marker) }.first.to_s
    return nil if part.blank?
    part.gsub(label_marker, "")
  end


  ##
  # If this event has an associated Informed Consent Event
  # during the same contact then update that Event's attributes
  # with this one
  def update_associated_informed_consent_event
    if ic = associated_informed_consent_event
      [ :event_disposition_category_code,
        :event_disposition,
        :event_start_date,
        :event_start_time,
        :event_end_date,
        :event_end_time,
        :psc_ideal_date
      ].each do |a|
        ic.send("#{a}=", self.send(a)) if ic.send(a).blank? || ic.send(a) == -4
      end
      ic.save!
    end
  end

  def set_suggested_event_disposition(contact_link)
    event_disposition = contact_link.contact.contact_disposition if event_disposition.blank? || event_disposition < 0
  end

  def set_suggested_event_disposition_category(contact_link)
    if (event_disposition_category.blank? || event_disposition_category_code < 0) && contact_link.try(:contact)
      set_event_disposition_category(contact_link.contact)
    end
  end

  def set_suggested_event_repeat_key
    if self.participant.nil?
      0
    else
      self.participant.events.where(:event_type_code => self.event_type_code).count - 1
    end
  end

  ##
  #
  def set_suggested_event_breakoff(contact_link)
    return if closed? || event_breakoff_code.to_i > 0
    if contact_link.instrument && contact_link.instrument.response_sets.exists?
      set_event_breakoff(contact_link.instrument.response_sets)
    end
  end

  ##
  # Finds the first Informed Consent (10) event that was created
  # during the same contact as this event.
  # @return[Event]
  def associated_informed_consent_event
    Event.joins(:contact_links).
          where(:participant_id => participant_id,
                :event_type_code => Event.informed_consent_code).
          where("contact_links.contact_id in (?)", contacts.map(&:id)).
          readonly(false).first
  end
  private :associated_informed_consent_event

  ##
  # If the event_disposition and event_disposition_category_code attributes
  # are set we validate that event_disposition value exists for that category
  # using the disposition_code composition.
  def disposition_code_is_in_disposition_category
    if self.event_disposition && (self.event_disposition_category_code.to_i > 0) && !self.disposition_code
      errors.add(:event_disposition, "does not exist in the disposition category.")
    end
  end

  comma do

    participant :last_name => 'Last Name', :first_name => 'First Name'
    event_type
    event_type_other
    event_repeat_key
    event_disposition_text 'Event Disposition'
    event_disposition_category
    event_start_date
    event_start_time
    event_end_date
    event_end_time
    event_breakoff
    event_incentive_type
    event_incentive_cash
    event_incentive_noncash
    event_comment

  end

  ##
  # Returns the consents which were signed within the date range for this event.
  #
  # @param [Array<ParticipantConsent>] the consents to check. This parameter is
  #   to enable caching of the consents list when matching across a series of
  #   events; if it is omitted, the event's associated participant's consents
  #   will be used.
  #
  # @return [Array<ParticipantConsent>]
  def match_consents_by_date(consents=self.participant.participant_consents)
    start = event_start_date || Date.new(0, 1, 1) # Date::Infinity.new(-1) does not work
    stop = event_end_date || Date::Infinity.new
    bounds = (start..stop)

    consents.select { |c| bounds.cover?(c.consent_date) }
  end

end
