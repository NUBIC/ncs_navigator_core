

class CreateParticipantPersonLinks < ActiveRecord::Migration
  def self.up
    create_table :participant_person_links do |t|

      t.string :psu_code,                       :null => false, :limit => 36
      t.references :person,                     :null => false
      t.references :participant,                :null => false
      t.integer :relationship_code,             :null => false
      t.string :relationship_other,             :limit => 255
      t.integer :is_active_code,                :null => false
      t.string :transaction_type,               :limit => 36

      t.binary :person_pid_id,                  :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_person_links
  end
end