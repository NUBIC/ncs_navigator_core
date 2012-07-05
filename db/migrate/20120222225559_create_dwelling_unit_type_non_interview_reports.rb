# -*- coding: utf-8 -*-


class CreateDwellingUnitTypeNonInterviewReports < ActiveRecord::Migration
  def change
    create_table :dwelling_unit_type_non_interview_reports do |t|
      t.integer :psu_code,                      :null => false, :limit => 36
      t.string :nir_dutype_id,                  :null => false, :limit => 36
      t.references :non_interview_report
      t.integer :nir_dwelling_unit_type_code,   :null => false
      t.string :nir_dwelling_unit_type_other

      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end
end