module ResponseSetPrepopulation
  class TracingModule < Populator
    include OldAccessMethods

    def self.applies_to?(rs)
      rs.survey.title.include?('_Tracing_')
    end

    def self.reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_should_show_address_for_tracing",
        "prepopulated_is_address_provided",
        "prepopulated_is_home_phone_provided",
        "prepopulated_is_valid_cell_phone_provided",
        "prepopulated_is_valid_cell_phone_2_provided",
        "prepopulated_is_valid_cell_phone_3_provided",
        "prepopulated_is_valid_cell_phone_4_provided",
        "prepopulated_should_show_email_for_tracing",
        "prepopulated_is_valid_email_provided",
        "prepopulated_is_valid_email_appt_provided",
        "prepopulated_is_valid_email_questionnaire_provided",
        "prepopulated_should_show_contact_for_tracing",
        "prepopulated_is_event_type_birth",
        "prepopulated_is_valid_contact_for_all_provided",
        "prepopulated_is_event_type_pbs_participant_eligibility_screening",
        "prepopulated_is_prev_city_provided",
        "prepopulated_valid_driver_license_provided"
      ]
    end

    def run
      self.class.reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(reference_identifier)
          response_type = "answer"

          answer = question.answers.first
          answer = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    prepopulated_mode_of_contact(question)
                  when "prepopulated_should_show_address_for_tracing"
                    should_show_address?(question)
                  when "prepopulated_is_address_provided"
                    has_address?(question)
                  when "prepopulated_is_home_phone_provided"
                    has_home_phone?(question)
                  when "prepopulated_is_valid_cell_phone_provided"
                    has_valid_cell_phone?(question)
                  when "prepopulated_is_valid_cell_phone_2_provided"
                    has_cell_phone_2_been_answered?(question)
                  when "prepopulated_is_valid_cell_phone_3_provided"
                    has_cell_phone_3_been_answered?(question)
                  when "prepopulated_is_valid_cell_phone_4_provided"
                    has_cell_phone_4_been_answered?(question)
                  when "prepopulated_should_show_email_for_tracing"
                    should_show_email_for_tracing?(question)
                  when "prepopulated_is_valid_email_provided"
                    has_email?(question)
                  when "prepopulated_is_valid_email_appt_provided"
                    has_answered_email_appt?(question)
                  when "prepopulated_is_valid_email_questionnaire_provided"
                    has_answered_email_quest?(question)
                  when "prepopulated_should_show_contact_for_tracing"
                    should_show_contact?(question)
                  when "prepopulated_is_event_type_birth"
                    is_event_birth?(question)
                  when "prepopulated_is_valid_contact_for_all_provided"
                    are_all_contacts_provided?(question)
                  when "prepopulated_is_event_type_pbs_participant_eligibility_screening"
                    is_event_pbs_participant_eligibility_screening?(question)
                  when "prepopulated_is_prev_city_provided"
                    has_answered_prev_city?(question)
                  when "prepopulated_valid_driver_license_provided"
                    has_answered_driver_license?(question)
                  else
                    nil
                  end

          build_response_for_value(response_type, response_set, question, answer, nil)
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
      ri = [
        Event.birth_code,
        Event.three_month_visit_code,
        Event.nine_month_visit_code,
        Event.eighteen_month_visit_code,
        Event.twenty_four_month_visit_code,
        Event.thirty_month_visit_code
      ].include?(event.try(:event_type_code))

      answer_for(question, mode == Instrument.cati && ri)
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
      answer_for(question, !person.primary_address.to_s.blank?)
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  PRELOAD HOME PHONE NUMBER FROM MOST RECENT INTERVIEW FOR (R_FNAME)(R_MNAME)(R_LNAME).
    #    -  IF HOME_PHONE_CONFIRM = 1, -1, OR -7, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING HOME_PHONE.
    #    -  OTHERWISE, IF HOME_PHONE_CONFIRM =2 OR -2, GO TO HOME_PHONE.
    def has_home_phone?(question)
      answer_for(question, !person.primary_home_phone.nil?)
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  PRELOAD CELL PHONE NUMBER FROM MOST RECENT INTERVIEW FOR CURRENT (R_FNAME)(R_MNAME)(R_LNAME).
    #    -  IF CELL_PHONE_CONFIRM = 1 AND CELL_PHONE_2 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER
    #       INSTRUCTIONS FOLLOWING CELL_PHONE.
    #    -  IF CELL_PHONE_CONFIRM = -1 OR -7, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_4.
    #    -  IF CELL_PHONE_CONFIRM = 2 OR -2, GO TO CELL_PHONE.
    #    -  OTHERWISE, GO TO CELL_PHONE_2.
    def has_valid_cell_phone?(question)
      answer_for(question, !person.primary_cell_phone.nil?)
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF CELL_PHONE = -1, -2, OR -7, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_4.
    #    -  IF CELL_PHONE_2 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_2.
    #    -  OTHERWISE, GO TO CELL_PHONE_2.
    def has_cell_phone_2_been_answered?(question)
      has_cell_phone_question_been_answered?(question, "2")
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF CELL_PHONE_3 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_3.
    #    -  OTHERWISE, GO TO CELL_PHONE_3.
    #
    # - IF CELL_PHONE_3 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED
    def has_cell_phone_3_been_answered?(question)
      has_cell_phone_question_been_answered?(question, "3")
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF CELL_PHONE_3 = 2, -1, OR -2, OR
    #    -  IF CELL_PHONE_4 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CELL_PHONE_4.
    #    -  OTHERWISE, GO TO CELL_PHONE_4.
    #
    # - IF CELL_PHONE_4 COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED
    def has_cell_phone_4_been_answered?(question)
      has_cell_phone_question_been_answered?(question, "4")
    end

    def has_cell_phone_question_been_answered?(question, int)
      has_answered_question?(question, "TRACING_INT.CELL_PHONE_#{int}")
    end
    private :has_cell_phone_question_been_answered?

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF EVENT_TYPE = BIRTH, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH:
    #        o  IF EMAIL COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO EMAIL_CONFIRM.
    #        o  OTHERWISE, GO TO EMAIL.
    #    -  OTHERWISE, IF EVENT_TYPE = PBS PARTICIPANT ELIGIBILITY SCREENING, 3 MONTH, 9 MONTH, 18 MONTH, 24 MONTH, 30 MONTH, OR
    #       36 MONTH, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING EMAIL_QUEST.
    def should_show_email_for_tracing?(question)
      # If event is Birth, PV1, PV2, 6M, 12M
      ri = [18, 13, 15, 24, 27].include?(event.try(:event_type_code))
      answer_for(question, ri)
    end

    def has_email?(question)
      answer_for(question, !person.primary_email.nil?)
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF EMAIL_APPT COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING EMAIL_APPT.
    #    -  OTHERWISE, GO TO EMAIL_APPT.
    def has_answered_email_appt?(question)
      has_answered_question?(question, "TRACING_INT.EMAIL_APPT")
    end

    #  PROGRAMMER INSTRUCTIONS:
    #    -  IF EMAIL_APPT = 2, -1, OR -2, OR
    #    -  IF EMAIL_QUEST COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING EMAIL_QUEST.
    #    -  OTHERWISE, GO TO EMAIL_QUEST.
    def has_answered_email_quest?(question)
      has_answered_question?(question, "TRACING_INT.EMAIL_QUEST")
    end

    # IF EVENT_TYPE = PBS PARTICIPANT ELIGIBILITY SCREENING, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH
    def should_show_contact?(question)
      ri = [34, 13, 15, 24, 27].include?(event.try(:event_type_code))
      answer_for(question, ri)
    end

    # IF EVENT_TYPE = BIRTH
    def is_event_birth?(question)
      answer_for(question, (event.try(:event_type_code).to_i == 18))
    end

    # - VALID CONTACT INFORMATION PROVIDED FOR THREE RELATIVES OR FRIENDS PREVIOUSLY FOR (R_FNAME)/(R_MNAME)/(R_LNAME)
    def are_all_contacts_provided?(question)
      ri = true
      [1,2,3].each do |i|
        ri = false if person.responses_for("TRACING_INT.CONTACT_RELATE_#{i}").blank?
      end
      answer_for(question, ri)
    end

    # IF EVENT_TYPE = PBS PARTICIPANT ELIGIBILITY SCREENING
    def is_event_pbs_participant_eligibility_screening?(question)
      answer_for(question, (event.try(:event_type_code).to_i == 34))
    end

    def has_answered_prev_city?(question)
      has_answered_question?(question, "TRACING_INT.PREV_CITY")
    end

    def has_answered_driver_license?(question)
      has_answered_question?(question, "TRACING_INT.DR_LICENSE_NUM")
    end

    def has_answered_question?(question, data_export_identifier)
      answer_for(question, !person.responses_for(data_export_identifier).blank?)
    end
    private :has_answered_question?
  end
end
