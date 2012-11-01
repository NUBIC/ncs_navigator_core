# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class Birth < Base

    def reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_birth_deliver_from_birth_visit_part_one"
      ]
    end

    ##
    # Set values in the most recent response set for the instrument
    def populate
      prepopulate_response_set(instrument.response_sets.last)
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
                  when "prepopulated_mode_of_contact"
                    response_type = "answer"
                    answer = prepopulated_mode_of_contact(question)
                  when "prepopulated_birth_deliver_from_birth_visit_part_one"
                    response_type = "answer"
                    if most_recent_response = person.responses_for("BIRTH_VISIT_3.BIRTH_DELIVER").last
                      answer = question.answers.select{ |a| a.reference_identifier == most_recent_response.answer.reference_identifier }.first
                    end
                  else
                    # TODO: handle other prepopulated fields
                    response_type = "string_value"
                    nil
                  end

        build_response_for_value(response_type, response_set, question, answer, value)
        end
      end
      response_set
    end

  end
end