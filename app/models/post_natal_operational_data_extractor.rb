# -*- coding: utf-8 -*-

class PostNatalOperationalDataExtractor

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


  class << self
    def extract_data(response_set)

      person = response_set.person
      participant = response_set.participant

      primary_rank = OperationalDataExtractor.primary_rank
      info_source = NcsCode.for_list_name_and_local_code("INFORMATION_SOURCE_CL2", 1)
      type_email = NcsCode.for_list_name_and_local_code('EMAIL_TYPE_CL1', 1)
      email_share = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
      email_active =  NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)

      email = nil
      cell_phone = nil
      contact1             = nil
      contact1relationship = nil
      contact1address      = nil
      contact1phone        = nil
      contact2             = nil
      contact2relationship = nil
      contact2address      = nil
      contact2phone        = nil

      contact1 = Person.new
      contact1address = Address.new(:person => contact1, :dwelling_unit => DwellingUnit.new, :address_rank => primary_rank)
      contact1relationship = ParticipantPersonLink.new(:person => contact1, :participant => participant)

      contact2 = Person.new
      contact2address = Address.new(:person => contact2, :dwelling_unit => DwellingUnit.new, :address_rank => primary_rank)
      contact2relationship = ParticipantPersonLink.new(:person => contact2, :participant => participant)

      response_set.responses.each do |r|
        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if CHILD_PERSON_NAME_MAP.has_key?(data_export_identifier)
          person = ParticipantPersonLink.where(:participant_id => participant).first.person
          OperationalDataExtractor.set_value(person, CHILD_PERSON_NAME_MAP[data_export_identifier], value)
          person.save!
        end


        if CHILD_PERSON_DATE_OF_BIRTH_MAP.has_key?(data_export_identifier)
          person = ParticipantPersonLink.where(:participant_id => participant).first.person
          unless value.blank?
            OperationalDataExtractor.set_value(person, CHILD_PERSON_DATE_OF_BIRTH_MAP[data_export_identifier], value)
          end
        end

        if EMAIL_MAP.has_key?(data_export_identifier)
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
            OperationalDataExtractor.set_value(email, EMAIL_MAP[data_export_identifier], value)
          end
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            cell_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.cell_phone_type.local_code).last
            if cell_phone.nil?
              cell_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.cell_phone_type, :response_set => response_set, :phone_rank => primary_rank)
            end
            OperationalDataExtractor.set_value(cell_phone, CELL_PHONE_MAP[data_export_identifier], value)
          end
        end

        if CONTACT_1_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            contact1 ||= Person.where(:response_set_id => response_set.id).where(CONTACT_1_PERSON_MAP[data_export_identifier].to_sym => value).first
            if contact1.nil?
              contact1 = Person.new(:psu => person.psu, :response_set => response_set)
            end
            OperationalDataExtractor.set_value(contact1, CONTACT_1_PERSON_MAP[data_export_identifier], value)
          end
        end

        if contact1

          if CONTACT_1_RELATIONSHIP_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact1relationship ||= ParticipantPersonLink.where(:response_set_id => response_set.id).where(CONTACT_1_RELATIONSHIP_MAP[data_export_identifier].to_sym => value).first
              if contact1relationship.nil?
                contact1relationship = ParticipantPersonLink.new(:person => contact1, :participant => participant,
                                                                 :psu => person.psu, :response_set => response_set)
              end
              value = OperationalDataExtractor.contact_to_person_relationship(value)
              OperationalDataExtractor.set_value(contact1relationship, CONTACT_1_RELATIONSHIP_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_1_ADDRESS_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact1address ||= Address.where(:response_set_id => response_set.id).where(CONTACT_1_ADDRESS_MAP[data_export_identifier].to_sym => value).first
              if contact1address.nil?
                contact1address = Address.new(:person => contact1, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set)
              end
              OperationalDataExtractor.set_value(contact1address, CONTACT_1_ADDRESS_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_1_PHONE_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact1phone ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_1_PHONE_MAP[data_export_identifier].to_sym => value).first
              if contact1phone.nil?
                contact1phone = Telephone.new(:person => contact1, :psu => person.psu, :response_set => response_set)
              end
              OperationalDataExtractor.set_value(contact1phone, CONTACT_1_PHONE_MAP[data_export_identifier], value)
            end
          end

        end

        if CONTACT_2_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            contact2 ||= Person.where(:response_set_id => response_set.id).where(CONTACT_2_PERSON_MAP[data_export_identifier].to_sym => value).first
            if contact2.nil?
              contact2 = Person.new(:psu => person.psu, :response_set => response_set)
            end
            OperationalDataExtractor.set_value(contact2, CONTACT_2_PERSON_MAP[data_export_identifier], value)
          end
        end

        if contact2

          if CONTACT_2_RELATIONSHIP_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact2relationship ||= ParticipantPersonLink.where(:response_set_id => response_set.id).where(CONTACT_2_RELATIONSHIP_MAP[data_export_identifier].to_sym => value).first
              if contact2relationship.nil?
                contact2relationship = ParticipantPersonLink.new(:person => contact2, :participant => participant,
                                                                 :psu => person.psu, :response_set => response_set)
              end
              value = OperationalDataExtractor.contact_to_person_relationship(value)
              OperationalDataExtractor.set_value(contact2relationship, CONTACT_2_RELATIONSHIP_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_2_ADDRESS_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact2address ||= Address.where(:response_set_id => response_set.id).where(CONTACT_2_ADDRESS_MAP[data_export_identifier].to_sym => value).first
              if contact2address.nil?
                contact2address = Address.new(:person => contact2, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set)
              end
              OperationalDataExtractor.set_value(contact2address, CONTACT_2_ADDRESS_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_2_PHONE_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact2phone ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_2_PHONE_MAP[data_export_identifier].to_sym => value).first
              if contact2phone.nil?
                contact2phone = Telephone.new(:person => contact2, :psu => person.psu, :response_set => response_set)
              end
              OperationalDataExtractor.set_value(contact2phone, CONTACT_2_PHONE_MAP[data_export_identifier], value)
            end
          end
        end
      end

      if contact1 && contact1relationship && !contact1.to_s.blank? && !contact1relationship.relationship_code.blank?
        if contact1address && !contact1address.to_s.blank?
          contact1address.save!
        end
        if contact1phone && !contact1phone.phone_nbr.blank?
          contact1phone.save!
        end
        contact1.save!
        contact1relationship.person_id = contact1.id
        contact1relationship.participant_id = participant.id
        contact1relationship.save!
      end

      if contact2 && contact2relationship && !contact2.to_s.blank? && !contact2relationship.relationship_code.blank?
        if contact2address && !contact2address.to_s.blank?
          contact2address.person = contact2
          contact2address.save!
        end
        if contact2phone && !contact2phone.phone_nbr.blank?
          contact2phone.person = contact2
          contact2phone.save!
        end
        contact2.save!
        contact2relationship.person_id = contact2.id
        contact2relationship.participant_id = participant.id
        contact2relationship.save!
      end
      if email && !email.email.blank?
        email.save!
      end

      if cell_phone && !cell_phone.phone_nbr.blank?
        cell_phone.save!
      end

      participant.save!
      person.save!
    end

  end

end
