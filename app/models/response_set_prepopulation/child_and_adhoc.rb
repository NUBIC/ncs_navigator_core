module ResponseSetPrepopulation
  class ChildAndAdhoc < Populator
    include OldAccessMethods

    def self.applies_to?(rs)
      [
        /_PM_Child/,
        /_BIO_Child/,
        /_CON_Reconsideration/,
        /_Father.*M2.1/,
        /_InternetUseContact/
      ].any?{ |regex| rs.survey.title =~ regex }
    end

    def self.reference_identifiers
      [
        "prepopulated_should_show_upper_arm_length",
        "prepopulated_is_6_month_event",
        "prepopulated_is_12_month_visit",
        "prepopulated_event_type",
        "prepopulated_is_subsequent_father_interview",
        "prepopulated_is_3_months_completed",
        "prepopulated_is_9_months_completed",
        "prepopulate_is_birth_or_subsequent_event"
      ]
    end

    def run
      self.class.reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(
                                              reference_identifier)
          response_type = "answer"
          answer =
            case reference_identifier
            when "prepopulated_should_show_upper_arm_length"
              answer_for(question, is_arm_circ_given_in_anthropo?(question,
                                                                 response_set))
            when "prepopulated_is_6_month_event"
              answer_for(question, event.six_month_visit?)
            when "prepopulated_is_12_month_visit"
              answer_for(question, event.twelve_month_visit?)
            when "prepopulated_event_type"
              answer_for(question, check_event_type_for_con_reconsideration)
            when "prepopulated_is_subsequent_father_interview"
              answer_for(question, is_this_a_subsequent_father_interview?)
            when "prepopulated_is_3_months_completed"
              answer_for(question,
                         is_event_completed?(Event::three_month_visit_code))
            when "prepopulated_is_9_months_completed"
              answer_for(question,
                         is_event_completed?(Event::nine_month_visit_code))
            else
              nil
            end

          build_response_for_value(response_type, response_set,
                                   question, answer, nil)
        end
      end
      response_set
    end

    def is_event_completed?(code)
      person.events.any? { |e| e.event_type_code == code && e.completed? }
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

    def is_arm_circ_given_in_anthropo?(question, response_set)
      valid_response_exists?("CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1", :last) ?
          prepopulate_bp_mid_upper_arm_circ(question, response_set) : false
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
