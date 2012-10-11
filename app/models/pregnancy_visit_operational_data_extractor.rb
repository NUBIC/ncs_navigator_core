# -*- coding: utf-8 -*-


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
      participant = response_set.participant

      cell_phone           = nil
      email                = nil
      birth_address        = nil
      contact1             = nil
      contact1relationship = nil
      contact1phone        = nil
      contact1address      = nil
      contact2             = nil
      contact2relationship = nil
      contact2phone        = nil
      contact2address      = nil
      father               = nil
      father_phone         = nil
      father_address       = nil
      father_relationship  = nil

      primary_rank = OperationalDataExtractor.primary_rank

      response_set.responses.sort_by { |r| r.question.display_order }.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?
            OperationalDataExtractor.set_value(person, PERSON_MAP[data_export_identifier], value)
          end
        end

        if PPG_STATUS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            participant.ppg_details.first.update_due_date(value, get_due_date_attribute(data_export_identifier))
          end
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            cell_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.cell_phone_type.local_code).first
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

        if BIRTH_ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            birth_address ||= Address.where(:response_set_id => response_set.id).where(BIRTH_ADDRESS_MAP[data_export_identifier].to_sym => value).first
            if birth_address.nil?
              birth_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set)
            end
            OperationalDataExtractor.set_value(birth_address, BIRTH_ADDRESS_MAP[data_export_identifier], value)
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
        end

        if FATHER_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?

            if FATHER_PERSON_MAP[data_export_identifier] == "full_name"
              full_name = value.split
              if full_name.size >= 2
                last_name = full_name.last
                first_name = full_name[0, (full_name.size - 1) ].join(" ")
                father ||= Person.where(:response_set_id => response_set.id).where(:first_name => first_name).where(:last_name => last_name).first
              else
                father ||= Person.where(:response_set_id => response_set.id).where(:first_name => value).first
              end
            else
              father ||= Person.where(:response_set_id => response_set.id).where(FATHER_PERSON_MAP[data_export_identifier].to_sym => value).first
            end

            if father.nil?
              father = Person.new(:psu => person.psu, :response_set => response_set)
              # TODO: determine the default relationship for Father when creating father esp. when child has not been born
              # 7	Partner/Significant Other
              father_relationship = ParticipantPersonLink.new(:person => father, :participant => participant, :relationship_code => 7)
            end
            OperationalDataExtractor.set_value(father, FATHER_PERSON_MAP[data_export_identifier], value)
          end
        end

        if FATHER_ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            father_address ||= Address.where(:response_set_id => response_set.id).where(FATHER_ADDRESS_MAP[data_export_identifier].to_sym => value).first
            if father_address.nil?
              father_address = Address.new(:person => father, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set, :address_rank => primary_rank)
            end
            OperationalDataExtractor.set_value(father_address, FATHER_ADDRESS_MAP[data_export_identifier], value)
          end
        end

        if FATHER_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            father_phone ||= Telephone.where(:response_set_id => response_set.id).where(FATHER_PHONE_MAP[data_export_identifier].to_sym => value).first
            if father_phone.nil?
              father_phone = Telephone.new(:person => father, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
            end
            OperationalDataExtractor.set_value(father_phone, FATHER_PHONE_MAP[data_export_identifier], value)
          end
        end

        if DUE_DATE_DETERMINER_MAP.has_key?(data_export_identifier)
          due_date = OperationalDataExtractor.determine_due_date(DUE_DATE_DETERMINER_MAP[data_export_identifier], r)
          participant.ppg_details.first.update_due_date(due_date, get_due_date_attribute(data_export_identifier)) if due_date
        end

      end

      if father
        if father_address && !father_address.to_s.blank?
          father_address.person = father
          father_address.save!
        end
        if father_phone && !father_phone.phone_nbr.blank?
          father_phone.person = father
          father_phone.save!
        end
        father.save!
        father_relationship.person_id = father.id
        father_relationship.participant_id = participant.id
        father_relationship.save!
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

      if birth_address && !birth_address.to_s.blank?
        birth_address.save!
      end

      if email && !email.email.blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary }
        email.save!
      end

      if cell_phone && !cell_phone.phone_nbr.blank?
        person.telephones.each { |t| t.demote_primary_rank_to_secondary }
        cell_phone.save!
      end

      participant.save!
      person.save!

    end

    def get_due_date_attribute(data_export_identifier)
      data_export_identifier.include?(PREGNANCY_VISIT_2_INTERVIEW_PREFIX) ? :due_date_3 : :due_date_2
    end
  end

end