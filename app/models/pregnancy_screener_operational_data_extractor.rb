class PregnancyScreenerOperationalDataExtractor
  
  PERSON_MAP = {
    "PREG_SCREEN_HI_2.R_FNAME"         => "first_name",
    "PREG_SCREEN_HI_2.R_LNAME"         => "last_name",
    "PREG_SCREEN_HI_2.PERSON_DOB"      => "person_dob",
    "PREG_SCREEN_HI_2.AGE"             => "age",
    "PREG_SCREEN_HI_2.AGE_RANGE"       => "age_range_code",
    "PREG_SCREEN_HI_2.ETHNICITY"       => "ethnic_group_code",
    "PREG_SCREEN_HI_2.PERSON_LANG"     => "language_code",
    "PREG_SCREEN_HI_2.PERSON_LANG_OTH" => "language_other" 
  }
  
  PARTICIPANT_MAP = {
    "PREG_SCREEN_HI_2.AGE_ELIG"        => "pid_age_eligibility_code"
  }

  ADDRESS_MAP = {
    "PREG_SCREEN_HI_2.ADDRESS_1"       => "address_one",
    "PREG_SCREEN_HI_2.ADDRESS_2"       => "address_two",
    "PREG_SCREEN_HI_2.UNIT"            => "unit",
    "PREG_SCREEN_HI_2.CITY"            => "city",
    "PREG_SCREEN_HI_2.STATE"           => "state_code",
    "PREG_SCREEN_HI_2.ZIP"             => "zip",
    "PREG_SCREEN_HI_2.ZIP4"            => "zip4"
  }
  
  MAIL_ADDRESS_MAP = {
    "PREG_SCREEN_HI_2.MAIL_ADDRESS_1"  => "address_one",
    "PREG_SCREEN_HI_2.MAIL_ADDRESS_2"  => "address_two",
    "PREG_SCREEN_HI_2.MAIL_UNIT"       => "unit",
    "PREG_SCREEN_HI_2.MAIL_CITY"       => "city",
    "PREG_SCREEN_HI_2.MAIL_STATE"      => "state_code",
    "PREG_SCREEN_HI_2.MAIL_ZIP"        => "zip",
    "PREG_SCREEN_HI_2.MAIL_ZIP4"       => "zip4"
  }
  
  TELEPHONE_MAP = {
    "PREG_SCREEN_HI_2.PHONE_NBR"       => "phone_nbr",
    "PREG_SCREEN_HI_2.PHONE_NBR_OTH"   => "phone_nbr",
    "PREG_SCREEN_HI_2.PHONE_TYPE"      => "phone_type_code",
    "PREG_SCREEN_HI_2.PHONE_TYPE_OTH"  => "phone_type_other",
  }
  
  HOME_PHONE_MAP = {
    "PREG_SCREEN_HI_2.HOME_PHONE"      => "phone_nbr"
  }
  
  CELL_PHONE_MAP = {
    "PREG_SCREEN_HI_2.CELL_PHONE_2"    => "cell_permission_code",
    "PREG_SCREEN_HI_2.CELL_PHONE_4"    => "text_permission_code",
    "PREG_SCREEN_HI_2.CELL_PHONE"      => "phone_nbr"
  }
  
  EMAIL_MAP = {
    "PREG_SCREEN_HI_2.EMAIL"           => "email",
    "PREG_SCREEN_HI_2.EMAIL_TYPE"      => "email_type_code"
  }
  
  PPG_DETAILS_MAP = {
    "PREG_SCREEN_HI_2.PREGNANT"        => "ppg_first_code",
    "PREG_SCREEN_HI_2.ORIG_DUE_DATE"   => "orig_due_date",
    "PREG_SCREEN_HI_2.TRYING"          => "ppg_first_code",
    "PREG_SCREEN_HI_2.HYSTER"          => "ppg_first_code",
    "PREG_SCREEN_HI_2.OVARIES"         => "ppg_first_code",
    "PREG_SCREEN_HI_2.MENOPAUSE"       => "ppg_first_code",
    "PREG_SCREEN_HI_2.MED_UNABLE"      => "ppg_first_code",
    "PREG_SCREEN_HI_2.MED_UNABLE_OTH"  => "ppg_first_code"    
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
          when "PREG_SCREEN_HI_2.PREGNANT"
            value = 1
          when "PREG_SCREEN_HI_2.TRYING"
            value = 2
          when "PREG_SCREEN_HI_2.HYSTER", "PREG_SCREEN_HI_2.OVARIES", "PREG_SCREEN_HI_2.TUBES_TIED", "PREG_SCREEN_HI_2.MENOPAUSE", "PREG_SCREEN_HI_2.MED_UNABLE", "PREG_SCREEN_HI_2.MED_UNABLE_OTH"
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
