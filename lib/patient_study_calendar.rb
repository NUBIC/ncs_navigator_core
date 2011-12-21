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

  ACTIVITY_OCCURRED = 'occurred'

  CAS_SECURITY_SUFFIX = "/auth/cas_security_check"

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
  
  def segments
    template = connection.get("studies/#{CGI.escape(study_identifier)}/template/current.xml")
    template.body.xpath('//psc:study-segment', Psc.xml_namespace)
  end

  def is_registered?(participant)
    resp = connection.get("subjects/#{participant.person.public_id}")
    resp.status < 300
  end
  
  def assign_subject(participant)
    return nil if is_registered?(participant) || participant.next_study_segment.blank?
    participant.register! if participant.can_register? # move state so that the participant can tell PSC what is the next study segment to schedule
    connection.post("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments", build_subject_assignment_request(participant), { 'Content-Length' => '1024' })
  end
  
  def schedules(participant, format = "json")
    resp = connection.get("subjects/#{participant.person.public_id}/schedules.#{format}")
    resp.body
  end
  
  def mark_activity_for_instrument(activity, participant, value)
    if scheduled_activity_identifier = get_scheduled_activity_identifier(activity, participant)
      resp = connection.post("studies/#{CGI.escape(study_identifier)}/schedules/#{participant.public_id}/activities/#{scheduled_activity_identifier}", 
        build_scheduled_activity_state_request(value), { 'Content-Length' => '1024' })
    end
  end
  
  def get_scheduled_activity_identifier(activity_name, participant)
    scheduled_activity_identifier = nil
    if subject_schedules = schedules(participant)
      subject_schedules["days"].keys.each do |date|
        subject_schedules["days"][date]["activities"].each do |activity|
          if activity_name =~ Regexp.new(activity["activity"]["name"])
            scheduled_activity_identifier = activity["id"]
          end
        end
      end
    end
    scheduled_activity_identifier
  end
  
  def activities_for_participant(participant)
    activities = []
    if subject_schedules = schedules(participant)  
      subject_schedules["days"].keys.each do |date|
        subject_schedules["days"][date]["activities"].each do |activity|
          participant.upcoming_events.each do |event|
            activities << activity["activity"]["name"] if activity["study_segment"].include?(event.to_s)
          end
        end
      end
    end
    activities.uniq
  end

  def activities_for_segment(participant, segment)
    activities = []
    if subject_schedules = schedules(participant)
      if subject_schedules["days"]
        subject_schedules["days"].keys.each do |date|
          subject_schedules["days"][date]["activities"].each do |activity|          
            activities << activity["activity"]["name"] if activity["study_segment"].include?(segment.to_s)
          end
        end
      end
    end
    activities.uniq
  end

  
  def scheduled_activities_report(options = {})
    filters = {:state => 'scheduled', :end_date => 3.months.from_now.to_date.to_s, :current_user => nil }
    filters = filters.merge(options)
    
    path = "reports/scheduled-activities.json?"
    path << "state=#{filters[:state]}"
    path << "&end-date=#{filters[:end_date]}" if filters[:end_date]
    path << "&start-date=#{filters[:start_date]}" if filters[:start_date]
    path << "&responsible-user=#{filters[:current_user]}" if filters[:current_user]
    
    resp = connection.get(path)
    resp.body
  end
  
  
  def assignment_identifier(participant)
    connection.get("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments")
  end
  
  def schedule_next_segment(participant, date = nil)
    return nil if participant.next_study_segment.blank?
    
    next_scheduled_event      = participant.next_scheduled_event
    next_scheduled_event_date = date.nil? ? next_scheduled_event.date.to_s : date
    
    if should_schedule_next_segment(participant, next_scheduled_event, next_scheduled_event_date)
      connection.post("studies/#{CGI.escape(study_identifier)}/schedules/#{participant.public_id}", build_next_scheduled_study_segment_request(next_scheduled_event, next_scheduled_event_date), { 'Content-Length' => '1024' })
    end
  end
  
  def should_schedule_next_segment(participant, next_scheduled_event, next_scheduled_event_date)
    result = true
    subject_schedules = schedules(participant)
    if subject_schedules && days = subject_schedules["days"]
      days.keys.each do |day|
        if day == next_scheduled_event_date.to_s
          days[day]["activities"].each do |activity|
            if activity["study_segment"].include?(next_scheduled_event.event)
              result = false
            end
          end
        end
      end
    end
    result
  end
  
  def update_subject(participant)
    resp = connection.put("subjects/#{participant.person.public_id}", build_subject_attributes_hash(participant, "_").to_json)
    Rails.logger.info(resp.body)
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
  def build_subject_assignment_request(participant)
    subject_attributes = build_subject_attributes_hash(participant)
    xm = Builder::XmlMarkup.new(:target => "")
    xm.instruct!
    xm.registration("xmlns"=>"http://bioinformatics.northwestern.edu/ns/psc", 
                    "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                    "xsi:schemaLocation" => "http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd", 
                    "first-study-segment-id" => get_study_segment_id(participant.next_study_segment), 
                    "date" => Date.today.to_s, 
                    "subject-coordinator-name" => user.username, 
                    "desired-assignment-id" => participant.public_id) { 
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
  
    xm = Builder::XmlMarkup.new(:target => "")
    xm.instruct!
    xm.tag!("next-scheduled-study-segment".to_sym, {"xmlns"=>"http://bioinformatics.northwestern.edu/ns/psc", 
                                    "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                    "xsi:schemaLocation" => "http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd", 
                                    "study-segment-id" => get_study_segment_id(next_scheduled_event.event), 
                                    "start-date" => next_scheduled_event_date,
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
  def build_scheduled_activity_state_request(value)
    xm = Builder::XmlMarkup.new(:target => "")
    xm.instruct!
    xm.tag!("scheduled-activity-state".to_sym, {"xmlns"=>"http://bioinformatics.northwestern.edu/ns/psc", 
                                    "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                    "xsi:schemaLocation" => "http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd", 
                                    "state" => value, 
                                    "date" => Date.today.strftime("%Y-%m-%d")})
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
    
    def uri
      psc_config["uri"]
    end

    def psc_config
      @psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    end
  
  end      
end