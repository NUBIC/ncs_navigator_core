# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class PregnancyVisit < Base
    def reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_should_show_height",
        "prepopulated_should_show_recent_move_for_preg_visit_one",
        "prepopulated_is_first_pregnancy_visit_one",
        "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one"
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
                  when "prepopulated_should_show_height"
                    should_show_height?(question)
                  when "prepopulated_should_show_recent_move_for_preg_visit_one"
                    should_show_recent_move_for_preg_visit_one?(question)
                  when "prepopulated_is_first_pregnancy_visit_one"
                    is_first_pregnancy_visit_one?(question)
                  when "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one"
                    is_pre_pregnancy_information_available_and_recent_move_coded_as_one?(question)
                  else
                    # TODO: handle other prepopulated fields
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
      ri = is_first_pv1? ? "true" : "false"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF FIRST PREGNANCY VISIT 1 INTERVIEW:
    # -   IF OWN_HOME WAS ASKED DURING PREGNANCY SCREENER OR PRE-PREGANCY VISIT, THEN ASK RECENT_MOVE.
    # -   OTHERWISE, GO TO OWN_HOME.
    # - IF SUBSEQUENT PREGNANCY VISIT 1 INTERVIEW:
    # -   GO TO RECENT_MOVE
    def should_show_recent_move_for_preg_visit_one?(question)
      ri = "true"
      if is_first_pv1?
        ri = (person.responses_for("PRE_PREG.OWN_HOME").size > 0) ? "true" : "false"
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
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
      ri = is_first_pv1? ? "true" : "false"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    def is_pre_pregnancy_information_available_and_recent_move_coded_as_one?(question)
      ri = "false"
      if is_first_pv1?
        most_recent_response = person.responses_for("PRE_PREG.RECENT_MOVE").last
        ri = (most_recent_response.try(:answer).try(:reference_identifier).to_i == 1) ? "true" : "false"
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    def is_first_pv1?
      pv1_contacts = person.contact_links.select do |cl|
        cl.event.try(:event_type_code) == 13
      end.map(&:contact).uniq
      pv1_contacts.count == 0
    end

  end
end