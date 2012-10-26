# -*- coding: utf-8 -*-


class OperationalDataExtractor::ParticipantVerification

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


  class << self

    def extract_data(response_set)
      person = response_set.person
      participant = response_set.participant

      primary_rank = OperationalDataExtractor::Base.primary_rank
      secondary_rank = OperationalDataExtractor::Base.secondary_rank

      child          = nil
      child_phone    = nil
      child_phone2   = nil
      child_address  = nil
      child_address2 = nil

      response_set.responses.each do |r|

        value = OperationalDataExtractor::Base.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          OperationalDataExtractor::Base.set_value(person, PERSON_MAP[data_export_identifier], value)
        end

        if CHILD_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            if child.nil?
              child = Person.new(:psu => person.psu)
            end
            OperationalDataExtractor::Base.set_value(child, CHILD_PERSON_MAP[data_export_identifier], value)
          end
        end

        if CHILD_ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            child_address ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.home_address_type.local_code).first
            if child_address.nil?
              child_address = Address.new(:person => child, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                         :address_type => Address.home_address_type, :response_set => response_set, :address_rank => primary_rank)
            end
            OperationalDataExtractor::Base.set_value(child_address, CHILD_ADDRESS_MAP[data_export_identifier], value)
          end
        end

        if CHILD_ADDRESS_2_MAP.has_key?(data_export_identifier)
          unless value.blank?
            child_address2 ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.home_address_type.local_code).first
            if child_address2.nil?
              child_address2 = Address.new(:person => child, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                         :address_type => Address.home_address_type, :response_set => response_set, :address_rank => secondary_rank)
            end
            OperationalDataExtractor::Base.set_value(child_address2, CHILD_ADDRESS_2_MAP[data_export_identifier], value)
          end
        end

        if CHILD_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            child_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_rank_code => primary_rank.local_code).first
            if child_phone.nil?
              child_phone = Telephone.new(:person => child, :psu => person.psu, :phone_type => Telephone.home_phone_type,
                                          :response_set => response_set, :phone_rank => primary_rank)
            end
            OperationalDataExtractor::Base.set_value(child_phone, CHILD_PHONE_MAP[data_export_identifier], value)
          end
        end

        if CHILD_PHONE_2_MAP.has_key?(data_export_identifier)
          unless value.blank?
            child_phone2 ||= Telephone.where(:response_set_id => response_set.id).where(:phone_rank_code => secondary_rank.local_code).first
            if child_phone2.nil?
              child_phone2 = Telephone.new(:person => child, :psu => person.psu, :phone_type => Telephone.home_phone_type,
                                           :response_set => response_set, :phone_rank => secondary_rank)
            end
            OperationalDataExtractor::Base.set_value(child_phone2, CHILD_PHONE_2_MAP[data_export_identifier], value)
          end
        end

      end

      if child
        child.save!
        # 8 - Child
        ParticipantPersonLink.create(:person_id => child.id, :participant_id => participant.id, :relationship_code => 8)
        OperationalDataExtractor::Base.make_child_participant(child, person)

        if child_phone && !child_phone.phone_nbr.blank?
          child_phone.save!
        end

        if child_phone2 && !child_phone2.phone_nbr.blank?
          child_phone2.save!
        end

        if child_address && !child_address.to_s.blank?
          child_address.save!
        end

        if child_address2 && !child_address2.to_s.blank?
          child_address2.save!
        end

      end

      person.save!
    end

  end

end