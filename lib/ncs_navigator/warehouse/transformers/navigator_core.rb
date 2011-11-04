require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/models/two_point_zero'

module NcsNavigator::Warehouse::Transformers
  class NavigatorCore
    include Database
    include NcsNavigator::Warehouse::Models::TwoPointZero

    bcdatabase :name => 'ncs_navigator_core'

    on_unused_columns :fail
    ignored_columns :id, :transaction_type, :updated_at, :created_at

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
        :ignored_or_used => %w(
           person_dob_date date_move_date being_processed
        )
      )
    end
  end
end
