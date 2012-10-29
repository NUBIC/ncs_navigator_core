# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class Birth < Base

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
      # TODO: determine way to know about initializing data for each survey
      reference_identifiers = [
        "prepopulated_mode_of_contact",
      ]

      response_type = "string_value"

      reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(reference_identifier)
          answer = question.answers.first
          value = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    response_type = "answer_value"
                    # If In-Person use 'capi' otherwise use 'cati'
                    # TODO: how to determine 'papi' ?
                    ri = contact.try(:contact_type_code) == 1 ? "capi" : "cati"
                    answer = question.answers.select { |a| a.reference_identifier == ri }.first
                  else
                    # TODO: handle other prepopulated fields
                    nil
                  end

        build_response_for_value(response_type, response_set, question, answer, value)
        end
      end
      response_set
    end

  end
end