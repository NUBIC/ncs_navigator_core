class PrePregnancyOperationalDataExtractor
  
  # EMAIL                 Email.email
  # 
  # CELL_PHONE            Telephone.phone_nbr
  # 
  # CONTACT_FNAME_1       Person.first_name
  # CONTACT_LNAME_1       Person.last_name
  # 
  # CONTACT_RELATE_1      ParticipantPersonLink.relationship_code   PERSON_PARTCPNT_RELTNSHP_CL1/CONTACT_RELATIONSHIP_CL2
  # CONTACT_RELATE1_OTH   ParticipantPersonLink.relationship_other
  # 
  # C_ADDR_1_1            Address.address_one
  # C_ADDR_2_1            Address.address_two
  # C_UNIT_1              Address.unit
  # C_CITY_1              Address.city
  # C_STATE_1             Address.state_code                        STATE_CL1
  # C_ZIP_1               Address.zip
  # C_ZIP4_1              Address.zip4
  # 
  # CONTACT_PHONE_1       Telephone.phone_nbr
  # 
  # 
  # CONTACT_FNAME_2       Person.first_name
  # CONTACT_LNAME_2       Person.last_name
  # 
  # CONTACT_RELATE_2      ParticipantPersonLink.relationship_code   PERSON_PARTCPNT_RELTNSHP_CL1/CONTACT_RELATIONSHIP_CL2
  # CONTACT_RELATE2_OTH   ParticipantPersonLink.relationship_other
  # 
  # C_ADDR_1_2            Address.address_one
  # C_ADDR_2_2            Address.address_two
  # C_UNIT_2              Address.unit
  # C_CITY_2              Address.city
  # C_STATE_2             Address.state_code                        STATE_CL1
  # C_ZIP_2               Address.zip
  # C_ZIP4_2              Address.zip4
  # 
  # CONTACT_PHONE_2       Telephone.phone_nbr
  
  INTERVIEW_PREFIX = "PRE_PREG"
  
  PERSON_MAP = {
    "#{INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
    "#{INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
    "#{INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
    "#{INTERVIEW_PREFIX}.MARISTAT"        => "marital_status_code" 
  }
  
  CELL_PHONE_MAP = {
    "#{INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr"
  }
  
  EMAIL_MAP = {
    "#{INTERVIEW_PREFIX}.EMAIL"           => "email"
  }
  
  class << self
    
    def extract_data(response_set)
      person = response_set.person
      if person.participant.blank?
        participant = Participant.create(:person => person) 
      else
        participant = person.participant
      end
      cell_phone = Telephone.new(:person => person, :phone_type => Telephone.cell_phone_type)
      email = Email.new(:person => person)
      
      response_set.responses.each do |r|
        
        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end
        
        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end
        
        if EMAIL_MAP.has_key?(data_export_identifier)
          email.send("#{EMAIL_MAP[data_export_identifier]}=", value) unless value.blank?
        end
        
      end

      email.save! unless email.email.blank?
      cell_phone.save! unless cell_phone.phone_nbr.blank?
      person.save!
      
    end
    
  end
  
end