class CreateMerges < ActiveRecord::Migration
  def change
    create_table :merges do |t|
      t.references :fieldwork
      t.text :conflict_report
      t.text :log
      t.text :proposed_data
      t.timestamp :completed_at
      t.timestamp :crashed_at
      t.timestamp :started_at
      t.timestamps
    end

    add_foreign_key 'merges', 'fieldworks', :name => 'merges_fieldworks_fk'
  end
end
