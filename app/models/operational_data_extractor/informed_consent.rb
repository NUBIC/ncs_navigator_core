# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class InformedConsent < Base

    PARTICIPANT_CONSENT_MAP = {
      "PARTICIPANT_CONSENT.CONSENT_FORM_TYPE_CODE"              => "consent_form_type_code",
      "PARTICIPANT_CONSENT.CONSENT_GIVEN_CODE"                  => "consent_given_code",
      "PARTICIPANT_CONSENT.CONSENT_DATE"                        => "consent_date",
      "PARTICIPANT_CONSENT.CONSENT_VERSION"                     => "consent_version",
      "PARTICIPANT_CONSENT.CONSENT_EXPIRATION"                  => "consent_expiration",
      "PARTICIPANT_CONSENT.WHO_CONSENTED_CODE"                  => "who_consented_code",
      "PARTICIPANT_CONSENT.CONSENT_LANGUAGE_CODE"               => "consent_language_code",
      "PARTICIPANT_CONSENT.CONSENT_TRANSLATE_CODE"              => "consent_translate_code",
      "PARTICIPANT_CONSENT.RECONSIDERATION_SCRIPT_USE_CODE"     => "reconsideration_script_use_code",
      "PARTICIPANT_CONSENT.CONSENT_COMMENTS"                    => "consent_comments",
      "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_CODE"               => "consent_withdraw_code",
      "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_TYPE_CODE"          => "consent_withdraw_type_code",
      "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_REASON_CODE"        => "consent_withdraw_reason_code",
      "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_DATE"               => "consent_withdraw_date",
      "PARTICIPANT_CONSENT.CONSENT_RECONSENT_CODE"              => "consent_reconsent_code",
      "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_CODE"       => "consent_reconsent_reason_code",
      "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_OTHER"      => "consent_reconsent_reason_other",
    }

    # TODO: PARTICIPANT_CONSENT_SAMPLE
    # "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_1"
    # "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_2"
    # "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_3"

    def initialize(response_set)
      super(response_set)
    end

    def maps
      [PARTICIPANT_CONSENT_MAP]
    end

    def extract_data
      consent = response_set.participant_consent
      raise InvalidSurveyException("No ParticipantConsent record associated with Response Set") unless consent

      PARTICIPANT_CONSENT_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            consent.send("#{attribute}=", value)
          end
        end
      end
      consent.save!
    end
  end

  class InvalidSurveyException < StandardError; end
end