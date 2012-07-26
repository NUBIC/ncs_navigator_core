# -*- coding: utf-8 -*-


class BirthOperationalDataExtractor

  BABY_NAME_PREFIX    = "BIRTH_VISIT_BABY_NAME_2"
  BIRTH_VISIT_PREFIX  = "BIRTH_VISIT_2"
  BABY_NAME_LI_PREFIX = "BIRTH_VISIT_LI_BABY_NAME"
  BIRTH_LI_PREFIX     = "BIRTH_VISIT_LI"

  CHILD_PERSON_MAP = {
    "#{BABY_NAME_PREFIX}.BABY_FNAME"        => "first_name",
    "#{BABY_NAME_PREFIX}.BABY_MNAME"        => "middle_name",
    "#{BABY_NAME_PREFIX}.BABY_LNAME"        => "last_name",
    "#{BABY_NAME_PREFIX}.BABY_SEX"          => "sex_code",

    "#{BABY_NAME_LI_PREFIX}.BABY_FNAME"      => "first_name",
    "#{BABY_NAME_LI_PREFIX}.BABY_MNAME"      => "middle_name",
    "#{BABY_NAME_LI_PREFIX}.BABY_LNAME"      => "last_name",
    "#{BABY_NAME_LI_PREFIX}.BABY_SEX"        => "sex_code",
  }

  PERSON_MAP = {
    "#{BIRTH_VISIT_PREFIX}.R_FNAME"         => "first_name",
    "#{BIRTH_VISIT_PREFIX}.R_LNAME"         => "last_name",

    "#{BIRTH_LI_PREFIX}.R_FNAME"         => "first_name",
    "#{BIRTH_LI_PREFIX}.R_LNAME"         => "last_name",
  }

  MAIL_ADDRESS_MAP = {
    "#{BIRTH_VISIT_PREFIX}.MAIL_ADDRESS1"   => "address_one",
    "#{BIRTH_VISIT_PREFIX}.MAIL_ADDRESS2"   => "address_two",
    "#{BIRTH_VISIT_PREFIX}.MAIL_UNIT"       => "unit",
    "#{BIRTH_VISIT_PREFIX}.MAIL_CITY"       => "city",
    "#{BIRTH_VISIT_PREFIX}.MAIL_STATE"      => "state_code",
    "#{BIRTH_VISIT_PREFIX}.MAIL_ZIP"        => "zip",
    "#{BIRTH_VISIT_PREFIX}.MAIL_ZIP4"       => "zip4",

    "#{BIRTH_LI_PREFIX}.MAIL_ADDRESS1"   => "address_one",
    "#{BIRTH_LI_PREFIX}.MAIL_ADDRESS2"   => "address_two",
    "#{BIRTH_LI_PREFIX}.MAIL_UNIT"       => "unit",
    "#{BIRTH_LI_PREFIX}.MAIL_CITY"       => "city",
    "#{BIRTH_LI_PREFIX}.MAIL_STATE"      => "state_code",
    "#{BIRTH_LI_PREFIX}.MAIL_ZIP"        => "zip",
    "#{BIRTH_LI_PREFIX}.MAIL_ZIP4"       => "zip4"
  }

  TELEPHONE_MAP = {
    "#{BIRTH_VISIT_PREFIX}.PHONE_NBR"       => "phone_nbr",
    "#{BIRTH_VISIT_PREFIX}.PHONE_NBR_OTH"   => "phone_nbr",
    "#{BIRTH_VISIT_PREFIX}.PHONE_TYPE"      => "phone_type_code",
    "#{BIRTH_VISIT_PREFIX}.PHONE_TYPE_OTH"  => "phone_type_other",

    "#{BIRTH_LI_PREFIX}.PHONE_NBR"       => "phone_nbr",
    "#{BIRTH_LI_PREFIX}.PHONE_NBR_OTH"   => "phone_nbr",
    "#{BIRTH_LI_PREFIX}.PHONE_TYPE"      => "phone_type_code",
    "#{BIRTH_LI_PREFIX}.PHONE_TYPE_OTH"  => "phone_type_other",
  }

  HOME_PHONE_MAP = {
    "#{BIRTH_VISIT_PREFIX}.HOME_PHONE"      => "phone_nbr",

    "#{BIRTH_LI_PREFIX}.HOME_PHONE"      => "phone_nbr"
  }

  CELL_PHONE_MAP = {
    "#{BIRTH_VISIT_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{BIRTH_VISIT_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{BIRTH_VISIT_PREFIX}.CELL_PHONE"      => "phone_nbr",

    "#{BIRTH_LI_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{BIRTH_LI_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{BIRTH_LI_PREFIX}.CELL_PHONE"      => "phone_nbr"
  }

  EMAIL_MAP = {
    "#{BIRTH_VISIT_PREFIX}.EMAIL"           => "email",
    "#{BIRTH_VISIT_PREFIX}.EMAIL_TYPE"      => "email_type_code",

    "#{BIRTH_LI_PREFIX}.EMAIL"           => "email",
    "#{BIRTH_LI_PREFIX}.EMAIL_TYPE"      => "email_type_code"
  }

  class << self

    def extract_data(response_set)

      Rails.logger.info("~~~~ extract_data called")

      person = response_set.person
      # TODO: The person taking the survey may not necessarily be the participant
      #       cf. Bug #2292
      #       fix this so that the participant is correctly set
      participant = person.participant

      primary_rank = OperationalDataExtractor.primary_rank

      child        = nil
      email        = nil
      home_phone   = nil
      cell_phone   = nil
      phone        = nil
      mail_address = nil

      mail_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :address_type => Address.mailing_address_type, :address_rank => primary_rank)
      home_phone = Telephone.new(:person => person, :phone_type => Telephone.home_phone_type, :psu => person.psu, :phone_rank => primary_rank)
      cell_phone = Telephone.new(:person => person, :phone_type => Telephone.cell_phone_type, :psu => person.psu, :phone_rank => primary_rank)
      phone = Telephone.new(:person => person, :psu => person.psu, :phone_rank => primary_rank)
      email = Email.new(:person => person, :psu => person.psu, :email_rank => primary_rank)

      response_set.responses.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end

        if CHILD_PERSON_MAP.has_key?(data_export_identifier)
          unless value.blank?

            if child.nil?
              child = Person.new(:psu => person.psu)
              Rails.logger.info("~~~ created child #{child.inspect}")
            end
            child.send("#{CHILD_PERSON_MAP[data_export_identifier]}=", value)
          end
        end

        if MAIL_ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            mail_address ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.mailing_address_type.local_code).first
            if mail_address.nil?
              mail_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                         :address_type => Address.mailing_address_type, :response_set => response_set)
            end
            mail_address.send("#{MAIL_ADDRESS_MAP[data_export_identifier]}=", value)
          end
        end

        if TELEPHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            phone ||= Telephone.where(:response_set_id => response_set.id).first
            if phone.nil?
              phone = Telephone.new(:person => person, :psu => person.psu, :response_set => response_set)
            end

            phone.send("#{TELEPHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if HOME_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            home_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.home_phone_type.local_code).last
            if home_phone.nil?
              home_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.home_phone_type, :response_set => response_set)
            end

            home_phone.send("#{HOME_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            cell_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.cell_phone_type.local_code).last
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

      end

      if child
        child.save!
        ParticipantPersonLink.create(:person_id => child.id, :participant_id => participant.id, :relationship_code => 8) # 8 Child
        self.make_child_participant(child, person)
      end

      if email && !email.email.blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary }
        email.save!
      end

      if mail_address && !mail_address.to_s.blank?
        person.addresses.each { |a| a.demote_primary_rank_to_secondary }
        mail_address.save!
      end

      if (cell_phone && !cell_phone.phone_nbr.blank?) ||
         (home_phone && !home_phone.phone_nbr.blank?) ||
         (phone && !phone.phone_nbr.blank?)
        person.telephones.each { |t| t.demote_primary_rank_to_secondary }
      end

      if cell_phone && !cell_phone.phone_nbr.blank?
        cell_phone.save!
      end

      if home_phone && !home_phone.phone_nbr.blank?
        home_phone.save!
      end

      if phone && !phone.phone_nbr.blank?
        phone.save!
      end

      participant.save!
      person.save!

    end

    def make_child_participant(child, mother)
      child_participant = Participant.create(:psu => child.psu, :p_type_code => 6)  # NCS Child
      child_participant.person = child
      child_participant.save!
      ParticipantPersonLink.create(:person_id => mother.id, :participant_id => child.id, :relationship_code => 2) # 2 = Mother, associating child with its mother
    end

  end

end
