# -*- coding: utf-8 -*-

Factory.define :participant_consent do |pc|

  pc.association :participant, :factory => :participant
  pc.association :contact, :factory => :contact
  pc.association :person_who_consented, :factory => :person
  pc.person_wthdrw_consent nil

  pc.psu                      { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  pc.consent_type             { |a| a.association(:ncs_code, :list_name => "CONSENT_TYPE_CL1", :display_text => "General Consent", :local_code => 1) }
  pc.consent_form_type        { |a| a.association(:ncs_code, :list_name => "CONSENT_TYPE_CL1", :display_text => "General Consent", :local_code => 1) }
  pc.consent_given            { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  pc.consent_withdraw         { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "No", :local_code => 2) }
  pc.consent_withdraw_type    { |a| a.association(:ncs_code, :list_name => "CONSENT_WITHDRAW_REASON_CL1", :display_text => "Voluntary withdrawal initiated by the Participant", :local_code => 1) }
  pc.consent_withdraw_reason  { |a| a.association(:ncs_code, :list_name => "CONSENT_WITHDRAW_REASON_CL2", :display_text => "Time Commitment", :local_code => 2) }

  pc.consent_language         { |a| a.association(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1) }
  pc.who_consented            { |a| a.association(:ncs_code, :list_name => "AGE_STATUS_CL1", :display_text => "Adult", :local_code => 2) }
  pc.who_wthdrw_consent       { |a| a.association(:ncs_code, :list_name => "AGE_STATUS_CL3", :display_text => "Adult", :local_code => 2) }

  pc.consent_translate          { |a| a.association(:ncs_code, :list_name => "TRANSLATION_METHOD_CL1", :display_text => "No Translation Needed", :local_code => 1) }
  pc.reconsideration_script_use { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.consent_version "1.2"

end

Factory.define :participant_visit_consent do |pc|

  pc.association :participant, :factory => :participant
  pc.association :contact, :factory => :contact
  pc.association :vis_person_who_consented, :factory => :person

  pc.psu                  { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  pc.vis_consent_type     { |a| a.association(:ncs_code, :list_name => "VISIT_TYPE_CL1", :display_text => "Interviewer-Administered Questionnaire", :local_code => 1) }
  pc.vis_consent_response { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
  pc.vis_language         { |a| a.association(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1) }
  pc.vis_who_consented    { |a| a.association(:ncs_code, :list_name => "AGE_STATUS_CL1", :display_text => "Adult", :local_code => 2) }
  pc.vis_translate        { |a| a.association(:ncs_code, :list_name => "TRANSLATION_METHOD_CL1", :display_text => "No Translation Needed", :local_code => 1) }

end

Factory.define :participant_authorization_form do |paf|

  paf.association :participant, :factory => :participant
  paf.association :contact, :factory => :contact
  # paf.association :provider, :factory => :provider

  paf.psu            { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  paf.auth_form_type { |a| a.association(:ncs_code, :list_name => "AUTH_FORM_TYPE_CL1", :display_text => "HIPPA Auth", :local_code => 1) }
  paf.auth_status    { |a| a.association(:ncs_code, :list_name => "AUTH_STATUS_CL1", :display_text => "Authorization Requested and Granted", :local_code => 1) }

end

Factory.define :participant_consent_sample do |pcs|

  pcs.association :participant, :factory => :participant
  pcs.association :participant_consent, :factory => :participant_consent

  pcs.psu                   { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  pcs.sample_consent_type   { |a| a.association(:ncs_code, :list_name => "CONSENT_TYPE_CL2", :display_text => "Consent to collect", :local_code => 1) }
  pcs.sample_consent_given  { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }

end

Factory.define :participant_visit_record do |pc|

  pc.association :participant, :factory => :participant
  pc.association :contact, :factory => :contact
  pc.association :rvis_person, :factory => :person

  pc.psu                  { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  pc.rvis_language        { |a| a.association(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1) }
  pc.rvis_who_consented   { |a| a.association(:ncs_code, :list_name => "AGE_STATUS_CL1", :display_text => "Adult", :local_code => 2) }
  pc.rvis_translate       { |a| a.association(:ncs_code, :list_name => "TRANSLATION_METHOD_CL1", :display_text => "No Translation Needed", :local_code => 1) }

  pc.rvis_sections        { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.rvis_during_interv   { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.rvis_during_bio      { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.rvis_bio_cord        { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.rvis_during_env      { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.rvis_during_thanks   { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.rvis_after_saq       { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }
  pc.rvis_reconsideration { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL21", :display_text => "Yes", :local_code => 1) }

end