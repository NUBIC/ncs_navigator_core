# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class Sample < Base

    SAMPLE_MAP = {
      "VACUUM_BAG.SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWF_SAMPLE[sample_number=1].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWF_SAMPLE[sample_number=3].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWQ_SAMPLE[sample_number=1].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWQ_SAMPLE[sample_number=2].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWQ_SAMPLE[sample_number=3].SAMPLE_ID" => "sample_id",

      # MDES 2.1 = are the same as 2.0
      # Updates for MDES 2.2
      "TAP_WATER_TWQ_SAMPLE_2[sample_number=1].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWQ_SAMPLE_2[sample_number=2].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWQ_SAMPLE_2[sample_number=3].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWF_SAMPLE_2[sample_number=1].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWF_SAMPLE_2[sample_number=2].SAMPLE_ID" => "sample_id",
      "TAP_WATER_TWF_SAMPLE_2[sample_number=3].SAMPLE_ID" => "sample_id",
      "VACUUM_BAG_2.SAMPLE_ID" => "sample_id",
        # New from SampleDistrib_DCI
      "SAMPLE_DIST_SAMP[type=1].SAMPLE_ID" => "sample_id",
      "SAMPLE_DIST_SAMP[type=2].SAMPLE_ID" => "sample_id",
      "SAMPLE_DIST_SAMP[type=3].SAMPLE_ID" => "sample_id",
        # New from TapWaterPestPartCollect_SAQSpec, TapWaterPharmPartCollect_SAQSpec, VacBagDustPartCollect_SAQSpec
      "TAP_WATER_TWQ_SAQ.P_TWQ_BOTTLE_1_ID" => "sample_id",
      "TAP_WATER_TWQ_SAQ.P_TWQ_BOTTLE_2_ID" => "sample_id",
      "TAP_WATER_TWF_SAQ.P_TWF_BOTTLE_1_ID" => "sample_id",
      "TAP_WATER_TWF_SAQ.P_TWF_BOTTLE_2_ID" => "sample_id",
      "TAP_WATER_TWF_SAQ.P_TWF_BOTTLE_3_ID" => "sample_id",
      "VACUUM_BAG_SAQ.P_VBD_BOTTLE_ID" => "sample_id",
    }

    def maps
      [SAMPLE_MAP]
    end

    def extract_data
      instrument = response_set.instrument
      raise InvalidSurveyException, "No Instrument associated with Response Set" unless instrument

      SAMPLE_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            sample = ::Sample.where(:response_set_id => response_set.id,
                                  :instrument_id => instrument.id,
                                  :data_export_identifier => key).first
            if sample.blank?
              sample = ::Sample.new(:response_set => response_set,
                                  :instrument => instrument,
                                  :data_export_identifier => key)
            end
            sample.sample_id = value
            sample.save!
          end
        end
      end
    end
  end
end