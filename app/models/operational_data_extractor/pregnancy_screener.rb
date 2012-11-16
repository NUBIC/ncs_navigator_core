# -*- coding: utf-8 -*-


class OperationalDataExtractor::PregnancyScreener

  # TODO: extract contact information (language/interpreter used)
  # TODO: is address the HOME address? if so, set address_type

  INTERVIEW_PREFIX = "PREG_SCREEN_HI_2"

  ENGLISH               = "#{INTERVIEW_PREFIX}.ENGLISH"
  CONTACT_LANG          = "#{INTERVIEW_PREFIX}.CONTACT_LANG"
  CONTACT_LANG_OTH      = "#{INTERVIEW_PREFIX}.CONTACT_LANG_OTH"
  INTERPRET             = "#{INTERVIEW_PREFIX}.INTERPRET"
  CONTACT_INTERPRET     = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET"
  CONTACT_INTERPRET_OTH = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET_OTH"

  PERSON_MAP = {
    "#{INTERVIEW_PREFIX}.R_FNAME"         => "first_name",
    "#{INTERVIEW_PREFIX}.R_LNAME"         => "last_name",
    "#{INTERVIEW_PREFIX}.R_GENDER"        => "sex_code",
    "#{INTERVIEW_PREFIX}.PERSON_DOB"      => "person_dob",
    "#{INTERVIEW_PREFIX}.AGE"             => "age",
    "#{INTERVIEW_PREFIX}.AGE_RANGE"       => "age_range_code",
    "#{INTERVIEW_PREFIX}.ETHNICITY"       => "ethnic_group_code",
    "#{INTERVIEW_PREFIX}.PERSON_LANG"     => "language_code",
    "#{INTERVIEW_PREFIX}.PERSON_LANG_OTH" => "language_other"
  }

  PARTICIPANT_MAP = {
    "#{INTERVIEW_PREFIX}.AGE_ELIG"        => "pid_age_eligibility_code"
  }

  ADDRESS_MAP = {
    "#{INTERVIEW_PREFIX}.ADDRESS_1"       => "address_one",
    "#{INTERVIEW_PREFIX}.ADDRESS_2"       => "address_two",
    "#{INTERVIEW_PREFIX}.UNIT"            => "unit",
    "#{INTERVIEW_PREFIX}.CITY"            => "city",
    "#{INTERVIEW_PREFIX}.STATE"           => "state_code",
    "#{INTERVIEW_PREFIX}.ZIP"             => "zip",
    "#{INTERVIEW_PREFIX}.ZIP4"            => "zip4"
  }

  MAIL_ADDRESS_MAP = {
    "#{INTERVIEW_PREFIX}.MAIL_ADDRESS_1"  => "address_one",
    "#{INTERVIEW_PREFIX}.MAIL_ADDRESS_2"  => "address_two",
    "#{INTERVIEW_PREFIX}.MAIL_UNIT"       => "unit",
    "#{INTERVIEW_PREFIX}.MAIL_CITY"       => "city",
    "#{INTERVIEW_PREFIX}.MAIL_STATE"      => "state_code",
    "#{INTERVIEW_PREFIX}.MAIL_ZIP"        => "zip",
    "#{INTERVIEW_PREFIX}.MAIL_ZIP4"       => "zip4"
  }

  TELEPHONE_MAP = {
    "#{INTERVIEW_PREFIX}.PHONE_NBR"       => "phone_nbr",
    "#{INTERVIEW_PREFIX}.PHONE_NBR_OTH"   => "phone_nbr",
    "#{INTERVIEW_PREFIX}.PHONE_TYPE"      => "phone_type_code",
    "#{INTERVIEW_PREFIX}.PHONE_TYPE_OTH"  => "phone_type_other",
  }

  HOME_PHONE_MAP = {
    "#{INTERVIEW_PREFIX}.HOME_PHONE"      => "phone_nbr"
  }

  CELL_PHONE_MAP = {
    "#{INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
    "#{INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
    "#{INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr"
  }

  EMAIL_MAP = {
    "#{INTERVIEW_PREFIX}.EMAIL"           => "email",
    "#{INTERVIEW_PREFIX}.EMAIL_TYPE"      => "email_type_code"
  }

  PPG_DETAILS_MAP = {
    "#{INTERVIEW_PREFIX}.PREGNANT"        => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE"   => "orig_due_date",
    "#{INTERVIEW_PREFIX}.TRYING"          => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.HYSTER"          => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.OVARIES"         => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.MENOPAUSE"       => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.MED_UNABLE"      => "ppg_first_code",
    "#{INTERVIEW_PREFIX}.MED_UNABLE_OTH"  => "ppg_first_code"
  }

  DUE_DATE_DETERMINER_MAP = {
    "#{INTERVIEW_PREFIX}.TRIMESTER"       => "TRIMESTER",
    "#{INTERVIEW_PREFIX}.MONTH_PREG"      => "MONTH_PREG",
    "#{INTERVIEW_PREFIX}.WEEKS_PREG"      => "WEEKS_PREG",
    "#{INTERVIEW_PREFIX}.DATE_PERIOD"     => "DATE_PERIOD",
    "#{INTERVIEW_PREFIX}.ORIG_DUE_DATE"   => "ORIG_DUE_DATE",
  }

  MAPS = [
    PERSON_MAP,
    PARTICIPANT_MAP,
    ADDRESS_MAP,
    MAIL_ADDRESS_MAP,
    TELEPHONE_MAP,
    HOME_PHONE_MAP,
    CELL_PHONE_MAP,
    EMAIL_MAP,
    PPG_DETAILS_MAP,
    DUE_DATE_DETERMINER_MAP
  ]

  class << self

    def known_keys
      @known_keys ||= get_keys_from_maps
    end

    def get_keys_from_maps
      MAPS.collect { |m| m.keys }.flatten
    end

    def data_export_identifier_indexed_responses(responses)
      result = Hash.new
      responses.each do |r|
        dei = r.question.data_export_identifier
        result[dei] = r if known_keys.include?(dei)
      end
      result
    end

    def get_address(response_set, person, address_type)
      address = Address.where(:response_set_id => response_set.id,
                              :address_type_code => address_type.local_code).first
      if address.nil?
        address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                              :address_type => address_type, :response_set => response_set,
                              :address_rank => OperationalDataExtractor::Base.primary_rank)
      end
      address
    end

    def get_telephone(response_set, person, phone_type = nil)
      criteria = Hash.new
      criteria[:response_set_id] = response_set.id
      criteria[:phone_type_code] = phone_type.local_code if phone_type
      phone = Telephone.where(criteria).last
      if phone.nil?
        phone = Telephone.new(:person => person, :psu => person.psu,
                              :response_set => response_set,
                              :phone_rank => OperationalDataExtractor::Base.primary_rank)
        phone.phone_type = phone_type if phone_type
      end
      phone
    end

    def get_email(response_set, person)
      email = Email.where(:response_set_id => response_set.id).first
      if email.nil?
        email = Email.new(:person => person, :psu => person.psu,
                          :response_set => response_set,
                          :email_rank => OperationalDataExtractor::Base.primary_rank)
      end
      email
    end

    def get_ppg_detail(response_set, participant)
      ppg_detail = PpgDetail.where(:response_set_id => response_set.id).first
      if ppg_detail.nil?
        ppg_detail = PpgDetail.new(:participant => participant, :psu => participant.psu,
                                   :response_set => response_set)
      end
      ppg_detail
    end

    def ppg_detail_value(key, value)
      result = value
      case key
      when "#{INTERVIEW_PREFIX}.PREGNANT"
        result = value
      when "#{INTERVIEW_PREFIX}.TRYING"
        case value
        when 1 # when Yes to Trying - set ppg_first_code to 2 - Trying
          result = 2
        when 2 # when No to Trying - set ppg_first_code to 4 - Not Trying
          result = 4
        else  # Otherwise Recent Loss, Not Trying, Unable match ppg_first_code
          result = value
        end
      when "#{INTERVIEW_PREFIX}.HYSTER", "#{INTERVIEW_PREFIX}.OVARIES", "#{INTERVIEW_PREFIX}.TUBES_TIED", "#{INTERVIEW_PREFIX}.MENOPAUSE", "#{INTERVIEW_PREFIX}.MED_UNABLE", "#{INTERVIEW_PREFIX}.MED_UNABLE_OTH"
        result = 5 if value == 1 # If yes to any set the ppg_first_code to 5 - Unable to become pregnant
      else
        result = value
      end
      result
    end

    def extract_data(response_set)
      person = response_set.person
      participant = response_set.participant

      primary_rank = OperationalDataExtractor::Base.primary_rank

      ppg_detail   = nil
      email        = nil
      home_phone   = nil
      cell_phone   = nil
      phone        = nil
      mail_address = nil
      address      = nil

      indexed_responses = data_export_identifier_indexed_responses(response_set.responses)

      PERSON_MAP.each do |key, attribute|
        if r = indexed_responses[key]
          OperationalDataExtractor::Base.set_value(person, attribute,
            OperationalDataExtractor::Base.response_value(r))
        end
      end

      if participant
        PARTICIPANT_MAP.each do |key, attribute|
          if r = indexed_responses[key]
            OperationalDataExtractor::Base.set_value(participant, attribute,
              OperationalDataExtractor::Base.response_value(r))
          end
        end
      end

      ADDRESS_MAP.each do |key, attribute|
        if r = indexed_responses[key]
          value = OperationalDataExtractor::Base.response_value(r)
          unless value.blank?
            address ||= get_address(response_set, person, Address.home_address_type)
            OperationalDataExtractor::Base.set_value(address, attribute, value)
          end
        end
      end

      MAIL_ADDRESS_MAP.each do |key, attribute|
        if r = indexed_responses[key]
          value = OperationalDataExtractor::Base.response_value(r)
          unless value.blank?
            mail_address ||= get_address(response_set, person, Address.mailing_address_type)
            OperationalDataExtractor::Base.set_value(mail_address, attribute, value)
          end
        end
      end

      TELEPHONE_MAP.each do |key, attribute|
        if r = indexed_responses[key]
          value = OperationalDataExtractor::Base.response_value(r)
          unless value.blank?
            phone ||= get_telephone(response_set, person)
            OperationalDataExtractor::Base.set_value(phone, attribute, value)
          end
        end
      end

      HOME_PHONE_MAP.each do |key, attribute|
        if r = indexed_responses[key]
          value = OperationalDataExtractor::Base.response_value(r)
          unless value.blank?
            home_phone ||= get_telephone(response_set, person, Telephone.home_phone_type)
            OperationalDataExtractor::Base.set_value(home_phone, attribute, value)
          end
        end
      end

      CELL_PHONE_MAP.each do |key, attribute|
        if r = indexed_responses[key]
          value = OperationalDataExtractor::Base.response_value(r)
          unless value.blank?
            cell_phone ||= get_telephone(response_set, person, Telephone.cell_phone_type)
            OperationalDataExtractor::Base.set_value(cell_phone, attribute, value)
          end
        end
      end

      EMAIL_MAP.each do |key, attribute|
        if r = indexed_responses[key]
          value = OperationalDataExtractor::Base.response_value(r)
          unless value.blank?
            email ||= get_email(response_set, person)
            OperationalDataExtractor::Base.set_value(email, attribute, value)
          end
        end
      end

      if participant
        PPG_DETAILS_MAP.each do |key, attribute|
          if r = indexed_responses[key]
            value = OperationalDataExtractor::Base.response_value(r)
            unless value.blank?
              ppg_detail ||= get_ppg_detail(response_set, participant)
              ppg_detail.send("#{attribute}=", ppg_detail_value(key, value))
            end
          end
        end

        if ppg_detail
          DUE_DATE_DETERMINER_MAP.each do |key, attribute|
            if r = indexed_responses[key]
              if due_date = OperationalDataExtractor::Base.determine_due_date(attribute, r)
                ppg_detail.orig_due_date = due_date
              end
            end
          end

          unless ppg_detail.ppg_first_code.blank?
            OperationalDataExtractor::Base.set_participant_type(participant, ppg_detail.ppg_first_code)
            ppg_detail.save!
          end

        end

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

      if phone && !phone.phone_nbr.blank?
        phone.save!
      end

      if mail_address && !mail_address.to_s.blank?
        mail_address.save!
      end

      if address && !address.to_s.blank?
        address.save!
      end

      participant.save!
      person.save!
    end

  end
end