class CreateParticipantPersonLinks < ActiveRecord::Migration
  def self.up
    create_table :participant_person_links do |t|

      t.string :psu_code,                       :null => false, :limit => 36
      t.integer :person_id,                     :null => false
      t.integer :participant_id,                :null => false
      t.integer :relationship_code,             :null => false
      t.string :relationship_other,             :limit => 255
      t.integer :is_active_code,                :null => false
      t.string :transaction_type,               :limit => 36

      # TODO: determine how to reference other ncs core models and use uuids
      # t.integer :person_pid_id

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_person_links
  end
end
