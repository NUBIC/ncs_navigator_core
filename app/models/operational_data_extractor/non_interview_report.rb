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

    # TODO: REFUSAL_NON_INTERVIEW_REPORT
    # "REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_CODE"                     => "REFUSAL_REASON_OTHER",
    # "REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_OTHER"                  => "WHO_REFUSED_OTHER",


    def initialize(response_set)
      super(response_set)
    end

    def maps
      [NON_INTERVIEW_REPORT_MAP]
    end

    def extract_data
      nir = response_set.non_interview_report
      raise InvalidSurveyException("No Non-Interview Report record associated with Response Set #{response_set.id}") unless nir

      NON_INTERVIEW_REPORT_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            nir.send("#{attribute}=", value)
          end
        end
      end

      # WIP
      # REFUSAL_NON_INTERVIEW_REPORT_MAP.each do |key, attribute|
      #   nir.build_refusal_non_interview_report(ATTRIBUTES GO HERE)
      # end

      nir.save!
    end
  end

  class InvalidSurveyException < StandardError; end
end