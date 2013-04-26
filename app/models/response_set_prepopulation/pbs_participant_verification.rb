# -*- coding: utf-8 -*-

module ResponseSetPrepopulation
  class PbsParticipantVerification < Populator
    include OldAccessMethods
    include BirthCohortPrepopulator

    def self.applies_to?(rs)
      rs.survey.title.include?('_PBSPartVerBirth_')
    end

    def self.reference_identifiers
      [
        "prepopulated_is_p_type_fifteen"
      ]
    end

    def run
      self.class.reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(reference_identifier)
          response_type = "answer"

          answer = case reference_identifier
                  when "prepopulated_is_p_type_fifteen"
                    is_p_type_15?(question, participant)
                  else
                    nil
                  end

          build_response_for_value(response_type, response_set, question, answer, nil)
        end
      end
    end
  end
end
