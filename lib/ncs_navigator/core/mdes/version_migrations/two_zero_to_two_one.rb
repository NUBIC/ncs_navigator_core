require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes::VersionMigrations
  class TwoZeroToTwoOne < Basic
    def initialize(options={})
      super('2.0', '2.1', options)
    end

    def run_after_code_list_changes
      # Remap 7 "HAS NOT BEEN SICK" ->
      #                   neg_7 "Not applicable has not been sick"
      remap_answers_ref_id("TWELVE_MTH_MOTHER_DETAIL.HCARE_SICK",
                           "7", "neg_7")
      # Remap neg_5 "Other" -> 4 "Some other place"
      remap_answers_ref_id("BIRTH_VISIT_2.HCARE", "neg_5", "4")
      remap_answers_ref_id("BIRTH_VISIT_LI.HCARE", "neg_5", "4")
      # "BIRTH_VISIT.HCARE" doesn't exist in any instruments so no remap needed
    end
    protected :run_after_code_list_changes

    def remap_answers_ref_id(data_export_id, old_ref_id, new_ref_id)
      Answer.includes(:question).where(
        "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
        data_export_id, old_ref_id
      ).each do |a|
          a.reference_identifier = new_ref_id
          a.save!
      end
    end
    private :remap_answers_ref_id

  end
end
