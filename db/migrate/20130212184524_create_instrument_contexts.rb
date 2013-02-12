class CreateInstrumentContexts < ActiveRecord::Migration
  def change
    create_table :instrument_contexts do |t|
      t.references :response_set, :null => false
      t.timestamps
    end
  end
end
