# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PbsEligibilityScreener < Base

    # TODO: extract contact information (language/interpreter used)
    # TODO: is address the HOME address? if so, set address_type

    INTERVIEW_PREFIX = "PBS_ELIG_SCREENER"
    INTERVIEW_PREFIX_PROVIDER_OFFICE = "PBS_ELIG_SCREENER_PR_OFFICE"
    HOSPITAL_INTERVIEW_PREFIX_PROVIDER_OFFICE = "PBS_ELIG_SCREENER_HOSP_PR_OFFICE"
    HOSPITAL_INTERVIEW_PREFIX = "PBS_ELIG_SCREENER_HOSP"
    PBS_ELIG_SCREENER_RACE_NEW_PREFIX = "PBS_ELIG_SCREENER_RACE_NEW"
    PBS_ELIG_SCREENER_RACE_1_PREFIX = "PBS_ELIG_SCREENER_RACE_1"
    PBS_ELIG_SCREENER_RACE_2_PREFIX = "PBS_ELIG_SCREENER_RACE_2"
    PBS_ELIG_SCREENER_RACE_3_PREFIX = "PBS_ELIG_SCREENER_RACE_3"

    ENGLISH               = "#{INTERVIEW_PREFIX}.ENGLISH"
    CONTACT_LANG          = "#{INTERVIEW_PREFIX}.CONTACT_LANG_NEW"
    CONTACT_LANG_OTH      = "#{INTERVIEW_PREFIX}.CONTACT_LANG_NEW_OTH"
    INTERPRET             = "#{INTERVIEW_PREFIX}.INTERPRET"
    CONTACT_INTERPRET     = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET"
    CONTACT_INTERPRET_OTH = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET_OTH"

    PERSON_MAP = {
      "#{INTERVIEW_PREFIX}.R_FNAME"             => "first_name",
      "#{INTERVIEW_PREFIX}.R_MNAME"             => "middle_name",
      "#{INTERVIEW_PREFIX}.R_LNAME"             => "last_name",
      "#{INTERVIEW_PREFIX}.PERSON_DOB"          => "person_dob",
      "#{INTERVIEW_PREFIX}.ETHNIC_ORIGIN"       => "ethnic_group_code",
      "#{INTERVIEW_PREFIX}.PERSON_LANG_NEW"     => "language_new_code",
      "#{INTERVIEW_PREFIX}.PERSON_LANG_NEW_OTH" => "language_new_other"
    }

    AGE_RANGE_MAP = {
      "#{INTERVIEW_PREFIX}.AGE_RANGE_PBS"   => "age_range_code",
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

    TELEPHONE_MAP1 = {
      "#{INTERVIEW_PREFIX}.R_PHONE_1"         => "phone_nbr",
      "#{INTERVIEW_PREFIX}.R_PHONE_TYPE1"     => "phone_type_code",
      "#{INTERVIEW_PREFIX}.R_PHONE_TYPE1_OTH" => "phone_type_other",
    }

    TELEPHONE_MAP2 = {
      "#{INTERVIEW_PREFIX}.R_PHONE_2"         => "phone_nbr",
      "#{INTERVIEW_PREFIX}.R_PHONE_TYPE2"     => "phone_type_code",
      "#{INTERVIEW_PREFIX}.R_PHONE_TYPE2_OTH" => "phone_type_other",
    }

    EMAIL_MAP = {
      "#{INTERVIEW_PREFIX}.R_EMAIL"         => "email",
    }

    PPG_DETAILS_MAP = {
      "#{INTERVIEW_PREFIX}.PREGNANT"        => "ppg_first_code",
    }

    DUE_DATE_DETERMINER_MAP = {
      "#{INTERVIEW_PREFIX}.TRIMESTER"          => "TRIMESTER",
      "#{INTERVIEW_PREFIX}.MONTH_PREG"         => "MONTH_PREG",
      "#{INTERVIEW_PREFIX}.WEEKS_PREG"         => "WEEKS_PREG",
      "#{INTERVIEW_PREFIX}.DATE_PERIOD_DD"     => "DATE_PERIOD_DD",
      "#{INTERVIEW_PREFIX}.DATE_PERIOD_MM"     => "DATE_PERIOD_MM",
      "#{INTERVIEW_PREFIX}.DATE_PERIOD_YY"     => "DATE_PERIOD_YY",
      "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD"   => "ORIG_DUE_DATE_DD",
      "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM"   => "ORIG_DUE_DATE_MM",
      "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY"   => "ORIG_DUE_DATE_YY",
    }

    MODE_OF_CONTACT_MAP = {
      "prepopulated_mode_of_contact" => "prepopulated_mode_of_contact"
    }

    PERSON_RACE_MAP = {
      "#{PBS_ELIG_SCREENER_RACE_NEW_PREFIX}.RACE_NEW" => "race_code",
      "#{PBS_ELIG_SCREENER_RACE_NEW_PREFIX}.RACE_NEW_OTH" => "race_other",
      "#{PBS_ELIG_SCREENER_RACE_1_PREFIX}.RACE_1" => "race_code",
      "#{PBS_ELIG_SCREENER_RACE_1_PREFIX}.RACE_1_OTH" => "race_other",
      "#{PBS_ELIG_SCREENER_RACE_2_PREFIX}.RACE_2" => "race_code",
      "#{PBS_ELIG_SCREENER_RACE_3_PREFIX}.RACE_3" => "race_code"
    }

    def maps
      [
        PERSON_MAP,
        AGE_RANGE_MAP,
        PERSON_RACE_MAP,
        PARTICIPANT_MAP,
        ADDRESS_MAP,
        TELEPHONE_MAP1,
        TELEPHONE_MAP2,
        EMAIL_MAP,
        PPG_DETAILS_MAP,
        DUE_DATE_DETERMINER_MAP,
        MODE_OF_CONTACT_MAP,
        PERSON_RACE_MAP
      ]
    end

    def extract_data

      process_person(PERSON_MAP)
      process_participant(PARTICIPANT_MAP)

      # AGE_RANGE_CL8 in instrument - AGE_RANGE_CL1 in person
      # So if it is 1 then 1 otherwise set to -6 unknown because of the code list mismatch
      AGE_RANGE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          val = case response_value(r)
                when 1
                  1
                when -1
                  -1
                else
                  -6
                end
          person.send("#{attribute}=", val)
        end
      end

      address = process_address(person, ADDRESS_MAP, Address.home_address_type)

      process_person_race(PERSON_RACE_MAP)

      phone1  = process_telephone(person, TELEPHONE_MAP1, nil, primary_rank)
      phone2  = process_telephone(person, TELEPHONE_MAP2, nil, secondary_rank)

      email   = process_email(EMAIL_MAP)

      if participant
        ppg_detail = process_ppg_details(participant, PPG_DETAILS_MAP, INTERVIEW_PREFIX)

        if ppg_detail
          DUE_DATE_DETERMINER_MAP.each do |key, attribute|
            if r = data_export_identifier_indexed_responses[key]
              if due_date = determine_due_date(attribute, r)
                ppg_detail.orig_due_date = due_date
              end
            end
          end

          if due_date = calculated_due_date(response_set)
            ppg_detail.orig_due_date = due_date
          elsif ppg_detail.orig_due_date.blank? && participant.known_to_be_pregnant?
            due_date = (Date.today + 280.days) - (140.days)
            ppg_detail.orig_due_date = due_date.strftime('%Y-%m-%d')
          end
          set_participant_type(participant, ppg_detail.ppg_first_code)
          ppg_detail.save!

        # Set the participant type for a Birth Cohort Participant
        elsif /_PBSampScreenHosp_/ =~ response_set.survey.title
          set_participant_type(participant, 1)
        end

      end

      finalize_email(email)
      finalize_addresses(address)
      finalize_telephones(phone1, phone2)

      update_instrument_mode

      participant.save! if participant
      person.save!
    end

    def calculated_due_date(response_set)
      # try due date first
      ret = due_date_response(response_set, "ORIG_DUE_DATE", INTERVIEW_PREFIX)
      ret = due_date_response(response_set, "DATE_PERIOD", INTERVIEW_PREFIX) unless ret
      ret
    end

    # @todo using reorder because surveyor applies unscoped ordering to responses
    def response_for(response_set, data_export_identifier)
      response_set.responses.includes(:question).where(
        "questions.data_export_identifier = ?", data_export_identifier).reorder('responses.created_at DESC').first
    end

  end
end
