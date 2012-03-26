class AddResponseSetToOperationalData < ActiveRecord::Migration
  def change
    add_column :people,                   :response_set_id, :integer
    add_column :addresses,                :response_set_id, :integer
    add_column :telephones,               :response_set_id, :integer
    add_column :emails,                   :response_set_id, :integer
    add_column :ppg_details,              :response_set_id, :integer
    add_column :ppg_status_histories,     :response_set_id, :integer
    add_column :participant_person_links, :response_set_id, :integer
  end

  def self.up
    remove_column :response_sets, :processed_for_operational_data_extraction
  end

  def self.down
    add_column :response_sets, :processed_for_operational_data_extraction, :boolean
  end
end
