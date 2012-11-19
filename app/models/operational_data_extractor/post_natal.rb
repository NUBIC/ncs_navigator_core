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

    def initialize(response_set)
      super(response_set)
    end

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
        CONTACT_2_PHONE_MAP
      ]
    end

    def extract_data

      person = response_set.person
      participant = response_set.participant

      # For surveys that update the child - the participant on the response_set
      # should be the child participant and thus the person being updated is the
      # child participant.person
      child = participant.person

      info_source = NcsCode.for_list_name_and_local_code("INFORMATION_SOURCE_CL2", 1)
      type_email = NcsCode.for_list_name_and_local_code('EMAIL_TYPE_CL1', 1)
      email_share = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
      email_active =  NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)

      email = nil
      cell_phone = nil

      contact1 = Person.new
      contact1phone = nil
      contact1address = Address.new(:person => contact1, :dwelling_unit => DwellingUnit.new, :address_rank => primary_rank)
      contact1relationship = ParticipantPersonLink.new(:participant => participant, :person => contact1)

      contact2 = Person.new
      contact2phone = nil
      contact2address = Address.new(:person => contact2, :dwelling_unit => DwellingUnit.new, :address_rank => primary_rank)
      contact2relationship = ParticipantPersonLink.new(:participant => participant, :person => contact2)

      if child
        CHILD_PERSON_NAME_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            set_value(child, attribute, response_value(r))
          end
        end

        CHILD_PERSON_DATE_OF_BIRTH_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            set_value(child, attribute, response_value(r))
          end
        end
      end

      EMAIL_MAP.each do |key, attribute|

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

      CELL_PHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            cell_phone ||= get_telephone(response_set, person, Telephone.cell_phone_type)
            set_value(cell_phone, attribute, value)
          end
        end
      end

      CONTACT_1_PERSON_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            contact1 ||= Person.where(:response_set_id => response_set.id,
                                      attribute => value.to_s).first
            if contact1.nil?
              contact1 = Person.new(:psu => person.psu, :response_set => response_set)
            end
            set_value(contact1, attribute, value)
          end
        end
      end

      if contact1

        CONTACT_1_RELATIONSHIP_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              contact1relationship ||= ParticipantPersonLink.where(:response_set_id => response_set.id,
                                                                    attribute => value.to_s).first
              if contact1relationship.nil?
                contact1relationship = ParticipantPersonLink.new(:person => contact1, :participant => participant,
                                                                 :psu => person.psu, :response_set => response_set)
              end
              set_value(contact1relationship, attribute, contact_to_person_relationship(value))
            end
          end
        end

        CONTACT_1_ADDRESS_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              contact1address ||= Address.where(:response_set_id => response_set.id,
                                                 attribute => value.to_s).first
              if contact1address.nil?
                contact1address = Address.new(:person => contact1, :dwelling_unit => DwellingUnit.new,
                                              :psu => person.psu, :response_set => response_set,
                                              :address_rank => primary_rank)
              end
              set_value(contact1address, attribute, value)
            end
          end
        end

        CONTACT_1_PHONE_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              contact1phone ||= Telephone.where(:response_set_id => response_set.id,
                                                attribute => value.to_s).first
              if contact1phone.nil?
                contact1phone = Telephone.new(:person => contact1, :psu => person.psu,
                                              :response_set => response_set, :phone_rank => primary_rank)
              end
              set_value(contact1phone, attribute, value)
            end
          end
        end
      end

      CONTACT_2_PERSON_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            contact2 ||= Person.where(:response_set_id => response_set.id,
                                      attribute => value.to_s).first
            if contact2.nil?
              contact2 = Person.new(:psu => person.psu, :response_set => response_set)
            end
            set_value(contact2, attribute, value)
          end
        end
      end

      if contact2

        CONTACT_2_RELATIONSHIP_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              contact2relationship ||= ParticipantPersonLink.where(:response_set_id => response_set.id,
                                                                    attribute => value.to_s).first
              if contact2relationship.nil?
                contact2relationship = ParticipantPersonLink.new(:person => contact2, :participant => participant,
                                                                 :psu => person.psu, :response_set => response_set)
              end
              set_value(contact2relationship, attribute, contact_to_person_relationship(value))
            end
          end
        end

        CONTACT_2_ADDRESS_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              contact2address ||= Address.where(:response_set_id => response_set.id,
                                                 attribute => value.to_s).first
              if contact2address.nil?
                contact2address = Address.new(:person => contact2, :dwelling_unit => DwellingUnit.new,
                                              :psu => person.psu, :response_set => response_set,
                                              :address_rank => primary_rank)
              end
              set_value(contact2address, attribute, value)
            end
          end
        end

        CONTACT_2_PHONE_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              contact2phone ||= Telephone.where(:response_set_id => response_set.id,
                                                attribute => value.to_s).first
              if contact2phone.nil?
                contact2phone = Telephone.new(:person => contact2, :psu => person.psu,
                                              :response_set => response_set, :phone_rank => primary_rank)
              end
              set_value(contact2phone, attribute, value)
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

      email.save! unless email.try(:email).blank?
      cell_phone.save! unless cell_phone.try(:phone_nbr).blank?

      child.save! if child
      participant.save!
      person.save!
    end
  end
end