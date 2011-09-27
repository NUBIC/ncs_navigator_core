class PpgFollowUpOperationalDataExtractor
  
  TELEPHONE_MAP = {
    "PPG_CATI.PHONE_NBR"       => "phone_nbr",
    "PPG_CATI.PHONE_TYPE"      => "phone_type_code",
  }

  HOME_PHONE_MAP = {
    "PPG_SAQ.HOME_PHONE"      => "phone_nbr"
  }

  WORK_PHONE_MAP = {
    "PPG_SAQ.WORK_PHONE"      => "phone_nbr"
  }
    
  OTHER_PHONE_MAP = {
    "PPG_SAQ.OTHER_PHONE"     => "phone_nbr"
  }
  
  CELL_PHONE_MAP = {
    "PPG_CATI.CELL_PHONE_2"    => "cell_permission_code",
    "PPG_CATI.CELL_PHONE_4"    => "text_permission_code",
    "PPG_CATI.CELL_PHONE"      => "phone_nbr",
    "PPG_SAQ.CELL_PHONE"       => "phone_nbr",
  }
  
  EMAIL_MAP = {
    "PPG_SAQ.EMAIL"            => "email",
    "PPG_SAQ.EMAIL_TYPE"       => "email_type_code"
  }
  
  PPG_STATUS_MAP = {
    "PPG_CATI.PREGNANT"        => "ppg_status_code",
    "PPG_CATI.PPG_DUE_DATE_1"  => "orig_due_date",
    "PPG_CATI.TRYING"          => "ppg_status_code",
    "PPG_CATI.MED_UNABLE"      => "ppg_status_code",
    "PPG_SAQ.PREGNANT"         => "ppg_status_code",
    "PPG_SAQ.PPG_DUE_DATE"     => "orig_due_date",
    "PPG_SAQ.TRYING"           => "ppg_status_code",
    "PPG_SAQ.MED_UNABLE"       => "ppg_status_code"
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
          when "PPG_CATI.PREGNANT", "PPG_SAQ.PREGNANT"
            # Do not set status code if answer to PREGNANT is "No" or "Refused" or "Don't Know"
            # TRYING response will set the status in this case
            ppg_status_history.send("#{PPG_STATUS_MAP[data_export_identifier]}=", value) unless [2, -1, -2].include?(value)
          when "PPG_CATI.TRYING", "PPG_SAQ.TRYING"
            
            value = 4 if value == 2 # "No" response means that the status is "Not Trying" - i.e. 4
            value = 2 if value == 1 # "Yes" response means that the status is "Trying" - i.e. 2
            
            ppg_status_history.send("#{PPG_STATUS_MAP[data_export_identifier]}=", value)
          when "PPG_CATI.MED_UNABLE", "PPG_SAQ.MED_UNABLE"
            value = 5 if value == 1 # "Yes" response means that the status is "Unable to become pregnant" - i.e. 5
            ppg_status_history.send("#{PPG_STATUS_MAP[data_export_identifier]}=", value)
          end
          
          if (data_export_identifier == "PPG_CATI.PPG_DUE_DATE_1" || data_export_identifier == "PPG_SAQ.PPG_DUE_DATE") && !value.blank?
            participant.ppg_details.first.update_due_date(value) 
          end
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