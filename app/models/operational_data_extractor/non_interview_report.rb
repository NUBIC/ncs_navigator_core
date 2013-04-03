# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class NonInterviewReport < Base

    NON_INTERVIEW_REPORT_MAP = {
      "NON_INTERVIEW_REPORT.NIR_TYPE_PERSON_CODE"       => "nir_type_person_code",
      "NON_INTERVIEW_REPORT.NIR_TYPE_PERSON_OTHER"      => "nir_type_person_other",
      "NON_INTERVIEW_REPORT.NIR"                        => "nir",
      "NON_INTERVIEW_REPORT.WHO_REFUSED_CODE"           => "who_refused_code",
      "NON_INTERVIEW_REPORT.WHO_REFUSED_OTHER"          => "who_refused_other",
      "NON_INTERVIEW_REPORT.REFUSER_STRENGTH_CODE"      => "refuser_strength_code",
      "NON_INTERVIEW_REPORT.REFUSAL_ACTION_CODE"        => "refusal_action_code",
    }

    REFUSAL_NON_INTERVIEW_REPORT_MAP = {
      "REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_CODE"  => "refusal_reason_code",
      "REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_OTHER" => "refusal_reason_other",
    }

    def maps
      [
        NON_INTERVIEW_REPORT_MAP,
        REFUSAL_NON_INTERVIEW_REPORT_MAP,
      ]
    end

    def extract_data
      nir = response_set.non_interview_report
      raise InvalidSurveyException, "No Non-Interview Report record associated with Response Set #{response_set.id}" unless nir

      NON_INTERVIEW_REPORT_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            nir.send("#{attribute}=", value)
          end
        end
      end

      refusal_reason_responses = collect_pick_any_responses("REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_CODE")
      refusal_reason_other_responses = collect_pick_any_responses("REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_OTHER")

      refusal_reason_responses.each do |r|
        value = response_value(r)
        unless value.blank?
          attrs = {:refusal_reason_code => value, :psu => nir.psu}
          # determine the associated "other" response value for refusal reason code "other"
          if value == -5
            oth_resp = refusal_reason_other_responses.find { |rror| rror.response_group == r.response_group }
            oth_val = response_value(oth_resp)
            unless oth_val.blank?
              attrs[:refusal_reason_other] = oth_val
            end
          end
          nir.refusal_non_interview_reports.build(attrs)
        end
      end

      nir.save!
    end
  end
end