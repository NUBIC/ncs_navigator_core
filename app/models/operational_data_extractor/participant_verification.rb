# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class ParticipantVerification < Base

    INTERVIEW_PREFIX = "PARTICIPANT_VERIF"

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
      "#{INTERVIEW_PREFIX}.C_FNAME"         => "first_name",
      "#{INTERVIEW_PREFIX}.C_LNAME"         => "last_name",
      "#{INTERVIEW_PREFIX}.CHILD_DOB"       => "person_dob",
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

    def initialize(response_set)
      super(response_set)
    end

    def maps
      [
        PERSON_MAP,
        CHILD_PERSON_MAP,
        CHILD_ADDRESS_MAP,
        CHILD_ADDRESS_2_MAP,
        CHILD_PHONE_MAP,
        CHILD_PHONE_2_MAP
      ]
    end

    def extract_data
      person = response_set.person
      participant = response_set.participant

      # For surveys that update the child - the participant on the response_set
      # should be the child participant and thus the person being updated is the
      # child participant.person
      child          = participant.person
      child_phone    = nil
      child_phone2   = nil
      child_address  = nil
      child_address2 = nil

      PERSON_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          set_value(person, attribute, response_value(r))
        end
      end

      if child
        CHILD_PERSON_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            set_value(child, attribute, response_value(r))
          end
        end

        CHILD_ADDRESS_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              child_address ||= get_address(response_set, child, Address.home_address_type, primary_rank)
              set_value(child_address, attribute, value)
            end
          end
        end

        CHILD_ADDRESS_2_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              child_address2 ||= get_address(response_set, child, Address.home_address_type, secondary_rank)
              set_value(child_address2, attribute, value)
            end
          end
        end

        CHILD_PHONE_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              child_phone ||= get_telephone(response_set, child, Telephone.home_phone_type, primary_rank)
              set_value(child_phone, attribute, value)
            end
          end
        end

        CHILD_PHONE_2_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              child_phone2 ||= get_telephone(response_set, child, Telephone.home_phone_type, secondary_rank)
              set_value(child_phone2, attribute, value)
            end
          end
        end
      end

      if child
        child.save!

        child_phone.save! unless child_phone.try(:phone_nbr).blank?
        child_phone2.save! unless child_phone2.try(:phone_nbr).blank?
        child_address.save! unless child_address.to_s.blank?
        child_address2.save! unless child_address2.to_s.blank?
      end

      person.save!
    end

  end
end