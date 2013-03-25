# -*- coding: utf-8 -*-
survey "IRB_CON_NonInterviewReport", :instrument_type => "-5", :description => "Non Interview Report", :instrument_version => "1.0" do
  section "Non Interview Report" do

    # Should this be anything other than REFUSAL ?
    q_nir_type_person_code "Description of Non-Interview of Person",
      :pick => :one,
      :data_export_identifier => "NON_INTERVIEW_REPORT.NIR_TYPE_PERSON_CODE"
      a_1 "COGNITIVE DISABILITY"
      a_2 "DECEASED"
      a_3 "REFUSAL"
      a_4 "LONG-TERM ILLNESS"
      a_5 "UNAVAILABLE TO PARTICIPATE"
      a_6 "MOVED"
      a_neg_5 "OTHER"

    q_nir_type_person_other "Description of Non-Interview of Person (other)",
      :data_export_identifier => "NON_INTERVIEW_REPORT.NIR_TYPE_PERSON_OTHER"
      a_nir_type_person_other :string
      dependency :rule => "A"
      condition_A :q_nir_type_person_code, "==", :a_neg_5

    q_nir "Report Text",
      :data_export_identifier => "NON_INTERVIEW_REPORT.NIR"
      a_nir :text

    q_who_refused_code "Relationship of informant to participant",
      :pick => :one,
      :data_export_identifier => "NON_INTERVIEW_REPORT.WHO_REFUSED_CODE"
      a_1 "PARTICIPANT/SELF"
      a_2 "PARENT OR LEGAL GUARDIAN"
      a_3 "SPOUSE"
      a_4 "PARTNER/SIGNIFICANT OTHER"
      a_5 "HOUSEHOLD MEMBER"
      a_6 "NON-HOUSEHOLD MEMBER"
      a_neg_6 "UNKNOWN"
      a_neg_5 "OTHER"

    q_who_refused_other "Relationship of informant to participant (Other)",
      :data_export_identifier => "NON_INTERVIEW_REPORT.WHO_REFUSED_OTHER"
      a_who_refused_other :string
      dependency :rule => "A"
      condition_A :q_who_refused_code, "==", :a_neg_5

    q_refuser_strength_code "Strength/Intensity of Refusal",
      :pick => :one,
      :data_export_identifier => "NON_INTERVIEW_REPORT.REFUSER_STRENGTH_CODE"
      a_1 "MILD, NON-HOSTILE"
      a_2 "FIRM, NON-HOSTILE"
      a_3 "HOSTILE"
      a_neg_6 "UNKNOWN"
      a_neg_7 "NOT APPLICABLE"

    q_refusal_action_code "Recommended next steps for case",
      :pick => :one,
      :data_export_identifier => "NON_INTERVIEW_REPORT.REFUSAL_ACTION_CODE"
      a_1 "RECOMMENDED NO MORE CONTACTS; SUPERVISOR REVIEW NEEDED"
      a_2 "FURTHER ATTEMPTS RECOMMENDED"
      a_neg_7 "NOT APPLICABLE"

    repeater "Refusal Non-Interview Report" do
      q_refusal_nir_reason "Refusal Reason",
        :pick => :one,
        :data_export_identifier => "REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_CODE"
        a_1 "TOO BUSY/NO TIME"
        a_2 "CONFIDENTIALITY/PRIVACY ISSUES"
        a_3 "NOT INTERESTED"
        a_4 "NOTHING IN IT FOR ME"
        a_5 "GOVERNMENT INTERFERENCE"
        a_6 "DO NOT BELIEVE IN STUDIES"
        a_7 "AFRAID TO PARTICIPATE"
        a_8 "THINK IT'S A SCAM OR TRYING TO SELL SOMETHING"
        a_9 "WASTE OF TIME/MONEY"
        a_neg_6 "UNKNOWN"
        a_neg_5 "OTHER"
        a_neg_7 "NOT APPLICABLE"

      q_refusal_nir_reason_other "Refusal Reason (Other)",
        :help_text => "Only enter if Refusal Reason above is 'OTHER'",
        :data_export_identifier => "REFUSAL_NON_INTERVIEW_REPORT.REFUSAL_REASON_OTHER"
        a_refusal_nir_reason_other :string
    end
  end
end