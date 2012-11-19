# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PregnancyVisit < Base

    PREGNANCY_VISIT_1_INTERVIEW_PREFIX = "PREG_VISIT_1_2"
    PREGNANCY_VISIT_2_INTERVIEW_PREFIX = "PREG_VISIT_2_2"
    PREGNANCY_VISIT_1_SAQ_PREFIX       = "PREG_VISIT_1_SAQ_2"
    PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX = "PREG_VISIT_1_3"
    PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX = "PREG_VISIT_2_3"

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
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_CITY"            => "city",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_CITY"            => "city",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ZIPCODE"         => "zip",
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

    WORK_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_UNIT"            => "unit",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_CITY"            => "city",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ZIP4"            => "zip4",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_UNIT"            => "unit",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_CITY"            => "city",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ZIP4"            => "zip4",
    }

    CONFIRM_WORK_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ADDRESS_1"       => "address_one",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ADDRESS_2"       => "address_two",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_UNIT"            => "unit",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_CITY"            => "city",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_STATE"           => "state_code",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ZIPCODE"         => "zip",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ZIP4"            => "zip4",
    }

    FATHER_PHONE_MAP = {
      "#{PREGNANCY_VISIT_1_SAQ_PREFIX}.F_PHONE"           => "phone_nbr",
    }

    DUE_DATE_DETERMINER_MAP = {
      "#{PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.DATE_PERIOD" => "DATE_PERIOD",
      "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DATE_PERIOD" => "DATE_PERIOD",
      "#{PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.DUE_DATE" => "DUE_DATE",
    }

    def initialize(response_set)
      super(response_set)
    end

    def maps
      [
        PERSON_MAP,
        PARTICIPANT_MAP,
        PPG_STATUS_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
        CONTACT_1_PERSON_MAP,
        CONTACT_1_RELATIONSHIP_MAP,
        CONTACT_1_ADDRESS_MAP,
        CONTACT_1_PHONE_MAP,
        CONTACT_2_PERSON_MAP,
        CONTACT_2_RELATIONSHIP_MAP,
        CONTACT_2_ADDRESS_MAP,
        CONTACT_2_PHONE_MAP,
        BIRTH_ADDRESS_MAP,
        FATHER_PERSON_MAP,
        FATHER_ADDRESS_MAP,
        WORK_ADDRESS_MAP,
        CONFIRM_WORK_ADDRESS_MAP,
        FATHER_PHONE_MAP,
        DUE_DATE_DETERMINER_MAP
      ]
    end

    def extract_data
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
      work_address         = nil
      confirm_work_address = nil

      PERSON_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          set_value(person, attribute, response_value(r))
        end
      end

      PPG_STATUS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            participant.ppg_details.first.update_due_date(value, get_due_date_attribute(key))
          end
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

      EMAIL_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            email ||= get_email(response_set, person)
            set_value(email, attribute, value)
          end
        end
      end

      BIRTH_ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?

            birth_address ||= Address.where(:response_set_id => response_set.id,
                                            attribute => value.to_s).first
            if birth_address.nil?
              birth_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new,
                                          :psu => person.psu, :response_set => response_set)
            end

            set_value(birth_address, attribute, value)
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

      FATHER_PERSON_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?

            if attribute == "full_name"
              full_name = value.split
              if full_name.size >= 2
                last_name = full_name.last
                first_name = full_name[0, (full_name.size - 1) ].join(" ")
                father ||= Person.where(:response_set_id => response_set.id,
                                        :first_name => first_name,
                                        :last_name => last_name).first
              else
                father ||= Person.where(:response_set_id => response_set.id,
                                        :first_name => value.to_s).first
              end
            else
              father ||= Person.where(:response_set_id => response_set.id,
                                      attribute => value.to_s).first
            end

            if father.nil?
              father = Person.new(:psu => person.psu, :response_set => response_set)
              # TODO: determine the default relationship for Father when creating father esp. when child has not been born
              # 7 Partner/Significant Other
              father_relationship = ParticipantPersonLink.new(:person => father, :participant => participant, :relationship_code => 7)
            end

            set_value(father, attribute, value)
          end
        end
      end

      if father

        FATHER_ADDRESS_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?

              father_address ||= Address.where(:response_set_id => response_set.id,
                                                attribute => value.to_s).first
              if father_address.nil?
                father_address = Address.new(:person => father, :dwelling_unit => DwellingUnit.new,
                  :psu => person.psu, :response_set => response_set, :address_rank => primary_rank)
              end

              set_value(father_address, attribute, value)
            end
          end
        end

        FATHER_PHONE_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              father_phone ||= Telephone.where(:response_set_id => response_set.id,
                                                attribute => value.to_s).first
              if father_phone.nil?
                father_phone = Telephone.new(:person => father, :psu => person.psu,
                  :response_set => response_set, :phone_rank => primary_rank)
              end

              set_value(father_phone, attribute, value)
            end
          end
        end
      end

      DUE_DATE_DETERMINER_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)

          unless value.blank?
            dt = nil
            begin
              dt = Date.parse(value)
            rescue
              # NOOP - date is unparseable
            end

            if dt
              if due_date = determine_due_date(attribute, r, dt)
                due_date_attr = get_due_date_attribute(key)
                participant.ppg_details.first.update_due_date(
                  due_date, due_date_attr)
              end
            end
          end
        end
      end

      WORK_ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?

            work_address ||= Address.where(:response_set_id => response_set.id,
                                            attribute => value.to_s).first
            if work_address.nil?
              work_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new,
                                          :psu => person.psu, :response_set => response_set,
                                          :address_type => Address.work_address_type)
            end

            set_value(work_address, attribute, value)
          end
        end
      end

      CONFIRM_WORK_ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?

            confirm_work_address ||= Address.where(:response_set_id => response_set.id,
                                            attribute => value.to_s).first
            if confirm_work_address.nil?
              confirm_work_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new,
                                          :psu => person.psu, :response_set => response_set,
                                          :address_type => Address.work_address_type,
                                          :address_rank => duplicate_rank)
            end

            set_value(confirm_work_address, attribute, value)
          end
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

      unless email.try(:email).blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary }
        email.save!
      end

      if !work_address.to_s.blank? || !birth_address.to_s.blank? || !confirm_work_address.to_s.blank?
        person.addresses.each { |a| a.demote_primary_rank_to_secondary }

        work_address.save! unless work_address.to_s.blank?
        birth_address.save! unless birth_address.to_s.blank?
        confirm_work_address.save! unless confirm_work_address.to_s.blank?
      end

      if !cell_phone.try(:phone_nbr).blank?
        person.telephones.each { |t| t.demote_primary_rank_to_secondary }

        cell_phone.save! unless cell_phone.try(:phone_nbr).blank?
      end

      if due_date = calculated_due_date(response_set)
        participant.ppg_details.first.update_due_date(due_date)
      end

      participant.save!
      person.save!

    end

    #TODO: PBS eligibility operational data extractor has similar methods to get the  Extract methods to some common module
    def calculated_due_date(response_set)
      # try due date first
      ret = nil
      ret = due_date_response(response_set, "DUE_DATE")
      ret
    end

    def due_date_response(response_set, date_question)
      dt = date_string(response_set, date_question)
      unless dt.blank?
        return determine_due_date(
          "#{date_question}_DD",
          response_for(response_set, "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.#{date_question}_DD"),
          Date.parse(dt))
      end
    end

    def date_string(response_set, str)
      dt = []
      ['YY', 'MM', 'DD'].each do |date_part|
        r = response_for(response_set, "#{PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.#{str}_#{date_part}")
        val = response_value(r) if r
        dt << val if val.to_i > 0
      end
      dt.join("-")
    end

    def response_for(response_set, data_export_identifier)
      response_set.responses.includes(:question).where(
        "questions.data_export_identifier = ?", data_export_identifier).first
    end

    def get_due_date_attribute(data_export_identifier)
      (data_export_identifier.include?(PREGNANCY_VISIT_2_INTERVIEW_PREFIX) || data_export_identifier.include?(PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX)) ? :due_date_3 : :due_date_2
    end
  end

end