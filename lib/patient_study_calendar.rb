require 'forwardable'
class PatientStudyCalendar
  extend Forwardable

  LOW_INTENSITY  = "LO-Intensity"
  HIGH_INTENSITY = "HI-Intensity"
  CHILD_EPOCH    = "Child"

  PREGNANCY_SCREENER    = "Pregnancy Screener"
  PPG_1_AND_2           = "PPG 1 and 2"
  PPG_FOLLOW_UP         = "PPG Follow-Up"
  BIRTH_VISIT_INTERVIEW = "Birth Visit Interview"
  HI_LO_CONVERSION      = "Low to High Conversion"

  PRE_PREGNANCY         = "Pre-Pregnancy Visit"
  PREGNANCY_VISIT_1     = "Pregnancy Visit 1"
  PREGNANCY_VISIT_2     = "Pregnancy Visit 2"
  CHILD                 = "Child"

  LOW_INTENSITY_PREGNANCY_SCREENER    = "#{LOW_INTENSITY}: #{PREGNANCY_SCREENER}"
  LOW_INTENSITY_PPG_1_AND_2           = "#{LOW_INTENSITY}: #{PPG_1_AND_2}"
  LOW_INTENSITY_PPG_FOLLOW_UP         = "#{LOW_INTENSITY}: #{PPG_FOLLOW_UP}"
  LOW_INTENSITY_BIRTH_VISIT_INTERVIEW = "#{LOW_INTENSITY}: #{BIRTH_VISIT_INTERVIEW}"

  HIGH_INTENSITY_HI_LO_CONVERSION       = "#{HIGH_INTENSITY}: #{HI_LO_CONVERSION}"
  HIGH_INTENSITY_PPG_FOLLOW_UP          = "#{HIGH_INTENSITY}: #{PPG_FOLLOW_UP}"
  HIGH_INTENSITY_PRE_PREGNANCY          = "#{HIGH_INTENSITY}: #{PRE_PREGNANCY}"
  HIGH_INTENSITY_PREGNANCY_VISIT_1      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_1}"
  HIGH_INTENSITY_PREGNANCY_VISIT_2      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_2}"

  CHILD_CHILD = "#{CHILD_EPOCH}: #{CHILD}"

  ACTIVITY_OCCURRED  = 'occurred'
  ACTIVITY_CANCELED  = 'canceled'
  ACTIVITY_SCHEDULED = 'scheduled'

  CAS_SECURITY_SUFFIX = "/auth/cas_security_check"

  INFORMED_CONSENT = "Informed Consent"
  SKIPPED_EVENT_TYPES = [INFORMED_CONSENT]

  attr_accessor :user
  attr_accessor :registered_participants

  def_delegators self, :uri, :psc_config, :strip_epoch

  ##
  # User object who was authenticated using CAS
  # @param [Aker::User]
  def initialize(user)
    self.user = user || fake_user
    self.registered_participants = RegisteredParticipantList.new(self)
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

  require 'logger'
  def log
    @@log ||= begin
                logfile = File.open(Rails.root.join('log', 'psc.log'), 'a')
                logfile.sync = true
                Logger.new(logfile)
              end
  end

  # TODO: put into configuration
  def study_identifier
    "NCS Hi-Lo"
  end

  # TODO: put in configuration
  def site_identifier
    "GCSC"
  end

  # TODO: put in configuration
  def activity_source_name
    "NCS"
  end

  def psc_client
    @psc_client ||= Psc::Client.new(uri, :authenticator => create_authenticator) do |builder|
      builder.use NcsNavigator::Core::Psc::Retry
      builder.use NcsNavigator::Core::Psc::Logger, log
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
    participant.register! if participant.can_register? # move state so that the participant can tell PSC what is the next study segment to schedule
    return nil if should_skip_event?(event_type)
    return nil if is_registered?(participant) || participant.next_study_segment.blank?
    data = build_subject_assignment_request(participant, event_type, date)

    Rails.logger.info("~~~ assign_subject #{data.inspect}")

    response = post("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments",
                    data)
    registered_participants.cache_registration_status(
      psc_assignment_id(participant), valid_response?(response))
    response
  end

  def should_skip_event?(event_type)
    SKIPPED_EVENT_TYPES.include? event_type
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
  # Gets information about all activities for a participant
  # (cf. ScheduledActivity Struct).
  # Intended to find and re-schedule activities
  # @param [Participant,String]
  # @return [Array<ScheduledActivity>]
  def scheduled_activities(participant)
    build_scheduled_activities(participant_activities(schedules(participant)))
  end

  def build_scheduled_activities(activities)
    scheduled_activities = []
    activities.each do |activity|
      scheduled_activities << ScheduledActivity.new(
        activity['study_segment'].to_s, activity['id'],
        activity['current_state']['name'], activity['ideal_date'], activity['current_state']['date'],
        activity['activity']['name'].to_s.strip, activity['activity']['type'],
        activity['labels'])
    end
    scheduled_activities
  end
  private :build_scheduled_activities

  ##
  # Gets information about all activities for a participant
  # (cf. ScheduledActivity Struct) that relate to the participant's currently
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
  # Gets all activities for an event
  # (cf. ScheduledActivity Struct)
  # @param [Event]
  # @return [Array<ScheduledActivity>]
  def activities_for_event(event)
    result = []
    scheduled_activities(event.participant).each do |a|
      result << a if event.matches_activity(a)
    end
    result
  end

  ##
  # Gets information about all activities for a participant
  # (cf. ScheduledActivity Struct) that match the given
  # Event.scheduled_study_segment_identifier
  # pending events.
  # @param [Participant]
  # @param [Event]
  # @return [Array<ScheduledActivity>]
  def activities_for_scheduled_segment(participant, scheduled_study_segment_identifier, event_start_date)
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

    # filter participant activities whose segment name and ideal date match the event
    if subject_schedules && study_segment_name
      build_scheduled_activities(participant_activities(subject_schedules)).each do |a|
        if (a.study_segment == study_segment_name) && (a.ideal_date.to_s == event_start_date.to_s)
          result << a
        end
      end
    end
    result
  end

  ##
  # Returns the activity ids for participant activities in the 'scheduled' state
  # whose segment matches the given event type
  # (from the MDES event code list - cf. #get_psc_segment_from_mdes_event_type)
  #
  # @param [Participant]
  # @param [String] - the event type label from the MDES Code List for 'EVENT_TYPE_CL1'
  # @return [String or nil] - the scheduled activity identifier or nil
  def activities_to_reschedule(participant, event_type)
    ids = []
    event_name = PatientStudyCalendar.get_psc_segment_from_mdes_event_type(event_type)
    scheduled_activities(participant).each do |scheduled_activity|
      if (PatientStudyCalendar.strip_epoch(scheduled_activity.study_segment).include?(event_name)) &&
         (scheduled_activity.current_state == ACTIVITY_SCHEDULED)
        ids << scheduled_activity.activity_id
      end
    end
    ids.blank? ? nil : ids
  end

  # Helper method to gather the activities returned from call to
  # schedules
  # @param[Hash] - result of json call to PSC
  # @return[Array<Hash>] - the activities under days
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
    filters = {:state => PatientStudyCalendar::ACTIVITY_SCHEDULED, :end_date => 3.months.from_now.to_date.to_s, :current_user => nil }
    filters = filters.merge(options)

    path = "reports/scheduled-activities.json?"
    path << "state=#{filters[:state]}"
    path << "&end-date=#{filters[:end_date]}" if filters[:end_date]
    path << "&start-date=#{filters[:start_date]}" if filters[:start_date]
    path << "&responsible-user=#{filters[:current_user]}" if filters[:current_user]

    get(path)
  end

  def assignment_identifier(participant)
    get("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments")
  end

  def schedule_next_segment(participant, date = nil)
    return nil if participant.next_study_segment.blank?

    next_scheduled_event      = participant.next_scheduled_event
    next_scheduled_event_date = date.nil? ? next_scheduled_event.date.to_s : date

    if should_schedule_segment(participant, next_scheduled_event.event, next_scheduled_event_date)
      post("studies/#{CGI.escape(study_identifier)}/schedules/#{psc_assignment_id(participant)}",
        build_next_scheduled_study_segment_request(next_scheduled_event.event, next_scheduled_event_date))
    end
  end

  ##
  # Schedules the matching PSC segment to the given event on the participant's calendar
  # if an existing event of the given type does not exist on the given date.
  #
  # @param [Participant]
  # @param [String] - the event type label from the MDES Code List for 'EVENT_TYPE_CL1'
  # @param [Date]
  def schedule_known_event(participant, event_type, date)
    if should_schedule_segment(participant, PatientStudyCalendar.get_psc_segment_from_mdes_event_type(event_type), date)
      log.debug("~~~ about to schedule #{event_type} for #{participant.person} on #{date}")
      request_data = build_known_event_request(event_type, date)
      post("studies/#{CGI.escape(study_identifier)}/schedules/#{psc_assignment_id(participant)}", request_data) if request_data
    end
  end

  ##
  # Defaults to True. If the given scheduled event exists on the given day for the participant
  # then return False since the participant already has that event scheduled on that date.
  #
  # @param [Participant]
  # @param [String] - event name
  # @param [Date]
  # @return [Boolean]
  def should_schedule_segment(participant, next_scheduled_event, next_scheduled_event_date)
    return false if should_skip_event?(next_scheduled_event)

    result = true
    scheduled_activities(participant).each do |activity|
      if (activity["date"] == next_scheduled_event_date.to_s) && (activity["study_segment"].include?(next_scheduled_event))
        result = false
      end
    end
    result
  end

  ##
  # Schedules the matching PSC segment to the given event on the participant's calendar.
  # Similar to #schedule_known_event but without the check on the date, instead here we
  # check if there are any existing scheduled activities for the given event type and
  # update the activity state and date for those that are currently 'scheduled'
  #
  # @param [Participant]
  # @param [String] - the event type label from the MDES Code List for 'EVENT_TYPE_CL1'
  # @param [Date]
  # @param [String] - reason
  def schedule_pending_event(participant, event_type, value, date, reason = nil)
    if activities = activities_to_reschedule(participant, event_type)
      activities.each do |activity_identifier|
        update_activity_state(activity_identifier, participant, value, date, reason)
      end
    else
      schedule_known_event(participant, event_type, date)
    end
  end

  ##
  # Updates the state of the scheduled activity in PSC.
  #
  # @param [String] - activity_name
  # @param [Participant]
  # @param [String] - one of the valid enumerable state attributes for an activity in PSC
  # @param [Date] (optional)
  # @param [String] (optional) - reason for change
  def update_activity_state_by_name(activity_name, participant, value, date = nil, reason = nil)
    if scheduled_activity_identifier = get_scheduled_activity_identifier(participant, activity_name)
      update_activity_state(scheduled_activity_identifier, participant, value, date, reason)
    end
  end

  ##
  # Returns the PSC activity identifier for the first participant scheduled activity
  # matching the given activity_name
  # @param [Participant]
  # @param [String]
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
  # @param [String] - activity_name
  # @param [Participant]
  # @param [String] - one of the valid enumerable state attributes for an activity in PSC
  # @param [Date] (optional)
  # @param [String] (optional) - reason for change
  def update_activity_state(activity_identifier, participant, value, date = nil, reason = nil)
    post("studies/#{CGI.escape(study_identifier)}/schedules/#{psc_assignment_id(participant)}/activities/#{activity_identifier}",
      build_scheduled_activity_state_request(value, date, reason))
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
                    "subject-coordinator-name" => user.username,
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
    if gender.blank? || gender == "Missing in Error"
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

  ##
  # Creates the xml request for a post to psc.
  # This method takes a String (Master Data Element Specification Code List Event Type)
  # to determine the Psc Segment and delegates to the #build_next_scheduled_study_segment_request
  # method.
  # @param [String] - Master Data Element Specification Code List Event Type
  # @param[String] - as date
  def build_known_event_request(event_type, date)
    build_next_scheduled_study_segment_request(PatientStudyCalendar.get_psc_segment_from_mdes_event_type(event_type), date)
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
  def build_scheduled_activity_state_request(value, date = nil, reason = nil)
    date = date.nil? ? Date.today.strftime("%Y-%m-%d") : date
    xm = Builder::XmlMarkup.new(:target => "")
    xm.instruct!
    xm.tag!("scheduled-activity-state".to_sym, {"xmlns"=>"http://bioinformatics.northwestern.edu/ns/psc",
                                    "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                    "xsi:schemaLocation" => "http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd",
                                    "state" => value,
                                    "date" => date,
                                    "reason" => reason.to_s })
    xm.target!
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
        log.debug "DEBUG [#{Time.now.to_s(:db)}] GET to #{path} succeeded - http status #{response.status}"
      else
        log.info "INFO  [#{Time.now.to_s(:db)}] GET to #{path} failed - http status #{response.status}"
      end
      response.send response_section
    rescue Exception => e
      log.error "ERROR [#{Time.now.to_s(:db)}] Exception #{e} during GET request to #{path}"
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
        log.debug "DEBUG [#{Time.now.to_s(:db)}] POST to #{path} succeeded - http status #{response.status}"
        log.debug "      - #{response.body}"
      else
        log.info "INFO  [#{Time.now.to_s(:db)}] POST to #{path} failed - http status #{response.status}"
        log.info "      - #{response.body}"
      end
      response
    rescue Exception => e
      log.error "ERROR [#{Time.now.to_s(:db)}] Exception #{e} during POST request to #{path}"
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
        log.debug "DEBUG [#{Time.now.to_s(:db)}] PUT to #{path} succeeded - http status #{response.status}"
        log.debug "      - #{response.body}"
      else
        log.info "INFO  [#{Time.now.to_s(:db)}] PUT to #{path} failed - http status #{response.status}"
        log.info "      - #{response.body}"
      end
      response
    rescue Exception => e
      log.error "ERROR [#{Time.now.to_s(:db)}] Exception #{e} during PUT request to #{path}"
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
              when "Informed Consent"
                "Informed Consent"
                # Informed Consent is an event type that does not map to a segment in PSC
              else
                event_type
              end
      event_type
    end

    def uri
      psc_config["uri"]
    end

    def psc_config
      @psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
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

  ScheduledActivity = Struct.new(:study_segment, :activity_id, :current_state, :ideal_date, :date, :activity_name, :activity_type, :labels)

  class ResponseError < StandardError
    attr_reader :status, :body

    def initialize(status, body, message=nil)
      super(message || body)
      @status = status
      @body = body
    end
  end
end

# class ScheduledActivity <
# end
