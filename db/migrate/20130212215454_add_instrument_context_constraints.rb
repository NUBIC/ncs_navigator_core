class AddInstrumentContextConstraints < ActiveRecord::Migration
  def up
    add_foreign_key 'instrument_context_elements', 'instrument_contexts'
    add_foreign_key 'instrument_contexts', 'response_sets'
  end

  def down
    remove_foreign_key 'instrument_context_elements', 'instrument_contexts'
    remove_foreign_key 'instrument_contexts', 'response_sets'
  end
end
