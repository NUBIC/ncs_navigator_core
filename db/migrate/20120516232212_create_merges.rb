class CreateMerges < ActiveRecord::Migration
  def change
    create_table :merges do |t|
      t.boolean :done, :default => false
      t.references :fieldwork
      t.string :status, :limit => 16, :default => 'pending'
      t.text :conflict_report
      t.text :log
      t.text :proposed_data
      t.timestamps
    end

    add_foreign_key 'merges', 'fieldworks', :name => 'merges_fieldworks_fk'
  end
end
