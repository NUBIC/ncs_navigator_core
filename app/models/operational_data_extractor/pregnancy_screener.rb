# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PregnancyScreener < Base

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
      "#{INTERVIEW_PREFIX}.TRIMESTER"       => "TRIMESTER",
      "#{INTERVIEW_PREFIX}.MONTH_PREG"      => "MONTH_PREG",
      "#{INTERVIEW_PREFIX}.WEEKS_PREG"      => "WEEKS_PREG",
      "#{INTERVIEW_PREFIX}.DATE_PERIOD"     => "DATE_PERIOD",
      "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE"   => "ORIG_DUE_DATE",
    }

    def initialize(response_set)
      super(response_set)
    end

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
        DUE_DATE_DETERMINER_MAP
      ]
    end

    def extract_data
      person = response_set.person
      participant = response_set.participant

      ppg_detail   = nil
      email        = nil
      home_phone   = nil
      cell_phone   = nil
      phone        = nil
      mail_address = nil
      address      = nil

      PERSON_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          set_value(person, attribute, response_value(r))
        end
      end

      if participant
        PARTICIPANT_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            set_value(participant, attribute, response_value(r))
          end
        end
      end

      ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            address ||= get_address(response_set, person, Address.home_address_type)
            set_value(address, attribute, value)
          end
        end
      end

      MAIL_ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            mail_address ||= get_address(response_set, person, Address.mailing_address_type)
            set_value(mail_address, attribute, value)
          end
        end
      end

      TELEPHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            phone ||= get_telephone(response_set, person)
            set_value(phone, attribute, value)
          end
        end
      end

      HOME_PHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            home_phone ||= get_telephone(response_set, person, Telephone.home_phone_type)
            set_value(home_phone, attribute, value)
          end
        end
      end

      CELL_PHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            cell_phone ||= get_telephone(response_set, person, Telephone.cell_phone_type)
            set_value(cell_phone, attribute, value)
          end
        end
      end

      EMAIL_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            email ||= get_email(response_set, person)
            set_value(email, attribute, value)
          end
        end
      end

      if participant
        PPG_DETAILS_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              ppg_detail ||= get_ppg_detail(response_set, participant)
              ppg_detail.send("#{attribute}=", ppg_detail_value(INTERVIEW_PREFIX, key, value))
            end
          end
        end

        if ppg_detail
          DUE_DATE_DETERMINER_MAP.each do |key, attribute|
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

      end

      unless email.try(:email).blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary }
        email.save!
      end

      if !mail_address.to_s.blank? || !address.to_s.blank?

        person.addresses.each { |a| a.demote_primary_rank_to_secondary }

        mail_address.save! unless mail_address.to_s.blank?
        address.save! unless address.to_s.blank?
      end

      if !cell_phone.try(:phone_nbr).blank? ||
         !home_phone.try(:phone_nbr).blank? ||
         !phone.try(:phone_nbr).blank?
        person.telephones.each { |t| t.demote_primary_rank_to_secondary }

        cell_phone.save! unless cell_phone.try(:phone_nbr).blank?
        home_phone.save! unless home_phone.try(:phone_nbr).blank?
        phone.save! unless phone.try(:phone_nbr).blank?
      end

      participant.save!
      person.save!
    end

  end
end