

class SampleOperationalDataExtractor

  VACUUM_BAG_DUST_SAMPLE_MAP = {
    "VACUUM_BAG.SAMPLE_ID" => "sample_id",
  }

  TAP_WATER_PHARM_SAMPLE_MAP = {
    "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWF_SAMPLE[sample_number=3].SAMPLE_ID" => "sample_id",
  }

  TAP_WATER_PEST_SAMPLE_MAP = {
    "TAP_WATER_TWQ_SAMPLE[sample_number=1].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWQ_SAMPLE[sample_number=2].SAMPLE_ID" => "sample_id",
    "TAP_WATER_TWQ_SAMPLE[sample_number=3].SAMPLE_ID" => "sample_id",
  }

  class << self

    def extract_data(response_set)
      instrument = response_set.instrument
      raise InvalidSurveyException("No Instrument associated with Response Set") unless instrument

      response_set.responses.sort_by { |r| r.question.display_order }.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if VACUUM_BAG_DUST_SAMPLE_MAP.has_key?(data_export_identifier)
          Sample.create!(:sample_id => value, :instrument => instrument) unless value.blank?
        end

        if TAP_WATER_PHARM_SAMPLE_MAP.has_key?(data_export_identifier)
          Sample.create!(:sample_id => value, :instrument => instrument) unless value.blank?
        end

        if TAP_WATER_PEST_SAMPLE_MAP.has_key?(data_export_identifier)
          Sample.create!(:sample_id => value, :instrument => instrument) unless value.blank?
        end

      end

    end
  end

end

class InvalidSurveyException < StandardError; end