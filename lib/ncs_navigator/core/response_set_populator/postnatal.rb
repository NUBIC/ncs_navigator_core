# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class Postnatal < Base

    def reference_identifiers
      [
        "prepopulated_should_show_room_mold_child",
        "prepopulated_should_show_demographics",
        "prepopulated_is_prev_event_birth_li_and_set_to_complete",
        "prepopulated_is_multiple_child",
        "prepopulated_is_birth_deliver_collelected_and_set_to_one",
        "prepopulated_mult_child_answer_from_part_one_for_6MM",
        "prepopulated_is_three_months_interview_set_to_complete"
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
            when "prepopulated_should_show_room_mold_child"
              answer_for(question, is_response_to_mold_question_yes?)
            when "prepopulated_should_show_demographics"
              answer_for(question, were_there_prenatal_events?)
            when "prepopulated_is_prev_event_birth_li_and_set_to_complete"
              answer_for(question, does_completed_birth_record_exists?)
            when "prepopulated_is_multiple_child"
              answer_for(question, participan_has_multiple_children?)
            when "prepopulated_is_birth_deliver_collelected_and_set_to_one"
              answer_for(question, was_birth_given_at_hospital?)
            when "prepopulated_mult_child_answer_from_part_one_for_6MM"
              answer_for(question, was_answer_to_mult_child_yes?)
            when "prepopulated_is_three_months_interview_set_to_complete"
              answer_for(question, was_three_month_event_completed?)
            else
              nil
            end
          build_response_for_value(response_type, response_set,
                                   question, answer, nil)
        end
      end
      response_set
    end

    def get_last_response_as_string(data_export_identifier)
      most_recent_response = person.responses_for(data_export_identifier).last
      most_recent_response.try(:answer).try(:reference_identifier)
    end

    def is_response_to_mold_question_yes?
      get_last_response_as_string(
                    "EIGHTEEN_MTH_MOTHER_2.MOLD") == NcsCode::YES.to_s
    end

    def were_there_prenatal_events?
      person.events.each do |event|
        return false unless Event::POSTNATAL_EVENTS.any? { |pnatal_event_code|
          event.event_type_code == pnatal_event_code
        }
      end

      true
    end

    def does_completed_birth_record_exists?
      ncs_code = NcsCode::for_list_name_and_local_code('EVENT_TYPE_CL1',
                                                       Event::birth_code)
      person.events.each do |event|
        if event.event_type_code == Event::birth_code
          return person.participant.completed_event?(ncs_code)
        end
      end

      false
    end

    def participan_has_multiple_children?
      participant.children.size > 1
    end

    def was_birth_given_at_hospital?
      get_last_response_as_string(
                    "BIRTH_VISIT_LI_2.BIRTH_DELIVER") == "1" # HOSPITAL
    end

    def was_answer_to_mult_child_yes?
      get_last_response_as_string(
                    "SIX_MTH_MOTHER.MULT_CHILD") == NcsCode::YES.to_s
    end

    def was_three_month_event_completed?
      ncs_code = NcsCode::for_list_name_and_local_code('EVENT_TYPE_CL1',
                                                Event::three_month_visit_code)
      person.events.each do |event|
        if event.event_type_code == Event::three_month_visit_code
          return person.participant.completed_event?(ncs_code)
        end
      end

      false
    end

  end
end
