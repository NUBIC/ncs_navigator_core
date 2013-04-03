# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PostNatal < Base

    THREE_MONTH_CHILD_SECTION_PREFIX  = "THREE_MTH_MOTHER_CHILD_DETAIL"
    SIX_MONTH_CHILD_SECTION_PREFIX   = "SIX_MTH_MOTHER_DETAIL"
    NINE_MONTH_CHILD_SECTION_PREFIX   = "NINE_MTH_MOTHER_DETAIL"
    TWELVE_MONTH_CHILD_SECTION_PREFIX = "TWELVE_MTH_MOTHER_DETAIL"
    EIGHTEEN_MONTH_CHILD_SECTION_PREFIX = "EIGHTEEN_MTH_MOTHER_DETAIL"
    TWENTY_FOUR_MONTH_CHILD_SECTION_PREFIX = "TWENTY_FOUR_MTH_MOTHER_DETAIL"

    SIX_MONTH_MOTHER_SECTION_PREFIX   = "SIX_MTH_MOTHER"
    TWELVE_MONTH_MOTHER_SECTION_PREFIX = "TWELVE_MTH_MOTHER"
    EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX = "EIGHTEEN_MTH_MOTHER"
    TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX = "TWENTY_FOUR_MTH_MOTHER"

    THREE_MONTH_MOTHER_RACE_PREFIX = "THREE_MTH_MOTHER_RACE"

    CHILD_PERSON_NAME_MAP = {
      "#{THREE_MONTH_CHILD_SECTION_PREFIX}.C_FNAME"       =>"first_name",
      "#{THREE_MONTH_CHILD_SECTION_PREFIX}.C_LNAME"       =>"last_name",
      "#{SIX_MONTH_CHILD_SECTION_PREFIX}.C_FNAME"       =>"first_name",
      "#{SIX_MONTH_CHILD_SECTION_PREFIX}.C_LNAME"       =>"last_name",
      "#{NINE_MONTH_CHILD_SECTION_PREFIX}.C_FNAME"       =>"first_name",
      "#{NINE_MONTH_CHILD_SECTION_PREFIX}.C_LNAME"       =>"last_name",
      "#{TWELVE_MONTH_CHILD_SECTION_PREFIX}.C_FNAME"       =>"first_name",
      "#{TWELVE_MONTH_CHILD_SECTION_PREFIX}.C_LNAME"       =>"last_name",
      "#{EIGHTEEN_MONTH_CHILD_SECTION_PREFIX}.C_FNAME"       =>"first_name",
      "#{EIGHTEEN_MONTH_CHILD_SECTION_PREFIX}.C_LNAME"       =>"last_name",
      "#{TWENTY_FOUR_MONTH_CHILD_SECTION_PREFIX}.C_FNAME"       =>"first_name",
      "#{TWENTY_FOUR_MONTH_CHILD_SECTION_PREFIX}.C_LNAME"       =>"last_name",
    }

    CHILD_PERSON_DATE_OF_BIRTH_MAP = {
      "#{THREE_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB"     =>"person_dob",
      "#{SIX_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB"     =>"person_dob",
      "#{NINE_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB"     =>"person_dob",
      "#{TWELVE_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB"     =>"person_dob",
      "#{EIGHTEEN_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB"     =>"person_dob",
      "#{TWENTY_FOUR_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB"     =>"person_dob",
    }

    EMAIL_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.EMAIL"           => "email",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.EMAIL"           => "email",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.EMAIL"           => "email",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.EMAIL"           => "email",
    }

    CELL_PHONE_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_1"    => "cell_permission_code",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE"      => "phone_nbr",

      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_1"    => "cell_permission_code",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE"      => "phone_nbr",

      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_1"    => "cell_permission_code",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE"      => "phone_nbr",

      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_1"    => "cell_permission_code",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE"      => "phone_nbr",
    }

    CONTACT_1_PERSON_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_1"     => "last_name",

      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_1"     => "last_name",

      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_1"     => "last_name",

      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_1"     => "first_name",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_1"     => "last_name",
    }

    CONTACT_1_RELATIONSHIP_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",

      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",

      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",

      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
    }

    CONTACT_1_ADDRESS_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_1"          => "address_one",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_1"          => "address_two",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_1"            => "unit",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_1"            => "city",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_1"           => "state_code",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_1"             => "zip",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_1"            => "zip4",

      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_1"          => "address_one",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_1"          => "address_two",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_1"            => "unit",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_1"            => "city",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_1"           => "state_code",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_1"             => "zip",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_1"            => "zip4",

      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_1"          => "address_one",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_1"          => "address_two",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_1"            => "unit",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_1"            => "city",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_1"           => "state_code",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_1"             => "zip",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_1"            => "zip4",

      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_1"          => "address_one",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_1"          => "address_two",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_1"            => "unit",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_1"            => "city",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_1"           => "state_code",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_1"             => "zip",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_1"            => "zip4",
    }

    CONTACT_1_PHONE_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
    }

    CONTACT_2_PERSON_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_2"     => "last_name",

      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_2"     => "last_name",

      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_2"     => "last_name",

      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_2"     => "first_name",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_2"     => "last_name",
    }

    CONTACT_2_RELATIONSHIP_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",

      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",

      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",

      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
    }

    CONTACT_2_ADDRESS_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_2"          => "address_one",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_2"            => "unit",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_2"            => "city",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_2"           => "state_code",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_2"             => "zip",
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_2"            => "zip4",

      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_2"          => "address_one",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_2"            => "unit",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_2"            => "city",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_2"           => "state_code",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_2"             => "zip",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_2"            => "zip4",

      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_2"          => "address_one",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_2"            => "unit",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_2"            => "city",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_2"           => "state_code",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_2"             => "zip",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_2"            => "zip4",

      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_2"          => "address_one",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_2"          => "address_two",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_2"            => "unit",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_2"            => "city",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_2"           => "state_code",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_2"             => "zip",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_2"            => "zip4",
    }

    CONTACT_2_PHONE_MAP = {
      "#{SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
      "#{TWELVE_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
      "#{EIGHTEEN_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
      "#{TWENTY_FOUR_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
    }

    PERSON_RACE_MAP = {
      "#{THREE_MONTH_MOTHER_RACE_PREFIX}.RACE"  => "race_code",
      "#{THREE_MONTH_MOTHER_RACE_PREFIX}.RACE_OTH"  => "race_other",
    }

    def maps
      [
        CHILD_PERSON_NAME_MAP,
        CHILD_PERSON_DATE_OF_BIRTH_MAP,
        EMAIL_MAP,
        CELL_PHONE_MAP,
        CONTACT_1_PERSON_MAP,
        CONTACT_1_RELATIONSHIP_MAP,
        CONTACT_1_ADDRESS_MAP,
        CONTACT_1_PHONE_MAP,
        CONTACT_2_PERSON_MAP,
        CONTACT_2_RELATIONSHIP_MAP,
        CONTACT_2_ADDRESS_MAP,
        CONTACT_2_PHONE_MAP,
        PERSON_RACE_MAP
      ]
    end

    def extract_data
      if child
        process_child(CHILD_PERSON_NAME_MAP)
        process_child_dob(CHILD_PERSON_DATE_OF_BIRTH_MAP)
        child.save!
      end

      email = process_email(EMAIL_MAP)
      cell_phone   = process_telephone(person, CELL_PHONE_MAP, Telephone.cell_phone_type)

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

      process_person_race(PERSON_RACE_MAP)

      finalize_contact(contact1, contact1relationship, contact1address, contact1phone)
      finalize_contact(contact2, contact2relationship, contact2address, contact2phone)

      finalize_email(email)
      finalize_telephones(cell_phone)

      child.save! if child
      participant.save!
      person.save!
    end

    # overridden method
    def process_email(map)
      info_source  = NcsCode.for_list_name_and_local_code("INFORMATION_SOURCE_CL2", 1)
      type_email   = NcsCode.for_list_name_and_local_code('EMAIL_TYPE_CL1', 1)
      email_share  = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
      email_active = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)

      email = nil
      map.each do |key, attribute|

        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            email ||= Email.where(:response_set_id => response_set.id).first
            if email.nil?
              email = Email.new(:person => person,
                                :psu => person.psu,
                                :response_set => response_set,
                                :email_rank => primary_rank,
                                :email_type => type_email,
                                :email_share => email_share,
                                :email_active => email_active,
                                :email_info_source => info_source)
            end
          end
          set_value(email, attribute, response_value(r))
        end
      end
      email
    end
  end
end
