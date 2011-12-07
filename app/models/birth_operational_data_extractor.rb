
class BirthOperationalDataExtractor

  BABY_NAME_PREFIX   = "BIRTH_VISIT_BABY_NAME_2"
  BIRTH_VISIT_PREFIX = "BIRTH_VISIT_2"
  BIRTH_LI_PREFIX    = "BIRTH_VISIT_LI"
  
  CHILD_PERSON_MAP = {
    "#{BABY_NAME_PREFIX}.BABY_FNAME"        => "first_name",
    "#{BABY_NAME_PREFIX}.BABY_MNAME"        => "middle_name",
    "#{BABY_NAME_PREFIX}.BABY_LNAME"        => "last_name",
    "#{BABY_NAME_PREFIX}.BABY_SEX"          => "sex_code",

    "#{BIRTH_VISIT_PREFIX}.BABY_FNAME"      => "first_name",
    "#{BIRTH_VISIT_PREFIX}.BABY_MNAME"      => "middle_name",
    "#{BIRTH_VISIT_PREFIX}.BABY_LNAME"      => "last_name",
    "#{BIRTH_VISIT_PREFIX}.BABY_SEX"        => "sex_code",
  }
  
  PERSON_MAP = {
    "#{BIRTH_VISIT_PREFIX}.R_FNAME"         => "first_name",
    "#{BIRTH_VISIT_PREFIX}.R_LNAME"         => "last_name",

    "#{BIRTH_LI_PREFIX}.R_FNAME"         => "first_name",
    "#{BIRTH_LI_PREFIX}.R_LNAME"         => "last_name",
  }
  
  MAIL_ADDRESS_MAP = {
    "#{BIRTH_VISIT_PREFIX}.MAIL_ADDRESS1"   => "address_one",
    "#{BIRTH_VISIT_PREFIX}.MAIL_ADDRESS2"   => "address_two",
    "#{BIRTH_VISIT_PREFIX}.MAIL_UNIT"       => "unit",
    "#{BIRTH_VISIT_PREFIX}.MAIL_CITY"       => "city",
    "#{BIRTH_VISIT_PREFIX}.MAIL_STATE"      => "state_code",
    "#{BIRTH_VISIT_PREFIX}.MAIL_ZIP"        => "zip",
    "#{BIRTH_VISIT_PREFIX}.MAIL_ZIP4"       => "zip4",

    "#{BIRTH_LI_PREFIX}.MAIL_ADDRESS1"   => "address_one",
    "#{BIRTH_LI_PREFIX}.MAIL_ADDRESS2"   => "address_two",
    "#{BIRTH_LI_PREFIX}.MAIL_UNIT"       => "unit",
    "#{BIRTH_LI_PREFIX}.MAIL_CITY"       => "city",
    "#{BIRTH_LI_PREFIX}.MAIL_STATE"      => "state_code",
    "#{BIRTH_LI_PREFIX}.MAIL_ZIP"        => "zip",
    "#{BIRTH_LI_PREFIX}.MAIL_ZIP4"       => "zip4"
  }
  
  TELEPHONE_MAP = {
    "#{BIRTH_VISIT_PREFIX}.PHONE_NBR"       => "phone_nbr",
    "#{BIRTH_VISIT_PREFIX}.PHONE_NBR_OTH"   => "phone_nbr",
    "#{BIRTH_VISIT_PREFIX}.PHONE_TYPE"      => "phone_type_code",
    "#{BIRTH_VISIT_PREFIX}.PHONE_TYPE_OTH"  => "phone_type_other",

    "#{BIRTH_LI_PREFIX}.PHONE_NBR"       => "phone_nbr",
    "#{BIRTH_LI_PREFIX}.PHONE_NBR_OTH"   => "phone_nbr",
    "#{BIRTH_LI_PREFIX}.PHONE_TYPE"      => "phone_type_code",
    "#{BIRTH_LI_PREFIX}.PHONE_TYPE_OTH"  => "phone_type_other",
  }
  
  HOME_PHONE_MAP = {
    "#{BIRTH_VISIT_PREFIX}.HOME_PHONE"      => "phone_nbr",

    "#{BIRTH_LI_PREFIX}.HOME_PHONE"      => "phone_nbr"
  }
  
  CELL_PHONE_MAP = {
    "#{BIRTH_VISIT_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{BIRTH_VISIT_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{BIRTH_VISIT_PREFIX}.CELL_PHONE"      => "phone_nbr",

    "#{BIRTH_LI_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{BIRTH_LI_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{BIRTH_LI_PREFIX}.CELL_PHONE"      => "phone_nbr"
  }

  EMAIL_MAP = {
    "#{BIRTH_VISIT_PREFIX}.EMAIL"           => "email",
    "#{BIRTH_VISIT_PREFIX}.EMAIL_TYPE"      => "email_type_code",

    "#{BIRTH_LI_PREFIX}.EMAIL"           => "email",
    "#{BIRTH_LI_PREFIX}.EMAIL_TYPE"      => "email_type_code"
  }
  

  class << self
    
    def extract_data(response_set)
      person = response_set.person
      if person.participant.blank?
        participant = Participant.create(:person => person) 
      else
        participant = person.participant
      end
      
      child = Person.new
      child_relationship  = ParticipantPersonLink.new(:person => child, :participant => participant, :relationship_code => 8) # 8 Child
      
      mail_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :address_type => Address.mailing_address_type)
      home_phone = Telephone.new(:person => person, :phone_type => Telephone.home_phone_type, :psu => person.psu)
      cell_phone = Telephone.new(:person => person, :phone_type => Telephone.cell_phone_type, :psu => person.psu)
      phone = Telephone.new(:person => person, :psu => person.psu)
      email = Email.new(:person => person, :psu => person.psu)
      
      response_set.responses.each do |r|
        
        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end

        if CHILD_PERSON_MAP.has_key?(data_export_identifier)
          child.send("#{CHILD_PERSON_MAP[data_export_identifier]}=", value) unless value.blank?
        end
        
        if MAIL_ADDRESS_MAP.has_key?(data_export_identifier)
          mail_address.send("#{MAIL_ADDRESS_MAP[data_export_identifier]}=", value)
        end
        
        if TELEPHONE_MAP.has_key?(data_export_identifier)
          phone.send("#{TELEPHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end
        
        if HOME_PHONE_MAP.has_key?(data_export_identifier)
          home_phone.send("#{HOME_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end
        
        if EMAIL_MAP.has_key?(data_export_identifier)
          email.send("#{EMAIL_MAP[data_export_identifier]}=", value)
        end
        
      end

      if !child.first_name.blank? && !child.last_name.blank?
        child.save!
        child_relationship.save!
      end
      
      email.save! unless email.email.blank?
      mail_address.save! unless mail_address.to_s.blank?
      home_phone.save! unless home_phone.phone_nbr.blank?
      cell_phone.save! unless cell_phone.phone_nbr.blank?
      phone.save! unless phone.phone_nbr.blank?
      participant.save!
      person.save!
      
    end
  end

end