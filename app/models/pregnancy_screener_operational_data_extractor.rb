class PregnancyScreenerOperationalDataExtractor

  INTERVIEW_PREFIX = "PREG_SCREEN_HI_2"
  
  PERSON_MAP = {
    "#{INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
    "#{INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
    "#{INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
    "#{INTERVIEW_PREFIX}.AGE"             => "age",
    "#{INTERVIEW_PREFIX}.AGE_RANGE"       => "age_range_code",
    "#{INTERVIEW_PREFIX}.ETHNICITY"       => "ethnic_group_code",
    "#{INTERVIEW_PREFIX}.PERSON_LANG"     => "language_code",
    "#{INTERVIEW_PREFIX}.PERSON_LANG_OTH" => "language_other" 
  }
  
  PARTICIPANT_MAP = {
    "#{INTERVIEW_PREFIX}.AGE_ELIG"        => "pid_age_eligibility_code"
  }

  ADDRESS_MAP = {
    "#{INTERVIEW_PREFIX}.ADDRESS_1"       => "address_one",
    "#{INTERVIEW_PREFIX}.ADDRESS_2"       => "address_two",
    "#{INTERVIEW_PREFIX}.UNIT"            => "unit",
    "#{INTERVIEW_PREFIX}.CITY"            => "city",
    "#{INTERVIEW_PREFIX}.STATE"           => "state_code",
    "#{INTERVIEW_PREFIX}.ZIP"             => "zip",
    "#{INTERVIEW_PREFIX}.ZIP4"            => "zip4"
  }
  
  MAIL_ADDRESS_MAP = {
    "#{INTERVIEW_PREFIX}.MAIL_ADDRESS_1"  => "address_one",
    "#{INTERVIEW_PREFIX}.MAIL_ADDRESS_2"  => "address_two",
    "#{INTERVIEW_PREFIX}.MAIL_UNIT"       => "unit",
    "#{INTERVIEW_PREFIX}.MAIL_CITY"       => "city",
    "#{INTERVIEW_PREFIX}.MAIL_STATE"      => "state_code",
    "#{INTERVIEW_PREFIX}.MAIL_ZIP"        => "zip",
    "#{INTERVIEW_PREFIX}.MAIL_ZIP4"       => "zip4"
  }
  
  TELEPHONE_MAP = {
    "#{INTERVIEW_PREFIX}.PHONE_NBR"       => "phone_nbr",
    "#{INTERVIEW_PREFIX}.PHONE_NBR_OTH"   => "phone_nbr",
    "#{INTERVIEW_PREFIX}.PHONE_TYPE"      => "phone_type_code",
    "#{INTERVIEW_PREFIX}.PHONE_TYPE_OTH"  => "phone_type_other",
  }
  
  HOME_PHONE_MAP = {
    "#{INTERVIEW_PREFIX}.HOME_PHONE"      => "phone_nbr"
  }
  
  CELL_PHONE_MAP = {
    "#{INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr"
  }
  
  EMAIL_MAP = {
    "#{INTERVIEW_PREFIX}.EMAIL"           => "email",
    "#{INTERVIEW_PREFIX}.EMAIL_TYPE"      => "email_type_code"
  }
  
  PPG_DETAILS_MAP = {
    "#{INTERVIEW_PREFIX}.PREGNANT"        => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE"   => "orig_due_date",
    "#{INTERVIEW_PREFIX}.TRYING"          => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.HYSTER"          => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.OVARIES"         => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.MENOPAUSE"       => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.MED_UNABLE"      => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.MED_UNABLE_OTH"  => "ppg_first_code"    
  }
  
  
  class << self
    
    def extract_data(response_set)
      person = response_set.person
      person.participant = Participant.new if person.participant.blank?
      address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new)
      mail_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new)

      home_phone = Telephone.new(:person => person, :phone_type => Telephone.home_phone_type)
      cell_phone = Telephone.new(:person => person, :phone_type => Telephone.cell_phone_type)
      phone = Telephone.new(:person => person)

      email = Email.new(:person => person)
      ppg_detail = PpgDetail.new(:participant => person.participant)

      response_set.responses.each do |r|
        
        value = OperationalDataExtractor.response_value(r)
        
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end

        if PARTICIPANT_MAP.has_key?(data_export_identifier)
          person.participant.send("#{PARTICIPANT_MAP[data_export_identifier]}=", value) unless person.participant.blank?
        end

        if ADDRESS_MAP.has_key?(data_export_identifier)
          address.send("#{ADDRESS_MAP[data_export_identifier]}=", value)
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

        # TODO: do not hard code ppg code
        if PPG_DETAILS_MAP.has_key?(data_export_identifier)
          value = value
          case data_export_identifier
          when "#{INTERVIEW_PREFIX}.PREGNANT"
            value = 1
          when "#{INTERVIEW_PREFIX}.TRYING"
            value = 2
          when "#{INTERVIEW_PREFIX}.HYSTER", "#{INTERVIEW_PREFIX}.OVARIES", "#{INTERVIEW_PREFIX}.TUBES_TIED", "#{INTERVIEW_PREFIX}.MENOPAUSE", "#{INTERVIEW_PREFIX}.MED_UNABLE", "#{INTERVIEW_PREFIX}.MED_UNABLE_OTH"
            value = 5
          end
          ppg_detail.send("#{PPG_DETAILS_MAP[data_export_identifier]}=", value)
        end

      end

      ppg_detail.save! unless ppg_detail.ppg_first.blank?
      email.save! unless email.email.blank?
      home_phone.save! unless home_phone.phone_nbr.blank?
      cell_phone.save! unless cell_phone.phone_nbr.blank?
      phone.save! unless phone.phone_nbr.blank?
      mail_address.save! unless mail_address.to_s.blank?
      address.save! unless address.to_s.blank?
      person.participant.save! unless person.participant.blank?
      person.save!
    end
  end
end
