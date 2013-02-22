# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class NonInterview < Base

    def reference_identifiers
      [
        "prepopulated_is_declined_participation_prior_to_enrollment",
        "prepopulated_study_center_type"
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
            when "prepopulated_study_center_type"
              what_study_center_type?(question)
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

    def what_study_center_type?(question)
      # Maps answer.text to answer.reference_identifier for clarity
      answer_map = {
        "OVC AND EH STUDY CENTER" => 1,
        "PB AND PBS STUDY CENTER" => 2,
        "HILI STUDY CENTER" => 3
      }

      # Maps recruitment_type_id to the corresponding answer.reference_identifier
      center_type_map = {
        # Enhanced Household Enumeration
        1 => answer_map["OVC AND EH STUDY CENTER"],
        # Provider-Based Recruitment
        2 => answer_map["PB AND PBS STUDY CENTER"],
        # Two-Tier
        3 => answer_map["HILI STUDY CENTER"],
        # Original VC
        4 => answer_map["OVC AND EH STUDY CENTER"],
        # Provider Based Subsample
        5 => answer_map["PB AND PBS STUDY CENTER"]
      }

      answer_for(question, center_type_map[NcsNavigatorCore.recruitment_type_id])
    end

  end
end
