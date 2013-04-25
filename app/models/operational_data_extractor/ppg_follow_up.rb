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
      phone        = process_telephone(person, TELEPHONE_MAP)
      home_phone   = process_telephone(person, HOME_PHONE_MAP, Telephone.home_phone_type)
      cell_phone   = process_telephone(person, CELL_PHONE_MAP, Telephone.cell_phone_type)

      work_phone   = process_telephone(person, WORK_PHONE_MAP, Telephone.work_phone_type)
      other_phone  = process_telephone(person, OTHER_PHONE_MAP, Telephone.other_phone_type)

      email        = process_email(EMAIL_MAP)

      ppg_status_history = process_status_history(PPG_STATUS_MAP)

      set_due_date(DUE_DATE_DETERMINER_MAP, :orig_due_date)

      finalize_ppg_status_history(ppg_status_history)

      finalize_email(email)
      finalize_telephones(cell_phone, home_phone, work_phone, other_phone, phone)

      participant.save!
      person.save!
    end

    def process_status_history(map)
      ppg_status_history = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?

            ppg_status_history ||= PpgStatusHistory.where(:response_set_id => response_set.id).first
            if ppg_status_history.nil?
              c = response_set.contact
              ppg_status_history = PpgStatusHistory.new(:participant => participant,
                :psu => participant.psu, :response_set => response_set,
                :ppg_status_date => c.try(:contact_date), :ppg_status_date_date => c.try(:contact_date_date))
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
      ppg_status_history
    end
    private :process_status_history

    def set_due_date(map, attribute)
      map.each do |key, att|
        if r = data_export_identifier_indexed_responses[key]
          if due_date = determine_due_date(att, r)
            participant.ppg_details.first.update_due_date(due_date, attribute)
          end
        end
      end
    end
    private :set_due_date

  end
end
