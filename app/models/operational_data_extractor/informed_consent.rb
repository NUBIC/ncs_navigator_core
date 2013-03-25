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
      "PARTICIPANT_CONSENT.WHO_WITHDREW_CONSENT"                => "who_wthdrw_consent_code",
      "PARTICIPANT_CONSENT.CONSENT_RECONSENT_CODE"              => "consent_reconsent_code",
      "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_CODE"       => "consent_reconsent_reason_code",
      "PARTICIPANT_CONSENT.CONSENT_RECONSENT_REASON_OTHER"      => "consent_reconsent_reason_other",
    }

    PARTICIPANT_CONSENT_SAMPLE_MAP = {
      "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_1"  => "sample_consent_given_code",
      "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_2"  => "sample_consent_given_code",
      "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_3"  => "sample_consent_given_code",
    }

    def initialize(response_set)
      super(response_set)
    end

    def maps
      [
        PARTICIPANT_CONSENT_MAP,
        PARTICIPANT_CONSENT_SAMPLE_MAP,
      ]
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

      # Set values on the ParticipantConsentSamples
      ParticipantConsentSample::SAMPLE_CONSENT_TYPE_CODES.each do |code|
        samples = consent.participant_consent_samples.where(:sample_consent_type_code => code).all
        # There should be only one - but might as well update all samples associated with this consent
        samples.each do |sample|
          key = "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_#{code}"
          if r = data_export_identifier_indexed_responses[key]
            value = response_value(r)
            unless value.blank?
              sample.sample_consent_given_code = value
              sample.save!
            end
          end
        end
      end
      update_enrollment_status(consent)

      consent.save!
    end

    ##
    # Either enroll or unenroll the participant based on the
    # recently updated participant consent
    # @param [ParticipantConsent]
    def update_enrollment_status(consent)
      participant = consent.participant
      if consent.consented?
        participant.update_enrollment_status!(true, consent.consent_date) unless participant.enrolled?
      elsif consent.withdrawn?
        participant.update_enrollment_status!(false)
      else
        participant.update_enrollment_status!(false)
      end
    end
  end

  class InvalidSurveyException < StandardError; end
end