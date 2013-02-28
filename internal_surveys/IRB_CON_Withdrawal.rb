# -*- coding: utf-8 -*-
survey "IRB_CON_Withdrawal", :instrument_type => 10, :description => "Withdrawal", :instrument_version => "1.0" do
  section "Withdrawal" do
    q_prepopulated_psu_id "PSU#",
      :custom_class => "prepopulated"
      a_psu_id :string

    q_consent_withdraw_code "Consent Withdraw",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_CODE"
      a_1 "YES"
      a_2 "NO"

    q_consent_withdraw_type_code "Consent Withdraw Type",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_TYPE_CODE"
      a_1 "VOLUNTARY WITHDRAWAL INITIATED BY THE PARTICIPANT"
      a_2 "INVOLUNTARY WITHDRAWAL INITIATED BY THE STUDY"
      a_neg_3 "LEGITIMATE SKIP"

    q_consent_withdraw_reason_code "Consent Withdraw Reason",
      :pick => :one,
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_TYPE_CODE"
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
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_WITHDRAW_DATE"
      a_consent_date :date, :custom_class => "date"

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

    q_consent_comments "Comments (optional)",
      :data_export_identifier => "PARTICIPANT_CONSENT.CONSENT_COMMENTS"
      a_consent_comments :text

  end
end