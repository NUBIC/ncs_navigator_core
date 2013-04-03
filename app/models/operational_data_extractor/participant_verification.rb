# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class ParticipantVerification < Base

    INTERVIEW_PREFIX = "PARTICIPANT_VERIF"
    INTERVIEW_CHILD_PREFIX = "PARTICIPANT_VERIF_CHILD"

    # TODO: determine how to handle these operational data items
    #
    # RESP_REL_NEW - relationship code for person taking survey and child
    #
    # RESP_GUARD   - if NOT Yes, create person record for child's guardian
    # G_FNAME
    # G_MNAME
    # G_LNAME
    #
    # RESP_PCARE   - if NOT Yes, create person record for child's primary care giver
    # P_FNAME
    # P_MNAME
    # P_LNAME
    # PCARE_REL    - relationship of primary care giver to child
    #
    # OCARE_CHILD  - if NOT Yes, create person record for child's other primary care giver
    # O_FNAME
    # O_MNAME
    # O_LNAME
    # OCARE_REL    - relationship of primary care giver to child
    #

    PERSON_MAP = {
      "#{INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
      "#{INTERVIEW_PREFIX}.R_MNAME"         => "middle_name",
      "#{INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
      "#{INTERVIEW_PREFIX}.MAIDEN_NAME"     => "maiden_name",
      "#{INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
    }

    CHILD_PERSON_MAP = {
      "#{INTERVIEW_CHILD_PREFIX}.C_FNAME"         => "first_name",
      "#{INTERVIEW_CHILD_PREFIX}.C_LNAME"         => "last_name",
      "#{INTERVIEW_CHILD_PREFIX}.CHILD_DOB"       => "person_dob",
      "#{INTERVIEW_CHILD_PREFIX}.CHILD_SEX"       => "sex_code",
    }

    CHILD_ADDRESS_MAP = {
      "#{INTERVIEW_PREFIX}.C_ADDRESS_1"       => "address_one",
      "#{INTERVIEW_PREFIX}.C_ADDRESS_2"       => "address_two",
      "#{INTERVIEW_PREFIX}.C_CITY"            => "city",
      "#{INTERVIEW_PREFIX}.C_STATE"           => "state_code",
      "#{INTERVIEW_PREFIX}.C_ZIP"             => "zip",
      "#{INTERVIEW_PREFIX}.C_ZIP4"            => "zip4"
    }

    CHILD_ADDRESS_2_MAP = {
      "#{INTERVIEW_PREFIX}.S_ADDRESS_1"       => "address_one",
      "#{INTERVIEW_PREFIX}.S_ADDRESS_2"       => "address_two",
      "#{INTERVIEW_PREFIX}.S_CITY"            => "city",
      "#{INTERVIEW_PREFIX}.S_STATE"           => "state_code",
      "#{INTERVIEW_PREFIX}.S_ZIP"             => "zip",
      "#{INTERVIEW_PREFIX}.S_ZIP4"            => "zip4"
    }

    CHILD_PHONE_MAP = {
      "#{INTERVIEW_PREFIX}.PA_PHONE"       => "phone_nbr",
    }

    CHILD_PHONE_2_MAP = {
      "#{INTERVIEW_PREFIX}.SA_PHONE"       => "phone_nbr",
    }

    MODE_OF_CONTACT_MAP = {
      "prepopulated_mode_of_contact" => "prepopulated_mode_of_contact"
    }

    def maps
      [
        PERSON_MAP,
        CHILD_PERSON_MAP,
        CHILD_ADDRESS_MAP,
        CHILD_ADDRESS_2_MAP,
        CHILD_PHONE_MAP,
        CHILD_PHONE_2_MAP,
        MODE_OF_CONTACT_MAP
      ]
    end

    def extract_data
      process_person(PERSON_MAP)

      if child

        process_child(CHILD_PERSON_MAP)

        child_address  = process_address(child, CHILD_ADDRESS_MAP, Address.home_address_type, primary_rank)
        child_address2 = process_address(child, CHILD_ADDRESS_2_MAP, Address.home_address_type, secondary_rank)

        child_phone    = process_telephone(child, CHILD_PHONE_MAP, Telephone.home_phone_type, primary_rank)
        child_phone2   = process_telephone(child, CHILD_PHONE_2_MAP, Telephone.home_phone_type, secondary_rank)

        finalize_addresses(child_address, child_address2)
        finalize_telephones(child_phone, child_phone2)

        update_instrument_mode

        child.save!

      end

      person.save!
    end

  end
end
