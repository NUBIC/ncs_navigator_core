module ResponseSetPrepopulation
  class PregnancyVisit < Populator
    include OldAccessMethods

    def self.applies_to?(rs)
      %w(PregVisit1 PregVisit2).any? { |t| rs.survey.title.include?("_#{t}_") }
    end

    def self.reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_should_show_height",
        "prepopulated_should_show_recent_move_for_preg_visit_one",
        "prepopulated_is_first_pregnancy_visit_one",
        "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one",
        "prepopulated_is_work_name_previously_collected_and_valid",
        "prepopulated_is_work_address_previously_collected_and_valid",
      ]
    end

    def run
      self.class.reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(reference_identifier)
          response_type = "answer"
          answer = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    prepopulated_mode_of_contact(question)
                  when "prepopulated_should_show_height"
                    should_show_height?(question)
                  when "prepopulated_should_show_recent_move_for_preg_visit_one"
                    should_show_recent_move_for_preg_visit_one?(question)
                  when "prepopulated_is_first_pregnancy_visit_one"
                    is_first_pregnancy_visit_one?(question)
                  when "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one"
                    is_pre_pregnancy_information_available_and_recent_move_coded_as_one?(question)
                  when "prepopulated_is_work_name_previously_collected_and_valid"
                    is_work_name_previously_collected_and_valid?(question)
                  when "prepopulated_is_work_address_previously_collected_and_valid"
                    is_work_address_previously_collected_and_valid?(question)
                  else
                    nil
                  end
          build_response_for_value(response_type, response_set, question, answer, nil)
        end
      end
      response_set
    end

    # PROGRAMMER INSTRUCTION:
    # - IF FIRST PREGNANCY VISIT 1 INTERVIEW, GO TO HEIGHT_FT/HT_INCH.
    #   true
    # - IF SUBSEQUENT PREGANCY VISIT 1 INTERVIEW, GO TO WEIGHT.
    #   false
    def should_show_height?(question)
      answer_for(question, is_first_pv1?)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF FIRST PREGNANCY VISIT 1 INTERVIEW:
    # -   IF OWN_HOME WAS ASKED DURING PREGNANCY SCREENER OR PRE-PREGANCY VISIT, THEN ASK RECENT_MOVE.
    # -   OTHERWISE, GO TO OWN_HOME.
    # - IF SUBSEQUENT PREGNANCY VISIT 1 INTERVIEW:
    # -   GO TO RECENT_MOVE
    def should_show_recent_move_for_preg_visit_one?(question)
      ri = true
      if is_first_pv1?
        ri = (person.responses_for("PRE_PREG.OWN_HOME").size > 0)
      end
      answer_for(question, ri)
    end

    # PROGRAMMER INSTRUCTIONS:
    #
    # - IF FIRST PREGNANCY VISIT 1 INTERVIEW:
    # -   THE REST OF THE QUESTIONS IN THIS SECTION ARE ONLY ASKED OF A SUBSET OF PARTICIPANTS, DEPENDING UPON WHETHER
    #     A PRE-PREGNANCY QUESTIONNAIRE WAS COMPLETED AND RESPONSES TO RECENT_MOVE ABOVE AND DURING THE PRE-PREGNANCY VISIT
    # -   IF RECENT_MOVE DURING THIS EVENT IS “1 ” GO TO AGE_HOME AND CONTINUE THROUGH REST OF SECTION
    # -   IF RECENT_MOVE DURING THIS EVENT IS ‘2,' -1,' OR ‘-2 AND
    #       NO PRE-PREGNANCY INFORMATION IS AVAILABLE; GO TO AGE_HOME AND CONTINUE THROUGH REST OF SECTION
    # -   IF RECENT_MOVE WAS ASKED DURING PRE-PREGNANCY QUESTIONNAIRE AND WAS CODED AS “1”; SKIP REST OF SECTION AND GO TO TIME_STAMP_9
    # -   IF RECENT_MOVE WAS ASKED DURING PRE-PREGNANCY QUESTIONNAIRE AND WAS NOT CODED AS “1”; GO TO (AGE_HOME) AND CONTINUE THROUGH SECTION
    # - IF SUBSEQUENT PREGNANCY VISIT 1 INTERVIEW:
    # -   IF RECENT_MOVE DURING THIS EVENT IS “1” GO TO AGE_HOME AND CONTINUE THROUGH REST OF SECTION
    # -   IF RECENT_MOVE DURING THIS EVENT IS ‘2,' -1,' OR ‘--2', GO TO HC018.
    def is_first_pregnancy_visit_one?(question)
      answer_for(question, is_first_pv1?)
    end

    def is_pre_pregnancy_information_available_and_recent_move_coded_as_one?(question)
      ri = false
      if is_first_pv1?
        most_recent_response = person.responses_for("PRE_PREG.RECENT_MOVE").last
        ri = (most_recent_response.try(:answer).try(:reference_identifier).to_i == 1)
      end
      answer_for(question, ri)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF WORKING= 1, AND WORK_NAME PREVIOUSLY COLLECTED AND VALID RESPONSE PROVIDED, GO TO WORK_NAME_CONFIRM.
    # - IF WORKING = 1, AND WORK_NAME NOT PREVIOUSLY COLLECTED OR VALID RESPONSE NOT PROVIDED, GO TO WORK_NAME.
    def is_work_name_previously_collected_and_valid?(question)
      answer_for(question, valid_response_exists?("PREG_VISIT_1_3.WORK_NAME", :last))
    end

    # - IF WORK_ADDRESS_VARIABLES NOT COLLECTED PREVIOUSLY OR VALID WORK ADDRESS NOT PROVIDED, GO TO WORK_ADDRESS_VARIABLES.
    # - IF WORK_ADDRESS_VARIABLES COLLECTED PREVIOUSLY AND VALID WORK ADDRESS PROVIDED, GO TO WORK_ADDRESS_VARIABLES_CONFIRM.
    #   OTHERWISE, GO TO TIME_STAMP_EM_ET.
    def is_work_address_previously_collected_and_valid?(question)
      answer_for(question, valid_response_exists?("PREG_VISIT_1_3.WORK_ADDRESS_1", :last))
    end

    ##
    # True if the participant has not completed the pv1 event previously
    # @return[Boolean]
    def is_first_pv1?
      !participant.completed_event?( NcsCode.for_list_name_and_local_code(
        'EVENT_TYPE_CL1', Event.pregnancy_visit_1_code) )
    end

  end
end
