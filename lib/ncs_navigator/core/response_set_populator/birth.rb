# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class Birth < Base

    def reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_birth_deliver_from_birth_visit_part_one",
        "prepopulated_release_from_birth_visit_part_one",
        "prepopulated_multiple_from_birth_visit_part_one",
        "prepopulated_is_valid_work_name_provided",
        "prepopulated_is_valid_work_address_provided",
        "prepopulated_is_pv_one_complete",
        "prepopulated_is_pv_two_complete"
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
                  when "prepopulated_birth_deliver_from_birth_visit_part_one"
                    answer_equal_to_response_from_part_one_for(question, "BIRTH_VISIT_3.BIRTH_DELIVER")
                  when "prepopulated_release_from_birth_visit_part_one"
                    answer_equal_to_response_from_part_one_for(question, "BIRTH_VISIT_3.RELEASE")
                  when "prepopulated_multiple_from_birth_visit_part_one"
                    answer_equal_to_response_from_part_one_for(question, "BIRTH_VISIT_3.MULTIPLE")
                  when "prepopulated_is_valid_work_name_provided"
                    is_valid_work_name_provided?(question)
                  when "prepopulated_is_valid_work_address_provided"
                    is_valid_work_address_provided?(question)
                  when "prepopulated_is_pv_one_complete"
                    answer_for(question, participant.try(:completed_event?, 13))
                  when "prepopulated_is_pv_two_complete"
                    answer_for(question, participant.try(:completed_event?, 15))
                  else
                    nil
                  end

        build_response_for_value(response_type, response_set, question, answer, nil)
        end
      end
      response_set
    end


    def answer_equal_to_response_from_part_one_for(question, data_export_identifier)
      if most_recent_response = person.responses_for(data_export_identifier).last
        question.answers.detect { |a| a.reference_identifier == most_recent_response.answer.reference_identifier }
      end
    end
    # PROGRAMMER INSTRUCTION:
    # - IF EMPLOY2 = 1, AND WORK_NAME PREVIOUSLY SET TO COMPLETE, AND VALID RESPONSE PROVIDED, GO TO WORK_NAME_CONFIRM.
    # - IF EMPLOY2 = 1, AND WORK_NAME PREVIOUSLY NOT SET TO COMPLETE, GO TO WORK_NAME.
    # - OTHERWISE, GO TO WCC003G.
    def is_valid_work_name_provided?(question)
      answer_for(question, work_attr_provided?(question, "WORK_NAME"))
    end

    # PROGRAMMER INSTUCTIONS:
    # - IF WORK_ADDRESS_VARIABLES COLLECTED PREVIOUSLY AND VALID WORK ADDRESS PROVIDED,
    #   GO TO WORK_ADDRESS_VARIABLES_CONFIRM.
    # - OTHERWISE, IF WORK_ADDRESS_VARIABLES NOT COLLECTED PREVIOUSLY OR VALID WORK
    #   ADDRESS NOT PROVIDED, GO TO WORK_ADDRESS_VARIABLES.
    def is_valid_work_address_provided?(question)
      answer_for(question, work_attr_provided?(question, "WORK_ADDRESS_1"))
    end

    def work_attr_provided?(question, att)
      ri = false
      ["PREG_VISIT_1_3", "PREG_VISIT_2_3"].each do |pv|
        ri = valid_response_exists?("#{pv}.#{att}", :last)
        break if ri # short-circuit check for pv2
      end
      ri
    end
    private :work_attr_provided?

  end
end