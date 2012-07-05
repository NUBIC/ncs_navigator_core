# -*- coding: utf-8 -*-


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
        participant = Participant.create
        participant.person = person
      else
        participant = person.participant
      end

      primary_rank = OperationalDataExtractor.primary_rank

      ppg_status_history = nil
      home_phone         = nil
      cell_phone         = nil
      work_phone         = nil
      other_phone        = nil
      phone              = nil
      email              = nil

      response_set.responses.each do |r|
        value = OperationalDataExtractor.response_value(r)

        data_export_identifier = r.question.data_export_identifier

        if TELEPHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            phone ||= Telephone.where(:response_set_id => response_set.id).first
            if phone.nil?
              phone = Telephone.new(:person => person, :psu => person.psu, :response_set => response_set, :phone_rank => primary_rank)
            end

            phone.send("#{TELEPHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if HOME_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            home_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.home_phone_type.local_code).last
            if home_phone.nil?
              home_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.home_phone_type, :response_set => response_set, :phone_rank => primary_rank)
            end

            home_phone.send("#{HOME_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if CELL_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            cell_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.cell_phone_type.local_code).last
            if cell_phone.nil?
              cell_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.cell_phone_type, :response_set => response_set, :phone_rank => primary_rank)
            end
            cell_phone.send("#{CELL_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if OTHER_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            other_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.other_phone_type.local_code).last
            if other_phone.nil?
              other_phone = Telephone.new(:person => person, :psu => person.psu,
                                          :phone_type => Telephone.other_phone_type, :response_set => response_set, :phone_rank => primary_rank)
            end

            other_phone.send("#{OTHER_PHONE_MAP[data_export_identifier]}=", value)
          end
        end

        if WORK_PHONE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            work_phone ||= Telephone.where(:response_set_id => response_set.id).where(:phone_type_code => Telephone.work_phone_type.local_code).last
            if work_phone.nil?
              work_phone = Telephone.new(:person => person, :psu => person.psu,
                                         :phone_type => Telephone.work_phone_type, :response_set => response_set, :phone_rank => primary_rank)
            end
            work_phone.send("#{WORK_PHONE_MAP[data_export_identifier]}=", value)
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
        if PPG_STATUS_MAP.has_key?(data_export_identifier)

          ppg_status_history ||= PpgStatusHistory.where(:response_set_id => response_set.id).first
          if ppg_status_history.nil?
            ppg_status_history = PpgStatusHistory.new(:participant => person.participant, :psu => person.psu, :response_set => response_set)
          end

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
            participant.ppg_details.first.update_due_date(value, :orig_due_date)
          end
        end

        if DUE_DATE_DETERMINER_MAP.has_key?(data_export_identifier)
          due_date = OperationalDataExtractor.determine_due_date(DUE_DATE_DETERMINER_MAP[data_export_identifier], r)
          participant.ppg_details.first.update_due_date(due_date, :orig_due_date) if due_date
        end

      end

      if ppg_status_history && !ppg_status_history.ppg_status_code.blank?
        OperationalDataExtractor.set_participant_type(participant, ppg_status_history.ppg_status_code)
        ppg_status_history.save!
      end

      if email && !email.email.blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary }
        email.save!
      end

      if (home_phone && !home_phone.phone_nbr.blank?) ||
         (cell_phone && !cell_phone.phone_nbr.blank?) ||
         (work_phone && !work_phone.phone_nbr.blank?) ||
         (other_phone && !other_phone.phone_nbr.blank?) ||
         (phone && !phone.phone_nbr.blank?)
        person.telephones.each { |t| t.demote_primary_rank_to_secondary }
      end

      if home_phone && !home_phone.phone_nbr.blank?
        home_phone.save!
      end

      if cell_phone && !cell_phone.phone_nbr.blank?
        cell_phone.save!
      end

      if work_phone && !work_phone.phone_nbr.blank?
        work_phone.save!
      end

      if other_phone && !other_phone.phone_nbr.blank?
        other_phone.save!
      end

      if phone && !phone.phone_nbr.blank?
        phone.save!
      end

      participant.save!
      person.save!
    end

  end
end