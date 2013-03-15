require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes::VersionMigrations
  class ThreeZeroToThreeTwo < Basic
    def initialize(options={})
      super('3.0', '3.2', options)
    end

    def run_after_code_list_changes
      # The recruitment strategy is always PBS for MDES 3.0, otherwise this
      # would need to be guarded.
      change_existing_participants_to_use_new_pbs_participant_type
    end
    protected :run_after_code_list_changes

    def change_existing_participants_to_use_new_pbs_participant_type
      # Have do do this inefficient way to ensure changes are logged
      Participant.where(:p_type_code => 3).order(:id).find_each do |p|
        p.p_type_code = 14
        p.save!
      end
    end
    private :change_existing_participants_to_use_new_pbs_participant_type
  end
end
