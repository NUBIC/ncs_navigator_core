require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/models/two_point_zero'

require 'ncs_navigator/warehouse/transformers/navigator_core_helpers'

module NcsNavigator::Warehouse::Transformers
  class NavigatorCore
    include Database
    include NcsNavigator::Warehouse::Models::TwoPointZero

    extend NavigatorCoreHelpers

    bcdatabase :name => 'ncs_navigator_core'

    on_unused_columns :fail
    ignored_columns :id, :transaction_type, :updated_at, :created_at, :being_processed

    produce_one_for_one(:people, Person,
      :column_map => {
        :language_code => :person_lang,
        :language_other => :person_lang_oth,
        :marital_status_code => :maristat,
        :marital_status_other => :maristat_oth,
        :preferred_contact_method_code => :pref_contact,
        :preferred_contact_method_other => :pref_contact_oth,
        :planned_move_code => :plan_move
      },
      :ignored_columns => %w(person_dob_date date_move_date)
    )

    # TODO: maybe unnecessary
#    produce_records :link_participant_self_person, :query => %Q(
#      SELECT p.person_id, par.p_id
#      FROM people p INNER JOIN participants par ON p.id=par.person_id
#    ) do |row|
#      LinkPersonParticipant.new(
#        :person_pid_id => [row.p_id, '-self'].join(''),
#        :person_id => row.person_id,
#        :p_id => row.p_id,
#        :relation => '1', # self
#        :is_active => '1' # yes
#      )
#    end

    produce_one_for_one(:person_races, PersonRace, :public_ids => %w(people))

    produce_one_for_one(:participants, Participant,
      :column_map => {
        :pid_age_eligibility_code => :pid_age_elig
      },
      :ignored_columns => %w(person_id high_intensity low_intensity_state high_intensity_state)
    )

    produce_one_for_one(:participant_person_links, LinkPersonParticipant,
      :public_ids => %w(people participants),
      :column_map => {
        :relationship_code => :relation,
        :relationship_other => :relation_oth,
        :public_person_id => :person_id
      }
    )

    produce_one_for_one(:participant_consents, ParticipantConsent,
      :public_ids => %w(participants)
    )

    produce_one_for_one(:participant_consent_samples, ParticipantConsentSample,
      :public_ids => %w(participants participant_consents)
    )

    produce_one_for_one(:participant_authorization_forms, ParticipantAuth,
      :public_ids => %w(participants contacts)
    )

    produce_one_for_one(:participant_visit_consents, ParticipantVisConsent,
      :public_ids => [
        :participants,
        :contacts,
        { :table => :people,
          :public_id => :person_id,
          :public_ref => :vis_person_who_consented_id }
      ]
    )

    produce_one_for_one(:participant_visit_records, ParticipantRvis,
      :public_ids => [
        :participants,
        :contacts,
        { :table => :people,
          :public_id => :person_id,
          :join_column => :rvis_person_id,
          :public_ref => :rvis_person }
      ]
    )
  end
end
