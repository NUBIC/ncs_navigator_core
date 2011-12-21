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
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if EMAIL_MAP.has_key?(data_export_identifier)
          email.send("#{EMAIL_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CONTACT_1_PERSON_MAP.has_key?(data_export_identifier)
          contact1.send("#{CONTACT_1_PERSON_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CONTACT_1_RELATIONSHIP_MAP.has_key?(data_export_identifier)
          contact1relationship.send("#{CONTACT_1_RELATIONSHIP_MAP[data_export_identifier]}=", OperationalDataExtractor.contact_to_person_relationship(value)) unless value.blank?
        end

        if CONTACT_1_ADDRESS_MAP.has_key?(data_export_identifier)
          contact1address.send("#{CONTACT_1_ADDRESS_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CONTACT_1_PHONE_MAP.has_key?(data_export_identifier)
          contact1phone.send("#{CONTACT_1_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CONTACT_2_PERSON_MAP.has_key?(data_export_identifier)
          contact2.send("#{CONTACT_2_PERSON_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CONTACT_2_RELATIONSHIP_MAP.has_key?(data_export_identifier)
          contact2relationship.send("#{CONTACT_2_RELATIONSHIP_MAP[data_export_identifier]}=", OperationalDataExtractor.contact_to_person_relationship(value)) unless value.blank?
        end

        if CONTACT_2_ADDRESS_MAP.has_key?(data_export_identifier)
          contact2address.send("#{CONTACT_2_ADDRESS_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CONTACT_2_PHONE_MAP.has_key?(data_export_identifier)
          contact2phone.send("#{CONTACT_2_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

      end

      if !contact1.to_s.blank? && !contact1relationship.relationship_code.blank?
        contact1address.save! unless contact1address.to_s.blank?
        contact1phone.save! unless contact1phone.phone_nbr.blank?
        contact1.save!
        contact1relationship.person_id = contact1.id
        contact1relationship.participant_id = participant.id
        contact1relationship.save!
      end

      if !contact2.to_s.blank? && !contact2relationship.relationship_code.blank?
        contact2address.save! unless contact2address.to_s.blank?
        contact2phone.save! unless contact2phone.phone_nbr.blank?
        contact2.save!
        contact2relationship.person_id = contact2.id
        contact2relationship.participant_id = participant.id
        contact2relationship.save!
      end


      email.save! unless email.email.blank?
      cell_phone.save! unless cell_phone.phone_nbr.blank?
      person.save!

    end

  end

end
