
class PregnancyVisitOperationalDataExtractor

  PREGNANCY_VISIT_1_INTERVIEW_PREFIX = "PREG_VISIT_1_2"
  PREGNANCY_VISIT_2_INTERVIEW_PREFIX = "PREG_VISIT_2_2"
  PREGNANCY_VISIT_1_SAQ_PREFIX       = "PREG_VISIT_1_SAQ_2"

  PERSON_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
  }

  PARTICIPANT_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.AGE_ELIG"        => "pid_age_eligibility_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.AGE_ELIG"        => "pid_age_eligibility_code"
  }

  PPG_STATUS_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.DUE_DATE"        => "orig_due_date",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.DUE_DATE"        => "orig_due_date",
  }

  CELL_PHONE_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr"
  }

  EMAIL_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.EMAIL"           => "email",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.EMAIL_TYPE"      => "email_type_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.EMAIL"           => "email",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.EMAIL_TYPE"      => "email_type_code"
  }

  CONTACT_1_PERSON_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1"     => "first_name",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_1"     => "last_name",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_FNAME_1"     => "first_name",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_LNAME_1"     => "last_name",
  }

  CONTACT_1_RELATIONSHIP_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE_1"    => "relationship_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE1_OTH" => "relationship_other",
  }

  CONTACT_1_ADDRESS_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_1_1"          => "address_one",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_2_1"          => "address_two",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_1"            => "unit",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_1"            => "city",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_1"           => "state_code",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP_1"             => "zip",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_1"            => "zip4",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR_1_1"          => "address_one",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR_2_1"          => "address_two",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_UNIT_1"            => "unit",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_CITY_1"            => "city",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_STATE_1"           => "state_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIP_1"             => "zip",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIP4_1"            => "zip4",
  }

  CONTACT_1_PHONE_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_PHONE_1"     => "phone_nbr",
  }

  CONTACT_2_PERSON_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_2"     => "first_name",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_2"     => "last_name",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_FNAME_2"     => "first_name",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_LNAME_2"     => "last_name",
  }

  CONTACT_2_RELATIONSHIP_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE_2"    => "relationship_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_RELATE2_OTH" => "relationship_other",
  }

  CONTACT_2_ADDRESS_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_1_2"          => "address_one",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_2_2"          => "address_two",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_2"            => "unit",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_2"            => "city",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_2"           => "state_code",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP_2"             => "zip",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_2"            => "zip4",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR_1_2"          => "address_one",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ADDR_2_2"          => "address_two",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_UNIT_2"            => "unit",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_CITY_2"            => "city",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_STATE_2"           => "state_code",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIP_2"             => "zip",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.C_ZIP4_2"            => "zip4",
  }

  CONTACT_2_PHONE_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
    "#{PREGNANCY_VISIT_2_INTERVIEW_PREFIX}.CONTACT_PHONE_2"     => "phone_nbr",
  }

  BIRTH_ADDRESS_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDR_1"            => "address_one",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDR_2"            => "address_two",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_UNIT"              => "unit",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_CITY"              => "city",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_STATE"             => "state_code",
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ZIPCODE"           => "zip",
  }

  FATHER_PERSON_MAP = {
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_NAME"       => "full_name",
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_AGE"        => "age",
  }

  FATHER_ADDRESS_MAP = {
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ADDR_1"          => "address_one",
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ADDR_2"          => "address_two",
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_UNIT"            => "unit",
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_CITY"            => "city",
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_STATE"           => "state_code",
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ZIPCODE"         => "zip",
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ZIP4"            => "zip4",
  }

  FATHER_PHONE_MAP = {
    "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_PHONE"           => "phone_nbr",
  }

  DUE_DATE_DETERMINER_MAP = {
    "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.DATE_PERIOD" => "DATE_PERIOD",
  }

  class << self

    def extract_data(response_set)
      person = response_set.person
      if person.participant.blank?
        participant = Participant.create(:person => person)
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

      # TODO: handle birth address address type
      birth_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new)

      father = Person.new
      father_phone = Telephone.new(:person => father)
      father_address = Address.new(:person => father, :dwelling_unit => DwellingUnit.new)
      # TODO: determine the default relationship for Father when creating father esp. when child has not been born
      father_relationship = ParticipantPersonLink.new(:person => father, :participant => participant, :relationship_code => 7) # 7	Partner/Significant Other

      response_set.responses.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end

        if PPG_STATUS_MAP.has_key?(data_export_identifier)
          participant.ppg_details.first.update_due_date(value) unless value.blank?
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if EMAIL_MAP.has_key?(data_export_identifier)
          email.send("#{EMAIL_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if BIRTH_ADDRESS_MAP.has_key?(data_export_identifier)
          birth_address.send("#{BIRTH_ADDRESS_MAP[data_export_identifier]}=", value)
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

        if FATHER_PERSON_MAP.has_key?(data_export_identifier)
          father.send("#{FATHER_PERSON_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if FATHER_ADDRESS_MAP.has_key?(data_export_identifier)
          father_address.send("#{FATHER_ADDRESS_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if FATHER_PHONE_MAP.has_key?(data_export_identifier)
          father_phone.send("#{FATHER_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if DUE_DATE_DETERMINER_MAP.has_key?(data_export_identifier)
          due_date = OperationalDataExtractor.determine_due_date(DUE_DATE_DETERMINER_MAP[data_export_identifier], r)
          participant.ppg_details.first.update_due_date(due_date) if due_date
        end

      end

      if !father.first_name.blank? && !father.last_name.blank?
        father_address.save! unless father_address.to_s.blank?
        father_phone.save! unless father_phone.phone_nbr.blank?
        father.save!
        father_relationship.save!
      end

      if !contact1.to_s.blank? && !contact1relationship.relationship_code.blank?
        contact1address.save! unless contact1address.to_s.blank?
        contact1phone.save! unless contact1phone.phone_nbr.blank?
        contact1.save!
        contact1relationship.save!
      end

      if !contact2.to_s.blank? && !contact2relationship.relationship_code.blank?
        contact2address.save! unless contact2address.to_s.blank?
        contact2phone.save! unless contact2phone.phone_nbr.blank?
        contact2.save!
        contact2relationship.save!
      end

      birth_address.save! unless birth_address.to_s.blank?
      email.save! unless email.email.blank?
      cell_phone.save! unless cell_phone.phone_nbr.blank?
      participant.save!
      person.save!

    end
  end

end
