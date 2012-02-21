class PrePregnancyOperationalDataExtractor

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

  class << self

    def extract_data(response_set)
      person = response_set.person
      if person.participant.blank?
        participant = Participant.create
        participant.person = person
        participant.save!
      else
        participant = person.participant
      end

      cell_phone           = nil
      email                = nil
      contact1             = nil
      contact1relationship = nil
      contact1phone        = nil
      contact1address      = nil
      contact2             = nil
      contact2relationship = nil
      contact2phone        = nil
      contact2address      = nil


      cell_phone = Telephone.new(:person => person, :phone_type => Telephone.cell_phone_type)
      email = Email.new(:person => person)

      contact1 = Person.new
      contact1phone = Telephone.new(:person => contact1)
      contact1address = Address.new(:person => contact1, :dwelling_unit => DwellingUnit.new)
      contact1relationship = ParticipantPersonLink.new(:person => contact1, :participant => participant)

      contact2 = Person.new
      contact2phone = Telephone.new(:person => contact2)
      contact2address = Address.new(:person => contact2, :dwelling_unit => DwellingUnit.new)
      contact2relationship = ParticipantPersonLink.new(:person => contact2, :participant => participant)


      response_set.responses.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            person.send("#{PERSON_MAP[data_export_identifier]}=", value)
          end
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            cell_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.cell_phone_type.local_code).first
            if cell_phone.nil?
              cell_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.cell_phone_type, :response_set => response_set)
            end
            cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if EMAIL_MAP.has_key?(data_export_identifier)
          unless value.blank?
            email ||= Email.where(:response_set_id => response_set.id).first
            if email.nil?
              email = Email.new(:person => person, :psu => person.psu, :response_set => response_set)
            end
            email.send("#{EMAIL_MAP[data_export_identifier]}=", value)
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

      person.save!

    end

  end

end
