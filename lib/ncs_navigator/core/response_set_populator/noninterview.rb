# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class NonInterview < Base

    def reference_identifiers
      [
        "prepopulated_is_declined_participation_prior_to_enrollment"
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
        if question = find_question_for_reference_identifier(
                                              reference_identifier)
          response_type = "answer"
          answer =
            case reference_identifier
            when "prepopulated_is_declined_participation_prior_to_enrollment"
              general_consent_given?(question)
            else
              nil
            end

          build_response_for_value(response_type, response_set,
                                   question, answer, nil)
        end
      end
      response_set
    end

    def general_consent_given?(question)
      general_consent = NcsCode.for_list_name_and_local_code(
                                                "CONSENT_TYPE_CL1", 1)
      answer_for(question, participant.consented?(general_consent))
    end

  end
end
