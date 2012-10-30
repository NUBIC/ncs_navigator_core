# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class TracingModule < Base

    def reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_should_show_address_for_tracing",
        "prepopulated_is_address_provided",
        "prepopulated_is_home_phone_provided",
        "prepopulated_is_valid_cell_phone_provided",
        "prepopulated_is_valid_cell_phone_2_provided"
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
          response_type = "answer_value"

          answer = question.answers.first
          value = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    answer = prepopulated_mode_of_contact(question)
                  when "prepopulated_should_show_address_for_tracing"
                    answer = should_show_address?(question)
                  when "prepopulated_is_address_provided"
                    answer = has_address?(question)
                  when "prepopulated_is_home_phone_provided"
                    answer = has_home_phone?(question)
                  when "prepopulated_is_valid_cell_phone_provided"
                    answer = has_valid_cell_phone?(question)
                  when "prepopulated_is_valid_cell_phone_2_provided"
                    answer = has_cell_phone_2_been_answered?(question)
                  else
                    # TODO: handle other prepopulated fields
                    nil
                  end

        build_response_for_value(response_type, response_set, question, answer, value)
        end
      end
      response_set
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF EVENT_TYPE = BIRTH, 3 MONTH, 9 MONTH, 18 MONTH, 24 MONTH, OR 30 MONTH AND MODE = CATI, GO
    #       STREET_ADDRESS_VARIABLES.
    #    True
    #
    #    -  OTHERWISE, IF EVENT_TYPE = PBS PARTICIPANT ELIGIBILITY SCREENING, PREGNANCY VISIT 1, PREGNANCY
    #       VISIT 2, 6 MONTH, 12 MONTH, OR 36 MONTH, OR EVENT TYPE = 3 MONTH, 9 MONTH, 18 MONTH, 24 MONTH, OR
    #       30 MONTH AND MODE = CAPI OR PAPI, GO TO PLAN_MOVE.
    #    False
    def should_show_address?(question)
      ri = ( contact.try(:via_telephone?) && event.try(:postnatal?) ) ? "true" : "false"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    # PROGRAMMER INSTRUCTIONS:
    #   - IF STREET ADDRESS VARIABLES COLLECTED PREVIOUSLY FOR (R_FNAME)(R_MNAME)(R_LNAME) AND VALID STREET ADDRESS PROVIDED,
    #     PRELOAD VALID STREET ADDRESS FROM MOST RECENT INTERVIEW AND DISPLAY  “Let me confirm your street address. I have it as {PARENT/CAREGIVER’S ADDRESS}”.
    #   True
    #   - OTHERWISE, IF STREET ADDRESS VARIABLES NOT COLLECTED PREVIOUSLY FOR (R_FNAME)(R_MNAME)(R_LNAME) OR VALID STREET ADDRESS
    #     IS NOT AVAILABLE, DISPLAY  “What is your street address?”.
    #   False
    #   - ALLOW INTERVIEWER TO MAKE CORRECTIONS OR ADD NEW ADDRESS INFORMATION.
    def has_address?(question)
      ri =  person.primary_address.to_s.blank? ? "false" : "true"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  PRELOAD HOME PHONE NUMBER FROM MOST RECENT INTERVIEW FOR (R_FNAME)(R_MNAME)(R_LNAME).
    #    -  IF HOME_PHONE_CONFIRM = 1, -1, OR -7, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING HOME_PHONE.
    #    -  OTHERWISE, IF HOME_PHONE_CONFIRM =2 OR -2, GO TO HOME_PHONE.
    def has_home_phone?(question)
      ri =  person.primary_home_phone.nil? ? "false" : "true"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  PRELOAD CELL PHONE NUMBER FROM MOST RECENT INTERVIEW FOR CURRENT (R_FNAME)(R_MNAME)(R_LNAME).
    #    -  IF CELL_PHONE_CONFIRM = 1 AND CELL_PHONE_2 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER
    #       INSTRUCTIONS FOLLOWING CELL_PHONE.
    #    -  IF CELL_PHONE_CONFIRM = -1 OR -7, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_4.
    #    -  IF CELL_PHONE_CONFIRM = 2 OR -2, GO TO CELL_PHONE.
    #    -  OTHERWISE, GO TO CELL_PHONE_2.
    def has_valid_cell_phone?(question)
      ri =  person.primary_cell_phone.nil? ? "false" : "true"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF CELL_PHONE = -1, -2, OR -7, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_4.
    #    -  IF CELL_PHONE_2 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_2.
    #    -  OTHERWISE, GO TO CELL_PHONE_2.
    def has_cell_phone_2_been_answered?(question)
      ri = person.responses_for("TRACING_INT.CELL_PHONE_2").blank? ? "false" : "true"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

  end
end