require 'forwardable'
class PatientStudyCalendar
  extend Forwardable
  
  LOW_INTENSITY  = "LO-Intensity"
  HIGH_INTENSITY = "HI-Intensity"
  
  PREGNANCY_SCREENER    = "Pregnancy Screener"
  PPG_1_AND_2           = "PPG 1 and 2"
  PPG_FOLLOW_UP         = "PPG Follow-Up"
  BIRTH_VISIT_INTERVIEW = "Birth Visit Interview"
  HI_LO_CONVERSION      = "Low to High Conversion"
  
  PRE_PREGNANCY         = "Pre-Pregnancy"
  PREGNANCY_VISIT_1     = "Pregnancy Visit 1"
  PREGNANCY_VISIT_2     = "Pregnancy Visit 2"
  
  LOW_INTENSITY_PREGNANCY_SCREENER    = "#{LOW_INTENSITY}: #{PREGNANCY_SCREENER}"
  LOW_INTENSITY_PPG_1_AND_2           = "#{LOW_INTENSITY}: #{PPG_1_AND_2}"
  LOW_INTENSITY_PPG_FOLLOW_UP         = "#{LOW_INTENSITY}: #{PPG_FOLLOW_UP}"
  LOW_INTENSITY_BIRTH_VISIT_INTERVIEW = "#{LOW_INTENSITY}: #{BIRTH_VISIT_INTERVIEW}"
  LOW_INTENSITY_HI_LO_CONVERSION      = "#{LOW_INTENSITY}: #{HI_LO_CONVERSION}"

  HIGH_INTENSITY_PPG_FOLLOW_UP          = "#{HIGH_INTENSITY}: #{PPG_FOLLOW_UP}"
  HIGH_INTENSITY_PRE_PREGNANCY          = "#{HIGH_INTENSITY}: #{PRE_PREGNANCY}"
  HIGH_INTENSITY_PREGNANCY_VISIT_1      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_1}"
  HIGH_INTENSITY_PREGNANCY_VISIT_2      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_2}"
  HIGH_INTENSITY_BIRTH_VISIT_INTERVIEW  = "#{HIGH_INTENSITY}: #{BIRTH_VISIT_INTERVIEW}"

  ACTIVITY_OCCURRED  = 'occurred'
  ACTIVITY_CANCELED  = 'canceled'
  ACTIVITY_SCHEDULED = 'scheduled'

  CAS_SECURITY_SUFFIX = "/auth/cas_security_check"

  INFORMED_CONSENT = "Informed Consent"
  SKIPPED_EVENT_TYPES = [INFORMED_CONSENT]

  attr_accessor :user
  
  def_delegators self, :uri, :psc_config, :strip_epoch
  
  ##
  # User object who was authenticated using CAS
  # @param [Aker::User]
  def initialize(user)
    self.user = user
  end

  def get_connection
    psc_client.connection
  end
  alias :connection :get_connection
  
  require 'logger'  
  def log
    logfile = File.open(Rails.root.join('log', 'psc.log'), 'a')
    logfile.sync = true
    @@log ||= Logger.new(logfile)
  end
  
  # TODO: put into configuration
  def study_identifier
    "NCS Hi-Lo"
  end

  # TODO: put in configuration
  def site_identifier
    "GCSC"
  end
  
  def psc_client
    @psc_client ||= Psc::Client.new(uri, :authenticator => create_authenticator )
  end
  
  def create_authenticator
    if ENV['PSC_USERNAME_PASSWORD']
      { :basic => ENV['PSC_USERNAME_PASSWORD'].split(',') }
    else
      { :token => lambda { user.cas_proxy_ticket(File.join(uri.to_s, CAS_SECURITY_SUFFIX)) } }
    end
  end
  
  ##
  # Gets the current template from PSC and returns the nodes matching 'psc:study-segment'.
  # @return [NodeList]
  def segments
    template = get("studies/#{CGI.escape(study_identifier)}/template/current.xml")
    template.xpath('//psc:study-segment', Psc.xml_namespace)
  end

  ##
  # True if the participant is known to psc by the participant public_id.
  # @return [Boolean]
  def is_registered?(participant)
    status = get("subjects/#{participant.person.public_id}", "status")
    status < 300
  end
  
  def assign_subject(participant, event_type = nil, date = nil)
    return nil if is_registered?(participant) || participant.next_study_segment.blank?
    return nil if should_skip_event?(event_type)
    participant.register! if participant.can_register? # move state so that the participant can tell PSC what is the next study segment to schedule
    post("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments", 
      build_subject_assignment_request(participant, event_type, date))
  end
  
  def should_skip_event?(event_type)
    SKIPPED_EVENT_TYPES.include? event_type
  end
    
  def schedules(participant, format = "json")
    get("subjects/#{participant.person.public_id}/schedules.#{format}")
  end

  ##
  # Updates the state of the scheduled activity in PSC.
  #
  # @param [String] - activity_name
  # @param [Participant] 
  # @param [String] - one of the valid enumerable state attributes for an activity in PSC
  # @param [Date] (optional)
  # @param [String] (optional) - reason for change
  def update_activity_state(activity_name, participant, value, date = nil, reason = nil)
    if scheduled_activity_identifier = get_scheduled_activity_identifier(participant, activity_name)
      post("studies/#{CGI.escape(study_identifier)}/schedules/#{participant.person.public_id}/activities/#{scheduled_activity_identifier}", 
        build_scheduled_activity_state_request(value, date, reason))
    end
  end
  
  def get_scheduled_activity_identifier(participant, activity_name)
    scheduled_activity_identifier = nil
    participant_activities(participant).each do |activity|
      if activity_name =~ Regexp.new(activity["activity"]["name"])
        scheduled_activity_identifier = activity["id"]
      end
    end
    scheduled_activity_identifier
  end
  
  def activities_for_participant(participant)
    activities = []
    participant_activities(participant).each do |activity|
      participant.upcoming_events.each do |event|
        if activity["study_segment"].include?(event.to_s)
          activities << activity["activity"]["name"]
        end
      end
    end
    activities.uniq
  end

  def activities_for_segment(participant, segment)
    activities = []
    participant_activities(participant).each do |activity|
      if activity["study_segment"].include?(segment.to_s)
        activities << activity["activity"]["name"]
      end
    end
    activities.uniq
  end

  def participant_activities(participant)
    activities = []
    if subject_schedules = schedules(participant)
      if subject_schedules["days"]
        subject_schedules["days"].keys.each do |date|
          subject_schedules["days"][date]["activities"].each do |activity|
            activities << activity
          end
        end
      end
    end
    activities
  end
  private :participant_activities

  def scheduled_activities_report(options = {})
    filters = {:state => 'scheduled', :end_date => 3.months.from_now.to_date.to_s, :current_user => nil }
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
      post("studies/#{CGI.escape(study_identifier)}/schedules/#{participant.person.public_id}", 
        build_next_scheduled_study_segment_request(next_scheduled_event, next_scheduled_event_date))
    end
  end
  
  ##
  # Defaults to True. If the given scheduled event exists on the given day for the participant
  # then return False since the participant already has that event scheduled.
  #
  # @param [Participant]
  # @param [String] - event name
  # @param [Date]
  # @return [Boolean]
  def should_schedule_segment(participant, next_scheduled_event, next_scheduled_event_date)
    return false if should_skip_event?(next_scheduled_event)
    
    result = true
    subject_schedules = schedules(participant)
    if subject_schedules && days = subject_schedules["days"]
      days.keys.each do |day|
        log.debug("~~~ checking if '#{day}' == '#{next_scheduled_event_date}'")
        if day == next_scheduled_event_date.to_s
          days[day]["activities"].each do |activity|
            log.debug("~~~ checking if '#{activity["study_segment"]}' includes '#{next_scheduled_event}'")
            if activity["study_segment"].include?(next_scheduled_event)
              result = false
            end
          end
        end
      end
    end
    
    log.debug("~~~ should_schedule_segment returning #{result} for #{participant.person} #{next_scheduled_event} on #{next_scheduled_event_date}")
    result
  end
  
  ##
  # Schedules the matching PSC segment to the given event on the participant's calendar.
  #
  # @param [Participant]
  # @param [String] - the event type label from the MDES Code List for 'EVENT_TYPE_CL1'
  # @param [Date]
  def schedule_known_event(participant, event_type, date)
    if should_schedule_segment(participant, PatientStudyCalendar.get_psc_segment_from_mdes_event_type(event_type), date)
      log.debug("~~~ about to schedule #{event_type} for #{participant.person} on #{date}")      
      post("studies/#{CGI.escape(study_identifier)}/schedules/#{participant.person.public_id}", 
        build_known_event_request(event_type, date))
    end
  end
  
  def update_subject(participant)
    put("subjects/#{participant.person.public_id}", 
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
                    "desired-assignment-id" => participant.person.public_id) { 
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
  def build_next_scheduled_study_segment_request(next_scheduled_event, next_scheduled_event_date)
    build_study_segment_request(get_study_segment_id(next_scheduled_event.event), next_scheduled_event_date)
  end

  def build_known_event_request(event_type, date)
    build_study_segment_request(get_study_segment_id(PatientStudyCalendar.get_psc_segment_from_mdes_event_type(event_type)), date)
  end

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
      if response.status < 300
        log.debug "DEBUG [#{Time.now}] GET to #{path} succeeded - http status #{response.status}"
      else
        log.info "INFO  [#{Time.now}] GET to #{path} failed - http status #{response.status}"
      end
      response.send response_section
    rescue Exception => e
      log.error "ERROR [#{Time.now}] Exception #{e} during GET request to #{path}"
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
      if response.status < 300
        log.debug "DEBUG [#{Time.now}] POST to #{path} succeeded - http status #{response.status}"
        log.debug "      - #{response.body}"
      else
        log.info "INFO  [#{Time.now}] POST to #{path} failed - http status #{response.status}"
        log.info "      - #{response.body}"
      end
      response
    rescue Exception => e
      log.error "ERROR [#{Time.now}] Exception #{e} during POST request to #{path}"
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
      if response.status < 300
        log.debug "DEBUG [#{Time.now}] PUT to #{path} succeeded - http status #{response.status}"
        log.debug "      - #{response.body}"
      else
        log.info "INFO  [#{Time.now}] PUT to #{path} failed - http status #{response.status}"
        log.info "      - #{response.body}"
      end
      response
    rescue Exception => e
      log.error "ERROR [#{Time.now}] Exception #{e} during PUT request to #{path}"
    end
  end
  
  
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
    # @param [String] - PSC Segment Name
    # @return [String] - Master Data Element Specification Code List Event Type
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
end