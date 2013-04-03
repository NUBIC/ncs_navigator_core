# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PregnancyScreener < Base

    # TODO: extract contact information (language/interpreter used)
    # TODO: is address the HOME address? if so, set address_type

    INTERVIEW_PREFIX = "PREG_SCREEN_HI_2"

    PREG_SCREEN_HI_RACE_2_PREFIX = "PREG_SCREEN_HI_RACE_2"

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
      "#{INTERVIEW_PREFIX}.TRIMESTER"       => "TRIMESTER",
      "#{INTERVIEW_PREFIX}.MONTH_PREG"      => "MONTH_PREG",
      "#{INTERVIEW_PREFIX}.WEEKS_PREG"      => "WEEKS_PREG",
      "#{INTERVIEW_PREFIX}.DATE_PERIOD"     => "DATE_PERIOD",
      "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE"   => "ORIG_DUE_DATE",
    }
    PERSON_RACE_MAP = {
      "#{PREG_SCREEN_HI_RACE_2_PREFIX}.RACE"         => "race_code",
      "#{PREG_SCREEN_HI_RACE_2_PREFIX}.RACE_OTH"     => "race_other"
    }

    def maps
      [
        PERSON_MAP,
        PARTICIPANT_MAP,
        ADDRESS_MAP,
        MAIL_ADDRESS_MAP,
        TELEPHONE_MAP,
        HOME_PHONE_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
        PPG_DETAILS_MAP,
        DUE_DATE_DETERMINER_MAP,
        PERSON_RACE_MAP
      ]
    end

    def extract_data
      process_person(PERSON_MAP)
      process_participant(PARTICIPANT_MAP)

      address      = process_address(person, ADDRESS_MAP, Address.home_address_type)
      mail_address = process_address(person, MAIL_ADDRESS_MAP, Address.mailing_address_type)
      phone        = process_telephone(person, TELEPHONE_MAP)
      home_phone   = process_telephone(person, HOME_PHONE_MAP, Telephone.home_phone_type)
      cell_phone   = process_telephone(person, CELL_PHONE_MAP, Telephone.cell_phone_type)
      email        = process_email(EMAIL_MAP)
      process_person_race(PERSON_RACE_MAP)

      if participant
        ppg_detail = process_ppg_details(participant, PPG_DETAILS_MAP, INTERVIEW_PREFIX)
        process_due_date(participant, ppg_detail, DUE_DATE_DETERMINER_MAP) if ppg_detail
      end

      finalize_email(email)
      finalize_addresses(mail_address, address)
      finalize_telephones(cell_phone, home_phone, phone)

      participant.save!
      person.save!
    end

    def process_due_date(participant, ppg_detail, map)
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          if due_date = determine_due_date(attribute, r)
            ppg_detail.orig_due_date = due_date
          end
        end
      end
      unless ppg_detail.ppg_first_code.blank?
        set_participant_type(participant, ppg_detail.ppg_first_code)
        ppg_detail.save!
      end
    end
    private :process_due_date

  end
end
