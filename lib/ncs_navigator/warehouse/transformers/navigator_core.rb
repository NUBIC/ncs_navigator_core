require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/models/two_point_zero'

module NcsNavigator::Warehouse::Transformers
  class NavigatorCore
    include Database
    include NcsNavigator::Warehouse::Models::TwoPointZero

    bcdatabase :name => 'ncs_navigator_core'

    on_unused_columns :fail
    ignored_columns :id, :transaction_type, :updated_at, :created_at, :being_processed

    produce_records :people do |row|
      model_row(Person, row,
        :column_map => {
          :language_code => :person_lang,
          :language_other => :person_lang_oth,
          :marital_status_code => :maristat,
          :marital_status_other => :maristat_oth,
          :preferred_contact_method_code => :pref_contact,
          :preferred_contact_method_other => :pref_contact_oth,
          :planned_move_code => :plan_move
        },
        :ignored_columns => %w(
           person_dob_date date_move_date
        )
      )
    end

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

    def self.person_associated_query(table)
      %Q(SELECT t.*, p.person_id AS public_person_id
         FROM #{table} t INNER JOIN people p ON t.person_id=p.id)
    end

    produce_records(:person_races, :query => person_associated_query('person_races')) do |row|
      model_row(PersonRace, row,
        :column_map => {
          :public_person_id => :person_id
        })
    end

    produce_records(:participants) do |row|
      model_row(Participant, row,
        :column_map => {
          :pid_age_eligibility_code => :pid_age_elig
        },
        :ignored_columns => %w(person_id high_intensity low_intensity_state high_intensity_state)
      )
    end

    produce_records(:participant_person_links, :query => %Q(
      SELECT lpp.*, p.person_id AS public_person_id, par.p_id
      FROM participant_person_links lpp
        INNER JOIN people p ON lpp.person_id=p.id
        INNER JOIN participants par ON lpp.participant_id=par.id
    )) do |row|
      model_row(LinkPersonParticipant, row,
        :column_map => {
          :relationship_code => :relation,
          :relationship_other => :relation_oth,
          :public_person_id => :person_id
        },
        :ignored_columns => %w(participant_id person_id)
      )
    end
  end
end
