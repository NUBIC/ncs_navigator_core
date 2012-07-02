

class CreateNonInterviewReports < ActiveRecord::Migration
  def change
    create_table :non_interview_reports do |t|

      t.integer :psu_code,                      :null => false, :limit => 36
      t.string :nir_id,                         :null => false, :limit => 36
      t.references :contact
      t.text :nir
      t.references :dwelling_unit
      t.references :person
      t.integer :nir_vacancy_information_code,  :null => false
      t.string :nir_vacancy_information_other
      t.integer :nir_no_access_code,            :null => false
      t.string :nir_no_access_other
      t.integer :nir_access_attempt_code,       :null => false
      t.string :nir_access_attempt_other
      t.integer :nir_type_person_code,          :null => false
      t.string :nir_type_person_other

      t.integer :cog_inform_relation_code,      :null => false
      t.string :cog_inform_relation_other
      t.text :cog_disability_description

      t.integer :permanent_disability_code,     :null => false
      t.integer :deceased_inform_relation_code, :null => false
      t.string :deceased_inform_relation_other
      t.integer :year_of_death
      t.integer :state_of_death_code,           :null => false

      t.integer :who_refused_code,              :null => false
      t.string :who_refused_other
      t.integer :refuser_strength_code,         :null => false
      t.integer :refusal_action_code,           :null => false

      t.text :long_term_illness_description

      t.integer :permanent_long_term_code,      :null => false

      t.integer :reason_unavailable_code,       :null => false
      t.string :reason_unavailable_other

      t.date :date_available_date
      t.string :date_available,               :limit => 10

      t.date :date_moved_date
      t.string :date_moved,                     :limit => 10

      t.decimal :moved_length_time,             :precision => 6, :scale => 2
      t.integer :moved_unit_code,               :null => false
      t.integer :moved_inform_relation_code,    :null => false
      t.string :moved_inform_relation_other

      t.text :nir_other
      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end
end