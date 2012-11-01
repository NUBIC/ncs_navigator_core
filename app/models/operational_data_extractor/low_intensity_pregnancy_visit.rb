# -*- coding: utf-8 -*-


class OperationalDataExtractor::LowIntensityPregnancyVisit

  INTERVIEW_PREFIX = "PREG_VISIT_LI_2"

  BIRTH_ADDRESS_MAP = {
    "#{INTERVIEW_PREFIX}.B_ADDR_1"            => "address_one",
    "#{INTERVIEW_PREFIX}.B_ADDR_2"            => "address_two",
    "#{INTERVIEW_PREFIX}.B_UNIT"              => "unit",
    "#{INTERVIEW_PREFIX}.B_CITY"              => "city",
    "#{INTERVIEW_PREFIX}.B_STATE"             => "state_code",
    "#{INTERVIEW_PREFIX}.B_ZIPCODE"           => "zip",
  }

  PPG_STATUS_MAP = {
    "#{INTERVIEW_PREFIX}.PREGNANT"        => "ppg_status_code",
    "#{INTERVIEW_PREFIX}.DUE_DATE"        => "orig_due_date",
    "#{INTERVIEW_PREFIX}.TRYING"          => "ppg_status_code",
    "#{INTERVIEW_PREFIX}.MED_UNABLE"      => "ppg_status_code"
  }

  class << self

    def extract_data(response_set)
      person = response_set.person
      participant = response_set.participant

      ppg_status_history = nil
      birth_address = nil

      response_set.responses.each do |r|
        value = OperationalDataExtractor::Base.response_value(r)

        data_export_identifier = r.question.data_export_identifier

        if BIRTH_ADDRESS_MAP.has_key?(data_export_identifier)
          unless value.blank?
            birth_address ||= Address.where(:response_set_id => response_set.id).where(BIRTH_ADDRESS_MAP[data_export_identifier].to_sym => value.to_s).first
            if birth_address.nil?
              birth_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new, :psu => person.psu, :response_set => response_set)
            end
            OperationalDataExtractor::Base.set_value(birth_address, BIRTH_ADDRESS_MAP[data_export_identifier], value)
          end
        end

        # TODO: do not hard code ppg code
        if PPG_STATUS_MAP.has_key?(data_export_identifier)

          ppg_status_history ||= PpgStatusHistory.where(:response_set_id => response_set.id).first
          if ppg_status_history.nil?
            ppg_status_history = PpgStatusHistory.new(:participant => participant, :psu => participant.psu, :response_set => response_set)
          end

          case data_export_identifier
          when "#{INTERVIEW_PREFIX}.PREGNANT"
            OperationalDataExtractor::Base.set_value(ppg_status_history, PPG_STATUS_MAP[data_export_identifier], value)
          end

          if (data_export_identifier == "#{INTERVIEW_PREFIX}.DUE_DATE") && !value.blank?
            participant.ppg_details.first.update_due_date(value, :due_date_2)
          end
        end

      end

      if ppg_status_history && !ppg_status_history.ppg_status_code.blank?
        OperationalDataExtractor::Base.set_participant_type(participant, ppg_status_history.ppg_status_code)
        ppg_status_history.save!
      end

      if birth_address && !birth_address.to_s.blank?
        birth_address.save!
      end

      participant.save!
      person.save!
    end
  end
end