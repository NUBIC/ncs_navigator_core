require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes::VersionMigrations
  class TwoOneToTwoTwo < Basic
    def initialize(options={})
      super('2.1', '2.2', options)
    end

    def run_after_code_list_changes
      remap_answers_ref_id("PREG_VISIT_LI_2.MAIN_HEAT", "9", "neg_7")
      remap_answers_ref_id("SIX_MTH_SAQ_SUPP.SUPPLEMENT", "neg_7", "5")
      remap_answers_ref_id("TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT", "5",
                           "neg_5")
      remap_answers_ref_id("SPEC_URINE.SPECIMEN_STATUS", "3", "2")
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
