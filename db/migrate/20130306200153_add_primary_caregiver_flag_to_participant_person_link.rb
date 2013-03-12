class AddPrimaryCaregiverFlagToParticipantPersonLink < ActiveRecord::Migration
  def change
  	add_column :participant_person_links, :primary_caregiver_flag_code, :integer, :null => false, :default => -4
  end
end
