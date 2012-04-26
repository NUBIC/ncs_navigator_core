# encoding: utf-8

class CreateVacantNonInterviewReports < ActiveRecord::Migration
  def change
    create_table :vacant_non_interview_reports do |t|

      t.integer :psu_code,                      :null => false, :limit => 36
      t.string :nir_vacant_id,                  :null => false, :limit => 36
      t.references :non_interview_report
      t.integer :nir_vacant_code,               :null => false
      t.string :nir_vacant_other

      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end
end