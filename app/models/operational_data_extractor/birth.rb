# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class Birth < Base

    BABY_NAME_PREFIX     = "BIRTH_VISIT_BABY_NAME_2"
    BIRTH_VISIT_PREFIX   = "BIRTH_VISIT_2"
    BABY_NAME_LI_PREFIX  = "BIRTH_VISIT_LI_BABY_NAME"
    BIRTH_LI_PREFIX      = "BIRTH_VISIT_LI"
    BIRTH_LI_2_PREFIX    = "BIRTH_VISIT_LI_2"
    BIRTH_VISIT_3_PREFIX = "BIRTH_VISIT_3"
    BIRTH_VISIT_4_PREFIX = "BIRTH_VISIT_4"

    BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX = "BIRTH_VISIT_BABY_RACE_NEW_3"
    BIRTH_VISIT_BABY_RACE_1_3_PREFIX   = "BIRTH_VISIT_BABY_RACE_1_3"
    BIRTH_VISIT_BABY_RACE_2_3_PREFIX   = "BIRTH_VISIT_BABY_RACE_2_3"
    BIRTH_VISIT_BABY_RACE_3_3_PREFIX   = "BIRTH_VISIT_BABY_RACE_3_3"

    CHILD_PERSON_MAP = {
      "#{BABY_NAME_PREFIX}.BABY_FNAME"        => "first_name",
      "#{BABY_NAME_PREFIX}.BABY_MNAME"        => "middle_name",
      "#{BABY_NAME_PREFIX}.BABY_LNAME"        => "last_name",
      "#{BABY_NAME_PREFIX}.BABY_SEX"          => "sex_code",

      "#{BABY_NAME_LI_PREFIX}.BABY_FNAME"      => "first_name",
      "#{BABY_NAME_LI_PREFIX}.BABY_MNAME"      => "middle_name",
      "#{BABY_NAME_LI_PREFIX}.BABY_LNAME"      => "last_name",
      "#{BABY_NAME_LI_PREFIX}.BABY_SEX"        => "sex_code",
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

    WORK_ADDRESS_MAP = {
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS1"   => "address_one",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS2"   => "address_two",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_UNIT"       => "unit",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_CITY"       => "city",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_STATE"      => "state_code",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ZIP"        => "zip",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ZIP4"       => "zip4",
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

    INSTITUTION_MAP = {
      "#{BIRTH_VISIT_3_PREFIX}.BIRTH_DELIVER"        => "institute_type_code",
    }

    MODE_OF_CONTACT_MAP = {
      "prepopulated_mode_of_contact" => "prepopulated_mode_of_contact"
    }

    PERSON_RACE_MAP = {
      "#{BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW"     => "race_code",
      "#{BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW_OTH" => "race_other",
      "#{BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1"         => "race_code",
      "#{BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1_OTH"     => "race_other",
      "#{BIRTH_VISIT_BABY_RACE_2_3_PREFIX}.BABY_RACE_2"         => "race_code",
      "#{BIRTH_VISIT_BABY_RACE_3_3_PREFIX}.BABY_RACE_3"         => "race_code"
    }

    def maps
      [
        CHILD_PERSON_MAP,
        PERSON_MAP,
        MAIL_ADDRESS_MAP,
        WORK_ADDRESS_MAP,
        TELEPHONE_MAP,
        HOME_PHONE_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
        INSTITUTION_MAP,
        MODE_OF_CONTACT_MAP,
        PERSON_RACE_MAP
      ]
    end

    def extract_data
      process_person(PERSON_MAP)

      child        = process_child(CHILD_PERSON_MAP)
      mail_address = process_address(person, MAIL_ADDRESS_MAP, Address.mailing_address_type)
      work_address = process_address(person, WORK_ADDRESS_MAP, Address.work_address_type)
      phone        = process_telephone(person, TELEPHONE_MAP)
      home_phone   = process_telephone(person, HOME_PHONE_MAP, Telephone.home_phone_type)
      cell_phone   = process_telephone(person, CELL_PHONE_MAP, Telephone.cell_phone_type)
      email        = process_email(EMAIL_MAP)
      institution  = process_institution(INSTITUTION_MAP, response_set)
      process_person_race(PERSON_RACE_MAP)

      finalize_email(email)
      finalize_addresses(mail_address, work_address)
      finalize_telephones(cell_phone, home_phone, phone)
      finalize_institution(institution)

      update_instrument_mode

      child.save! if child
      participant.save!
      person.save!

    end

  end
end
