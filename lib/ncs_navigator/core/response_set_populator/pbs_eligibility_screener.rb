# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class PbsEligibilityScreener < Base

    def reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_psu_id",
        "prepopulated_practice_num",
        "prepopulated_provider_id",
        "NAME_PRACTICE"
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
        response_type = "string_value"

        if question = find_question_for_reference_identifier(reference_identifier)
          answer = question.answers.first
          value = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    response_type = "answer"
                    answer = prepopulated_mode_of_contact(question)
                  when "prepopulated_psu_id"
                    NcsNavigatorCore.psu
                  when "prepopulated_practice_num"
                    person.provider.pbs_list.try(:practice_num) if person.provider
                  when "prepopulated_provider_id"
                    person.provider.public_id if person.provider
                  when "NAME_PRACTICE"
                    person.provider.name_practice if person.provider
                  else
                    nil
                  end

        build_response_for_value(response_type, response_set, question, answer, value)
        end
      end
      response_set
    end

  end
end