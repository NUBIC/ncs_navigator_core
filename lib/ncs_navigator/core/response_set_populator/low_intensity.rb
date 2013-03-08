# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class LowIntensity < Base

    def reference_identifiers
      [
        "prepopulated_ppg_status",
      ]
    end

    ##
    # Creates responses for questions with reference identifiers
    # that are known values and should be prepopulated
    # @param [ResponseSet]
    # @return [ResponseSet]
    def prepopulate_response_set(response_set)
      reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(reference_identifier)
          answer = question.answers.first
          value = case reference_identifier
                  when "prepopulated_ppg_status"
                    response_type = "integer_value"
                    person.ppg_status
                  else
                    # TODO: handle other prepopulated fields
                    response_type = "string_value"
                    nil
                  end
          response_set.responses.build(:question => question, :answer => answer, response_type.to_sym => value)
        end
      end
      response_set
    end

  end
end