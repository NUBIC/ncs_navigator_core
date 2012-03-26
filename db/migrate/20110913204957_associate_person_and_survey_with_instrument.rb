class AssociatePersonAndSurveyWithInstrument < ActiveRecord::Migration
  def up
    add_column :instruments, :person_id, :integer
    add_column :instruments, :survey_id, :integer
  end

  def down
  end
end
