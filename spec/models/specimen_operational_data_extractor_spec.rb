

require 'spec_helper'

describe SpecimenOperationalDataExtractor do
  include SurveyCompletion

  describe ".extract_data" do

    let(:person) { Factory(:person) }

    context "the adult urine collection instrument" do
      it "creates a sample from the instrument response" do
        survey = create_adult_urine_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, survey)
        expected = 'AA1234567-UR01'

        take_survey(survey, response_set) do |a|
          a.str "SPEC_URINE.SPECIMEN_ID", expected
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        SpecimenOperationalDataExtractor.extract_data(response_set)

        specimens = Specimen.where(:instrument_id => instrument.id).all
        specimens.should_not be_blank
        specimens.size.should == 1
        specimens.first.specimen_id.should == expected
      end

      it "raises an exception if there is no instrument associated with the response_set" do
        mock_response_set = mock(ResponseSet, :instrument => nil)
        expect { SpecimenOperationalDataExtractor.extract_data(mock_response_set) }.to raise_error
      end

    end

    context "the adult blood collection instrument" do
      it "creates up to 6 specimens from the instrument response" do
        survey = create_adult_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, survey)
        specimen_ids = [
          "AA123456-SS10",
          "AA123456-RD10",
          "AA123456-PP10",
          "AA123456-LV10",
          "AA123456-PN10",
          "AA123456-AD10",
        ]

        take_survey(survey, response_set) do |a|
          a.str "SPEC_BLOOD_TUBE[tube_type=1].SPECIMEN_ID", specimen_ids[0]
          a.str "SPEC_BLOOD_TUBE[tube_type=2].SPECIMEN_ID", specimen_ids[1]
          a.str "SPEC_BLOOD_TUBE[tube_type=3].SPECIMEN_ID", specimen_ids[2]
          a.str "SPEC_BLOOD_TUBE[tube_type=4].SPECIMEN_ID", specimen_ids[3]
          a.str "SPEC_BLOOD_TUBE[tube_type=5].SPECIMEN_ID", specimen_ids[4]
          a.str "SPEC_BLOOD_TUBE[tube_type=6].SPECIMEN_ID", specimen_ids[5]
        end

        response_set.responses.reload
        response_set.responses.size.should == 6

        SpecimenOperationalDataExtractor.extract_data(response_set)

        specimens = Specimen.where(:instrument_id => instrument.id).all
        specimens.should_not be_blank
        specimens.size.should == 6

        specimen_ids.each do |specimen_id|
          Specimen.where(:instrument_id => instrument.id, :specimen_id => specimen_id).first.should_not be_nil
        end

      end

      it "creates only the number of specimens as there are related responses" do
        survey = create_adult_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, survey)
        specimen_ids = [
          "AA123456-SS10",
        ]

        take_survey(survey, response_set) do |a|
          a.str "SPEC_BLOOD_TUBE[tube_type=1].SPECIMEN_ID", specimen_ids[0]
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        SpecimenOperationalDataExtractor.extract_data(response_set)

        specimens = Specimen.where(:instrument_id => instrument.id).all
        specimens.should_not be_blank
        specimens.size.should == 1

        specimen_ids.each do |specimen_id|
          Specimen.where(:instrument_id => instrument.id, :specimen_id => specimen_id).first.should_not be_nil
        end

      end

    end

    context "the cord blood collection instrument" do
      it "creates up to 3 specimens from the instrument response" do
        survey = create_cord_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, survey)
        specimen_ids = [
          "AA123456-CL01",
          "AA123456-CS01",
          "AA123456-CB01",
        ]

        take_survey(survey, response_set) do |a|
          a.str "SPEC_CORD_BLOOD_SPECIMEN[cord_container=1].SPECIMEN_ID", specimen_ids[0]
          a.str "SPEC_CORD_BLOOD_SPECIMEN[cord_container=2].SPECIMEN_ID", specimen_ids[1]
          a.str "SPEC_CORD_BLOOD_SPECIMEN[cord_container=3].SPECIMEN_ID", specimen_ids[2]
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        SpecimenOperationalDataExtractor.extract_data(response_set)

        specimens = Specimen.where(:instrument_id => instrument.id).all
        specimens.should_not be_blank
        specimens.size.should == 3

        specimen_ids.each do |specimen_id|
          Specimen.where(:instrument_id => instrument.id, :specimen_id => specimen_id).first.should_not be_nil
        end

      end

      it "creates only the number of specimens as there are related responses" do
        survey = create_cord_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, survey)
        specimen_ids = [
          "AA123456-CB01",
        ]

        take_survey(survey, response_set) do |a|
          a.str "SPEC_CORD_BLOOD_SPECIMEN[cord_container=1].SPECIMEN_ID", specimen_ids[0]
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        SpecimenOperationalDataExtractor.extract_data(response_set)

        specimens = Specimen.where(:instrument_id => instrument.id).all
        specimens.should_not be_blank
        specimens.size.should == 1

        specimen_ids.each do |specimen_id|
          Specimen.where(:instrument_id => instrument.id, :specimen_id => specimen_id).first.should_not be_nil
        end

      end

    end

  end

end