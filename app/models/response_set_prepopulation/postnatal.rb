module ResponseSetPrepopulation
  class Postnatal < Populator
    include OldAccessMethods

    def self.applies_to?(rs)
      rs.survey.title =~ /_(?:Core|\d{1,2}(?:Month|MMother))_/
    end

    def self.reference_identifiers
      [
        "prepopulated_should_show_room_mold_child",
        "prepopulated_should_show_demographics",
        "prepopulated_is_prev_event_birth_li_and_set_to_complete",
        "prepopulated_is_multiple_child",
        "prepopulated_is_birth_deliver_collected_and_set_to_one",
        "prepopulated_mult_child_answer_from_part_one_for_6MM",
        "prepopulated_is_three_months_interview_set_to_complete",
        "prepopulated_is_child_qnum_one",
        "prepopulated_is_resp_rel_new",
        "prepopulated_mult_child_answer_from_part_one_for_12MM",
        "prepopulated_should_show_num_hh_group",
        "prepopulated_is_valid_work_name_provided",
        "prepopulated_is_valid_work_address_provided",
        "prepopulated_is_child_num_gt_or_eq_one_for_first_child",
        "prepopulated_intro_30_months"
      ]
    end

    def run
      self.class.reference_identifiers.each do |reference_identifier|
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
              answer_for(question, !is_event_completed?(Event::birth_code))
            when "prepopulated_is_multiple_child"
              answer_for(question, prepopulated_is_multiple_child?(question))
            when "prepopulated_is_birth_deliver_collected_and_set_to_one"
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
              ans = answer_for(question, was_household_number_not_collected?)
            when "prepopulated_is_valid_work_name_provided"
              answer_for(question, was_work_name_collected?)
            when "prepopulated_is_valid_work_address_provided"
              answer_for(question, was_work_address_collected?)
            when "prepopulated_is_child_num_gt_or_eq_one_for_first_child"
              answer_for(question, is_the_first_child?)
            when "prepopulated_intro_30_months"
              answer_for(question, get_last_response_as_string(
                                  "THIRTY_MONTH_INTERVIEW_CHILD.INTRO_30MO"))
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
      d_identifiers = %w(EIGHTEEN_MTH_MOTHER_3.MOLD EIGHTEEN_MTH_MOTHER_2.MOLD)
      d_identifiers.any?{|d_identifier| get_last_response_as_string(d_identifier) == NcsCode::YES.to_s}
    end

    def were_there_no_prenatal_events?
      person_events_array = person.events.inject([]) { |arr, el|
        arr + [el.event_type_code]
      }
      # Returns true if events found that are not in the POSTNATAL_EVENTS set
      (Set.new(person_events_array) - Set.new(Event::POSTNATAL_EVENTS)).empty?
    end

    def is_event_completed?(code)
      event = participant.events.chronological.where(
                            :event_type_code => code).last
      event && event.try(:completed?) ? true : false
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
      check_multiple_surveys_for_response("BIRTH_DELIVER", "1")
    end

    def was_answer_to_mult_child_yes?(data_export_id)
      get_last_response_as_string(
                    "#{data_export_id}.MULT_CHILD") == NcsCode::YES.to_s
    end

    def is_this_child_number_one?
      person.responses_for("PARTICIPANT_VERIF.CHILD_QNUM"
                          ).last.try(:value) == 1 # Child number 1
    end

    def is_the_first_child?
      return true unless was_answer_to_mult_child_yes?("PARTICIPANT_VERIF")
      is_this_child_number_one?
    end

    def was_resp_rel_new_biological_mother?
      get_last_response_as_string(
          "PARTICIPANT_VERIF.RESP_REL_NEW") == "1" # BIOLOGICAL (OR BIRTH) MOTHER
    end

    def check_multiple_surveys_for_response(q_ref_id, a_ref_id = nil)
      candidates = Response.includes([:answer, :question, :response_set]).where(
        "response_sets.user_id = ? AND questions.data_export_identifier like ?",
        person.id, "%.#{q_ref_id}")
        candidates.any? { |c|
          c.value || a_ref_id && c.answer.reference_identifier == a_ref_id
        }
    end

    def was_household_number_not_collected?
      !check_multiple_surveys_for_response("NUM_HH")
    end

    def was_work_name_collected?
      check_multiple_surveys_for_response("WORK_NAME")
    end

    def was_work_address_collected?
      check_multiple_surveys_for_response("WORK_ADDRESS_1") ||
              check_multiple_surveys_for_response("CWORK_ADDRESS_1") ||
              check_multiple_surveys_for_response("WORK_ADDRESS1")
    end
  end
end
