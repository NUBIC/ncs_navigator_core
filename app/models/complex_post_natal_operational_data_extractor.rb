# -*- coding: utf-8 -*-

class ComplexPostNatalOperationalDataExtractor

  SIX_MONTH_MOTHER_PREFIX   = "SIX_MTH_MOTHER_DETAIL"
  TWELVE_MONTH_MOTHER_PREFIX = ""
  EIGHTEEN_MONTH_MOTHER_PREFIX = ""
  TWENTY_FOUR_MONTH_MOTHER_PREFIX = ""

  CHILD_PERSON_NAME_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.C_FNAME"       =>"first_name",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_LNAME"       =>"last_name",
  }

  CHILD_PERSON_DATE_OF_BIRTH_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CHILD_DOB"     =>"person_dob",
  }

  EMAIL_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.EMAIL"           => "email",
  }

  CELL_PHONE_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CELL_PHONE_1"    => "cell_permission_code",
    "#{SIX_MONTH_MOTHER_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{SIX_MONTH_MOTHER_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{SIX_MONTH_MOTHER_PREFIX}.CELL_PHONE"      => "phone_nbr"
  }

  CONTACT_1_PERSON_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_FNAME_1"     => "first_name",
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_LNAME_1"     => "last_name",
  }

  CONTACT_1_RELATIONSHIP_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
  }

  CONTACT_1_ADDRESS_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ADDR_1_1"          => "address_one",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ADDR_2_1"          => "address_two",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_UNIT_1"            => "unit",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_CITY_1"            => "city",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_STATE_1"           => "state_code",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ZIP_1"             => "zip",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ZIP4_1"            => "zip4",
  }

  CONTACT_1_PHONE_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
  }

  CONTACT_2_PERSON_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_FNAME_2"     => "first_name",
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_LNAME_2"     => "last_name",
  }

  CONTACT_2_RELATIONSHIP_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
  }

  CONTACT_2_ADDRESS_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ADDR_1_2"          => "address_one",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ADDR_2_2"          => "address_two",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_UNIT_2"            => "unit",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_CITY_2"            => "city",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_STATE_2"           => "state_code",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ZIP_2"             => "zip",
    "#{SIX_MONTH_MOTHER_PREFIX}.C_ZIP4_2"            => "zip4",
  }

  CONTACT_2_PHONE_MAP = {
    "#{SIX_MONTH_MOTHER_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
  }

  class << self
    def extract_data(response_set)

      person = response_set.person
      if person.participant.blank?
        participant = Participant.create
        participant.person = person
      else
        participant = person.participant
      end

      primary_rank = OperationalDataExtractor.primary_rank
      info_source = NcsCode.for_list_name_and_local_code("INFORMATION_SOURCE_CL2", 1) # TODO: CHANGE THIS!!!!
      type_email = NcsCode.for_list_name_and_local_code('EMAIL_TYPE_CL1', 1) # TODO: CHANGE THIS!!!!
      email_share_and_active =  NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1) # TODO: CHANGE THIS!!!!

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
          #person.send("#{CHILD_PERSON_NAME_MAP[data_export_identifier]}=", value)
          person.update_attribute("#{CHILD_PERSON_NAME_MAP[data_export_identifier]}", value)
        end


        if CHILD_PERSON_DATE_OF_BIRTH_MAP.has_key?(data_export_identifier)
          unless value.blank?
            #person.send("#{CHILD_PERSON_DATE_OF_BIRTH_MAP[data_export_identifier]}=", value)
            person.update_attribute("#{CHILD_PERSON_DATE_OF_BIRTH_MAP[data_export_identifier]}", value)
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
                                :email_share => email_share_and_active,
                                :email_active => email_share_and_active,
                                :email_info_source => info_source)
            end
            email.update_attribute("#{EMAIL_MAP[data_export_identifier]}", value)
          end
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            cell_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.cell_phone_type.local_code).last
            if cell_phone.nil?
              cell_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.cell_phone_type, :response_set => response_set, :phone_rank => primary_rank)
            end
            cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if CONTACT_1_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            contact1 ||= Person.where(:response_set_id => response_set.id).where(CONTACT_1_PERSON_MAP[data_export_identifier].to_sym => value).first
            if contact1.nil?
              contact1 = Person.new(:psu => person.psu, :response_set => response_set)
            end
            contact1.send("#{CONTACT_1_PERSON_MAP[data_export_identifier]}=", value)
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
              contact1relationship.send("#{CONTACT_1_RELATIONSHIP_MAP[data_export_identifier]}=", OperationalDataExtractor.contact_to_person_relationship(value))
            end
          end

          if CONTACT_1_ADDRESS_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact1address ||= Address.where(:response_set_id => response_set.id).where(CONTACT_1_ADDRESS_MAP[data_export_identifier].to_sym => value).first
              if contact1address.nil?
                contact1address = Address.new(:person => contact1, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set)
              end
              contact1address.send("#{CONTACT_1_ADDRESS_MAP[data_export_identifier]}=", value)
            end
          end

          if CONTACT_1_PHONE_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact1phone ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_1_PHONE_MAP[data_export_identifier].to_sym => value).first
              if contact1phone.nil?
                contact1phone = Telephone.new(:person => contact1, :psu => person.psu, :response_set => response_set)
              end
              contact1phone.send("#{CONTACT_1_PHONE_MAP[data_export_identifier]}=", value)
            end
          end

        end

        if CONTACT_2_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            contact2 ||= Person.where(:response_set_id => response_set.id).where(CONTACT_2_PERSON_MAP[data_export_identifier].to_sym => value).first
            if contact2.nil?
              contact2 = Person.new(:psu => person.psu, :response_set => response_set)
            end
            contact2.send("#{CONTACT_2_PERSON_MAP[data_export_identifier]}=", value)
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
              contact2relationship.send("#{CONTACT_2_RELATIONSHIP_MAP[data_export_identifier]}=", OperationalDataExtractor.contact_to_person_relationship(value))
            end
          end

          if CONTACT_2_ADDRESS_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact2address ||= Address.where(:response_set_id => response_set.id).where(CONTACT_2_ADDRESS_MAP[data_export_identifier].to_sym => value).first
              if contact2address.nil?
                contact2address = Address.new(:person => contact2, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set)
              end
              contact2address.send("#{CONTACT_2_ADDRESS_MAP[data_export_identifier]}=", value)
            end
          end

          if CONTACT_2_PHONE_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact2phone ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_2_PHONE_MAP[data_export_identifier].to_sym => value).first
              if contact2phone.nil?
                contact2phone = Telephone.new(:person => contact2, :psu => person.psu, :response_set => response_set)
              end
              contact2phone.send("#{CONTACT_2_PHONE_MAP[data_export_identifier]}=", value)
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
