# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PpgFollowUp < Base

    INTERVIEW_PREFIX = "PPG_CATI"
    SAQ_PREFIX       = "PPG_SAQ"

    TELEPHONE_MAP = {
      "#{INTERVIEW_PREFIX}.PHONE_NBR"       => "phone_nbr",
      "#{INTERVIEW_PREFIX}.PHONE_TYPE"      => "phone_type_code",
    }

    HOME_PHONE_MAP = {
      "#{SAQ_PREFIX}.HOME_PHONE"            => "phone_nbr"
    }

    WORK_PHONE_MAP = {
      "#{SAQ_PREFIX}.WORK_PHONE"            => "phone_nbr"
    }

    OTHER_PHONE_MAP = {
      "#{SAQ_PREFIX}.OTHER_PHONE"           => "phone_nbr"
    }

    CELL_PHONE_MAP = {
      "#{INTERVIEW_PREFIX}.CELL_PHONE_2"    => "cell_permission_code",
      "#{INTERVIEW_PREFIX}.CELL_PHONE_4"    => "text_permission_code",
      "#{INTERVIEW_PREFIX}.CELL_PHONE"      => "phone_nbr",
      "#{SAQ_PREFIX}.CELL_PHONE"            => "phone_nbr",
    }

    EMAIL_MAP = {
      "#{SAQ_PREFIX}.EMAIL"                 => "email",
      "#{SAQ_PREFIX}.EMAIL_TYPE"            => "email_type_code"
    }

    PPG_STATUS_MAP = {
      "#{INTERVIEW_PREFIX}.PREGNANT"        => "ppg_status_code",
      "#{INTERVIEW_PREFIX}.PPG_DUE_DATE_1"  => "orig_due_date",
      "#{INTERVIEW_PREFIX}.TRYING"          => "ppg_status_code",
      "#{INTERVIEW_PREFIX}.MED_UNABLE"      => "ppg_status_code",
      "#{SAQ_PREFIX}.PREGNANT"              => "ppg_status_code",
      "#{SAQ_PREFIX}.PPG_DUE_DATE"          => "orig_due_date",
      "#{SAQ_PREFIX}.TRYING"                => "ppg_status_code",
      "#{SAQ_PREFIX}.MED_UNABLE"            => "ppg_status_code"
    }

    DUE_DATE_DETERMINER_MAP = {
      "#{INTERVIEW_PREFIX}.DATE_PERIOD"     => "DATE_PERIOD",
      "#{INTERVIEW_PREFIX}.WEEKS_PREG"      => "WEEKS_PREG",
      "#{INTERVIEW_PREFIX}.MONTH_PREG"      => "MONTH_PREG",
      "#{INTERVIEW_PREFIX}.TRIMESTER"       => "TRIMESTER",
    }

    def initialize(response_set)
      super(response_set)
    end

    def maps
      [
        TELEPHONE_MAP,
        HOME_PHONE_MAP,
        WORK_PHONE_MAP,
        OTHER_PHONE_MAP,
        CELL_PHONE_MAP,
        EMAIL_MAP,
        PPG_STATUS_MAP,
        DUE_DATE_DETERMINER_MAP
      ]
    end

    def extract_data
      person = response_set.person
      participant = response_set.participant

      ppg_status_history = nil
      home_phone         = nil
      cell_phone         = nil
      work_phone         = nil
      other_phone        = nil
      phone              = nil
      email              = nil

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

      OTHER_PHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            other_phone ||= get_telephone(response_set, person, Telephone.other_phone_type)
            set_value(other_phone, attribute, value)
          end
        end
      end

      WORK_PHONE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            work_phone ||= get_telephone(response_set, person, Telephone.work_phone_type)
            set_value(work_phone, attribute, value)
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


      PPG_STATUS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?

            ppg_status_history ||= PpgStatusHistory.where(:response_set_id => response_set.id).first
            if ppg_status_history.nil?
              ppg_status_history = PpgStatusHistory.new(:participant => participant,
                :psu => participant.psu, :response_set => response_set)
            end

            case key
            when "#{INTERVIEW_PREFIX}.PREGNANT", "#{SAQ_PREFIX}.PREGNANT"
              # Do not set status code if answer to PREGNANT is "No" or "Refused" or "Don't Know"
              # TRYING response will set the status in this case
              ppg_status_history.send("#{attribute}=", value) unless [2, -1, -2].include?(value)
            when "#{INTERVIEW_PREFIX}.TRYING", "#{SAQ_PREFIX}.TRYING"

              value = 4 if value == 2 # "No" response means that the status is "Not Trying" - i.e. 4
              value = 2 if value == 1 # "Yes" response means that the status is "Trying" - i.e. 2

              ppg_status_history.send("#{attribute}=", value)
            when "#{INTERVIEW_PREFIX}.MED_UNABLE", "#{SAQ_PREFIX}.MED_UNABLE"
              value = 5 if value == 1 # "Yes" response means that the status is "Unable to become pregnant" - i.e. 5
              ppg_status_history.send("#{attribute}=", value)
            end

            if (key == "#{INTERVIEW_PREFIX}.PPG_DUE_DATE_1" || key == "#{SAQ_PREFIX}.PPG_DUE_DATE") && !value.blank?
              participant.ppg_details.first.update_due_date(value, :orig_due_date)
            end

          end
        end
      end

      DUE_DATE_DETERMINER_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          if due_date = determine_due_date(attribute, r)
            participant.ppg_details.first.update_due_date(due_date, :orig_due_date)
          end
        end
      end

      if ppg_status_history && !ppg_status_history.ppg_status_code.blank?
        set_participant_type(participant, ppg_status_history.ppg_status_code)
        ppg_status_history.save!
      end

      unless email.try(:email).blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary }
        email.save!
      end

      if !cell_phone.try(:phone_nbr).blank? ||
         !home_phone.try(:phone_nbr).blank? ||
         !work_phone.try(:phone_nbr).blank? ||
         !other_phone.try(:phone_nbr).blank? ||
         !phone.try(:phone_nbr).blank?
        person.telephones.each { |t| t.demote_primary_rank_to_secondary }

        cell_phone.save! unless cell_phone.try(:phone_nbr).blank?
        home_phone.save! unless home_phone.try(:phone_nbr).blank?
        work_phone.save! unless work_phone.try(:phone_nbr).blank?
        other_phone.save! unless other_phone.try(:phone_nbr).blank?
        phone.save! unless phone.try(:phone_nbr).blank?
      end

      participant.save!
      person.save!
    end

  end
end