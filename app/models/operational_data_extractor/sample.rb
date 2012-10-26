# -*- coding: utf-8 -*-


class OperationalDataExtractor::Sample

  SAMPLE_MAP = {
    "VACUUM_BAG.SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWF_SAMPLE[sample_number=3].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWQ_SAMPLE[sample_number=1].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWQ_SAMPLE[sample_number=2].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWQ_SAMPLE[sample_number=3].SAMPLE_ID" => "sample_id",
  }

  class << self

    def extract_data(response_set)
      instrument = response_set.instrument
      raise InvalidSurveyException("No Instrument associated with Response Set") unless instrument

      response_set.responses.sort_by { |r| r.question.display_order }.each do |r|

        value = OperationalDataExtractor::Base.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if SAMPLE_MAP.has_key?(data_export_identifier)
          unless value.blank?
            sample = Sample.where(:response_set_id => response_set.id,
                                  :instrument_id => instrument.id,
                                  :data_export_identifier => data_export_identifier).first
            if sample.blank?
              sample = Sample.new(:response_set => response_set,
                                  :instrument => instrument,
                                  :data_export_identifier => data_export_identifier)
            end
            sample.sample_id = value
            sample.save!
          end
        end

      end

    end
  end

end

class InvalidSurveyException < StandardError; end