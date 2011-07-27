class CreateContactLinks < ActiveRecord::Migration
  def self.up
    create_table :contact_links do |t|
      
      t.integer :psu_code,            :null => false, :limit => 36
      t.string :contact_link_id,      :null => false, :limit => 36
      t.references :contact,          :null => false
      t.references :event
      t.references :instrument
      t.string :staff_id,             :null => false, :limit => 36
      t.references :person
      t.references :provider
      t.string :transaction_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contact_links
  end
end
