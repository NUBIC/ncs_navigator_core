class CreateInstrumentContextElements < ActiveRecord::Migration
  def change
    create_table :instrument_context_elements do |t|
      t.references :instrument_context, :null => false
      t.string :key
      t.text :value
      t.timestamps
    end
  end
end
