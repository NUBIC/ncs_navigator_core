class AddPreScreeningPerformed < ActiveRecord::Migration
  def change
    create_table :pre_screening_performeds do |t|
      t.string :psu_code,                       :null => false, :limit => 36
      t.string :pre_screening_performed_id,     :null => false, :limit => 36
      t.references :provider,                   :null => false
      t.integer :pr_pregnancy_eligible_code,    :null => false
      t.integer :pr_age_eligible_code,          :null => false
      t.integer :pr_first_provider_visit_code,  :null => false
      t.integer :pr_county_of_residence_code,   :null => false

      t.string :transaction_type,               :limit => 36
      t.timestamps
    end
  end
end