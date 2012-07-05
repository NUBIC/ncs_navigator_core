# -*- coding: utf-8 -*-


class SpecimenOperationalDataExtractor
  ADULT_URINE_SPECIMEN_MAP = {
    "SPEC_URINE.SPECIMEN_ID" => "specimen_id",
  }

  ADULT_BLOOD_SPECIMEN_MAP = {
    "SPEC_BLOOD_TUBE[tube_type=1].SPECIMEN_ID" => "specimen_id",
    "SPEC_BLOOD_TUBE[tube_type=2].SPECIMEN_ID" => "specimen_id",
    "SPEC_BLOOD_TUBE[tube_type=3].SPECIMEN_ID" => "specimen_id",
    "SPEC_BLOOD_TUBE[tube_type=4].SPECIMEN_ID" => "specimen_id",
    "SPEC_BLOOD_TUBE[tube_type=5].SPECIMEN_ID" => "specimen_id",
    "SPEC_BLOOD_TUBE[tube_type=6].SPECIMEN_ID" => "specimen_id",
    "SPEC_BLOOD_TUBE[tube_type=7].SPECIMEN_ID" => "specimen_id",
    "SPEC_BLOOD_TUBE[tube_type=8].SPECIMEN_ID" => "specimen_id",
  }

  CORD_BLOOD_SPECIMEN_MAP = {
    "SPEC_CORD_BLOOD_SPECIMEN[cord_container=1].SPECIMEN_ID" => "specimen_id",
    "SPEC_CORD_BLOOD_SPECIMEN[cord_container=2].SPECIMEN_ID" => "specimen_id",
    "SPEC_CORD_BLOOD_SPECIMEN[cord_container=3].SPECIMEN_ID" => "specimen_id",
  }

  class << self

    def extract_data(response_set)
      instrument = response_set.instrument
      raise InvalidSurveyException("No Instrument associated with Response Set") unless instrument

      response_set.responses.sort_by { |r| r.question.display_order }.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if ADULT_URINE_SPECIMEN_MAP.has_key?(data_export_identifier)
          Specimen.create!(:specimen_id => value, :instrument => instrument) unless value.blank?
        end

        if ADULT_BLOOD_SPECIMEN_MAP.has_key?(data_export_identifier)
          Specimen.create!(:specimen_id => value, :instrument => instrument) unless value.blank?
        end

        if CORD_BLOOD_SPECIMEN_MAP.has_key?(data_export_identifier)
          Specimen.create!(:specimen_id => value, :instrument => instrument) unless value.blank?
        end

      end

    end
  end

end