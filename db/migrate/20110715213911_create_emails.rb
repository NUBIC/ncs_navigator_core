class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.integer :psu_code,                :null => false, :limit => 36
      t.binary :email_id,                 :null => false
      t.references :person
      # t.references institute
      # t.references provider
      t.string :email,                    :limit => 100
      t.integer :email_rank_code,         :null => false
      t.string :email_rank_other
      t.integer :email_info_source_code,  :null => false
      t.string :email_info_source_other
      t.date :email_info_date
      t.date :email_info_update
      t.integer :email_type_code,         :null => false
      t.string :email_type_other
      t.integer :email_share_code,        :null => false
      t.integer :email_active_code,       :null => false
      t.text :email_comment
      t.string :email_start_date,         :limit => 10
      t.date :start_date
      t.string :email_end_date,           :limit => 10
      t.date :end_date
      t.string :transaction_type
      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
