# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class ChildAndAdHoc < Base

    def reference_identifiers
      [
        "prepopulated_should_show_upper_arm_length",
        "prepopulated_is_6_month_event",
        "prepopulated_is_12_month_visit",
        "prepopulated_event_type",
        "prepopulated_is_subsequent_father_interview"
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
              answer_for(question, event.six_month_visit?)
            when "prepopulated_is_12_month_visit"
              answer_for(question, event.twelve_month_visit?)
            when "prepopulated_event_type"
              answer_for(question, check_event_type_for_con_reconsideration)
            when "prepopulated_is_subsequent_father_interview"
              answer_for(question, is_this_a_subsequent_father_interview?)
            else
              nil
            end

          build_response_for_value(response_type, response_set,
                                   question, answer, nil)
        end
      end
      response_set
    end

    def prepopulate_bp_mid_upper_arm_circ(question, response_set)
      bp_arm_circ = person.responses_for("CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1"
                                        ).last.string_value

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

    def is_this_a_subsequent_father_interview?
      person.events.any? do |e|
        # Skip current event then try matching
        e.id != event.id && e.event_type_code == Event::father_visit_code ||
                            e.event_type_code == Event::father_visit_saq_code
      end
    end
 
    def check_event_type_for_con_reconsideration
      # List of all pregnancy visit events
      pregnancy_visits = [
        event.pregnancy_visit_1?,
        event.pregnancy_visit_1_saq?,
        event.pregnancy_visit_2?,
        event.pregnancy_visit_2_saq?
      ]
      if pregnancy_visits.any?
        "pv"
      elsif event.twelve_month_visit?
        "twelve_mns"
      else
        "" 
      end
    end

  end
end
