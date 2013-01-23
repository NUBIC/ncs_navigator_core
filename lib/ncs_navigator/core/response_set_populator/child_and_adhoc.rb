# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class ChildAndAdHoc < Base

    def reference_identifiers
      [
        "prepopulated_should_show_upper_arm_length",
        "prepopulated_is_6_month_event",
        "prepopulated_is_12_month_visit"
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
            when "prepopulated_should_show_upper_arm_length"
              is_arm_circ_given_in_anthropo?(question) ?
                answer_for(question,
                           prepopulate_bp_mid_upper_arm_circ(question,
                                                             response_set)) :
                answer_for(question, false)
            when "prepopulated_is_6_month_event"
              answer_for(question, (event.try(:event_type_code).to_i == 24))
            when "prepopulated_is_12_month_visit"
              answer_for(question, (event.try(:event_type_code).to_i == 27))
            else
              nil
            end

          build_response_for_value(response_type, response_set,
                                   question, answer, nil)
        end
      end
      response_set
    end

    def get_upper_arm_circ_as_float
      most_recent_response = person.responses_for(
                    "CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1"
      ).last.string_value

      begin
        bp_arm_circ = Float(most_recent_response)
      rescue ArgumentError
        false
      end
    end

    def prepopulate_bp_mid_upper_arm_circ(question, response_set)
      #bp_arm_circ = get_upper_arm_circ_as_float
      return false unless bp_arm_circ = get_upper_arm_circ_as_float

      prepop_question = find_question_for_reference_identifier(
                                                  "BP_MID_UPPER_ARM_CIRC")
      prepop_answer = answer_for(prepop_question, "1")
      build_response_for_value("float_value", response_set, prepop_question,
                               prepop_answer, bp_arm_circ)
      true
    end
      
    def is_arm_circ_given_in_anthropo?(question)
      valid_response_exists?("CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1", :last)
    end

  end
end
