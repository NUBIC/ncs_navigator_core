class PregnancyScreenerOperationalDataExtractor

  # TODO: extract contact information (language/interpreter used)
  # TODO: is address the HOME address? if so, set address_type

  INTERVIEW_PREFIX = "PREG_SCREEN_HI_2"

  ENGLISH               = "#{INTERVIEW_PREFIX}.ENGLISH"
  CONTACT_LANG          = "#{INTERVIEW_PREFIX}.CONTACT_LANG"
  CONTACT_LANG_OTH      = "#{INTERVIEW_PREFIX}.CONTACT_LANG_OTH"
  INTERPRET             = "#{INTERVIEW_PREFIX}.INTERPRET"
  CONTACT_INTERPRET     = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET"
  CONTACT_INTERPRET_OTH = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET_OTH"

  PERSON_MAP = {
    "#{INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
    "#{INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
    "#{INTERVIEW_PREFIX}.R_GENDER"        => "sex_code",
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

  DUE_DATE_DETERMINER_MAP = {
    "#{INTERVIEW_PREFIX}.DATE_PERIOD"     => "DATE_PERIOD",
    "#{INTERVIEW_PREFIX}.WEEKS_PREG"      => "WEEKS_PREG",
    "#{INTERVIEW_PREFIX}.MONTH_PREG"      => "MONTH_PREG",
    "#{INTERVIEW_PREFIX}.TRIMESTER"       => "TRIMESTER",
  }

  class << self

    def extract_data(response_set)
      person = response_set.person
      if person.participant.blank?
        participant = Participant.create
        participant.person = person
      else
        participant = person.participant
      end

      ppg_detail   = nil
      email        = nil
      home_phone   = nil
      cell_phone   = nil
      phone        = nil
      mail_address = nil
      address      = nil

      response_set.responses.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end

        if PARTICIPANT_MAP.has_key?(data_export_identifier)
          participant.send("#{PARTICIPANT_MAP[data_export_identifier]}=", value) unless participant.blank?
        end

        if ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            address ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.home_address_type.local_code).first
            if address.nil?
              address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                    :address_type => Address.home_address_type, :response_set => response_set)
            end
            address.send("#{ADDRESS_MAP[data_export_identifier]}=", value)
          end
        end

        if MAIL_ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            mail_address ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.mailing_address_type.local_code).first
            if mail_address.nil?
              mail_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                         :address_type => Address.mailing_address_type, :response_set => response_set)
            end
            mail_address.send("#{MAIL_ADDRESS_MAP[data_export_identifier]}=", value)
          end
        end

        if TELEPHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            phone ||= Telephone.where(:response_set_id => response_set.id).first
            if phone.nil?
              phone = Telephone.new(:person => person, :psu => person.psu, :response_set => response_set)
            end

            phone.send("#{TELEPHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if HOME_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            home_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.home_phone_type.local_code).last
            if home_phone.nil?
              home_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.home_phone_type, :response_set => response_set)
            end

            home_phone.send("#{HOME_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            cell_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.cell_phone_type.local_code).last
            if cell_phone.nil?
              cell_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.cell_phone_type, :response_set => response_set)
            end
            cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if EMAIL_MAP.has_key?(data_export_identifier)
          unless value.blank?
            email ||= Email.where(:response_set_id => response_set.id).first
            if email.nil?
              email = Email.new(:person => person, :psu => person.psu, :response_set => response_set)
            end
            email.send("#{EMAIL_MAP[data_export_identifier]}=", value)
          end
        end

        # TODO: do not hard code ppg code
        if PPG_DETAILS_MAP.has_key?(data_export_identifier)

          ppg_detail ||= PpgDetail.where(:response_set_id => response_set.id).first
          if ppg_detail.nil?
            ppg_detail = PpgDetail.new(:participant => person.participant, :psu => person.psu, :response_set => response_set)
          end

          case data_export_identifier
          when "#{INTERVIEW_PREFIX}.PREGNANT"
            ppg_detail_value = value
          when "#{INTERVIEW_PREFIX}.TRYING"
            case value
            when 1 # when Yes to Trying - set ppg_first_code to 2 - Trying
              ppg_detail_value = 2
            when 2 # when No to Trying - set ppg_first_code to 4 - Not Trying
              ppg_detail_value = 4
            else  # Otherwise Recent Loss, Not Trying, Unable match ppg_first_code
              ppg_detail_value = value
            end
          when "#{INTERVIEW_PREFIX}.HYSTER", "#{INTERVIEW_PREFIX}.OVARIES", "#{INTERVIEW_PREFIX}.TUBES_TIED", "#{INTERVIEW_PREFIX}.MENOPAUSE", "#{INTERVIEW_PREFIX}.MED_UNABLE", "#{INTERVIEW_PREFIX}.MED_UNABLE_OTH"
            ppg_detail_value = 5 if value == 1 # If yes to any set the ppg_first_code to 5 - Unable to become pregnant
          else
            ppg_detail_value = value
          end
          ppg_detail.send("#{PPG_DETAILS_MAP[data_export_identifier]}=", ppg_detail_value)
        end

        if DUE_DATE_DETERMINER_MAP.has_key?(data_export_identifier)
          due_date = OperationalDataExtractor.determine_due_date(DUE_DATE_DETERMINER_MAP[data_export_identifier], r)
          ppg_detail.orig_due_date = due_date if due_date
        end
      end

      if ppg_detail && !ppg_detail.ppg_first.blank?
        OperationalDataExtractor.set_participant_type(participant, ppg_detail.ppg_first_code)
        ppg_detail.save!
      end

      if email && !email.email.blank?
        email.save!
      end

      if home_phone && !home_phone.phone_nbr.blank?
        home_phone.save!
      end

      if cell_phone && !cell_phone.phone_nbr.blank?
        cell_phone.save!
      end

      if phone && !phone.phone_nbr.blank?
        phone.save!
      end

      if mail_address && !mail_address.to_s.blank?
        mail_address.save!
      end

      if address && !address.to_s.blank?
        address.save!
      end

      participant.save!
      person.save!
    end

  end
end
