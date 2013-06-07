require 'spec_helper'

module NcsNavigator::Core::Mdes::VersionMigrations
  # clean_with_truncation because CodeListLoader#load_from_pg_dump hangs
  # when there's an open transaction that's touched ncs_codes.
  describe TwoZeroToTwoOne, :clean_with_truncation do
    include SurveyCompletion

    let(:migration) {
      TwoZeroToTwoOne.new
    }

    it 'goes from 2.0' do
      migration.from.should == '2.0'
    end

    it 'goes to 2.1' do
      migration.to.should == '2.1'
    end

    describe '#run' do
      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }
      let(:survey) { create_12MM_mother_detail_hcare_sick_m20 }
      let(:survey_birth) { create_birth_M2_0_hcare("BIRTH_VISIT_2") }
      let(:survey_birth_li) { create_birth_M2_0_hcare("BIRTH_VISIT_LI") }

      before do
        # Skip code list switch for performance
        NcsNavigator::Core::Mdes::CodeListLoader.any_instance.stub(:load_from_yaml)

        response_set, instrument = prepare_instrument(person, participant,
                                                      survey)
        take_survey(survey, response_set) do |r|
          r.a "TWELVE_MTH_MOTHER_DETAIL.HCARE_SICK", {
            :reference_identifier => '7'
          }
        end

        response_set_birth, instrument_birth = prepare_instrument(person,
                                                   participant, survey_birth)
        take_survey(survey_birth, response_set_birth) do |r|
          r.a "BIRTH_VISIT_2.HCARE", { :reference_identifier => 'neg_5' }
        end

        response_set_birth_li, instrument_birth_li = prepare_instrument(person,
                                                   participant, survey_birth_li)
        take_survey(survey_birth_li, response_set_birth_li) do |r|
          r.a "BIRTH_VISIT_LI.HCARE", { :reference_identifier => 'neg_5' }
        end

        NcsNavigator::Core::Mdes::Version.set!(migration.from)
        with_versioning do
          migration.run
        end
      end

      describe 'for data_export_id TWELVE_MTH_MOTHER_DETAIL.HCARE_SICK' do
        it "changes answer's reference_identifier from '7' to 'neg_7'" do
          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "TWELVE_MTH_MOTHER_DETAIL.HCARE_SICK", "neg_7"
          ).count.should == 1

          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "TWELVE_MTH_MOTHER_DETAIL.HCARE_SICK", "7"
          ).count.should == 0

          Response.includes(:question).where(
            "questions.data_export_identifier = ?",
            "TWELVE_MTH_MOTHER_DETAIL.HCARE_SICK"
          ).first.answer.reference_identifier.should == "neg_7"
        end

        it "leaves all other answers with ref_id '7' alone" do
          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "TWELVE_MTH_MOTHER_DETAIL.R_HCARE", "neg_7"
          ).count.should == 0

          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "TWELVE_MTH_MOTHER_DETAIL.R_HCARE", "7"
          ).count.should == 1
        end
      end

      describe 'for data_export_id BIRTH_VISIT_2.HCARE' do
        it "changes answer's reference_identifier from 'neg_5' to '4'" do
          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_2.HCARE", "4"
          ).count.should == 1

          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_2.HCARE", "neg_5"
          ).count.should == 0

          Response.includes(:question).where(
            "questions.data_export_identifier = ?",
            "BIRTH_VISIT_2.HCARE"
          ).first.answer.reference_identifier.should == "4"
        end

        it "leaves all other answers with ref_id 'neg_5' alone" do
          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_2.HOW_FED", "4"
          ).count.should == 0

          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_2.HOW_FED", "neg_5"
          ).count.should == 1
        end
      end

      describe 'for data_export_id BIRTH_VISIT_LI.HCARE' do
        it "changes answer's reference_identifier from 'neg_5' to '4'" do
          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_LI.HCARE", "4"
          ).count.should == 1

          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_LI.HCARE", "neg_5"
          ).count.should == 0

          Response.includes(:question).where(
            "questions.data_export_identifier = ?",
            "BIRTH_VISIT_LI.HCARE"
          ).first.answer.reference_identifier.should == "4"
        end

        it "leaves all other answers with ref_id 'neg_5' alone" do
          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_LI.HOW_FED", "4"
          ).count.should == 0

          Answer.includes(:question).where(
            "questions.data_export_identifier = ? AND answers.reference_identifier = ?",
            "BIRTH_VISIT_LI.HOW_FED", "neg_5"
          ).count.should == 1
        end
      end

    end
  end
end
