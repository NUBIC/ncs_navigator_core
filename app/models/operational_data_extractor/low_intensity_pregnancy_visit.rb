# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class LowIntensityPregnancyVisit < Base

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

    def initialize(response_set)
      super(response_set)
    end

    def maps
      [ BIRTH_ADDRESS_MAP, PPG_STATUS_MAP ]
    end


    def extract_data
      person = response_set.person
      participant = response_set.participant

      ppg_status_history = nil
      birth_address = nil


      BIRTH_ADDRESS_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            birth_address ||= get_address(response_set, person)
            birth_address(address, attribute, value)
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
            when "#{INTERVIEW_PREFIX}.PREGNANT"
              set_value(ppg_status_history, attribute, value)
            end

            if (key == "#{INTERVIEW_PREFIX}.DUE_DATE") && !value.blank?
              participant.ppg_details.first.update_due_date(value, :due_date_2)
            end
          end
        end
      end

      if ppg_status_history && !ppg_status_history.ppg_status_code.blank?
        set_participant_type(participant, ppg_status_history.ppg_status_code)
        ppg_status_history.save!
      end

      birth_address.save! unless birth_address.to_s.blank?

      participant.save!
      person.save!
    end
  end
end