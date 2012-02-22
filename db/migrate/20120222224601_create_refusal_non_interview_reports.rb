class CreateRefusalNonInterviewReports < ActiveRecord::Migration
  def change
    create_table :refusal_non_interview_reports do |t|
      t.integer :psu_code,                      :null => false, :limit => 36
      t.string :nir_refusal_id,                 :null => false, :limit => 36
      t.references :non_interview_report
      t.integer :refusal_reason_code,           :null => false
      t.string :refusal_reason_other

      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end
end
