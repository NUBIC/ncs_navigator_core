# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class TracingModule < Base

    TRACING_MODULE_PREFIX = "TRACING_INT"

    ADDRESS_MAP = {
      "#{TRACING_MODULE_PREFIX}.ADDRESS_1"       => "address_one",
      "#{TRACING_MODULE_PREFIX}.ADDRESS_2"       => "address_two",
      "#{TRACING_MODULE_PREFIX}.UNIT"            => "unit",
      "#{TRACING_MODULE_PREFIX}.CITY"            => "city",
      "#{TRACING_MODULE_PREFIX}.STATE"           => "state_code",
      "#{TRACING_MODULE_PREFIX}.ZIP"             => "zip",
      "#{TRACING_MODULE_PREFIX}.ZIP4"            => "zip4"
    }

    NEW_ADDRESS_MAP = {
      "#{TRACING_MODULE_PREFIX}.NEW_ADDRESS1"   => "address_one",
      "#{TRACING_MODULE_PREFIX}.NEW_ADDRESS2"   => "address_two",
      "#{TRACING_MODULE_PREFIX}.NEW_UNIT"       => "unit",
      "#{TRACING_MODULE_PREFIX}.NEW_CITY"       => "city",
      "#{TRACING_MODULE_PREFIX}.NEW_STATE"      => "state_code",
      "#{TRACING_MODULE_PREFIX}.NEW_ZIP"        => "zip",
      "#{TRACING_MODULE_PREFIX}.NEW_ZIP4"       => "zip4"
    }

    HOME_PHONE_MAP = {
      "#{TRACING_MODULE_PREFIX}.HOME_PHONE"      => "phone_nbr",
    }

    CELL_PHONE_MAP = {
      "#{TRACING_MODULE_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{TRACING_MODULE_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{TRACING_MODULE_PREFIX}.CELL_PHONE"      => "phone_nbr",
    }

    EMAIL_MAP = {
      "#{TRACING_MODULE_PREFIX}.EMAIL"           => "email",
    }

    CONTACT_1_PERSON_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{TRACING_MODULE_PREFIX}.CONTACT_LNAME_1"     => "last_name",
    }

    CONTACT_1_RELATIONSHIP_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
    }

    CONTACT_1_ADDRESS_MAP = {
      "#{TRACING_MODULE_PREFIX}.C_ADDR1_1"           => "address_one",
      "#{TRACING_MODULE_PREFIX}.C_ADDR2_1"           => "address_two",
      "#{TRACING_MODULE_PREFIX}.C_UNIT_1"            => "unit",
      "#{TRACING_MODULE_PREFIX}.C_CITY_1"            => "city",
      "#{TRACING_MODULE_PREFIX}.C_STATE_1"           => "state_code",
      "#{TRACING_MODULE_PREFIX}.C_ZIPCODE_1"         => "zip",
      "#{TRACING_MODULE_PREFIX}.C_ZIP4_1"            => "zip4",
    }

    CONTACT_1_PHONE_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE_1"           => "phone_nbr",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_1"     => "phone_type_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_1_OTH" => "phone_type_other",
    }

    CONTACT_1_PHONE_2_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE_2_1"         => "phone_nbr",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_1"     => "phone_type_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_1_OTH" => "phone_type_other",
    }

    CONTACT_2_PERSON_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{TRACING_MODULE_PREFIX}.CONTACT_LNAME_2"     => "last_name",
    }

    CONTACT_2_RELATIONSHIP_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
    }

    CONTACT_2_ADDRESS_MAP = {
      "#{TRACING_MODULE_PREFIX}.C_ADDR1_2"           => "address_one",
      "#{TRACING_MODULE_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{TRACING_MODULE_PREFIX}.C_UNIT_2"            => "unit",
      "#{TRACING_MODULE_PREFIX}.C_CITY_2"            => "city",
      "#{TRACING_MODULE_PREFIX}.C_STATE_2"           => "state_code",
      "#{TRACING_MODULE_PREFIX}.C_ZIPCODE_2"         => "zip",
      "#{TRACING_MODULE_PREFIX}.C_ZIP4_2"            => "zip4",
    }

    CONTACT_2_PHONE_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE_2"           => "phone_nbr",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_2"     => "phone_type_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_2_OTH" => "phone_type_other",
    }

    CONTACT_2_PHONE_2_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE_2_2"         => "phone_nbr",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_2"     => "phone_type_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_2_OTH" => "phone_type_other",
    }

    CONTACT_3_PERSON_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_FNAME_3"     => "first_name",
      "#{TRACING_MODULE_PREFIX}.CONTACT_LNAME_3"     => "last_name",
    }

    CONTACT_3_RELATIONSHIP_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_RELATE_3"    => "relationship_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_RELATE3_OTH" => "relationship_other",
    }

    CONTACT_3_ADDRESS_MAP = {
      "#{TRACING_MODULE_PREFIX}.C_ADDR1_3"           => "address_one",
      "#{TRACING_MODULE_PREFIX}.C_ADDR_2_3"          => "address_two",
      "#{TRACING_MODULE_PREFIX}.C_UNIT_3"            => "unit",
      "#{TRACING_MODULE_PREFIX}.C_CITY_3"            => "city",
      "#{TRACING_MODULE_PREFIX}.C_STATE_3"           => "state_code",
      "#{TRACING_MODULE_PREFIX}.C_ZIPCODE_3"         => "zip",
      "#{TRACING_MODULE_PREFIX}.C_ZIP4_3"            => "zip4",
    }

    CONTACT_3_PHONE_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE_3"           => "phone_nbr",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_3"     => "phone_type_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_3_OTH" => "phone_type_other",
    }

    CONTACT_3_PHONE_2_MAP = {
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE_2_3"         => "phone_nbr",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_3"     => "phone_type_code",
      "#{TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_3_OTH" => "phone_type_other",
    }

    MODE_OF_CONTACT_MAP = {
      "prepopulated_mode_of_contact" => "prepopulated_mode_of_contact"
    }

    def maps
      [
        ADDRESS_MAP,
        NEW_ADDRESS_MAP,
        HOME_PHONE_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
        CONTACT_1_PERSON_MAP,
        CONTACT_1_RELATIONSHIP_MAP,
        CONTACT_1_ADDRESS_MAP,
        CONTACT_1_PHONE_MAP,
        CONTACT_1_PHONE_2_MAP,
        CONTACT_2_PERSON_MAP,
        CONTACT_2_RELATIONSHIP_MAP,
        CONTACT_2_ADDRESS_MAP,
        CONTACT_2_PHONE_MAP,
        CONTACT_2_PHONE_2_MAP,
        CONTACT_3_PERSON_MAP,
        CONTACT_3_RELATIONSHIP_MAP,
        CONTACT_3_ADDRESS_MAP,
        CONTACT_3_PHONE_MAP,
        CONTACT_3_PHONE_2_MAP,
        MODE_OF_CONTACT_MAP
      ]
    end

    def extract_data
      address = process_address(person, ADDRESS_MAP, Address.home_address_type)
      new_address = process_address(person, NEW_ADDRESS_MAP, Address.home_address_type)

      home_phone   = process_telephone(person, HOME_PHONE_MAP, Telephone.home_phone_type)
      cell_phone   = process_telephone(person, CELL_PHONE_MAP, Telephone.cell_phone_type)

      email        = process_email(EMAIL_MAP)

      if contact1 = process_contact(CONTACT_1_PERSON_MAP)
        contact1relationship = process_contact_relationship(contact1, CONTACT_1_RELATIONSHIP_MAP)
        contact1address = process_address(contact1, CONTACT_1_ADDRESS_MAP, Address.home_address_type)
        contact1phone = process_telephone(contact1, CONTACT_1_PHONE_MAP)
        contact1phone2 = process_telephone(contact1, CONTACT_1_PHONE_2_MAP, Telephone.cell_phone_type)
      end

      if contact2 = process_contact(CONTACT_2_PERSON_MAP)
        contact2relationship = process_contact_relationship(contact2, CONTACT_2_RELATIONSHIP_MAP)
        contact2address = process_address(contact2, CONTACT_2_ADDRESS_MAP, Address.home_address_type)
        contact2phone = process_telephone(contact2, CONTACT_2_PHONE_MAP)
        contact2phone2 = process_telephone(contact2, CONTACT_2_PHONE_2_MAP)
      end

      if contact3 = process_contact(CONTACT_3_PERSON_MAP)
        contact3relationship = process_contact_relationship(contact3, CONTACT_3_RELATIONSHIP_MAP)
        contact3address = process_address(contact3, CONTACT_3_ADDRESS_MAP, Address.home_address_type)
        contact3phone = process_telephone(contact3, CONTACT_3_PHONE_MAP)
        contact3phone2 = process_telephone(contact3, CONTACT_3_PHONE_2_MAP)
      end

      finalize_contact(contact1, contact1relationship, contact1address, contact1phone, contact1phone2)
      finalize_contact(contact2, contact2relationship, contact2address, contact2phone, contact2phone2)
      finalize_contact(contact3, contact3relationship, contact3address, contact3phone, contact3phone2)

      finalize_email(email)
      finalize_addresses(address, new_address)
      finalize_telephones(cell_phone, home_phone)

      update_instrument_mode

      participant.save! if participant
      person.save!
    end

  end
end
