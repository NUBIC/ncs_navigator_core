# -*- coding: utf-8 -*-


class TracingModuleOperationalDataExtractor

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
    "#{TRACING_MODULE_PREFIX}.NEW_ADDRESS_1"  => "address_one",
    "#{TRACING_MODULE_PREFIX}.NEW_ADDRESS_2"  => "address_two",
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

  class << self

    def extract_data(response_set)
      person = response_set.person
      participant = response_set.participant

      primary_rank = OperationalDataExtractor.primary_rank

      email        = nil
      home_phone   = nil
      cell_phone   = nil
      new_address  = nil
      address      = nil

      contact1             = nil
      contact1relationship = nil
      contact1phone        = nil
      contact1phone2       = nil
      contact1address      = nil
      contact2             = nil
      contact2relationship = nil
      contact2phone        = nil
      contact2phone2       = nil
      contact2address      = nil
      contact3             = nil
      contact3relationship = nil
      contact3phone        = nil
      contact3phone2       = nil
      contact3address      = nil

      response_set.responses.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            address ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.home_address_type.local_code).first
            if address.nil?
              address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                    :address_type => Address.home_address_type, :response_set => response_set, :address_rank => primary_rank)
            end
            OperationalDataExtractor.set_value(address, ADDRESS_MAP[data_export_identifier], value)
          end
        end

        if NEW_ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            new_address ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.home_address_type.local_code).first
            if new_address.nil?
              new_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                         :address_type => Address.home_address_type, :response_set => response_set, :address_rank => primary_rank)
            end
            OperationalDataExtractor.set_value(new_address, NEW_ADDRESS_MAP[data_export_identifier], value)
          end
        end

        if HOME_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            home_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.home_phone_type.local_code).last
            if home_phone.nil?
              home_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.home_phone_type, :response_set => response_set, :phone_rank => primary_rank)
            end
            OperationalDataExtractor.set_value(home_phone, HOME_PHONE_MAP[data_export_identifier], value)
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

        if EMAIL_MAP.has_key?(data_export_identifier)
          unless value.blank?
            email ||= Email.where(:response_set_id => response_set.id).first
            if email.nil?
              email = Email.new(:person => person, :psu => person.psu, :response_set => response_set, :email_rank => primary_rank)
            end
            OperationalDataExtractor.set_value(email, EMAIL_MAP[data_export_identifier], value)
          end
        end

        if CONTACT_1_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            contact1 ||= Person.where(:response_set_id => response_set.id).where(CONTACT_1_PERSON_MAP[data_export_identifier].to_sym => value.to_s).first
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
                contact1address = Address.new(:person => contact1, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set, :address_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact1address, CONTACT_1_ADDRESS_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_1_PHONE_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact1phone ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_1_PHONE_MAP[data_export_identifier].to_sym => value).first
              if contact1phone.nil?
                contact1phone = Telephone.new(:person => contact1, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact1phone, CONTACT_1_PHONE_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_1_PHONE_2_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact1phone2 ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_1_PHONE_2_MAP[data_export_identifier].to_sym => value).first
              if contact1phone2.nil?
                contact1phone2 = Telephone.new(:person => contact1, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact1phone2, CONTACT_1_PHONE_2_MAP[data_export_identifier], value)
            end
          end

        end

        if CONTACT_2_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            contact2 ||= Person.where(:response_set_id => response_set.id).where(CONTACT_2_PERSON_MAP[data_export_identifier].to_sym => value.to_s).first
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
                contact2address = Address.new(:person => contact2, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set, :address_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact2address, CONTACT_2_ADDRESS_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_2_PHONE_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact2phone ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_2_PHONE_MAP[data_export_identifier].to_sym => value).first
              if contact2phone.nil?
                contact2phone = Telephone.new(:person => contact2, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact2phone, CONTACT_2_PHONE_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_2_PHONE_2_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact2phone2 ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_2_PHONE_2_MAP[data_export_identifier].to_sym => value).first
              if contact2phone2.nil?
                contact2phone2 = Telephone.new(:person => contact2, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact2phone2, CONTACT_2_PHONE_2_MAP[data_export_identifier], value)
            end
          end

        end

        if CONTACT_3_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            contact3 ||= Person.where(:response_set_id => response_set.id).where(CONTACT_3_PERSON_MAP[data_export_identifier].to_sym => value.to_s).first
            if contact3.nil?
              contact3 = Person.new(:psu => person.psu, :response_set => response_set)
            end
            OperationalDataExtractor.set_value(contact3, CONTACT_3_PERSON_MAP[data_export_identifier], value)
          end
        end

        if contact3

          if CONTACT_3_RELATIONSHIP_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact3relationship ||= ParticipantPersonLink.where(:response_set_id => response_set.id).where(CONTACT_3_RELATIONSHIP_MAP[data_export_identifier].to_sym => value).first
              if contact3relationship.nil?
                contact3relationship = ParticipantPersonLink.new(:person => contact3, :participant => participant,
                                                                 :psu => person.psu, :response_set => response_set)
              end
              value = OperationalDataExtractor.contact_to_person_relationship(value)
              OperationalDataExtractor.set_value(contact3relationship, CONTACT_3_RELATIONSHIP_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_3_ADDRESS_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact3address ||= Address.where(:response_set_id => response_set.id).where(CONTACT_3_ADDRESS_MAP[data_export_identifier].to_sym => value).first
              if contact3address.nil?
                contact3address = Address.new(:person => contact3, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set, :address_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact3address, CONTACT_3_ADDRESS_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_3_PHONE_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact3phone ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_3_PHONE_MAP[data_export_identifier].to_sym => value).first
              if contact3phone.nil?
                contact3phone = Telephone.new(:person => contact3, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact3phone, CONTACT_3_PHONE_MAP[data_export_identifier], value)
            end
          end

          if CONTACT_3_PHONE_2_MAP.has_key?(data_export_identifier)
            unless value.blank?
              contact3phone2 ||= Telephone.where(:response_set_id => response_set.id).where(CONTACT_3_PHONE_2_MAP[data_export_identifier].to_sym => value).first
              if contact3phone2.nil?
                contact3phone2 = Telephone.new(:person => contact3, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
              end
              OperationalDataExtractor.set_value(contact3phone2, CONTACT_3_PHONE_2_MAP[data_export_identifier], value)
            end
          end
        end


      end

      if contact1 && contact1relationship && !contact1.to_s.blank? && !contact1relationship.relationship_code.blank?
        if contact1address && !contact1address.to_s.blank?
          contact1address.save!
        end
        if contact1phone && !contact1phone.phone_nbr.blank?
          contact1phone.person = contact1
          contact1phone.save!
        end
        if contact1phone2 && !contact1phone2.phone_nbr.blank?
          contact1phone.person = contact1
          contact1phone2.save!
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
        if contact2phone2 && !contact2phone2.phone_nbr.blank?
          contact2phone2.person = contact2
          contact2phone2.save!
        end

        contact2.save!
        contact2relationship.person_id = contact2.id
        contact2relationship.participant_id = participant.id
        contact2relationship.save!
      end

      if contact3 && contact3relationship && !contact3.to_s.blank? && !contact3relationship.relationship_code.blank?
        if contact3address && !contact3address.to_s.blank?
          contact3address.person = contact3
          contact3address.save!
        end
        if contact3phone && !contact3phone.phone_nbr.blank?
          contact3phone.person = contact3
          contact3phone.save!
        end
        if contact3phone2 && !contact3phone2.phone_nbr.blank?
          contact3phone2.person = contact3
          contact3phone2.save!
        end
        contact3.save!
        contact3relationship.person_id = contact3.id
        contact3relationship.participant_id = participant.id
        contact3relationship.save!
      end

      if email && !email.email.blank?
        email.save!
      end

      if home_phone && !home_phone.phone_nbr.blank?
        home_phone.save!
      end

      if cell_phone && !cell_phone.phone_nbr.blank?
        cell_phone.save!
      end

      if new_address && !new_address.to_s.blank?
        new_address.save!
      end

      if address && !address.to_s.blank?
        address.save!
      end

      participant.save!
      person.save!
    end

  end

end