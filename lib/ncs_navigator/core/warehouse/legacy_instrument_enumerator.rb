require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  class LegacyInstrumentEnumerator
    include NcsNavigator::Warehouse::Transformers::Database

    bcdatabase :name => 'ncs_navigator_core'

    produce_records(
      :legacy_instrument_data_records,
      :query => <<-SQL
        WITH RECURSIVE child_records(parent_record_id, child_record_id, depth) AS (
            SELECT rec.parent_record_id, rec.id, 1 FROM legacy_instrument_data_records rec WHERE rec.parent_record_id IS NULL
          UNION
            SELECT rec_sub.parent_record_id, rec_sub.id, depth + 1
            FROM child_records ch, legacy_instrument_data_records rec_sub
            WHERE rec_sub.parent_record_id=ch.child_record_id
        )
        SELECT
          rec.mdes_table_name, rec.public_id,
          string_agg(val.mdes_variable_name, E'\\x1') variable_names,
          string_agg(val.value, E'\\x1') variable_values
        FROM legacy_instrument_data_records rec
          INNER JOIN child_records ch ON rec.id = ch.child_record_id
          LEFT JOIN legacy_instrument_data_values val ON rec.id=val.legacy_instrument_data_record_id
        GROUP BY rec.mdes_table_name, rec.public_id, ch.depth
        ORDER BY ch.depth ASC
      SQL
    ) do |row, meta|
      model = meta[:configuration].model(row.mdes_table_name)
      key = model.key.first.name
      model.new.tap { |i|
        i[key] = row.public_id
        if row.variable_names && row.variable_values
          row.variable_names.split("\1").zip(row.variable_values.split("\1")).each do |var, val|
            i[var] = val
          end
        end
      }
    end

  end
end
