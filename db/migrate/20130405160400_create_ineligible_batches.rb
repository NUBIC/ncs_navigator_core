class CreateIneligibleBatches < ActiveRecord::Migration
  def change
    create_table :ineligible_batches do |t|
      t.integer :age_eligible_code,           :null => true
      t.string :batch_id,                     :null => false, :limit => 36
      t.integer :county_of_residence_code,    :null => true
      t.date :created_at,                     :null => false
      t.string :date_first_visit,             :null => false, :limit => 255
      t.date :date_first_visit_date,          :null => false
      t.integer :first_prenatal_visit_code,   :null => true
      t.integer :ineligible_by_code,          :null => true
      t.integer :people_count,                :null => false
      t.integer :pre_screening_status_code,   :null => false
      t.integer :pregnancy_eligible_code,     :null => true
      t.integer :provider_id,                 :null => false
      t.integer :provider_intro_outcome_code, :null => false
      t.string :provider_intro_outcome_other, :null => true, :limit => 255
      t.integer :psu_code,                    :null => false
      t.integer :sampled_person_code,         :null => false

      t.timestamps
    end
  end
end
