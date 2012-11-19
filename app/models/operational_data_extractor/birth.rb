# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class Birth < Base

    BABY_NAME_PREFIX     = "BIRTH_VISIT_BABY_NAME_2"
    BIRTH_VISIT_PREFIX   = "BIRTH_VISIT_2"
    BABY_NAME_LI_PREFIX  = "BIRTH_VISIT_LI_BABY_NAME"
    BIRTH_LI_PREFIX      = "BIRTH_VISIT_LI"
    BIRTH_VISIT_3_PREFIX = "BIRTH_VISIT_3"

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

    WORK_ADDRESS_MAP = {
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS1"   => "address_one",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS2"   => "address_two",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_UNIT"       => "unit",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_CITY"       => "city",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_STATE"      => "state_code",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ZIP"        => "zip",
      "#{BIRTH_VISIT_3_PREFIX}.WORK_ZIP4"       => "zip4",
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

    def initialize(response_set)
      super(response_set)
    end


    def maps
      [
        CHILD_PERSON_MAP,
        PERSON_MAP,
        MAIL_ADDRESS_MAP,
        WORK_ADDRESS_MAP,
        TELEPHONE_MAP,
        HOME_PHONE_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
      ]
    end

    def extract_data

      person = response_set.person
      participant = response_set.participant

      # For surveys that update the child - the participant on the response_set
      # should be the child participant and thus the person being updated is the
      # child participant.person
      child        = participant.person
      email        = nil
      home_phone   = nil
      cell_phone   = nil
      phone        = nil
      mail_address = nil
      work_address = nil

      PERSON_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          set_value(person, attribute, response_value(r))
        end
      end

      if child
        CHILD_PERSON_MAP.each do |key, attribute|
          if r = data_export_identifier_indexed_responses[key]
            set_value(child, attribute, response_value(r))
          end
        end
      end

      MAIL_ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            mail_address ||= get_address(response_set, person, Address.mailing_address_type)
            set_value(mail_address, attribute, value)
          end
        end
      end

      WORK_ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            work_address ||= get_address(response_set, person, Address.work_address_type)
            set_value(work_address, attribute, value)
          end
        end
      end

      TELEPHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            phone ||= get_telephone(response_set, person)
            set_value(phone, attribute, value)
          end
        end
      end

      HOME_PHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            home_phone ||= get_telephone(response_set, person, Telephone.home_phone_type)
            set_value(home_phone, attribute, value)
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

      unless email.try(:email).blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary }
        email.save!
      end

      if !mail_address.to_s.blank? || !work_address.to_s.blank?

        person.addresses.each { |a| a.demote_primary_rank_to_secondary }

        mail_address.save! unless mail_address.to_s.blank?
        work_address.save! unless work_address.to_s.blank?
      end

      if !cell_phone.try(:phone_nbr).blank? ||
         !home_phone.try(:phone_nbr).blank? ||
         !phone.try(:phone_nbr).blank?
        person.telephones.each { |t| t.demote_primary_rank_to_secondary }

        cell_phone.save! unless cell_phone.try(:phone_nbr).blank?
        home_phone.save! unless home_phone.try(:phone_nbr).blank?
        phone.save! unless phone.try(:phone_nbr).blank?
      end

      child.save! if child
      participant.save!
      person.save!

    end

  end
end