class CreateSampledPersonsIneligibilities < ActiveRecord::Migration
  def change
    create_table :sampled_persons_ineligibilities do |t|


      t.integer :provider_id
      t.integer :person_id
      t.string :sampled_persons_inelig_id,       :null => false, :limit => 36
      t.string :transaction_type,                :limit => 36
      t.string :psu_code,                        :null => false, :limit => 36
      t.integer :age_eligible_code
      t.integer :county_of_residence_code
      t.integer :pregnancy_eligible_code
      t.integer :first_prenatal_visit_code
      t.integer :ineligible_by_code

      t.timestamps
    end
  end
end
