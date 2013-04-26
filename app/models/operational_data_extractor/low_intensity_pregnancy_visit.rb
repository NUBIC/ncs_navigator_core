# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class LowIntensityPregnancyVisit < Base

    PREGNANCY_VISIT_LI_INTERVIEW_PREFIX   = "PREG_VISIT_LI"
    PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX = "PREG_VISIT_LI_2"

    BIRTH_ADDRESS_MAP = {
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.B_ADDRESS_1"            => "address_one",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.B_ADDRESS_2"            => "address_two",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.B_UNIT"              => "unit",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.B_CITY"              => "city",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.B_STATE"             => "state_code",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.B_ZIPCODE"           => "zip",

      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_ADDRESS_1"            => "address_one",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_ADDRESS_2"            => "address_two",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_UNIT"              => "unit",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_CITY"              => "city",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_STATE"             => "state_code",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_ZIPCODE"           => "zip",
    }

    PPG_STATUS_MAP = {
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.PREGNANT"        => "ppg_status_code",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.DUE_DATE"        => "orig_due_date",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.TRYING"          => "ppg_status_code",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.MED_UNABLE"      => "ppg_status_code",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT"        => "ppg_status_code",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.DUE_DATE"        => "orig_due_date",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.TRYING"          => "ppg_status_code",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.MED_UNABLE"      => "ppg_status_code"
    }

    INSTITUTION_MAP = {
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.BIRTH_PLAN"         => "institute_type_code",
      "#{PREGNANCY_VISIT_LI_INTERVIEW_PREFIX}.BIRTH_PLACE"        => "institute_name",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.BIRTH_PLAN"       => "institute_type_code",
      "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.BIRTH_PLACE"      => "institute_name"
    }

    def maps
      [ BIRTH_ADDRESS_MAP, PPG_STATUS_MAP, INSTITUTION_MAP ]
    end

    def extract_data

      ppg_status_history = nil

      birth_address, institution = process_birth_institution_and_address(BIRTH_ADDRESS_MAP, INSTITUTION_MAP)

      finalize_institution_with_birth_address(birth_address, institution)

      PPG_STATUS_MAP.each do |key, attribute|
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
            when "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT"
              set_value(ppg_status_history, attribute, value)
            end

            if (key == "#{PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.DUE_DATE") && !value.blank?
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
