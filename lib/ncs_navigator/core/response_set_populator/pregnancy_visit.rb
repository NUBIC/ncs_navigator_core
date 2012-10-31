# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class PregnancyVisit < Base
        def reference_identifiers
      [
        "prepopulated_mode_of_contact",
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
          response_type = "answer"

          answer = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    prepopulated_mode_of_contact(question)
                  else
                    # TODO: handle other prepopulated fields
                    nil
                  end

          build_response_for_value(response_type, response_set, question, answer, nil)
        end
      end
      response_set
    end

  end
end