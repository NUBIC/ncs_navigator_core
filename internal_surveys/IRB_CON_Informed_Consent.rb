# -*- coding: utf-8 -*-
survey "IRB_CON_Informed_Consent", :instrument_type => "-5", :description => "Informed Consent", :instrument_version => "1.0" do

  section "Informed Consent" do

    q_consent_type "What type of Consent is this?",
      :data_export_identifier => "consent_type",
      :pick => :one
      a_1 "INFORMED CONSENT"
      a_2 "RECONSENT"
      a_3 "WITHDRAWAL"

    q_consent_form_type_code "Consent Form Type",
      :pick => :one,
      :data_export_identifier => "consent_form_type_code"
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
      :data_export_identifier => "consent_given_code"
      a_1 "YES"
      a_2 "NO"

    q_consent_date "Consent Date",
      :data_export_identifier => "consent_date"
      a_consent_date :string, :custom_class => "date"

    q_consent_version "Consent Version",
      :data_export_identifier => "consent_version"
      a_consent_version :string

    group "Informed Consent" do
      dependency :rule => "A"
      condition_A :q_consent_type, "==", :a_1

      q_consent_expiration "Consent Expiration Date",
        :data_export_identifier => "consent_expiration"
        a_consent_expiration :string, :custom_class => "date"

      q_who_consented_code "Who Consented?",
        :pick => :one,
        :data_export_identifier => "who_consented_code"
        a_1 "EMANCIPATED MINOR"
        a_2 "ADULT AT AGE OF MAJORITY OR OLDER"
        a_3 "PARENT OR LEGAL GUARDIAN OF MINOR"
    end

    group "Reconsent" do
      dependency :rule => "A"
      condition_A :q_consent_type, "==", :a_2

      q_consent_reconsent_code "Is this a reconsent?",
        :pick => :one,
        :data_export_identifier => "consent_reconsent_code"
        a_1 "YES"
        a_2 "NO"

      q_consent_reconsent_reason_code "Reconsent reason",
        :pick => :one,
        :data_export_identifier => "consent_reconsent_reason_code"
        a_1 "Updated consent booklet, local IRB requirement"
        a_2 "Updated signature page only, local IRB requirement"
        a_3 "Moved into PSU"
        a_4 "Later agreed to specimen or sample or genetic testing"
        a_5 "Withdrew consent for specimen or sample or genetic testing"
        a_6 "Child turned 6 months old"
        a_7 "Child turned 18 years old/local age of majority"
        a_8 "New caregiver re-consent for child"
        a_9 "Rejoined study after withdrawal"
        a_10 "Conversion from Low-intensity to High-intensity group"
        a_11 "Transitioned to new data collection organization"
        a_12 "Subsequent Pregnancy"
        a_13 "Previously administered consent was not properly administered"
        a_neg_5 "Other"
        a_neg_7 "Not applicable"
        dependency :rule => "A"
        condition_A :q_consent_reconsent_code, "==", :a_1

      q_consent_reconsent_reason_other "Reconsent Reason Other",
        :data_export_identifier => "consent_reconsent_reason_other"
        a_consent_reconsent_reason_other :string
        dependency :rule => "A"
        condition_A :q_consent_reconsent_reason_code, "==", :a_neg_5
    end

    group "Withdrawal" do
      dependency :rule => "A or B"
      condition_A :q_consent_type, "==", :a_3
      condition_B :q_consent_given_code, "==", :a_2

      q_consent_withdraw_code "Consent Withdrawn?",
        :pick => :one,
        :data_export_identifier => "consent_withdraw_code"
        a_1 "YES"
        a_2 "NO"

      q_consent_withdraw_type_code "Consent Withdraw Type",
        :pick => :one,
        :data_export_identifier => "consent_withdraw_type_code"
        a_1 "VOLUNTARY WITHDRAWAL INITIATED BY THE PARTICIPANT"
        a_2 "INVOLUNTARY WITHDRAWAL INITIATED BY THE STUDY"
        a_neg_3 "LEGITIMATE SKIP"

      q_consent_withdraw_reason_code "Consent Withdraw Reason",
        :pick => :one,
        :data_export_identifier => "consent_withdraw_reason_code"
        a_1 "FAMILY REASONS"
        a_2 "TIME COMMITMENT"
        a_3 "SAFETY CONCERNS"
        a_4 "CONFIDENTIALITY CONCERNS"
        a_5 "GENETIC CONCERNS"
        a_6 "MOVING"
        a_7 "SOCIAL/RELIGIOUS REASON"
        a_8 "LACK OF INCENTIVES/COMPENSATION NOT ADEQUATE"
        a_9 "MEDICAL ISSUES"
        a_10 "NO LONGER FEELS STUDY IS IMPORTANT"
        a_11 "MISTRUST/ISSUES WITH STUDY STAFF/PERSONNEL"
        a_12 "GOALS OF STUDY NOT CONGRUENT WITH ORIGINAL UNDERSTANDING"
        a_13 "LOST INTEREST IN PARTICIPATING"
        a_14 "SPOUSE/PARTNER NOT SUPPORTIVE OF PARTICIPATION"
        a_15 "EXTERNAL PRESSURE TO WITHDRAW"
        a_16 "HEARD BAD THINGS ABOUT THE STUDY"
        a_17 "SCARED/AFRAID"
        a_18 "NO REASON"
        a_neg_5 "OTHER"

      q_consent_withdraw_date "Consent Withdraw Date",
        :data_export_identifier => "consent_withdraw_date"
        a_consent_withdraw_date :string, :custom_class => "date"

      q_who_wthdrw_consent_code "Who Withdrew Consent",
        :pick => :one,
        :data_export_identifier => "who_wthdrw_consent_code"
        a_1 "EMANCIPATED MINOR"
        a_2 "ADULT AT AGE OF MAJORITY OR OLDER"
        a_3 "PARENT OR LEGAL GUARDIAN OF MINOR"
    end

    q_collect_specimen_consent "Should Specimen/Sample Consent be asked?",
      :data_export_identifier => "collect_specimen_consent",
      :pick => :one
      a_1 "YES"
      a_2 "NO"
      dependency :rule => "A and B"
      condition_A :q_consent_type, "!=", :a_3
      condition_B :q_consent_given_code, "==", :a_1

    group "Specimen/Sample Consent" do
      dependency :rule => "A"
      condition_A :q_collect_specimen_consent, "==", :a_1

      q_sample_consent_given_1 "Consent to collect environmental samples",
        :pick => :one,
        :data_export_identifier => "sample_consent_given_code_1"
        a_1 "YES"
        a_2 "NO"

      q_sample_consent_given_2 "Consent to collect biospecimens",
        :pick => :one,
        :data_export_identifier => "sample_consent_given_code_2"
        a_1 "YES"
        a_2 "NO"

      q_sample_consent_given_3 "Consent to collect genetic material",
        :pick => :one,
        :data_export_identifier => "sample_consent_given_code_3"
        a_1 "YES"
        a_2 "NO"
    end

    q_consent_language_code "Language",
      :pick => :one,
      :data_export_identifier => "consent_language_code"
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
      :data_export_identifier => "consent_translate_code"
      a_1 "NO TRANSLATION NEEDED"
      a_2 "BILINGUAL INTERVIEWER"
      a_3 "IN-PERSON PROFESSIONAL INTERPRETER"
      a_4 "IN PERSON FAMILY MEMBER INTERPRETER"
      a_5 "LANGUAGE-LINE INTERPRETER"
      a_6 "VIDEO INTERPRETER"

    q_reconsideration_script_use_code "Reconsideration Script Use",
      :pick => :one,
      :data_export_identifier => "reconsideration_script_use_code"
      a_1 "YES"
      a_2 "NO"
      a_neg_7 "NOT APPLICABLE"

    q_consent_comments "Comments (optional)",
      :data_export_identifier => "consent_comments"
      a_consent_comments :text
  end
end