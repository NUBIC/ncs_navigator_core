class PpgFollowUpOperationalDataExtractor

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

  class << self

    def extract_data(response_set)
      person = response_set.person
      if person.participant.blank?
        participant = Participant.create(:person => person)
      else
        participant = person.participant
      end
      ppg_status_history = PpgStatusHistory.new(:participant => participant)

      home_phone = Telephone.new(:person => person, :phone_type => Telephone.home_phone_type)
      cell_phone = Telephone.new(:person => person, :phone_type => Telephone.cell_phone_type)
      work_phone = Telephone.new(:person => person, :phone_type => Telephone.work_phone_type)
      other_phone = Telephone.new(:person => person, :phone_type => Telephone.other_phone_type)
      phone = Telephone.new(:person => person)
      email = Email.new(:person => person)

      response_set.responses.each do |r|
        value = OperationalDataExtractor.response_value(r)

        data_export_identifier = r.question.data_export_identifier

        if TELEPHONE_MAP.has_key?(data_export_identifier)
          phone.send("#{TELEPHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if HOME_PHONE_MAP.has_key?(data_export_identifier)
          home_phone.send("#{HOME_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if OTHER_PHONE_MAP.has_key?(data_export_identifier)
          other_phone.send("#{OTHER_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if WORK_PHONE_MAP.has_key?(data_export_identifier)
          work_phone.send("#{WORK_PHONE_MAP[data_export_identifier]}=", value) unless value.blank?
        end

        if EMAIL_MAP.has_key?(data_export_identifier)
          email.send("#{EMAIL_MAP[data_export_identifier]}=", value)
        end

        # TODO: do not hard code ppg code
        if PPG_STATUS_MAP.has_key?(data_export_identifier)
          case data_export_identifier
          when "#{INTERVIEW_PREFIX}.PREGNANT", "#{SAQ_PREFIX}.PREGNANT"
            # Do not set status code if answer to PREGNANT is "No" or "Refused" or "Don't Know"
            # TRYING response will set the status in this case
            ppg_status_history.send("#{PPG_STATUS_MAP[data_export_identifier]}=", value) unless [2, -1, -2].include?(value)
          when "#{INTERVIEW_PREFIX}.TRYING", "#{SAQ_PREFIX}.TRYING"

            value = 4 if value == 2 # "No" response means that the status is "Not Trying" - i.e. 4
            value = 2 if value == 1 # "Yes" response means that the status is "Trying" - i.e. 2

            ppg_status_history.send("#{PPG_STATUS_MAP[data_export_identifier]}=", value)
          when "#{INTERVIEW_PREFIX}.MED_UNABLE", "#{SAQ_PREFIX}.MED_UNABLE"
            value = 5 if value == 1 # "Yes" response means that the status is "Unable to become pregnant" - i.e. 5
            ppg_status_history.send("#{PPG_STATUS_MAP[data_export_identifier]}=", value)
          end

          if (data_export_identifier == "#{INTERVIEW_PREFIX}.PPG_DUE_DATE_1" || data_export_identifier == "#{SAQ_PREFIX}.PPG_DUE_DATE") && !value.blank?
            participant.ppg_details.first.update_due_date(value)
          end
        end

        if DUE_DATE_DETERMINER_MAP.has_key?(data_export_identifier)
          due_date = OperationalDataExtractor.determine_due_date(DUE_DATE_DETERMINER_MAP[data_export_identifier], r)
          participant.ppg_details.first.update_due_date(due_date) if due_date
        end

      end

      email.save! unless email.email.blank?
      home_phone.save! unless home_phone.phone_nbr.blank?
      work_phone.save! unless work_phone.phone_nbr.blank?
      cell_phone.save! unless cell_phone.phone_nbr.blank?
      other_phone.save! unless other_phone.phone_nbr.blank?
      phone.save! unless phone.phone_nbr.blank?
      ppg_status_history.save! unless ppg_status_history.ppg_status_code.blank?
      participant.save!
      person.save!
    end
  end
end
