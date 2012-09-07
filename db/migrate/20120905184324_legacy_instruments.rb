class LegacyInstruments < ActiveRecord::Migration
  def change
    create_table :legacy_instrument_data_records do |t|
      t.references :instrument, :null => false
      t.references :parent_record

      t.string :mdes_version, :null => false, :limit => 16
      t.string :mdes_table_name, :null => false, :limit => 100
      t.string :public_id, :null => false, :limit => 36
      t.integer :psu_id, :limit => 16

      t.timestamps
    end

    add_foreign_key :legacy_instrument_data_records, :instruments,
      :name => 'fk_legacy_instrument_data_record_instrument'
    add_index :legacy_instrument_data_records, :instrument_id, :unique => false,
      :name => 'idx_legacy_instrument_data_record_instrument'

    add_foreign_key :legacy_instrument_data_records, :legacy_instrument_data_records,
      :column => :parent_record_id,
      :name => 'fk_legacy_instrument_data_record_parent_record'

    create_table :legacy_instrument_data_values do |t|
      t.references :legacy_instrument_data_record, :null => false

      t.string :mdes_variable_name, :null => false, :limit => 50
      t.text :value

      t.timestamps
    end

    add_foreign_key :legacy_instrument_data_values, :legacy_instrument_data_records,
      :name => 'fk_legacy_instrument_data_value_record'
    add_index :legacy_instrument_data_values, :legacy_instrument_data_record_id,
      :unique => false, :name => 'idx_legacy_instrument_data_value_record'
  end
end
