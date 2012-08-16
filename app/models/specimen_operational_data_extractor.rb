# -*- coding: utf-8 -*-


class SpecimenOperationalDataExtractor
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
  }

  class << self

    def extract_data(response_set)
      instrument = response_set.instrument
      raise InvalidSurveyException("No Instrument associated with Response Set") unless instrument

      response_set.responses.each do |r|

        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if SPECIMEN_MAP.has_key?(data_export_identifier)
          unless value.blank?
            specimen = Specimen.where(:response_set_id => response_set.id,
                                      :instrument_id => instrument.id,
                                      :data_export_identifier => data_export_identifier).first
            if specimen.blank?
              specimen = Specimen.new(:response_set => response_set,
                                      :instrument => instrument,
                                      :data_export_identifier => data_export_identifier)
            end
            specimen.specimen_id = value
            specimen.save!
          end
        end
      end

    end
  end

end