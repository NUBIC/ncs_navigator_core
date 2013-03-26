# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class Specimen < Base
    SPECIMEN_MAP = {
      "SPEC_URINE.SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=1].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=2].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=3].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=4].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=5].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=6].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=7].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_TUBE[tube_type=8].SPECIMEN_ID" => "specimen_id",
      "SPEC_CORD_BLOOD_SPECIMEN[cord_container=1].SPECIMEN_ID" => "specimen_id",
      "SPEC_CORD_BLOOD_SPECIMEN[cord_container=2].SPECIMEN_ID" => "specimen_id",
      "SPEC_CORD_BLOOD_SPECIMEN[cord_container=3].SPECIMEN_ID" => "specimen_id",

      # MDES 2.1
      "SPEC_CORD_BLOOD_SPECIMEN_2[collection_type=1].SPECIMEN_ID" => "specimen_id",
      "SPEC_CORD_BLOOD_SPECIMEN_2[collection_type=2].SPECIMEN_ID" => "specimen_id",
      "SPEC_CORD_BLOOD_SPECIMEN_2[collection_type=3].SPECIMEN_ID" => "specimen_id",
      # MDES 2.2
      "SPEC_CORD_BLOOD_SPECIMEN_3[collection_type=1].SPECIMEN_ID" => "specimen_id",
      "SPEC_CORD_BLOOD_SPECIMEN_3[collection_type=2].SPECIMEN_ID" => "specimen_id",
      "SPEC_CORD_BLOOD_SPECIMEN_3[collection_type=3].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=1].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=2].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=3].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=4].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=5].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=6].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=7].SPECIMEN_ID" => "specimen_id",
      "SPEC_BLOOD_2_TUBE[tube_type=8].SPECIMEN_ID" => "specimen_id",
      # MDES 3.1
      # New from BreastMilkColl_SAQSpec
      "BREAST_MILK_SAQ.SPECIMEN_ID" => "specimen_id",
      # New from ChildBlood_INT
      "CHILD_BLOOD_TUBE[tube_type=1].SPECIMEN_ID" => "specimen_id",
      "CHILD_BLOOD_TUBE[tube_type=2].SPECIMEN_ID" => "specimen_id",
      "CHILD_BLOOD_TUBE[tube_type=3].SPECIMEN_ID" => "specimen_id",
      "CHILD_BLOOD_TUBE[tube_type=4].SPECIMEN_ID" => "specimen_id",
      # New from ChildSalivaColl_INT
      "CHILD_SALIVA.SPECIMEN_ID" => "specimen_id",
      # New from ChildSalivaColl_SAQSpec
      "CHILD_SALIVA_SAQ.SPECIMEN_ID" => "specimen_id",
      # New from ChildUrineColl_INT
      "CHILD_URINE.SPECIMEN_ID" => "specimen_id",
    }

    def initialize(response_set)
      super(response_set)
    end

    def maps
      [SPECIMEN_MAP]
    end

    def extract_data
      instrument = response_set.instrument
      raise InvalidSurveyException, "No Instrument associated with Response Set" unless instrument

      SPECIMEN_MAP.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            specimen = ::Specimen.where(:response_set_id => response_set.id,
                                      :instrument_id => instrument.id,
                                      :data_export_identifier => key).first
            if specimen.blank?
              specimen = ::Specimen.new(:response_set => response_set,
                                      :instrument => instrument,
                                      :data_export_identifier => key)
            end
            specimen.specimen_id = value
            specimen.save!
          end
        end
      end
    end
  end
  class InvalidSurveyException < StandardError; end
end
