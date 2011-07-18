class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|

      t.string :psu_code,                       :null => false, :limit => 36
      t.binary :person_id,                      :null => false
      t.integer :prefix_code,                   :null => false
      t.string :first_name,                     :limit => 30
      t.string :last_name,                      :limit => 30
      t.string :middle_name,                    :limit => 30
      t.string :maiden_name,                    :limit => 30
      t.integer :suffix_code,                   :null => false
      t.string :title,                          :limit => 5
      t.integer :sex_code,                      :null => false
      t.integer :age
      t.integer :age_range_code,                :null => false
      t.string :person_dob,                     :limit => 10
      t.date :date_of_birth
      t.integer :deceased_code,                 :null => false
      t.integer :ethnic_group_code,             :null => false
      t.integer :language_code,                 :null => false
      t.string :language_other,                 :limit => 255
      t.integer :marital_status_code,           :null => false
      t.string :marital_status_other,           :limit => 255
      t.integer :preferred_contact_method_code, :null => false
      t.string :preferred_contact_method_other, :limit => 255
      t.integer :planned_move_code,             :null => false
      t.integer :move_info_code,                :null => false
      # t.references :new_address
      t.integer :when_move_code,                :null => false
      t.date :moving_date
      t.string :date_move
      t.integer :p_tracing_code,                :null => false
      t.integer :p_info_source_code,            :null => false
      t.string :p_info_source_other,            :limit => 255
      t.date :p_info_date
      t.date :p_info_update
      t.text :person_comment
      t.string :transaction_type,               :limit => 36
      
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
