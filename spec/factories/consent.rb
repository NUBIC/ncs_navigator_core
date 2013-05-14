# -*- coding: utf-8 -*-


Factory.define :participant_consent do |pc|

  pc.association :participant, :factory => :participant
  pc.association :contact, :factory => :contact
  pc.association :person_who_consented, :factory => :person
  pc.association :response_set, :factory => :response_set
  pc.person_wthdrw_consent nil

  pc.psu_code                      20000030
  pc.consent_type_code             1
  pc.consent_form_type_code        1
  pc.consent_given_code            1
  pc.consent_withdraw_code         2
  pc.consent_withdraw_type_code    1
  pc.consent_withdraw_reason_code  2

  pc.consent_language_code         1
  pc.who_consented_code            2
  pc.who_wthdrw_consent_code       2

  pc.consent_translate_code          1
  pc.reconsideration_script_use_code 1
  pc.consent_version "1.2"

end

Factory.define :participant_visit_consent do |pc|

  pc.association :participant, :factory => :participant
  pc.association :contact, :factory => :contact
  pc.association :vis_person_who_consented, :factory => :person

  pc.psu_code                  20000030
  pc.vis_consent_type_code     1
  pc.vis_consent_response_code 1
  pc.vis_language_code         1
  pc.vis_who_consented_code    2
  pc.vis_translate_code        1

end

Factory.define :participant_authorization_form do |paf|

  paf.association :participant, :factory => :participant
  paf.association :contact, :factory => :contact
  paf.association :provider, :factory => :provider

  paf.psu_code            20000030
  paf.auth_form_type_code 1
  paf.auth_status_code    1

end

Factory.define :participant_consent_sample do |pcs|

  pcs.association :participant_consent, :factory => :participant_consent

  pcs.psu_code                   20000030
  pcs.sample_consent_type_code   1
  pcs.sample_consent_given_code  1

end

Factory.define :participant_visit_record do |pc|

  pc.association :participant, :factory => :participant
  pc.association :contact, :factory => :contact
  pc.association :rvis_person, :factory => :person

  pc.psu_code                  20000030
  pc.rvis_language_code        1
  pc.rvis_who_consented_code   2
  pc.rvis_translate_code       1

  pc.rvis_sections_code        1
  pc.rvis_during_interv_code   1
  pc.rvis_during_bio_code      1
  pc.rvis_bio_cord_code        1
  pc.rvis_during_env_code      1
  pc.rvis_during_thanks_code   1
  pc.rvis_after_saq_code       1
  pc.rvis_reconsideration_code 1

end
