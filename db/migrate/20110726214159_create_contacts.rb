# encoding: utf-8

class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|

      t.integer :psu_code,                  :null => false, :limit => 36
      t.binary :contact_id,                 :null => false
      t.integer :contact_disposition
      t.integer :contact_type_code,         :null => false
      t.string :contact_type_other
      t.string :contact_date,               :limit => 10
      t.date :contact_date_date
      t.string :contact_start_time
      t.string :contact_end_time
      t.integer :contact_language_code,     :null => false
      t.string :contact_language_other
      t.integer :contact_interpret_code,    :null => false
      t.string :contact_interpret_other
      t.integer :contact_location_code,     :null => false
      t.string :contact_location_other
      t.integer :contact_private_code,      :null => false
      t.string :contact_private_detail
      t.decimal :contact_distance,          :precision => 6, :scale => 2
      t.integer :who_contacted_code,        :null => false
      t.string :who_contacted_other
      t.text :contact_comment
      t.string :transaction_type

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end