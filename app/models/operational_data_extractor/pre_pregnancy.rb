# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PrePregnancy < Base

    INTERVIEW_PREFIX = "PRE_PREG"

    PERSON_MAP = {
      "#{INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
      "#{INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
      "#{INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
      "#{INTERVIEW_PREFIX}.MARISTAT"        => "marital_status_code"
    }

    CELL_PHONE_MAP = {
      "#{INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr"
    }

    EMAIL_MAP = {
      "#{INTERVIEW_PREFIX}.EMAIL"           => "email"
    }

    CONTACT_1_PERSON_MAP = {
      "#{INTERVIEW_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{INTERVIEW_PREFIX}.CONTACT_LNAME_1"     => "last_name",
    }

    CONTACT_1_RELATIONSHIP_MAP = {
      "#{INTERVIEW_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{INTERVIEW_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
    }

    CONTACT_1_ADDRESS_MAP = {
      "#{INTERVIEW_PREFIX}.C_ADDR_1_1"          => "address_one",
      "#{INTERVIEW_PREFIX}.C_ADDR_2_1"          => "address_two",
      "#{INTERVIEW_PREFIX}.C_UNIT_1"            => "unit",
      "#{INTERVIEW_PREFIX}.C_CITY_1"            => "city",
      "#{INTERVIEW_PREFIX}.C_STATE_1"           => "state_code",
      "#{INTERVIEW_PREFIX}.C_ZIP_1"             => "zip",
      "#{INTERVIEW_PREFIX}.C_ZIP4_1"            => "zip4",
    }

    CONTACT_1_PHONE_MAP = {
      "#{INTERVIEW_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
    }

    CONTACT_2_PERSON_MAP = {
      "#{INTERVIEW_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{INTERVIEW_PREFIX}.CONTACT_LNAME_2"     => "last_name",
    }

    CONTACT_2_RELATIONSHIP_MAP = {
      "#{INTERVIEW_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{INTERVIEW_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
    }

    CONTACT_2_ADDRESS_MAP = {
      "#{INTERVIEW_PREFIX}.C_ADDR_1_2"          => "address_one",
      "#{INTERVIEW_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{INTERVIEW_PREFIX}.C_UNIT_2"            => "unit",
      "#{INTERVIEW_PREFIX}.C_CITY_2"            => "city",
      "#{INTERVIEW_PREFIX}.C_STATE_2"           => "state_code",
      "#{INTERVIEW_PREFIX}.C_ZIP_2"             => "zip",
      "#{INTERVIEW_PREFIX}.C_ZIP4_2"            => "zip4",
    }

    CONTACT_2_PHONE_MAP = {
      "#{INTERVIEW_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
    }

    def maps
      [
        PERSON_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
        CONTACT_1_PERSON_MAP,
        CONTACT_1_RELATIONSHIP_MAP,
        CONTACT_1_ADDRESS_MAP,
        CONTACT_1_PHONE_MAP,
        CONTACT_2_PERSON_MAP,
        CONTACT_2_RELATIONSHIP_MAP,
        CONTACT_2_ADDRESS_MAP,
        CONTACT_2_PHONE_MAP
      ]
    end


    def extract_data
      process_person(PERSON_MAP)
      cell_phone = process_telephone(person, CELL_PHONE_MAP, Telephone.cell_phone_type)
      email = process_email(EMAIL_MAP)

      if contact1 = process_contact(CONTACT_1_PERSON_MAP)
        contact1relationship = process_contact_relationship(contact1, CONTACT_1_RELATIONSHIP_MAP)
        contact1address = process_address(contact1, CONTACT_1_ADDRESS_MAP, Address.home_address_type)
        contact1phone = process_telephone(contact1, CONTACT_1_PHONE_MAP)
      end

      if contact2 = process_contact(CONTACT_2_PERSON_MAP)
        contact2relationship = process_contact_relationship(contact2, CONTACT_2_RELATIONSHIP_MAP)
        contact2address = process_address(contact2, CONTACT_2_ADDRESS_MAP, Address.home_address_type)
        contact2phone = process_telephone(contact2, CONTACT_2_PHONE_MAP)
      end

      finalize_contact(contact1, contact1relationship, contact1address, contact1phone)
      finalize_contact(contact2, contact2relationship, contact2address, contact2phone)

      finalize_email(email)
      finalize_telephones(cell_phone)

      person.save!

    end

  end

end
