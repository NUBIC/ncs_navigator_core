# -*- coding: utf-8 -*-


require 'spec_helper'

describe SampleOperationalDataExtractor do
  include SurveyCompletion

  describe ".extract_data" do

    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }

    context "the vacuum bag dust collection instrument" do
      it "creates a sample from the instrument response" do
        survey = create_vacuum_bag_dust_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        expected = 'EC2345671 – DB01'

        take_survey(survey, response_set) do |a|
          a.str "VACUUM_BAG.SAMPLE_ID", expected
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        SampleOperationalDataExtractor.extract_data(response_set)

        samples = Sample.where(:instrument_id => instrument.id).all
        samples.should_not be_blank
        samples.size.should == 1
        samples.first.sample_id.should == expected
      end

      it "raises an exception if there is no instrument associated with the response_set" do
        mock_response_set = mock(ResponseSet, :instrument => nil)
        expect { SampleOperationalDataExtractor.extract_data(mock_response_set) }.to raise_error
      end

    end

    context "the tap water pharm collection instrument" do
      it "creates up to 3 samples from the instrument response" do
        survey = create_tap_water_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        sample_ids = [
          'EC2224441 – WQ01',
          'EC2224442 – WQ02',
          'EC2224443 – WQ03',
        ]

        take_survey(survey, response_set) do |a|
          a.str "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
          a.str "TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID", sample_ids[1]
          a.str "TAP_WATER_TWF_SAMPLE[sample_number=3].SAMPLE_ID", sample_ids[2]
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        SampleOperationalDataExtractor.extract_data(response_set)

        samples = Sample.where(:instrument_id => instrument.id).all
        samples.should_not be_blank
        samples.size.should == 3

        sample_ids.each do |sample_id|
          Sample.where(:instrument_id => instrument.id, :sample_id => sample_id).first.should_not be_nil
        end

      end

      it "creates only the number of samples as there are related responses" do
        survey = create_tap_water_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        sample_ids = [
          'EC2224441 – WQ01',
        ]

        take_survey(survey, response_set) do |a|
          a.str "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        SampleOperationalDataExtractor.extract_data(response_set)

        samples = Sample.where(:instrument_id => instrument.id).all
        samples.should_not be_blank
        samples.size.should == 1

        sample_ids.each do |sample_id|
          Sample.where(:instrument_id => instrument.id, :sample_id => sample_id).first.should_not be_nil
        end

      end

      it "raises an exception if there is no instrument associated with the response_set" do
        mock_response_set = mock(ResponseSet, :instrument => nil)
        expect { SampleOperationalDataExtractor.extract_data(mock_response_set) }.to raise_error
      end

    end

    context "the tap water pest collection instrument" do
      it "creates up to 3 samples from the instrument response" do
        survey = create_tap_water_pest_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        sample_ids = [
          'EC2224441 – WQ01',
          'EC2224442 – WQ02',
          'EC2224443 – WQ03',
        ]

        take_survey(survey, response_set) do |a|
          a.str "TAP_WATER_TWQ_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
          a.str "TAP_WATER_TWQ_SAMPLE[sample_number=2].SAMPLE_ID", sample_ids[1]
          a.str "TAP_WATER_TWQ_SAMPLE[sample_number=3].SAMPLE_ID", sample_ids[2]
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        SampleOperationalDataExtractor.extract_data(response_set)

        samples = Sample.where(:instrument_id => instrument.id).all
        samples.should_not be_blank
        samples.size.should == 3

        sample_ids.each do |sample_id|
          Sample.where(:instrument_id => instrument.id, :sample_id => sample_id).first.should_not be_nil
        end

      end
    end

  end

end