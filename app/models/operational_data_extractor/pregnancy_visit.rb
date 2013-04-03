# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PregnancyVisit < Base
    PREGNANCY_VISIT_1_INTERVIEW_PREFIX    = "PREG_VISIT_1"
    PREGNANCY_VISIT_2_INTERVIEW_PREFIX    = "PREG_VISIT_2"
    PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX  = "PREG_VISIT_1_2"
    PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX  = "PREG_VISIT_2_2"
    PREGNANCY_VISIT_1_SAQ_PREFIX          = "PREG_VISIT_1_SAQ_2"
    PREGNANCY_VISIT_1_SAQ_2_PREFIX        = "PREG_VISIT_1_SAQ_2"
    PREGNANCY_VISIT_1_SAQ_3_PREFIX        = "PREG_VISIT_1_SAQ_3"
    PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX  = "PREG_VISIT_1_3"
    PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX  = "PREG_VISIT_2_3"

    PREG_VISIT_1_RACE_NEW_3_INTERVIEW_PREFIX = "PREG_VISIT_1_RACE_NEW_3"
    PREG_VISIT_1_RACE_1_3_INTERVIEW_PREFIX   = "PREG_VISIT_1_RACE_1_3"
    PREG_VISIT_1_RACE_2_3_INTERVIEW_PREFIX   = "PREG_VISIT_1_RACE_2_3"
    PREG_VISIT_1_RACE_3_3_INTERVIEW_PREFIX   = "PREG_VISIT_1_RACE_3_3"

    PERSON_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_FNAME"           => "first_name",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_LNAME"           => "last_name",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.PERSON_DOB"        => "person_dob",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.R_FNAME"           => "first_name",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.R_LNAME"           => "last_name",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.PERSON_DOB"        => "person_dob",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
    }

    PARTICIPANT_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.AGE_ELIG"          => "pid_age_eligibility_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.AGE_ELIG"          => "pid_age_eligibility_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.AGE_ELIG"        => "pid_age_eligibility_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.AGE_ELIG"        => "pid_age_eligibility_code"
    }

    PPG_STATUS_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.DUE_DATE"          => "orig_due_date",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.DUE_DATE"          => "orig_due_date",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.DUE_DATE"        => "orig_due_date",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.DUE_DATE"        => "orig_due_date",
    }

    CELL_PHONE_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_2"      => "cell_permission_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_4"      => "text_permission_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE"        => "phone_nbr",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CELL_PHONE_2"      => "cell_permission_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CELL_PHONE_4"      => "text_permission_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CELL_PHONE"        => "phone_nbr",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr"
    }

    EMAIL_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.EMAIL"             => "email",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.EMAIL"             => "email",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.EMAIL"           => "email",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.EMAIL"           => "email",
    }

    CONTACT_1_PERSON_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1"       => "first_name",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1"       => "first_name",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_LNAME_1"       => "last_name",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_LNAME_1"       => "last_name",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_LNAME_1"     => "last_name",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_LNAME_1"     => "last_name",
    }

    CONTACT_1_RELATIONSHIP_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1"      => "relationship_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE1_OTH"   => "relationship_other",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE_1"      => "relationship_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE1_OTH"   => "relationship_other",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
    }

    CONTACT_1_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR1_1"           => "address_one",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR2_1"           => "address_two",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_1"            => "unit",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_1"            => "city",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_1"           => "state_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIPCODE_1"         => "zip",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_1"            => "zip4",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR1_1"           => "address_one",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR2_1"           => "address_two",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_UNIT_1"            => "unit",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_CITY_1"            => "city",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_STATE_1"           => "state_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIPCODE_1"         => "zip",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIP4_1"            => "zip4",

      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ADDR_1_1"          => "address_one",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ADDR_2_1"          => "address_two",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_UNIT_1"            => "unit",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_CITY_1"            => "city",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_STATE_1"           => "state_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ZIPCODE_1"             => "zip",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ZIP4_1"            => "zip4",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ADDR_1_1"          => "address_one",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ADDR_2_1"          => "address_two",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_UNIT_1"            => "unit",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_CITY_1"            => "city",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_STATE_1"           => "state_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ZIPCODE_1"         => "zip",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ZIP4_1"            => "zip4",
    }

    CONTACT_1_PHONE_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_1"       => "phone_nbr",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_PHONE_1"       => "phone_nbr",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
    }

    CONTACT_2_PERSON_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_2"       => "first_name",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_2"       => "last_name",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_FNAME_2"       => "first_name",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_LNAME_2"       => "last_name",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_LNAME_2"     => "last_name",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_LNAME_2"     => "last_name",
    }

    CONTACT_2_RELATIONSHIP_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_2"      => "relationship_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE2_OTH"   => "relationship_other",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE_2"      => "relationship_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE2_OTH"   => "relationship_other",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
    }

    CONTACT_2_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_1_2"            => "address_one",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_2_2"            => "address_two",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_2"              => "unit",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_2"              => "city",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_2"             => "state_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIPCODE_2"           => "zip",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_2"              => "zip4",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR_1_2"            => "address_one",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR_2_2"            => "address_two",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_UNIT_2"              => "unit",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_CITY_2"              => "city",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_STATE_2"             => "state_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIPCODE_2"           => "zip",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIP4_2"              => "zip4",

      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ADDR_1_2"          => "address_one",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_UNIT_2"            => "unit",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_CITY_2"            => "city",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_STATE_2"           => "state_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ZIPCODE_2"         => "zip",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.C_ZIP4_2"            => "zip4",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ADDR_1_2"          => "address_one",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_UNIT_2"            => "unit",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_CITY_2"            => "city",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_STATE_2"           => "state_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ZIPCODE_2"         => "zip",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.C_ZIP4_2"            => "zip4",
    }

    CONTACT_2_PHONE_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_2"       => "phone_nbr",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_PHONE_2"       => "phone_nbr",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
    }

    BIRTH_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDRESS_1"         => "address_one",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDRESS_2"         => "address_two",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_CITY"              => "city",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_STATE"             => "state_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ZIPCODE"           => "zip",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.B_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.B_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.B_CITY"            => "city",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.B_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.B_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_CITY"            => "city",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.B_ADDRESS_1"         => "address_one",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.B_ADDRESS_2"         => "address_two",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.B_CITY"              => "city",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.B_STATE"             => "state_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.B_ZIPCODE"           => "zip",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.B_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.B_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.B_CITY"            => "city",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.B_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.B_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_CITY"            => "city",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ZIPCODE"         => "zip",
    }

    FATHER_PERSON_MAP = {
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.FATHER_NAME"       => "full_name",
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.FATHER_AGE"        => "age",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.FATHER_NAME"       => "full_name",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.FATHER_AGE"        => "age",
    }

    FATHER_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_ADDR1_2"           => "address_one",
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_ADDR_2_2"          => "address_two",
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_UNIT_2"            => "unit",
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_CITY_2"            => "city",
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_STATE_2"           => "state_code",
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_ZIPCODE_2"         => "zip",
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_ZIP4_2"            => "zip4",

      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_ADDR1_3"           => "address_one",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_ADDR_2_3"          => "address_two",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_UNIT_3"            => "unit",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_CITY_3"            => "city",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_STATE_3"           => "state_code",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_ZIPCODE_3"         => "zip",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_ZIP4_3"            => "zip4",
    }

    WORK_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_UNIT"            => "unit",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_CITY"            => "city",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ZIP"             => "zip",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ZIP4"            => "zip4",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_UNIT"            => "unit",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_CITY"            => "city",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ZIP4"            => "zip4",
    }

    CONFIRM_WORK_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_UNIT"            => "unit",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_CITY"            => "city",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ZIP4"            => "zip4",
    }

    FATHER_PHONE_MAP = {
      "#{PREGNANCY_VISIT_1_SAQ_2_PREFIX}.F_PHONE"           => "phone_nbr",
      "#{PREGNANCY_VISIT_1_SAQ_3_PREFIX}.F_PHONE"           => "phone_nbr",
    }

    DUE_DATE_DETERMINER_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.DATE_PERIOD"     => "DATE_PERIOD",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.DATE_PERIOD"   => "DATE_PERIOD",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DATE_PERIOD"   => "DATE_PERIOD",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.DUE_DATE"      => "DUE_DATE",
    }

    INSTITUTION_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.BIRTH_PLAN"          => "institute_type_code",
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.BIRTH_PLACE"         => "institute_name",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.BIRTH_PLAN"          => "institute_type_code",
      "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.BIRTH_PLACE"         => "institute_name",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.BIRTH_PLAN"        => "institute_type_code",
      "#{PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX}.BIRTH_PLACE"       => "institute_name",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.BIRTH_PLAN"        => "institute_type_code",
      "#{PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX}.BIRTH_PLACE"       => "institute_name",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN"        => "institute_type_code",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLACE"       => "institute_name",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.BIRTH_PLAN"        => "institute_type_code",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.BIRTH_PLACE"       => "institute_name",
    }

    MODE_OF_CONTACT_MAP = {
      "prepopulated_mode_of_contact" => "prepopulated_mode_of_contact"
    }

    PERSON_RACE_MAP = {
      "#{PREG_VISIT_1_RACE_NEW_3_INTERVIEW_PREFIX}.RACE_NEW"        => "race_code",
      "#{PREG_VISIT_1_RACE_NEW_3_INTERVIEW_PREFIX}.RACE_NEW_OTH"    => "race_other",
      "#{PREG_VISIT_1_RACE_1_3_INTERVIEW_PREFIX}.RACE_1"            => "race_code",
      "#{PREG_VISIT_1_RACE_1_3_INTERVIEW_PREFIX}.RACE_1_OTH"        => "race_other",
      "#{PREG_VISIT_1_RACE_2_3_INTERVIEW_PREFIX}.RACE_2"            => "race_code",
      "#{PREG_VISIT_1_RACE_3_3_INTERVIEW_PREFIX}.RACE_3"            => "race_code"
    }

    def maps
      [
        PERSON_MAP,
        PARTICIPANT_MAP,
        PPG_STATUS_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
        CONTACT_1_PERSON_MAP,
        CONTACT_1_RELATIONSHIP_MAP,
        CONTACT_1_ADDRESS_MAP,
        CONTACT_1_PHONE_MAP,
        CONTACT_2_PERSON_MAP,
        CONTACT_2_RELATIONSHIP_MAP,
        CONTACT_2_ADDRESS_MAP,
        CONTACT_2_PHONE_MAP,
        BIRTH_ADDRESS_MAP,
        FATHER_PERSON_MAP,
        FATHER_ADDRESS_MAP,
        WORK_ADDRESS_MAP,
        CONFIRM_WORK_ADDRESS_MAP,
        FATHER_PHONE_MAP,
        DUE_DATE_DETERMINER_MAP,
        INSTITUTION_MAP,
        MODE_OF_CONTACT_MAP,
        PERSON_RACE_MAP
      ]
    end

    def extract_data
      process_person(PERSON_MAP)
      process_ppg_status(PPG_STATUS_MAP)
      cell_phone = process_telephone(person, CELL_PHONE_MAP, Telephone.cell_phone_type)
      email = process_email(EMAIL_MAP)
      birth_address, institution = process_birth_institution_and_address(BIRTH_ADDRESS_MAP, INSTITUTION_MAP)

      work_address = process_address(person, WORK_ADDRESS_MAP, Address.work_address_type)
      confirm_work_address = process_address(person, CONFIRM_WORK_ADDRESS_MAP, Address.work_address_type, duplicate_rank)

      if contact1 = process_contact(CONTACT_1_PERSON_MAP)
        contact1relationship = process_contact_relationship(contact1, CONTACT_1_RELATIONSHIP_MAP)
        contact1address = process_address(contact1, CONTACT_1_ADDRESS_MAP, Address.home_address_type)
        contact1phone = process_telephone(contact1, CONTACT_1_PHONE_MAP, Telephone.home_phone_type)
      end

      if contact2 = process_contact(CONTACT_2_PERSON_MAP)
        contact2relationship = process_contact_relationship(contact2, CONTACT_2_RELATIONSHIP_MAP)
        contact2address = process_address(contact2, CONTACT_2_ADDRESS_MAP, Address.home_address_type)
        contact2phone = process_telephone(contact2, CONTACT_2_PHONE_MAP, Telephone.home_phone_type)
      end

      finalize_contact(contact1, contact1relationship, contact1address, contact1phone)
      finalize_contact(contact2, contact2relationship, contact2address, contact2phone)

      father, father_relationship = process_father(FATHER_PERSON_MAP)
      if father
        father_address = process_address(father, FATHER_ADDRESS_MAP, Address.home_address_type)
        father_phone = process_telephone(father, FATHER_PHONE_MAP)
      end

      process_person_race(PERSON_RACE_MAP)

      set_due_date(DUE_DATE_DETERMINER_MAP)

      finalize_father(father, father_relationship, father_address, father_phone)

      finalize_contact(contact1, contact1relationship, contact1address, contact1phone)
      finalize_contact(contact2, contact2relationship, contact2address, contact2phone)

      finalize_email(email)

      finalize_addresses(birth_address, work_address, confirm_work_address)
      finalize_telephones(cell_phone)
      finalize_institution_with_birth_address(birth_address, institution)

      if due_date = calculated_due_date(response_set)
        participant.ppg_details.first.update_due_date(due_date)
      end

      update_instrument_mode

      participant.save!
      person.save!

    end

    # TODO: PBS eligibility operational data extractor has similar methods to get the due date
    #      Extract methods to some common module
    def calculated_due_date(response_set)
      # try due date first
      ret = nil
      ret = due_date_response(response_set, "DUE_DATE", PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX)
      ret
    end

    def response_for(response_set, data_export_identifier)
      response_set.responses.includes(:question).where(
        "questions.data_export_identifier = ?", data_export_identifier).first
    end

    def get_due_date_attribute(data_export_identifier)
      dei = data_export_identifier

      if dei.start_with?(PREGNANCY_VISIT_2_2_INTERVIEW_PREFIX) || dei.start_with?(PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX)
        :due_date_3
      else
        :due_date_2
      end
    end

    def set_due_date(map)
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)

          unless value.blank?
            dt = nil
            begin
              dt = Date.parse(value)
            rescue
              # NOOP - date is unparseable
            end

            if dt
              if due_date = determine_due_date(attribute, r, dt)
                due_date_attr = get_due_date_attribute(key)
                participant.ppg_details.first.update_due_date(
                  due_date, due_date_attr)
              end
            end
          end
        end
      end
    end
    private :set_due_date
  end
end
