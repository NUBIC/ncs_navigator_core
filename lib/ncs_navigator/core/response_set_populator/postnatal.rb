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
        "q_prepopulated_is_birth_deliver_collected_and_set_to_one",
        "prepopulated_mult_child_answer_from_part_one_for_6MM",
        "prepopulated_is_three_months_interview_set_to_complete",
        "prepopulated_is_child_qnum_one",
        "prepopulated_is_resp_rel_new",
        "prepopulated_mult_child_answer_from_part_one_for_12MM",
        "prepopulated_should_show_num_hh_group",
        "prepopulated_is_valid_work_name_provided",
        "prepopulated_is_valid_work_address_provided"
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
              answer_for(question, were_there_no_prenatal_events?)
            when "prepopulated_is_prev_event_birth_li_and_set_to_complete"
              answer_for(question, is_event_completed?(Event::birth_code))
            when "prepopulated_is_multiple_child"
              answer_for(question, prepopulated_is_multiple_child?(question))
            when "q_prepopulated_is_birth_deliver_collected_and_set_to_one"
              answer_for(question, was_birth_given_at_hospital?)
            when "prepopulated_mult_child_answer_from_part_one_for_6MM"
              answer_for(question,
                         was_answer_to_mult_child_yes?("SIX_MTH_MOTHER"))
            when "prepopulated_is_three_months_interview_set_to_complete"
              answer_for(question, 
                         is_event_completed?(Event::three_month_visit_code))
            when "prepopulated_is_child_qnum_one"
              answer_for(question, is_this_child_number_one?)
            when "prepopulated_is_resp_rel_new"
              answer_for(question, was_resp_rel_new_biological_mother?)
            when "prepopulated_mult_child_answer_from_part_one_for_12MM"
              answer_for(question,
                         was_answer_to_mult_child_yes?("TWELVE_MTH_MOTHER"))
            when "prepopulated_should_show_num_hh_group"
              answer_for(question, was_household_number_collected?)
            when "prepopulated_is_valid_work_name_provided"
              answer_for(question, was_work_name_collected?)
            when "prepopulated_is_valid_work_address_provided"
              answer_for(question, was_work_address_collected?)
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

    def were_there_no_prenatal_events?
      person_events_array = person.events.inject([]) { |arr, el|
        arr + [el.event_type_code]
      }
      # Returns true if events found that are not in the POSTNATAL_EVENTS set
      (Set.new(person_events_array) - Set.new(Event::POSTNATAL_EVENTS)).empty?
    end

    def is_event_completed?(code)
      person.events.each do |e|
        e.event_type_code == code && 
                      e.completed? ? (return true) : (return false)
      end
      
      false
    end

    def prepopulated_is_multiple_child?(question)
      # Two different surveys have this question signature, easier to
      # check for survey name here then split-out into yet another file
      if question.survey_section.survey.title =~ /6Month/i
        get_last_response_as_string(
                    "PARTICIPANT_VERIF.MULT_CHILD") == NcsCode::YES.to_s
      else
        participant.children.size > 1
      end
    end

    def was_birth_given_at_hospital?
      get_last_response_as_string(
                    "BIRTH_VISIT_LI_2.BIRTH_DELIVER") == "1" # HOSPITAL
    end

    def was_answer_to_mult_child_yes?(data_export_id)
      get_last_response_as_string(
                    "#{data_export_id}.MULT_CHILD") == NcsCode::YES.to_s
    end

    def is_this_child_number_one?
      person.responses_for("PARTICIPANT_VERIF.CHILD_QNUM"
                          ).last.try(:value) == 1 # Child number 1
    end

    def was_resp_rel_new_biological_mother?
      get_last_response_as_string(
          "PARTICIPANT_VERIF.RESP_REL_NEW") == "1" # BIOLOGICAL (OR BIRTH) MOTHER
    end

    def check_multiple_surveys_for_response(reference_id)
      Response.includes([:answer, :question, :response_set]).where(
        "response_sets.user_id = ? AND questions.data_export_identifier like ?",
        person.id, "%.#{reference_id}").each do |response|
          # Presense of an value implies selection of answer with 
          # ref_id "number", so no need to check.
          return true if response.try(:value)
        end
        
      false
    end

    def was_household_number_collected?
      check_multiple_surveys_for_response("NUM_HH")
    end
      
    def was_work_name_collected?
      check_multiple_surveys_for_response("WORK_NAME")
    end

    def was_work_address_collected?
      check_multiple_surveys_for_response("WORK_ADDRESS_1")
    end
    
  end
end
