# -*- coding: utf-8 -*-


class PbsEligibilityScreenerOperationalDataExtractor

  # TODO: extract contact information (language/interpreter used)
  # TODO: is address the HOME address? if so, set address_type

  INTERVIEW_PREFIX = "PBS_ELIG_SCREENER"

  ENGLISH               = "#{INTERVIEW_PREFIX}.ENGLISH"
  CONTACT_LANG          = "#{INTERVIEW_PREFIX}.CONTACT_LANG_NEW"
  CONTACT_LANG_OTH      = "#{INTERVIEW_PREFIX}.CONTACT_LANG_NEW_OTH"
  INTERPRET             = "#{INTERVIEW_PREFIX}.INTERPRET"
  CONTACT_INTERPRET     = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET"
  CONTACT_INTERPRET_OTH = "#{INTERVIEW_PREFIX}.CONTACT_INTERPRET_OTH"

  PERSON_MAP = {
    "#{INTERVIEW_PREFIX}.R_FNAME"             => "first_name",
    "#{INTERVIEW_PREFIX}.R_MNAME"             => "middle_name",
    "#{INTERVIEW_PREFIX}.R_LNAME"             => "last_name",
    "#{INTERVIEW_PREFIX}.PERSON_DOB"          => "person_dob",
    "#{INTERVIEW_PREFIX}.ETHNIC_ORIGIN"       => "ethnic_group_code",
    "#{INTERVIEW_PREFIX}.PERSON_LANG_NEW"     => "language_new_code",
    "#{INTERVIEW_PREFIX}.PERSON_LANG_NEW_OTH" => "language_new_other"
  }

  AGE_RANGE_MAP = {
    "#{INTERVIEW_PREFIX}.AGE_RANGE_PBS"   => "age_range_code",
  }

  PERSON_RACE_MAP = {
    "#{INTERVIEW_PREFIX}.RACE_NEW"         => "race_code",
    "#{INTERVIEW_PREFIX}.RACE_NEW_OTH"     => "race_other",
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

  TELEPHONE_MAP1 = {
    "#{INTERVIEW_PREFIX}.R_PHONE_1"         => "phone_nbr",
    "#{INTERVIEW_PREFIX}.R_PHONE_TYPE1"     => "phone_type_code",
    "#{INTERVIEW_PREFIX}.R_PHONE_TYPE1_OTH" => "phone_type_other",
  }

  TELEPHONE_MAP2 = {
    "#{INTERVIEW_PREFIX}.R_PHONE_2"         => "phone_nbr",
    "#{INTERVIEW_PREFIX}.R_PHONE_TYPE2"     => "phone_type_code",
    "#{INTERVIEW_PREFIX}.R_PHONE_TYPE2_OTH" => "phone_type_other",
  }

  EMAIL_MAP = {
    "#{INTERVIEW_PREFIX}.R_EMAIL"           => "email",
  }

  PPG_DETAILS_MAP = {
    "#{INTERVIEW_PREFIX}.PREGNANT"        => "ppg_first_code",
  }

  DUE_DATE_DETERMINER_MAP = {
    "#{INTERVIEW_PREFIX}.WEEKS_PREG"         => "WEEKS_PREG",
    "#{INTERVIEW_PREFIX}.MONTH_PREG"         => "MONTH_PREG",
    "#{INTERVIEW_PREFIX}.TRIMESTER"          => "TRIMESTER",
  }

  class << self

    def extract_data(response_set)
      person = response_set.person
      participant = response_set.participant

      primary_rank = OperationalDataExtractor.primary_rank

      ppg_detail   = nil
      email        = nil
      phone1       = nil
      phone2       = nil
      address      = nil

      response_set.responses.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if PERSON_MAP.has_key?(data_export_identifier)
          person.send("#{PERSON_MAP[data_export_identifier]}=", value)
        end

        # AGE_RANGE_CL8 in instrument - AGE_RANGE_CL1 in person
        # So if it is 1 then 1 otherwise set to -6 unknown because of the code list mismatch
        if AGE_RANGE_MAP.has_key?(data_export_identifier)
          val = value == 1 ? 1 : -6
          person.send("#{AGE_RANGE_MAP[data_export_identifier]}=", val)
        end

        if PARTICIPANT_MAP.has_key?(data_export_identifier)
          participant.send("#{PARTICIPANT_MAP[data_export_identifier]}=", value) unless participant.blank?
        end

        if ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            address ||= Address.where(:response_set_id => response_set.id).where(:address_type_code => Address.home_address_type.local_code).first
            if address.nil?
              address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu,
                                    :address_type => Address.home_address_type, :response_set => response_set, :address_rank => primary_rank)
            end
            address.send("#{ADDRESS_MAP[data_export_identifier]}=", value)
          end
        end

        if TELEPHONE_MAP1.has_key?(data_export_identifier)
          unless value.blank?
            phone1 ||= Telephone.where(:response_set_id => response_set.id).first
            if phone1.nil?
              phone1 = Telephone.new(:person => person, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
            end

            phone1.send("#{TELEPHONE_MAP1[data_export_identifier]}=", value)
          end
        end

        if TELEPHONE_MAP2.has_key?(data_export_identifier)
          unless value.blank?
            phone2 ||= Telephone.where(:response_set_id => response_set.id).first
            if phone2.nil?
              phone2 = Telephone.new(:person => person, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
            end

            phone2.send("#{TELEPHONE_MAP2[data_export_identifier]}=", value)
          end
        end

        if EMAIL_MAP.has_key?(data_export_identifier)
          unless value.blank?
            email ||= Email.where(:response_set_id => response_set.id).first
            if email.nil?
              email = Email.new(:person => person, :psu => person.psu, :response_set => response_set, :email_rank => primary_rank)
            end
            email.send("#{EMAIL_MAP[data_export_identifier]}=", value)
          end
        end

        # TODO: do not hard code ppg code
        if PPG_DETAILS_MAP.has_key?(data_export_identifier)

          ppg_detail ||= PpgDetail.where(:response_set_id => response_set.id).first
          if ppg_detail.nil?
            ppg_detail = PpgDetail.new(:participant => participant, :psu => participant.psu, :response_set => response_set)
          end

          ppg_detail.send("#{PPG_DETAILS_MAP[data_export_identifier]}=", value)
        end

        if DUE_DATE_DETERMINER_MAP.has_key?(data_export_identifier)
          due_date = OperationalDataExtractor.determine_due_date(DUE_DATE_DETERMINER_MAP[data_export_identifier], r)
          ppg_detail.orig_due_date = due_date if due_date
        end

      end

      if ppg_detail && !ppg_detail.ppg_first_code.blank?
        if due_date = calculated_due_date(response_set)
          ppg_detail.orig_due_date = due_date
        end
        OperationalDataExtractor.set_participant_type(participant, ppg_detail.ppg_first_code)
        ppg_detail.save!
      end

      if email && !email.email.blank?
        email.save!
      end

      if phone1 && !phone1.phone_nbr.blank?
        phone1.save!
      end

      if phone2 && !phone2.phone_nbr.blank?
        phone2.save!
      end

      if address && !address.to_s.blank?
        address.save!
      end

      participant.save!
      person.save!
    end

    def calculated_due_date(response_set)
      # try due date first
      ret = nil
      ret = due_date_response(response_set, "ORIG_DUE_DATE")
      ret = due_date_response(response_set, "DATE_PERIOD") unless ret
      ret
    end

    def due_date_response(response_set, date_question)
      dt = date_string(response_set, date_question)
      unless dt.blank?
        return OperationalDataExtractor.determine_due_date(
          "#{date_question}_DD",
          response_for(response_set, "#{INTERVIEW_PREFIX}.#{date_question}_DD"),
          Date.parse(dt))
      end
    end

    def date_string(response_set, str)
      dt = []
      ['YY', 'MM', 'DD'].each do |date_part|
        r = response_for(response_set, "#{INTERVIEW_PREFIX}.#{str}_#{date_part}")
        val = OperationalDataExtractor.response_value(r) if r
        dt << val if val.to_i > 0
      end
      dt.join("-")
    end

    def response_for(response_set, data_export_identifier)
      response_set.responses.includes(:question).where(
        "questions.data_export_identifier = ?", data_export_identifier).first
    end

  end

end