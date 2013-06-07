require 'spec_helper'

module NcsNavigator::Core::Mdes::VersionMigrations
  # clean_with_truncation because CodeListLoader#load_from_pg_dump hangs
  # when there's an open transaction that's touched ncs_codes.
  describe TwoOneToTwoTwo, :clean_with_truncation do
    include SurveyCompletion

    let(:migration) {
      TwoOneToTwoTwo.new
    }

    it 'goes from 2.1' do
      migration.from.should == '2.1'
    end

    it 'goes to 2.2' do
      migration.to.should == '2.2'
    end

    describe '#run' do
      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }
      let(:twelve_mmonth_survey) { create_12_month_mother_supplement_survey }
      let(:six_mmonth_survey) { create_6_month_mother_supplement_survey }
      let(:lo_intensity_survey) { create_li_preg_not_preg_main_heat_survey }
      let(:samples_survey) { create_adult_urine_specimen_status_survey }

      before do
        # skip code list updating for performance
        NcsNavigator::Core::Mdes::CodeListLoader.any_instance.stub(:load_from_yaml)
      end

      context "postnatal surveys" do
        describe 'for data_export_id TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT' do
          before do
            response_set, instrument = prepare_instrument(
                                          person, participant,
                                          twelve_mmonth_survey)
            take_survey(twelve_mmonth_survey, response_set) do |r|
              r.a "TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT", {
                :reference_identifier => '5'
              }
              r.a "TEST_TABLE.TEST", {
                :reference_identifier => '5'
              }
            end

            NcsNavigator::Core::Mdes::Version.set!(migration.from)
            with_versioning do
              migration.run
            end

          end

          it "changes answer's reference_identifier from '5' to 'neg_5'" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT", "neg_5"
            ).count.should == 1

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT", "5"
            ).count.should == 0

            Response.includes(:question).where(
              "questions.data_export_identifier = ?",
              "TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT"
            ).first.answer.reference_identifier.should == "neg_5"
          end

          it "leaves all other answers with ref_id '5' alone" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "neg_5"
            ).count.should == 0

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "5"
            ).count.should == 1
          end
        end

        describe 'for data_export_id SIX_MTH_SAQ_SUPP.SUPPLEMENT' do
          before do
            response_set, instrument = prepare_instrument(
                                          person, participant,
                                          six_mmonth_survey)
            take_survey(six_mmonth_survey, response_set) do |r|
              r.a "SIX_MTH_SAQ_SUPP.SUPPLEMENT", {
                :reference_identifier => 'neg_7'
              }
              r.a "TEST_TABLE.TEST", {
                :reference_identifier => 'neg_7'
              }
            end

            NcsNavigator::Core::Mdes::Version.set!(migration.from)
            with_versioning do
              migration.run
            end

          end

          it "changes answer's reference_identifier from 'neg_7' to '5'" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "SIX_MTH_SAQ_SUPP.SUPPLEMENT", "5"
            ).count.should == 1

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "SIX_MTH_SAQ_SUPP.SUPPLEMENT", "neg_7"
            ).count.should == 0

            Response.includes(:question).where(
              "questions.data_export_identifier = ?",
              "SIX_MTH_SAQ_SUPP.SUPPLEMENT"
            ).first.answer.reference_identifier.should == "5"
          end

          it "leaves all other answers with ref_id 'neg_7' alone" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "5"
            ).count.should == 0

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "neg_7"
            ).count.should == 1
          end
        end

        describe 'for data_export_id PREG_VISIT_LI_2.MAIN_HEAT' do
          before do
            response_set, instrument = prepare_instrument(
                                          person, participant,
                                          lo_intensity_survey)
            take_survey(lo_intensity_survey, response_set) do |r|
              r.a "PREG_VISIT_LI_2.MAIN_HEAT", {
                :reference_identifier => '9'
              }
              r.a "TEST_TABLE.TEST", {
                :reference_identifier => '9'
              }
            end

            NcsNavigator::Core::Mdes::Version.set!(migration.from)
            with_versioning do
              migration.run
            end

          end

          it "changes answer's reference_identifier from '9' to 'neg_7'" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "PREG_VISIT_LI_2.MAIN_HEAT", "neg_7"
            ).count.should == 1

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "PREG_VISIT_LI_2.MAIN_HEAT", "9"
            ).count.should == 0

            Response.includes(:question).where(
              "questions.data_export_identifier = ?",
              "PREG_VISIT_LI_2.MAIN_HEAT"
            ).first.answer.reference_identifier.should == "neg_7"
          end

          it "leaves all other answers with ref_id '9' alone" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "neg_7"
            ).count.should == 0

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "9"
            ).count.should == 1
          end
        end

        describe 'for data_export_id SPEC_URINE.SPECIMEN_STATUS' do
          before do
            response_set, instrument = prepare_instrument(
                                          person, participant,
                                          samples_survey)
            take_survey(samples_survey, response_set) do |r|
              r.a "SPEC_URINE.SPECIMEN_STATUS", {
                :reference_identifier => '3'
              }
              r.a "TEST_TABLE.TEST", {
                :reference_identifier => '3'
              }
            end

            NcsNavigator::Core::Mdes::Version.set!(migration.from)
            with_versioning do
              migration.run
            end

          end

          it "changes answer's reference_identifier from '3' to '2'" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "SPEC_URINE.SPECIMEN_STATUS", "2"
            ).count.should == 1

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "SPEC_URINE.SPECIMEN_STATUS", "3"
            ).count.should == 0

            Response.includes(:question).where(
              "questions.data_export_identifier = ?",
              "SPEC_URINE.SPECIMEN_STATUS"
            ).first.answer.reference_identifier.should == "2"
          end

          it "leaves all other answers with ref_id '3' alone" do
            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "2"
            ).count.should == 0

            Answer.includes(:question).where(
              "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
              "TEST_TABLE.TEST", "3"
            ).count.should == 1
          end
        end

      end

    end
  end
end
