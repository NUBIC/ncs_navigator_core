class EnsureResponsesHaveResponseSets < ActiveRecord::Migration
  def up
    change_column :responses, :response_set_id, :integer, :null => false
    add_foreign_key :responses, :response_sets, :column => 'response_set_id', :name => "response_set_id_to_response_sets_fk"
  end

  def down
    change_column :responses, :response_set_id, :integer
    remove_foreign_key :responses, :name => "response_set_id_to_response_sets_fk"
  end
end
