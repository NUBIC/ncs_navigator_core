# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: samples
#
#  created_at             :datetime
#  data_export_identifier :string(255)
#  id                     :integer          not null, primary key
#  instrument_id          :integer
#  response_set_id        :integer
#  sample_id              :string(36)       not null
#  sample_shipping_id     :integer
#  updated_at             :datetime
#  volume_amount          :decimal(6, 2)
#  volume_unit            :string(36)
#



require 'spec_helper'

describe OperationalDataExtractor do
  describe "::extractor_for" do
    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }

    it "returns OperationalDataExtractor of type Sample" do
      SamplesAndSpecimens.instance_methods.select{|m| m.to_s =~ /^create.*sample_operational_data/}.each do |m|
        survey = send(m)
        response_set, instrument = prepare_instrument(person, participant, survey)

        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.instance_of?(OperationalDataExtractor::Sample).should be(true)

      end
    end
  end
end

describe OperationalDataExtractor::Sample do
  include SurveyCompletion

  describe ".extract_data" do

    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }

    context "the vacuum bag dust collection instrument" do
      it "creates a sample from the instrument response" do
        survey = create_vacuum_bag_dust_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        expected = 'EC2345671 – DB01'

        take_survey(survey, response_set) do |r|
          r.a "VACUUM_BAG.SAMPLE_ID", expected
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        OperationalDataExtractor::Sample.new(response_set).extract_data

        samples = Sample.where(:instrument_id => instrument.id).all
        samples.should_not be_blank
        samples.size.should == 1
        samples.first.sample_id.should == expected
      end

      it "raises an exception if there is no instrument associated with the response_set" do
        mock_response_set = mock(ResponseSet, :instrument => nil)
        expect { OperationalDataExtractor::Sample.extract_data(mock_response_set) }.to raise_error
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

        take_survey(survey, response_set) do |r|
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID", sample_ids[1]
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=3].SAMPLE_ID", sample_ids[2]
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        OperationalDataExtractor::Sample.new(response_set).extract_data

        instrument.samples.reload
        instrument.samples.count.should == 3


        instrument.samples.collect(&:sample_id).sort.should == sample_ids.sort
      end

      it "updates existing records instead of creating new ones" do
        survey = create_tap_water_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        sample_ids = [
          'EC2224441 – WQ01',
          'EC2224442 – WQ02',
        ]

        take_survey(survey, response_set) do |r|
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID", sample_ids[1]
        end

        response_set.responses.reload
        response_set.responses.size.should == 2

        OperationalDataExtractor::Sample.new(response_set).extract_data

        instrument.samples.reload
        instrument.samples.count.should == 2

        sample_ids.each do |sample_id|
          instrument.samples.where(:sample_id => sample_id).first.should_not be_nil
        end

        sample_ids = [
          'EC8989898 – WQ01',
          'EC8989898 – WQ02',
          'EC8989898 – WQ03',
        ]

        take_survey(survey, response_set) do |r|
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID", sample_ids[1]
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=3].SAMPLE_ID", sample_ids[2]
        end

        response_set.responses.reload
        response_set.responses.size.should == 5

        OperationalDataExtractor::Sample.new(response_set).extract_data

        instrument.samples.reload
        instrument.samples.count.should == 3

        instrument.samples.collect(&:sample_id).sort.should == sample_ids.sort

      end

      it "creates only the number of samples as there are related responses" do
        survey = create_tap_water_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        sample_ids = [
          'EC2224441 – WQ01',
        ]

        take_survey(survey, response_set) do |r|
          r.a "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        OperationalDataExtractor::Sample.new(response_set).extract_data

        instrument.samples.reload
        instrument.samples.count.should == 1

        sample_ids.each do |sample_id|
          instrument.samples.where(:sample_id => sample_id).first.should_not be_nil
        end

      end

      it "raises an exception if there is no instrument associated with the response_set" do
        mock_response_set = mock(ResponseSet, :instrument => nil)
        expect { OperationalDataExtractor::Sample.extract_data(mock_response_set) }.to raise_error
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

        take_survey(survey, response_set) do |r|
          r.a "TAP_WATER_TWQ_SAMPLE[sample_number=1].SAMPLE_ID", sample_ids[0]
          r.a "TAP_WATER_TWQ_SAMPLE[sample_number=2].SAMPLE_ID", sample_ids[1]
          r.a "TAP_WATER_TWQ_SAMPLE[sample_number=3].SAMPLE_ID", sample_ids[2]
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        OperationalDataExtractor::Sample.new(response_set).extract_data

        instrument.samples.reload
        instrument.samples.count.should == 3

        sample_ids.each do |sample_id|
          instrument.samples.where(:sample_id => sample_id).first.should_not be_nil
        end

      end
    end


    context "the sample kit distribution instrument" do
      it "creates up to 3 samples from the instrument response" do
        survey = create_sample_distrib_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        sample_ids = [
          'EC2224444-SB01',
          'EC2224444-SB02',
          'EC2224444-SB03',
        ]

        take_survey(survey, response_set) do |r|
          r.a "SAMPLE_DIST_SAMP[type=1].SAMPLE_ID", sample_ids[0]
          r.a "SAMPLE_DIST_SAMP[type=2].SAMPLE_ID", sample_ids[1]
          r.a "SAMPLE_DIST_SAMP[type=3].SAMPLE_ID", sample_ids[2]
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        OperationalDataExtractor::Base.extractor_for(response_set).extract_data

        instrument.samples.reload
        instrument.samples.count.should == 3

        sample_ids.each do |sample_id|
          instrument.samples.where(:sample_id => sample_id).first.should_not be_nil
        end

      end
    end
  end

end
