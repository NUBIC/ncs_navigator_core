# -*- coding: utf-8 -*-
survey "IRB_CON_Informed_Consent", :instrument_type => 10, :description => "Informed Consent", :instrument_version => "1.0" do
  section "Informed Consent" do
    q_consent_form_type_code "Consent Form Type",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_FORM_TYPE_CODE"
      a_1 "PREGNANT WOMAN CONSENT"
      a_2 "NON-PREGNANT WOMAN CONSENT"
      a_3 "FATHER CONSENT"
      a_4 "CHILD CONSENT BIRTH TO 6-MONTHS"
      a_5 "CHILD CONSENT 6-MONTHS TO AGE OF MAJORITY"
      a_6 "NEW ADULT CONSENT"
      a_7 "LOW INTENSITY CONSENT"
      a_neg_7 "NOT APPLICABLE"

    q_consent_given_code "Consent Given",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_GIVEN_CODE"
      a_1 "YES"
      a_2 "NO"

    q_sample_consent_given_1 "Consent to collect environmental samples",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_1"
      a_1 "YES"
      a_2 "NO"

    q_sample_consent_given_2 "Consent to collect biospecimens",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_2"
      a_1 "YES"
      a_2 "NO"

    q_sample_consent_given_3 "Consent to collect genetic material",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT_SAMPLE.SAMPLE_CONSENT_GIVEN_CODE_3"
      a_1 "YES"
      a_2 "NO"

    q_consent_date "Consent Date",
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_DATE"
      a_consent_date :string, :custom_class => "date"

    q_consent_version "Consent Version",
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_VERSION"
      a_consent_version :string

    q_consent_expiration "Consent Expiration Date",
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_EXPIRATION"
      a_consent_expiration :string, :custom_class => "date"

    q_who_consented_code "Who Consented?",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.WHO_CONSENTED_CODE"
      a_1 "EMANCIPATED MINOR"
      a_2 "ADULT AT AGE OF MAJORITY OR OLDER"
      a_3 "PARENT OR LEGAL GUARDIAN OF MINOR"

    q_consent_language_code "Language",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_LANGUAGE_CODE"
      a_1 "ENGLISH"
      a_2 "SPANISH"
      a_3 "ARABIC"
      a_4 "CHINESE"
      a_5 "FRENCH"
      a_6 "FRENCH CREOLE"
      a_7 "GERMAN"
      a_8 "ITALIAN"
      a_9 "KOREAN"
      a_10 "POLISH"
      a_11 "RUSSIAN"
      a_12 "TAGALOG"
      a_13 "VIETNAMESE"
      a_14 "URDU"
      a_15 "PUNJABI"
      a_16 "BENGALI"
      a_17 "FARSI"
      a_neg_1 "REFUSED"
      a_neg_5 "OTHER"
      a_neg_6 "UNKNOWN"

    q_consent_translate_code "Consent Translated",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_TRANSLATE_CODE"
      a_1 "NO TRANSLATION NEEDED"
      a_2 "BILINGUAL INTERVIEWER"
      a_3 "IN-PERSON PROFESSIONAL INTERPRETER"
      a_4 "IN PERSON FAMILY MEMBER INTERPRETER"
      a_5 "LANGUAGE-LINE INTERPRETER"
      a_6 "VIDEO INTERPRETER"

    q_reconsideration_script_use_code "Reconsideration Script Use",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.RECONSIDERATION_SCRIPT_USE_CODE"
      a_1 "YES"
      a_2 "NO"
      a_neg_7 "NOT APPLICABLE"

    q_consent_comments "Comments (optional)",
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_COMMENTS"
      a_consent_comments :text
  end
end