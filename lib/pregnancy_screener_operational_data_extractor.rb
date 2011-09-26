class PregnancyScreenerOperationalDataExtractor < OperationalDataExtractor
  
  PERSON_MAP = {
    "R_FNAME"         => "first_name",
    "R_LNAME"         => "last_name",
    "PERSON_DOB"      => "person_dob",
    "AGE"             => "age",
    "AGE_RANGE"       => "age_range_code",
    "ETHNICITY"       => "ethnic_group_code",
    "PERSON_LANG"     => "language_code",
    "PERSON_LANG_OTH" => "language_other" 
  }
  
  PARTICIPANT_MAP = {
    "AGE_ELIG"        => "pid_age_eligibility_code"
  }

  ADDRESS_MAP = {
    "ADDRESS_1"       => "address_one",
    "ADDRESS_2"       => "address_two",
    "UNIT"            => "unit",
    "CITY"            => "city",
    "STATE"           => "state_code",
    "ZIP"             => "zip",
    "ZIP4"            => "zip4"
  }
  
  MAIL_ADDRESS_MAP = {
    "MAIL_ADDRESS_1"  => "address_one",
    "MAIL_ADDRESS_2"  => "address_two",
    "MAIL_UNIT"       => "unit",
    "MAIL_CITY"       => "city",
    "MAIL_STATE"      => "state_code",
    "MAIL_ZIP"        => "zip",
    "MAIL_ZIP4"       => "zip4"
  }
  
  TELEPHONE_MAP = {
    "PHONE_NBR"       => "phone_nbr",
    "PHONE_NBR_OTH"   => "phone_nbr",
    "PHONE_TYPE"      => "phone_type_code",
    "PHONE_TYPE_OTH"  => "phone_type_other",
  }
  
  HOME_PHONE_MAP = {
    "HOME_PHONE"      => "phone_nbr"
  }
  
  CELL_PHONE_MAP = {
    "CELL_PHONE_2"    => "cell_permission_code",
    "CELL_PHONE_4"    => "text_permission_code",
    "CELL_PHONE"      => "phone_nbr"
  }
  
  EMAIL_MAP = {
    "EMAIL"           => "email",
    "EMAIL_TYPE"      => "email_type_code"
  }
  
  PPG_DETAILS_MAP = {
    "PREGNANT"        => "ppg_first_code",
    "ORIG_DUE_DATE"   => "orig_due_date",
    "TRYING"          => "ppg_first_code",
    "HYSTER"          => "ppg_first_code",
    "OVARIES"         => "ppg_first_code",
    "MENOPAUSE"       => "ppg_first_code",
    "MED_UNABLE"      => "ppg_first_code",
    "MED_UNABLE_OTH"  => "ppg_first_code"    
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

        reference_identifier = r.question.reference_identifier

        if PERSON_MAP.has_key?(reference_identifier)
          person.send("#{PERSON_MAP[reference_identifier]}=", response_value(r))
        end

        if PARTICIPANT_MAP.has_key?(reference_identifier)
          person.participant.send("#{PARTICIPANT_MAP[reference_identifier]}=", response_value(r)) unless person.participant.blank?
        end

        if ADDRESS_MAP.has_key?(reference_identifier)
          address.send("#{ADDRESS_MAP[reference_identifier]}=", response_value(r))
        end

        if MAIL_ADDRESS_MAP.has_key?(reference_identifier)
          mail_address.send("#{MAIL_ADDRESS_MAP[reference_identifier]}=", response_value(r))
        end

        if TELEPHONE_MAP.has_key?(reference_identifier)
          value = response_value(r)
          phone.send("#{TELEPHONE_MAP[reference_identifier]}=", value) unless value.blank?
        end

        if HOME_PHONE_MAP.has_key?(reference_identifier)
          value = response_value(r)
          home_phone.send("#{HOME_PHONE_MAP[reference_identifier]}=", value) unless value.blank?
        end

        if CELL_PHONE_MAP.has_key?(reference_identifier)
          value = response_value(r)
          cell_phone.send("#{CELL_PHONE_MAP[reference_identifier]}=", value) unless value.blank?
        end

        if EMAIL_MAP.has_key?(reference_identifier)
          email.send("#{EMAIL_MAP[reference_identifier]}=", response_value(r))
        end

        # TODO: do not hard code ppg code
        if PPG_DETAILS_MAP.has_key?(reference_identifier)
          value = response_value(r)
          case reference_identifier
          when "PREGNANT"
            value = 1
          when "TRYING"
            value = 2
          when "HYSTER", "OVARIES", "TUBES_TIED", "MENOPAUSE", "MED_UNABLE", "MED_UNABLE_OTH"
            value = 5
          end
          ppg_detail.send("#{PPG_DETAILS_MAP[reference_identifier]}=", value)
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
