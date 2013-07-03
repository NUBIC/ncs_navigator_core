# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class InformedConsent < Base

    PARTICIPANT_CONSENT_MAP = {
      "consent_form_type_code"              => "consent_form_type_code",
      "consent_given_code"                  => "consent_given_code",
      "consent_date"                        => "consent_date",
      "consent_version"                     => "consent_version",
      "consent_expiration"                  => "consent_expiration",
      "who_consented_code"                  => "who_consented_code",
      "consent_language_code"               => "consent_language_code",
      "consent_translate_code"              => "consent_translate_code",
      "reconsideration_script_use_code"     => "reconsideration_script_use_code",
      "consent_comments"                    => "consent_comments",
      "consent_withdraw_code"               => "consent_withdraw_code",
      "consent_withdraw_type_code"          => "consent_withdraw_type_code",
      "consent_withdraw_reason_code"        => "consent_withdraw_reason_code",
      "consent_withdraw_date"               => "consent_withdraw_date",
      "who_wthdrw_consent_code"             => "who_wthdrw_consent_code",
      "consent_reconsent_code"              => "consent_reconsent_code",
      "consent_reconsent_reason_code"       => "consent_reconsent_reason_code",
      "consent_reconsent_reason_other"      => "consent_reconsent_reason_other",
    }

    PARTICIPANT_CONSENT_SAMPLE_MAP = {
      "sample_consent_given_code_1"  => "sample_consent_given_code",
      "sample_consent_given_code_2"  => "sample_consent_given_code",
      "sample_consent_given_code_3"  => "sample_consent_given_code",
      "collect_specimen_consent"     => "collect_specimen_consent"
    }

    def maps
      [
        PARTICIPANT_CONSENT_MAP,
        PARTICIPANT_CONSENT_SAMPLE_MAP,
      ]
    end

    def extract_data
      consent = response_set.participant_consent
      raise InvalidSurveyException, "No ParticipantConsent record associated with Response Set" unless consent

      PARTICIPANT_CONSENT_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            consent.send("#{attribute}=", value)
          end
        end
      end

      # Set values on the ParticipantConsentSamples
      create_or_update_participant_consent_sample_records(data_export_identifier_indexed_responses, consent)

      update_enrollment_status(consent)

      if consent.withdrawal? && consent.person_wthdrw_consent.nil?
        consent.person_wthdrw_consent = response_set.person
      end

      consent.save!
    end

    ##
    # If the respondant answered YES to the question "Should Specimen/Sample Consent be asked?"
    # create ParticipantConsentSample records associated with the given ParticipantConsent.
    # @param data_export_identifier_indexed_responses [Hash]
    # @param consent [ParticipantConsent]
    def create_or_update_participant_consent_sample_records(data_export_identifier_indexed_responses, consent)
      if create_samples_response = data_export_identifier_indexed_responses['collect_specimen_consent']
        if response_value(create_samples_response).to_i == NcsCode::YES
          ParticipantConsentSample::SAMPLE_CONSENT_TYPE_CODES.each do |code|
            if r = data_export_identifier_indexed_responses["sample_consent_given_code_#{code}"]
              if value = response_value(r)
                psc = consent.participant_consent_samples.where(:sample_consent_type_code => code).first
                if psc
                  psc.update_attribute(:sample_consent_given_code, value)
                else
                  consent.participant_consent_samples.create(
                    :sample_consent_type_code => code, :sample_consent_given_code => value)
                end
              end
            end
          end
        end
      end
    end
    private :create_or_update_participant_consent_sample_records

    ##
    # Either enroll or unenroll the participant based on the
    # recently updated participant consent
    # @param [ParticipantConsent]
    def update_enrollment_status(consent)
      participant = consent.participant
      if consent.consented?
        participant.consent_to_study!(consent)
      else
        participant.withdraw_from_study!(consent)
      end
    end
    private :update_enrollment_status
  end
end