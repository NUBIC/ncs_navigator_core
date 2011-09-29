class PatientStudyCalendar
  
  LOW_INTENSITY  = "LO-Intensity"
  HIGH_INTENSITY = "HI-Intensity"
  
  PREGNANCY_SCREENER    = "Pregnancy Screener"
  PPG_1_AND_2           = "PPG 1 and 2"
  PPG_FOLLOW_UP         = "PPG Follow Up"
  BIRTH_VISIT_INTERVIEW = "Birth Visit Interview"
  HI_LO_CONVERSION      = "Low to High Conversion"
  
  PPG_3_MONTH_FOLLOW_UP = "PPG Follow Up CATI after 3 months"
  PPG_6_MONTH_FOLLOW_UP = "PPG Follow Up CATI after 6 months"
  PRE_PREGNANCY         = "Pre-Pregnancy"
  PREGNANCY_VISIT_1     = "Pregnancy Visit 1"
  PREGNANCY_VISIT_2     = "Pregnancy Visit 2"
  
  LOW_INTENSITY_PREGNANCY_SCREENER    = "#{LOW_INTENSITY}: #{PREGNANCY_SCREENER}"
  LOW_INTENSITY_PPG_1_AND_2           = "#{LOW_INTENSITY}: #{PPG_1_AND_2}"
  LOW_INTENSITY_PPG_FOLLOW_UP         = "#{LOW_INTENSITY}: #{PPG_FOLLOW_UP}"
  LOW_INTENSITY_BIRTH_VISIT_INTERVIEW = "#{LOW_INTENSITY}: #{BIRTH_VISIT_INTERVIEW}"
  LOW_INTENSITY_HI_LO_CONVERSION      = "#{LOW_INTENSITY}: #{HI_LO_CONVERSION}"

  HIGH_INTENSITY_3_MONTH_FOLLOW_UP      = "#{HIGH_INTENSITY}: #{PPG_3_MONTH_FOLLOW_UP}"
  HIGH_INTENSITY_6_MONTH_FOLLOW_UP      = "#{HIGH_INTENSITY}: #{PPG_6_MONTH_FOLLOW_UP}"
  HIGH_INTENSITY_PRE_PREGNANCY          = "#{HIGH_INTENSITY}: #{PRE_PREGNANCY}"
  HIGH_INTENSITY_PREGNANCY_VISIT_1      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_1}"
  HIGH_INTENSITY_PREGNANCY_VISIT_2      = "#{HIGH_INTENSITY}: #{PREGNANCY_VISIT_2}"
  HIGH_INTENSITY_BIRTH_VISIT_INTERVIEW  = "#{HIGH_INTENSITY}: #{BIRTH_VISIT_INTERVIEW}"

  class << self
    
    def get_connection
      psc_client.connection
    end
    alias :connection :get_connection
    
    def study_identifier
      @study_identifier ||= psc_client.studies.first["assigned_identifier"]
    end

    def site_identifier
      @site_identifier ||= connection.get('sites').body.xpath('//psc:site', Psc.xml_namespace).first.attr('assigned-identifier')
    end
    
    def psc_client
      @psc_client ||= Psc::Client.new(uri, :authenticator => { :basic => [username,password] })
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
      connection.post("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments", build_subject_assignment_request(participant), { 'Content-Length' => '1024' })
    end
    
    def schedules(participant)
      resp = connection.get("subjects/#{participant.person.public_id}/schedules.json")
      resp.body
    end
    
    def assignment_identifier(participant)
      connection.get("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments")
    end
    
    def schedule_next_segment(participant, date = nil)
      return nil if participant.next_study_segment.blank?
      connection.post("studies/#{CGI.escape(study_identifier)}/schedules/#{participant.public_id}", build_next_scheduled_study_segment_request(participant, date), { 'Content-Length' => '1024' })
    end
    
    def update_subject(participant)
      connection.put("subjects/#{participant.person.public_id}", build_subject_attributes_hash(participant, "_").to_json)      
    end
       
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
    # The Segment in PSC often, but not always, maps directly to the Event as named in the Instrument to Event Map
    # section in the Master Data Element Specification.
    #
    # This method takes the segment name from PSC and translates it into the Event as named in the MDES
    # @param [String]
    # @return [String]
    def map_psc_segment_to_mdes_event(segment)
      event = PatientStudyCalendar.strip_epoch(segment)
      event = case event
              when "HI-LO Conversion"
                "Low to High Conversion"
              when "Birth Visit Interview"
                "Birth"
              when "PPG 1 and 2"
                "Low Intensity Data Collection"
              when "PPG Follow Up"
                "Pregnancy Probability"
              else
                event
              end

      event
    end
    
    # private
    
      def uri
        psc_config["uri"]
      end
    
      def username
        psc_config["username"]
      end
    
      def password
        psc_config["password"]
      end
    
      def psc_config
        @psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
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
                        "subject-coordinator-name" => username, 
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
        if gender.blank?
          gender = "unknown"
        elsif gender == "Missing in Error"         
          gender = "unknown"
        end
        subject_attributes["gender"] = gender
        
        subject_attributes["first#{separator}name"] = participant.first_name unless participant.first_name.blank?
        subject_attributes["last#{separator}name"]  = participant.last_name  unless participant.last_name.blank?
        subject_attributes["birth#{separator}date"] = participant.person_dob unless participant.person_dob.blank?
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
      def build_next_scheduled_study_segment_request(participant, date)
        
        next_scheduled_event      = participant.next_scheduled_event
        next_scheduled_event_date = date.nil? ? next_scheduled_event.date.to_s : date
        
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
      
      def get_study_segment_id(segment)
        result = nil
        segment = strip_epoch(segment)
        segments.each do |seg|
          result = seg.attribute('id').value if seg.attribute('name').value.strip == segment
          break if result
        end
        result
      end      
      
  end
end