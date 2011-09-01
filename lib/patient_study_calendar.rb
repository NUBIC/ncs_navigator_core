class PatientStudyCalendar
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
      template = connection.get("studies/#{CGI.escape(study_identifier)}/template.xml")
      template.body.xpath('//psc:study-segment', Psc.xml_namespace)
    end

    def is_registered?(participant)
      resp = connection.get("subjects/#{participant.person.public_id}")
      resp.status < 300
    end
    
    # TODO: set desired assignment id
    # TODO: determine first-study-segment-id for participant based on participant ppg status
    def assign_subject(participant)
      return nil if is_registered?(participant)
      connection.post("studies/#{CGI.escape(study_identifier)}/sites/#{CGI.escape(site_identifier)}/subject-assignments", build_subject_assignment_request(participant), { 'Content-Length' => '1024' })
    end
    
    def schedules(participant)
      resp = connection.get("subjects/#{participant.person.public_id}/schedules.json")
      resp.body
    end
    
    
    private
    
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
      
      def build_subject_assignment_request(participant)
        subject = {:first_name => participant.first_name, :last_name => participant.last_name, :person_id => participant.person.public_id, :gender => participant.gender}
        if participant.person_dob
          subject[:birth_date] = participant.person_dob
        end
        
        Rails.logger.info(subject.inspect)
        
        xm = Builder::XmlMarkup.new(:target => "")
        xm.instruct!
        xm.registration("xmlns"=>"http://bioinformatics.northwestern.edu/ns/psc", 
                        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                        "xsi:schemaLocation" => "http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd", 
                        "first-study-segment-id" => segments.first.attribute('id').value, 
                        "date" => Date.today.to_s, "subject-coordinator-name" => username, "desired-assignment-id" => "todo_#{Time.now.to_i}") { 
          xm.subject("first-name" => subject[:first_name], "last-name" => subject[:last_name], "birth-date" => subject[:birth_date], "person-id" => subject[:person_id], "gender" => subject[:gender]) 
        }
        xm.target!
      end
  end
end