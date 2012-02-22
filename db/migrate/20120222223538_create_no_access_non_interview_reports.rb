class CreateNoAccessNonInterviewReports < ActiveRecord::Migration
  def change
    create_table :no_access_non_interview_reports do |t|
      t.integer :psu_code,                      :null => false, :limit => 36
      t.string :nir_no_access_id,               :null => false, :limit => 36
      t.references :non_interview_report
      t.integer :nir_no_access_code,            :null => false
      t.string :nir_no_access_other

      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end
end
