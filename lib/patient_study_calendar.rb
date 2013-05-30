# -*- coding: utf-8 -*-

require 'forwardable'
require 'logger'
require 'ncs_navigator/core/psc/logger'
require 'ncs_navigator/core/psc/retry'
require 'psc_error'
require 'psc_participant'

class PatientStudyCalendar
  extend Forwardable

  # Epochs
  LOW_INTENSITY   = "LO-Intensity"
  HIGH_INTENSITY  = "HI-Intensity"
  CHILD_EPOCH     = "Child"
  PBS_ELIGIBILITY = "PBS-Eligibility"
  INFORMED_CONSENT_EPOCH = "Informed Consent"

  # PBS Segment
  PBS_ELIGIBILITY_SCREENING = "PBS Participant Eligibility Screening"

  # Lo Segments
  PREGNANCY_SCREENER    = "Pregnancy Screener"
  PPG_1_AND_2           = "PPG 1 and 2"
  HI_LO_CONVERSION      = "Low to High Conversion"
  POSTNATAL             = "Postnatal"
  LOW_INTENSITY_CHILD   = "Lo Intensity Child"

  # Hi and Lo Segments (incl. EH, PB, PBS)
  PPG_FOLLOW_UP         = "PPG Follow-Up" # Not for PBS
  BIRTH_VISIT_INTERVIEW = "Birth Visit Interview"

  # Hi Segments (incl. EH, PB, PBS)
  PRE_PREGNANCY         = "Pre-Pregnancy Visit"
  PREGNANCY_VISIT_1     = "Pregnancy Visit 1"
  PREGNANCY_VISIT_2     = "Pregnancy Visit 2"
  CHILD                 = "Child"
  BIRTH_COHORT          = "Birth Cohort"

  # Low Intensity Epoch and Segments
  LOW_INTENSITY_PREGNANCY_SCREENER    = "#{LOW_INTENSITY}: #{PREGNANCY_SCREENER}"
  LOW_INTENSITY_PPG_1_AND_2           = "#{LOW_INTENSITY}: #{PPG_1_AND_2}"
  LOW_INTENSITY_PPG_FOLLOW_UP         = "#{LOW_INTENSITY}: #{PPG_FOLLOW_UP}"
  LOW_INTENSITY_BIRTH_VISIT_INTERVIEW = "#{LOW_INTENSITY}: #{BIRTH_VISIT_INTERVIEW}"
  LOW_INTENSITY_POSTNATAL             = "#{LOW_INTENSITY}: #{POSTNATAL}"

  # High Intensity Epoch and Segments
  HIGH_INTENSITY_HI_LO_CONVERSION       = "#{HIGH_INTENSITY}: #{HI_LO_CONVERSION}"
  HIGH_INTENSITY_PPG_FOLLOW_UP          = "#{HIGH_INTENSITY}: #{PPG_FOLLOW_UP}"
  HIGH_INTENSITY_PRE_PREGNANCY          = "#{HIGH_INTENSITY}: #{PRE_PREGNANCY}"
  HIGH_INTENSITY_PREGNANCY_VISIT_1      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_1}"
  HIGH_INTENSITY_PREGNANCY_VISIT_2      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_2}"

  # PBS Eligibility Epoch and Segment
  PBS_ELIGIBILITY_SCREENER = "#{PBS_ELIGIBILITY}: #{PBS_ELIGIBILITY}"

  # Birth Cohort Segment
  BIRTH_COHORT_SCREENING = "#{PBS_ELIGIBILITY}: #{BIRTH_COHORT}"

  # Birth and Post-Natal Epoch and Segment
  CHILD_CHILD               = "#{CHILD_EPOCH}: #{CHILD}"
  CHILD_LOW_INTENSITY_CHILD = "#{CHILD_EPOCH}: #{LOW_INTENSITY_CHILD}"

  # Informed Consent Segments
  INFORMED_CONSENT = "Informed Consent"
  CHILD_CONSENT_BIRTH = "Parental Permission for Child Participation Birth to 6 months"
  CHILD_CONSENT_SIX_MONTHS = "Parental Permission for Child Participation 6 months to Age of Majority"
  WITHDRAWAL = "Withdrawal"
  RECONSENT = "Reconsent"

  # Informed Consent Epoch and Segments
  INFORMED_CONSENT_GENERAL_CONSENT = "#{INFORMED_CONSENT_EPOCH}: #{INFORMED_CONSENT}"
  INFORMED_CONSENT_CHILD_CONSENT_BIRTH = "#{INFORMED_CONSENT_EPOCH}: #{CHILD_CONSENT_BIRTH}"
  INFORMED_CONSENT_CHILD_CONSENT_SIX_MONTHS = "#{INFORMED_CONSENT_EPOCH}: #{CHILD_CONSENT_SIX_MONTHS}"
  INFORMED_CONSENT_WITHDRAWAL= "#{INFORMED_CONSENT_EPOCH}: #{WITHDRAWAL}"
  INFORMED_CONSENT_RECONSENT = "#{INFORMED_CONSENT_EPOCH}: #{RECONSENT}"

  # CAS
  CAS_SECURITY_SUFFIX = "/auth/cas_security_check"

  attr_reader :psc_client

  attr_accessor :logger
  attr_accessor :user
  attr_accessor :registered_participants

  def_delegators self, :uri, :psc_config, :strip_epoch

  ##
  # User object who was authenticated using CAS
  # @param [Aker::User]
  def initialize(user, logger = NcsNavigatorCore.psc_logger)
    self.user = user || fake_user
    self.registered_participants = RegisteredParticipantList.new(self)
    self.logger = logger

    build_client
  end

  ##
  # The user who will act as subject coordinator; defaults to user.username.
  # Can be changed if participants are being registered on behalf of another
  # user (i.e. in the Field -> Cases merge process).
  #
  # @see #build_subject_assignment_request
  # @see Psc::Participant#register!
  def responsible_user
    @responsible_user || user.username
  end

  def responsible_user=(username)
    @responsible_user = username
  end

  def fake_user
    if ENV['PSC_USERNAME_PASSWORD']
      Struct.new(:username).new(ENV['PSC_USERNAME_PASSWORD'].split(',').first)
    end
  end
  private :fake_user

  def get_connection
    psc_client.connection
  end
  alias :connection :get_connection

  def log
    ActiveSupport::Deprecation.warn("#{self.class.name}#log is deprecated.  Use #{self.class.name}#logger instead.", caller(1))
    logger
  end

  # TODO: put into configuration
  def study_identifier
    "NCS Hi-Lo"
  end

  def site_identifier
    NcsNavigatorCore.psu
  end

  # TODO: put in configuration
  def activity_source_name
    "NCS"
  end

  def build_client
    @psc_client = Psc::Client.new(uri, :authenticator => create_authenticator) do |builder|
      builder.use NcsNavigator::Core::Psc::Retry
      builder.use NcsNavigator::Core::Psc::Logger, logger
    end
  end

  def create_authenticator
    if ENV['PSC_USERNAME_PASSWORD']
      { :basic => ENV['PSC_USERNAME_PASSWORD'].split(',') }
    else
      { :token => lambda { user.cas_proxy_ticket(File.join(uri.to_s, CAS_SECURITY_SUFFIX)) } }
    end
  end

  ##
  # @return [PscParticipant] a PscParticipant for the given
  #   participant record. Repeated invocations will return the same
  #   instance for the same participant.
  def psc_participant(participant)
    psc_participants[participant.p_id] ||= PscParticipant.new(self, participant)
  end

  def psc_participants
    @psc_participants ||= {}
  end
  private :psc_participants

  ##
  # @return [String] the value that should be used as PSC's assignment
  #   ID for this participant on the NCS primary protocol.
  def psc_assignment_id(participant)
    case participant
    when String
      participant
    else
      participant.person.public_id
    end
  end

  ##
  # Loads and caches the current template snapshot.
  #
  # @return [Nokogiri::XML::Document]
  def template_snapshot
    return @template_snapshot unless @template_snapshot.nil?

    response = connection.get("studies/#{URI.escape study_identifier}/template/current.xml")
    if response.success?
      @template_snapshot = response.body
    else
      raise ResponseError.new(response.status, response.body)
    end
  end

  ##
  # Gets the current template from PSC and returns the nodes matching 'psc:study-segment'.
  # @return [NodeList]
  def segments
    template_snapshot.xpath('//psc:study-segment', Psc.xml_namespace)
  end

  ##
  # Given a list of labels of the form EPOCH: SEGMENT, returns a label =>
  # segment uuid mapping.  Labels that cannot be resolved will not appear in
  # the mapping.
  #
  # If there are two study segments in a given epoch that have the same name,
  # the UUID of the first encountered segment will be chosen.
  def segment_uuids(segment_labels)
    segs = segments

    segment_labels.each_with_object({}) do |label, hash|
      epoch_name, segment_name = label.split(':', 2).map(&:strip)

      # This could be done in one XPath query if we had intersect.  However:
      #
      # 1. intersect is an XPath 2.0 operator,
      # 2. Nokogiri uses libxml2's XPath implementation,
      # 3. libxml2 will never support XPath 2.0.
      #
      # @see https://mail.gnome.org/archives/xml/2007-February/msg00077.html
      epoch_query = %Q{ancestor::psc:epoch[@name="#{epoch_name}"]}
      segment_query = %Q{psc:study-segment[@name="#{segment_name}"]}

      segment = segs.xpath(epoch_query, Psc.xml_namespace).
        xpath(segment_query, Psc.xml_namespace).first

      if !segment
        log.warn(%Q{Cannot resolve ID for segment label "#{label}"})
        next
      end

      hash[label] = segment['id']
    end
  end

  ##
  # True if the participant is known to psc by the participant public_id.
  # @return [Boolean]
  def is_registered?(participant)
    registered_participants.is_registered?(psc_assignment_id(participant))
  end

  ##
  # True if the participant identifier is known to self.
  # @return [Boolean]
  def registered_participant?(participant)
    registered_participants.is_registered?(psc_assignment_id(participant), false)
  end

  def assign_subject(participant, event_type = nil, date = nil)
    # move state so that the participant can tell PSC what is the next study segment to schedule
    participant.register! if participant.can_register?
    if is_registered?(participant) || participant.next_study_segment.blank?
      return nil
    else
      data = build_subject_assignment_request(participant, event_type, date)
      response = post("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments",
                      data)
      registered_participants.cache_registration_status(
        psc_assignment_id(participant), valid_response?(response))
      response
    end
  end

  def schedules(participant, format = "json")
    get("subjects/#{psc_assignment_id(participant)}/schedules.#{format}")
  end

  def activities_for_segment(participant, segment)
    activities = []
    participant_activities(schedules(participant)).each do |activity|
      if activity["study_segment"].include?(segment.to_s)
        activities << activity["activity"]["name"]
      end
    end
    activities.uniq
  end

  ##
  # Gets information about all open activities
  # (scheduled or conditional) for a participant.
  #
  # @see #build_scheduled_activities
  # @see #participant_activities
  # @see #schedules
  #
  # @param [Participant,String]
  # @return [Array<ScheduledActivity>]
  def scheduled_activities(participant)
    build_scheduled_activities(
      participant_activities(schedules(participant)),
      Psc::ScheduledActivity::OPEN_STATES
    )
  end

  ##
  # Given a response from PSC for a participant's schedule
  # this method creates an Array of ScheduledActivity objects.
  #
  # @param [Array<Hash>]
  # @param [Array<String>]
  # @return [Array<ScheduledActivity>]
  def build_scheduled_activities(activities, states = nil)
    scheduled_activities = []
    activities.each do |activity|
      if states.nil? or states.include?(activity['current_state']['name'])
        sa = ScheduledActivity.new({
          :study_segment => activity['study_segment'].to_s,
          :activity_id => activity['id'],
          :current_state => activity['current_state']['name'],
          :ideal_date => activity['ideal_date'],
          :date => activity['current_state']['date'],
          :activity_name => activity['activity']['name'].to_s.strip,
          :activity_type => activity['activity']['type'],
          :labels => activity['labels'] })
        if activity['current_state'].has_key?("time")
          sa.activity_time = activity['current_state']['time']
        end
        scheduled_activities << sa
      end
    end
    scheduled_activities
  end
  private :build_scheduled_activities

  ##
  # Gets information about all activities for a participant
  # (cf. ScheduledActivity ) that relate to the participant's currently
  # pending events.
  # @param [Participant,String]
  # @return [Array<ScheduledActivity>]
  def activities_for_pending_events(participant)
    result = []
    scheduled_activities(participant).each do |a|
      participant.pending_events.each do |e|
        result << a if e.matches_activity(a)
      end
    end
    result
  end

  ##
  # Gets all open activities for the participant of an event.
  # If the participant does not exist, it returns an empty
  # array.
  #
  # @see PatientStudyCalendar#scheduled_activities
  #
  # @param [Event]
  # @return [Array<ScheduledActivity>]
  def activities_for_event(event)
    result = []
    return result if event.participant.blank?

    scheduled_activities(event.participant).each do |a|
      result << a if event.matches_activity(a)
    end
    result
  end

  ##
  # Creates a new InstrumentPlan from the
  # schedule for the given Participant.
  #
  # @param [Participant]
  # @return [InstrumentPlan]
  def build_activity_plan(participant)
    InstrumentPlan.from_schedule(schedules(participant))
  end

  ##
  # Gets information about all activities for a participant
  # (cf. ScheduledActivity Struct) that match the given
  # Event.scheduled_study_segment_identifier.
  #
  # @param participant [Participant]
  # @param scheduled_study_segment_identifier [String] the unique segment id
  # @return [Array<ScheduledActivity>]
  def activities_for_scheduled_segment(participant, scheduled_study_segment_identifier)
    result = []

    # get name of study segment matching event scheduled_study_segment_identifier
    study_segment_name = nil
    subject_schedules = schedules(participant)
    if subject_schedules && subject_schedules["study_segments"]
      subject_schedules["study_segments"].each do |study_segment|
        if study_segment["id"] == scheduled_study_segment_identifier
          study_segment_name = study_segment["name"]
          break
        end
      end
    end

    # filter participant activities whose segment name matches the event
    if subject_schedules && study_segment_name
      build_scheduled_activities(participant_activities(subject_schedules)).each do |a|
        if (a.study_segment == study_segment_name)
          result << a
        end
      end
    end
    result
  end

  ##
  # Get the unique ideal_date label pairs from a segment that
  # match the given Event.scheduled_study_segment_identifier
  # pending events.
  # @param [Participant]
  # @param [String] segment id
  # @return [Array<Array>]
  def unique_label_ideal_date_pairs_for_scheduled_segment(participant, scheduled_study_segment_identifier)
    label_ideal_date_pairs = []
    activities_for_scheduled_segment(participant, scheduled_study_segment_identifier).each do |a|
      label_ideal_date_pairs << [Event.parse_label(a.labels), a.ideal_date]
    end
    label_ideal_date_pairs.uniq
  end

  # Helper method to gather the activities returned from call to
  # schedules
  # @param [Hash] result of json call to PSC
  # @return [Array<Hash>] the activities under days
  def participant_activities(subject_schedules)
    activities = []
    if subject_schedules && subject_schedules["days"]
      subject_schedules["days"].values.each do |date|
        date["activities"].each do |activity|
          activities << activity
        end
      end
    end
    activities
  end
  private :participant_activities

  def scheduled_activities_report(options = {})
    filters = {:state => Psc::ScheduledActivity::SCHEDULED, :end_date => 3.months.from_now.to_date.to_s, :current_user => nil }
    filters.merge!(options)

    path = "reports/scheduled-activities.json?"
    path << "state=#{filters[:state]}"
    path << "&end-date=#{filters[:end_date]}" if filters[:end_date]
    path << "&start-date=#{filters[:start_date]}" if filters[:start_date]
    path << "&responsible-user=#{filters[:current_user]}" if filters[:current_user]

    get(path)
  end

  ##
  # Returns a preview of the schedule for the given study sgements starting at
  # the given date.
  #
  # The PSC service underlying this method expects at least one study segment,
  # and as such you must supply at least one study segment.  This method raises
  # ArgumentError if given zero study segments.
  def schedule_preview(date, study_segments)
    raise ArgumentError, "Cannot retrieve a schedule preview for zero study segments" if study_segments.empty?

    uuids = segment_uuids(study_segments)

    q = uuids.values.zip([date].cycle).map.with_index do |(segment_id, date), i|
      "segment[#{i}]=#{segment_id}&start_date[#{i}]=#{date}"
    end.join('&')

    get("studies/#{URI.escape(study_identifier)}/template/current/schedule-preview.json?#{q}")
  end

  def assignment_identifier(participant)
    get("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments")
  end

  ##
  # For the given Participant, ask for the next scheduled event and determine
  # if that segment should be scheduled. If it should, create a scheduled study
  # segment in PSC.
  #
  # @see Participant#next_scheduled_event
  # @see PatientStudyCalendar#should_schedule_segment
  #
  # @param [Participant]
  # @param [Date] (optional)
  def schedule_next_segment(participant, date = nil)
    return nil if participant.next_study_segment.blank?

    next_scheduled_event      = participant.next_scheduled_event
    next_scheduled_event_date = date.nil? ? next_scheduled_event.date.to_s : date

    if should_schedule_segment(participant, next_scheduled_event.event, next_scheduled_event_date)
      schedule_segment(participant, next_scheduled_event.event, next_scheduled_event_date)
    end
  end

  def schedule_general_informed_consent(participant, date = Date.today.to_s)
    schedule_segment(participant, INFORMED_CONSENT_GENERAL_CONSENT, date)
  end

  def schedule_reconsent(participant, date = Date.today.to_s)
    schedule_segment(participant, INFORMED_CONSENT_RECONSENT, date)
  end

  def schedule_withdrawal(participant, date = Date.today.to_s)
    schedule_segment(participant, INFORMED_CONSENT_WITHDRAWAL, date)
  end

  def schedule_child_consent_birth_to_six_months(participant, date = Date.today.to_s)
    schedule_segment(participant, INFORMED_CONSENT_CHILD_CONSENT_BIRTH, date)
  end

  def schedule_child_consent_six_months_to_age_of_majority(participant, date = Date.today.to_s)
    schedule_segment(participant, INFORMED_CONSENT_CHILD_CONSENT_SIX_MONTHS, date)
  end

  def schedule_low_intensity_postnatal(participant, date = Date.today.to_s)
    schedule_segment(participant, CHILD_LOW_INTENSITY_CHILD, date)
  end

  ##
  # Make POST request to schedule given event in PSC for given participant on the given date
  # @see build_next_scheduled_study_segment_request
  # @param [Participant]
  # @param event [String] describing event in format "EPOCH: SEGMENT"
  # @param date [String] formatted date
  def schedule_segment(participant, event, date)
    post("studies/#{CGI.escape(study_identifier)}/schedules/#{psc_assignment_id(participant)}",
      build_next_scheduled_study_segment_request(event, date))
  end

  ##
  # Defaults to True. If the given scheduled event exists on the given day for the participant
  # then return False since the participant already has that event scheduled on that date.
  #
  # @param participant [Participant]
  # @param next_scheduled_event [String] event name
  # @param next_scheduled_event_date [Date]
  # @return [Boolean]
  def should_schedule_segment(participant, next_scheduled_event, next_scheduled_event_date)
    next_scheduled_event = strip_epoch(next_scheduled_event)

    result = true
    scheduled_activities(participant).each do |activity|
      if (activity.date == next_scheduled_event_date.to_s) &&
          (activity.study_segment.include?(next_scheduled_event))
        result = false
      end
    end
    result
  end

  ##
  # Reschedules open activities for the PSC segment matching the given event on the participant's calendar.
  # Open activities are those activities that are "scheduled" or "conditional".
  #
  # @param event [Event] the event to re-schedule
  # @param date [Date] the date on which to schedule
  # @param [String] reason (optional)
  # @param [String] time (optional)
  def reschedule_pending_event(event, date, reason = nil, time = nil)
    participant = event.participant
    raise "No participant exists for event #{event.inspect}" unless participant
    activities_for_event(event).each do |activity|
      next unless activity.open?
      update_activity_state(activity.activity_id, participant, activity.current_state, date, reason, time)
    end
  end

  ##
  # Returns the PSC activity identifier for the first participant scheduled activity
  # matching the given activity_name
  # @param participant [Participant]
  # @param activity_name [String]
  # @return [String]
  def get_scheduled_activity_identifier(participant, activity_name)
    scheduled_activity_identifier = nil
    scheduled_activities(participant).each do |activity|
      if activity_name =~ Regexp.new(activity.activity_name)
        scheduled_activity_identifier = activity.activity_id
      end
    end
    scheduled_activity_identifier
  end
  private :get_scheduled_activity_identifier

  ##
  # Updates the state of the scheduled activity in PSC.
  #
  # @param activity_identifier [String] the activity name
  # @param participant [Participant]
  # @param value [String] one of the valid enumerable state attributes for an activity in PSC
  # @param date [Date] (optional)
  # @param reason [String] (optional) reason for change
  # @param time [String] (optional) scheduled time
  def update_activity_state(activity_identifier, participant, value, date = nil, reason = nil, time = nil)
    post("studies/#{CGI.escape(study_identifier)}/schedules/#{psc_assignment_id(participant)}/activities/#{activity_identifier}",
      build_scheduled_activity_state_request(activity_identifier, value, date, reason, time))
  end

  ##
  # Marks all activities as canceled for those labeled as collection instruments (environmental or biological)
  # for the participant. Called when scheduling new segments.
  # @param participant [Participant]
  # @param scheduled_study_segment_identifier [String]
  # @param date [Date]
  # @param reason [String]
  def cancel_collection_instruments(participant, scheduled_study_segment_identifier, date, reason)
    activities_for_scheduled_segment(participant, scheduled_study_segment_identifier).each do |a|
      if Instrument.collection?(a.labels)
        update_activity_state(a.activity_id, participant, Psc::ScheduledActivity::CANCELED, date, reason)
      end
    end
  end

  ##
  # Marks all activities as canceled for those whose activity date is less that the cancel_before_date
  # @param participant [Participant]
  # @param scheduled_study_segment_identifier [String]
  # @param date [Date]
  # @param reason [String]
  # @param cancel_before_date [Date]
  def cancel_activities_prior_to_date(participant, scheduled_study_segment_identifier, date, reason, cancel_before_date)
    activities_for_scheduled_segment(participant, scheduled_study_segment_identifier).each do |a|
      if activity_date_scheduled_before(a, cancel_before_date)
        update_activity_state(a.activity_id, participant, Psc::ScheduledActivity::CANCELED, date, reason)
      end
    end
  end

  def activity_date_scheduled_before(activity, cancel_before_date)
    activity.date && cancel_before_date && (Date.parse(activity.date) < cancel_before_date)
  end
  private :activity_date_scheduled_before

  ##
  # Cancels all activities as canceled for those that have instruments but those instruments do not match
  # the current mdes version known to the application. Called when scheduling new segments.
  # @param participant [Participant]
  # @param scheduled_study_segment_identifier [String]
  # @param date [Date]
  # @param reason [String]
  def cancel_non_matching_mdes_version_instruments(participant, scheduled_study_segment_identifier, date, reason)
    activities_for_scheduled_segment(participant, scheduled_study_segment_identifier).each do |a|
      if a.has_non_matching_mdes_version_instrument?
        update_activity_state(a.activity_id, participant, Psc::ScheduledActivity::CANCELED, date, reason)
      end
    end
  end

  ##
  # Cancels all consent activities in segments that are not the Informed Consent Epoch.
  # The Informed Consent Epoch segment is scheduled explicitly for the Participant and should
  # be performed whether the Participant had previously consented or not. Other non Informed
  # Consent Epoch consent activities are scheduled in consort with other activities and, if the
  # Participant has already consented, those activities do not need to remain scheduled.
  # @param participant [Participant]
  # @param scheduled_study_segment_identifier [String]
  # @param date [Date]
  # @param reason [String]
  def cancel_consent_activities(participant, scheduled_study_segment_identifier, date, reason)
    return unless participant.consented?
    activities_for_scheduled_segment(participant, scheduled_study_segment_identifier).each do |a|
      if a.cancelable_consent_activity?
        update_activity_state(a.activity_id, participant, Psc::ScheduledActivity::CANCELED, date, reason)
      end
    end
  end

  ##
  # Updates the subject attributes in PSC for the given participant.
  # @param [Participant]
  def update_subject(participant)
    put("subjects/#{psc_assignment_id(participant)}",
      build_subject_attributes_hash(participant, "_").to_json)
  end

  # <xsd:element name="registration" type="psc:Registration"/>
  #
  # <xsd:complexType name="Registration">
  #     <xsd:sequence>
  #         <xsd:element name="subject" type="psc:Subject"/>
  #     </xsd:sequence>
  #     <xsd:attribute name="first-study-segment-id" type="xsd:string" use="required"/>
  #     <xsd:attribute name="date" type="xsd:date" use="required"/>
  #     <xsd:attribute name="subject-coordinator-name" type="xsd:string"/>
  #     <xsd:attribute name="desired-assignment-id" type="xsd:string"/>
  #     <xsd:attribute name="study-subject-id" type="xsd:string"/>
  # </xsd:complexType>
  #
  def build_subject_assignment_request(participant, event_type, date)
    date = date.nil? ? Date.today.to_s : date.to_s
    subject_attributes = build_subject_attributes_hash(participant)

    segment = event_type.blank? ? participant.next_study_segment : PatientStudyCalendar.get_psc_segment_from_mdes_event_type(event_type)
    segment_id = get_study_segment_id(segment)

    xm = Builder::XmlMarkup.new(:target => "")
    xm.instruct!
    xm.registration("xmlns"=>"http://bioinformatics.northwestern.edu/ns/psc",
                    "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                    "xsi:schemaLocation" => "http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd",
                    "first-study-segment-id" => segment_id,
                    "date" => date,
                    "subject-coordinator-name" => responsible_user,
                    "desired-assignment-id" => psc_assignment_id(participant)) {
      xm.subject(subject_attributes)
    }
    xm.target!
  end

  # <xsd:complexType name="Subject">
  #     <xsd:sequence>
  #         <xsd:element name="property" type="psc:Property" minOccurs="0" maxOccurs="unbounded"/>
  #     </xsd:sequence>
  #     <xsd:attribute name="first-name" type="xsd:string"/>
  #     <xsd:attribute name="last-name" type="xsd:string"/>
  #     <xsd:attribute name="birth-date" type="xsd:date"/>
  #     <xsd:attribute name="person-id" type="xsd:string"/>
  #     <xsd:attribute name="gender" use="required">
  #         <xsd:simpleType>
  #             <xsd:restriction base="xsd:string">
  #                 <xsd:enumeration value="male"/>
  #                 <xsd:enumeration value="female"/>
  #                 <xsd:enumeration value="not reported"/>
  #                 <xsd:enumeration value="unknown"/>
  #             </xsd:restriction>
  #         </xsd:simpleType>
  #     </xsd:attribute>
  # </xsd:complexType>
  def build_subject_attributes_hash(participant, separator = "-")
    subject_attributes = Hash.new
    subject_attributes["person#{separator}id"]  = participant.person.public_id

    gender = participant.gender
    if gender.blank? || gender == "Missing in Error" || gender == "Both"
      gender = "unknown"
    end
    subject_attributes["gender"] = gender

    subject_attributes["first#{separator}name"] = participant.first_name unless participant.first_name.blank?
    subject_attributes["last#{separator}name"]  = participant.last_name  unless participant.last_name.blank?
    dob = formatted_dob(participant)
    subject_attributes["birth#{separator}date"] = dob unless dob.blank?
    subject_attributes
  end

  ##
  # Creates the xml request for a post to psc.
  # This method takes a ScheduledEvent which has the PSC Segment name of the event
  # which is used to determine the study_segment_id - cf. get_study_segment_id
  # @param[String] - Psc Segment
  # @param[String] - as date
  def build_next_scheduled_study_segment_request(event, date)
    study_segment_id = get_study_segment_id(event)
    build_study_segment_request(study_segment_id, date) if study_segment_id
  end

  # <xsd:element name="next-scheduled-study-segment" type="psc:NextScheduledStudySegment"/>
  #
  # <xsd:complexType name="NextScheduledStudySegment">
  #     <xsd:attribute name="start-date" type="xsd:date" use="required"/>
  #     <xsd:attribute name="study-segment-id" type="xsd:string" use="required"/>
  #     <xsd:attribute name="mode" use="required">
  #         <xsd:simpleType>
  #             <xsd:restriction base="xsd:string">
  #                 <xsd:enumeration value="per-protocol"/>
  #                 <xsd:enumeration value="immediate"/>
  #             </xsd:restriction>
  #         </xsd:simpleType>
  #     </xsd:attribute>
  # </xsd:complexType>
  def build_study_segment_request(segment_id, start_date)
    log.debug("~~~ build_study_segment_request for #{segment_id} on #{start_date}")
    xm = Builder::XmlMarkup.new(:target => "")
    xm.instruct!
    xm.tag!("next-scheduled-study-segment".to_sym, {"xmlns"=>"http://bioinformatics.northwestern.edu/ns/psc",
                                    "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                    "xsi:schemaLocation" => "http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd",
                                    "study-segment-id" => segment_id,
                                    "start-date" => start_date,
                                    "mode" => "per-protocol"})
    xm.target!
  end

  # <xsd:element name="scheduled-activity-state" type="psc:ScheduledActivityState"/>
  #
  # <xsd:complexType name="ScheduledActivityState">
  #     <xsd:attribute name="state" use="required">
  #         <xsd:simpleType>
  #             <xsd:restriction base="xsd:string">
  #                 <xsd:enumeration value="canceled"/>
  #                 <xsd:enumeration value="conditional"/>
  #                 <xsd:enumeration value="missing"/>
  #                 <xsd:enumeration value="not-applicable"/>
  #                 <xsd:enumeration value="occurred"/>
  #                 <xsd:enumeration value="scheduled"/>
  #             </xsd:restriction>
  #         </xsd:simpleType>
  #     </xsd:attribute>
  #     <xsd:attribute name="date" type="xsd:date"/>
  #     <xsd:attribute name="reason" type="xsd:string"/>
  # </xsd:complexType>
  def build_scheduled_activity_state_request(activity_identifier, value, date = nil, reason = nil, time = nil)
    activity_hash = Hash.new
    date = date.nil? ? Date.today.strftime("%Y-%m-%d") : date
    state = {
      'date' => date,
      'reason' => reason.to_s,
      'state' => value
    }
    state["time"] = time unless time.blank?
    activity_hash["#{activity_identifier}"] = state
    activity_hash
  end

  def get_study_segment_id(segment)
    result = nil
    segment = strip_epoch(segment)
    segments.each do |seg|
      result = seg.attribute('id').value if seg.attribute('name').value.strip == segment
      break if result
    end
    result
  end

  ##
  # Given a response from psc - extract the identifier from the response
  # @param [Nokogiri::Doc] xml response body
  # @return [String]
  def self.extract_scheduled_study_segment_identifier(xml)
    xml.css("scheduled-study-segment").first['id'] rescue nil
  end

  def formatted_dob(participant)
    dob = nil
    if !(participant.person_dob.to_i < 0) && !participant.person_dob.blank?
      begin
        dt = Date.parse(participant.person_dob)
        dob = dt.strftime("%Y-%m-%d") if dt
      rescue
       # NOOP - failed to parse person_dob into date - return default nil
      end
    end
    dob
  end
  private :formatted_dob

  ##
  # Makes the GET request to the given path and returns the requested response
  # section (e.g. 'body' or 'status').
  # Logs the request.
  # @param [String] - request path
  # @param [String] - "body" or "status"
  # @return [String] - response section
  def get(path, response_section = "body")
    begin
      response = connection.get(path)
      if valid_response? response
        logger.debug "DEBUG [#{Time.now.to_s(:db)}] GET to #{path} succeeded - http status #{response.status}"
      else
        logger.info "INFO  [#{Time.now.to_s(:db)}] GET to #{path} failed - http status #{response.status}"
      end
      response.send response_section
    rescue Exception => e
      logger.error "ERROR [#{Time.now.to_s(:db)}] Exception #{e} during GET request to #{path}"
      logger.error e.backtrace.join("\n")
      raise PscError, "Patient Study Calendar is currently down. #{e}" if e.to_s.include?("Connection refused")
    end
  end

  ##
  # Makes the POST request to the given path with the param and
  # logs the request.
  # @param [String] - the request path
  # @param [String] - the post parameters
  # @return [Response]
  def post(path, payload)
    begin
      response = connection.post(path, payload, { 'Content-Length' => '1024' })
      if valid_response? response
        logger.debug "DEBUG [#{Time.now.to_s(:db)}] POST to #{path} succeeded - http status #{response.status}"
        logger.debug "      - #{response.body}"
      else
        logger.info "INFO  [#{Time.now.to_s(:db)}] POST to #{path} failed - http status #{response.status}"
        logger.info "      - #{response.body}"
      end
      response
    rescue Exception => e
      logger.error "ERROR [#{Time.now.to_s(:db)}] Exception #{e} during POST request to #{path}"
      raise PscError, "Patient Study Calendar is currently down. #{e}" if e.to_s.include?("Connection refused")
    end
  end

  ##
  # Makes the PUT request to the given path with the param and
  # logs the request.
  # @param [String] - the request path
  # @param [String] - the put parameters
  # @return [Response]
  def put(path, payload)
    begin
      response = connection.put(path, payload)
      if valid_response? response
        logger.debug "DEBUG [#{Time.now.to_s(:db)}] PUT to #{path} succeeded - http status #{response.status}"
        logger.debug "      - #{response.body}"
      else
        logger.info "INFO  [#{Time.now.to_s(:db)}] PUT to #{path} failed - http status #{response.status}"
        logger.info "      - #{response.body}"
      end
      response
    rescue Exception => e
      logger.error "ERROR [#{Time.now.to_s(:db)}] Exception #{e} during PUT request to #{path}"
      raise PscError, "Patient Study Calendar is currently down. #{e}" if e.to_s.include?("Connection refused")
    end
  end

  def valid_response?(response)
    response && response.status < 300
  end
  private :valid_response?

  class << self
    ##
    # The PSC assigments returns the epoch prefix to the study segment (e.g. "HI-Intesity: HI-LO Conversion")
    # but when scheduling someone to a segment, it is more useful to use only the study segment name minus the epoch prefix.
    # This method removes the prefix.
    #
    # @param [String]
    # @return [String]
    def strip_epoch(segment)
      return segment unless segment.include?(":")
      segments = segment.split(":")
      return segments[1].strip
    end

    ##
    # The Segment in PSC often, but not always, maps directly to the Event Type as named in the
    # Master Data Element Specification Code List.
    #
    # This method takes the segment name from PSC and translates it into the Event as named in the MDES
    # @param [String] - PSC Segment Name
    # @return [String] - Master Data Element Specification Code List Event Type
    def map_psc_segment_to_mdes_event_type(segment)
      event = PatientStudyCalendar.strip_epoch(segment)
      event = case event
              when "HI-LO Conversion"
                "Low to High Conversion"
              when "Birth Visit Interview"
                "Birth"
              when "PPG 1 and 2"
                "Low Intensity Data Collection"
              when "Pre-Pregnancy"
                "Pre-Pregnancy Visit"
              when "Pregnancy Visit 1"
                "Pregnancy Visit  1"
              when "PPG Follow-Up"
                "Pregnancy Probability"
              when "Father Consent and Interview"
                "Father"
              when "PBS-Eligibility"
                "PBS Participant Eligibility Screening"
              when /Consent/
                "Informed Consent"
              else
                event
              end
      event
    end

    ##
    # This method takes the event type display text from the MDES codes lists and
    # translates it into the Segment Name as known by PSC.
    # @param [String] - Master Data Element Specification Code List Event Type
    # @return [String] - PSC Segment Name
    def get_psc_segment_from_mdes_event_type(event_type)
      event_type = case event_type
              when "Birth"
                "Birth Visit Interview"
              when "Low Intensity Data Collection"
                "PPG 1 and 2"
              when "Pre-Pregnancy Visit"
                "Pre-Pregnancy"
              when "Pregnancy Visit  1"
                "Pregnancy Visit 1"
              when "Pregnancy Visit  2"
                "Pregnancy Visit 2"
              when "Pregnancy Probability"
                "PPG Follow-Up"
              when "Father Consent and Interview"
                "Father"
              else
                event_type
              end
      event_type
    end

    def uri
      psc_config["uri"]
    end

    def psc_config
      NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    end
  end

  class RegisteredParticipantList
    def initialize(psc)
      @psc = psc
      @map = {}
    end

    def is_registered?(person_id, check_server_if_not_cached=true)
      if @map.has_key?(person_id)
        @map[person_id]
      elsif check_server_if_not_cached
        cache_registration_status(person_id, check_if_registered(person_id))
      end
    end

    def cache_registration_status(person_id, status)
      @map[person_id] = status
    end

    def check_if_registered(person_id)
      status = @psc.get("subjects/#{person_id}", "status")
      status && status < 300
    end
  end

  class ResponseError < StandardError
    attr_reader :status, :body

    def initialize(status, body, message=nil)
      super(message || body)
      @status = status
      @body = body
    end
  end
end
