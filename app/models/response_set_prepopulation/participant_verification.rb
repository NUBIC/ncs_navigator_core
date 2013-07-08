module ResponseSetPrepopulation
  class ParticipantVerification < Populator
    include OldAccessMethods

    def self.applies_to?(rs)
      rs.survey.title.include?('_ParticipantVerif_')
    end

    def self.reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification",
        "prepopulated_respondent_name_collected",
        "prepopulated_should_show_maiden_name_and_nicknames",
        "prepopulated_person_dob_previously_collected",
        "prepopulated_should_show_child_name",
        "prepopulated_should_show_child_dob",
        "prepopulated_should_show_child_sex",
        "prepopulated_first_child",
        "prepopulated_resp_guard_previously_collected",
        "prepopulated_should_show_resp_pcare",
        "prepopulated_resp_pcare_equals_one_in_previous_survey",
        "prepopulated_pcare_rel_previously_collected",
        "prepopulated_ocare_child_previously_collected_and_equals_one",
        "prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected",
        "prepopulated_ocare_rel_previously_collected",
        "prepopulated_child_time_previously_collected",
        "prepopulated_child_primary_address_variables_previously_collected",
        "prepopulated_pa_phone_previously_collected",
        "prepopulated_should_show_secondary_address_questions",
        "prepopulated_child_secondary_address_variables_previously_collected",
        "prepopulated_sa_phone_previously_collected",
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
                  when "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification"
                    is_pv1_or_pv2_or_father_or_informed_consent?(question)
                  when "prepopulated_respondent_name_collected"
                    has_name_been_collected?(question)
                  when "prepopulated_should_show_maiden_name_and_nicknames"
                    should_show_maiden_name_and_nicknames?(question)
                  when "prepopulated_person_dob_previously_collected"
                    has_dob_been_previously_collected?(question)
                  when "prepopulated_should_show_child_name"
                    should_show_child_name?(question)
                  when "prepopulated_should_show_child_dob"
                    should_show_child_dob?(question)
                  when "prepopulated_should_show_child_sex"
                    should_show_child_sex?(question)
                  when "prepopulated_first_child"
                    is_first_child?(question)
                  when "prepopulated_resp_guard_previously_collected"
                    resp_guard_previously_collected?(question)
                  when "prepopulated_should_show_resp_pcare"
                    should_show_resp_pcare?(question)
                  when "prepopulated_resp_pcare_equals_one_in_previous_survey"
                    resp_pcare_equals_one?(question)
                  when "prepopulated_pcare_rel_previously_collected"
                    pcare_rel_previously_collected?(question)
                  when "prepopulated_ocare_child_previously_collected_and_equals_one"
                    ocare_child_previously_collected_and_equals_one?(question)
                  when "prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected"
                    ocare_child_equal_one_and_other_caregiver_name_previously_collected?(question)
                  when "prepopulated_ocare_rel_previously_collected"
                    ocare_rel_previously_collected?(question)
                  when "prepopulated_child_time_previously_collected"
                    child_time_previously_collected?(question)
                  when "prepopulated_child_primary_address_variables_previously_collected"
                    child_primary_address_variables_previously_collected?(question)
                  when "prepopulated_pa_phone_previously_collected"
                    pa_phone_previously_collected?(question)
                  when "prepopulated_should_show_secondary_address_questions"
                    should_show_secondary_address_questions?(question)
                  when "prepopulated_child_secondary_address_variables_previously_collected"
                    child_secondary_address_variables_previously_collected?(question)
                  when "prepopulated_sa_phone_previously_collected"
                    sa_phone_previously_collected?(question)
                  else
                    nil
                  end

          build_response_for_value(response_type, response_set, question, answer, nil)
        end
      end
      response_set
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF EVENT_TYPE = PREGNANCY VISIT 1, PREGNANCY VISIT 2, OR FATHER, PRELOAD EVENT_TYPE, AND GO TO PV006.
    # - OTHERWISE, GO TO MULT_CHILD.
    def is_pv1_or_pv2_or_father_or_informed_consent?(question)
      event_type_code = event.try(:event_type_code).to_i
      # If event is PV1, PV2, Father, or Informed Consent
      valid_event_type_codes = [
        Event.pregnancy_visit_1_code,
        Event.pregnancy_visit_2_code,
        Event.informed_consent_code,
        Event.father_code
      ]
      answer_for(question, valid_event_type_codes.include?(event_type_code))
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF CHILD_QNUM = 1 AND (R_FNAME)(R_MNAME)(R_LNAME) COLLECTED FOR PARENT/CAREGIVER DURING PREVIOUS INTERVIEW AND VALID
    #   RESPONSE PROVIDED, GO TO NAME_CONFIRM.
    # - IF CHILD_QNUM > 1 AND (R_FNAME)(R_MNAME)(R_LNAME) COLLECTED FOR PREVIOUS CHILD_QNUM, GO TO PROGRAMMER INSTRUCTIONS
    #   FOLLOWING PERSON_DOB.
    # - OTHERWISE, GO TO (R_FNAME) (R_MNAME) (R_LNAME).
    def has_name_been_collected?(question)
      ri = false
      if person.full_name_exists?
        ri = true
      elsif person.only_middle_name_missing?
        ri = true if middle_name_response_exists?
      else
        ri = true if first_name_response_exists? && middle_name_response_exists? && last_name_response_exists?
      end
      answer_for(question, ri)
    end

    def first_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.R_FNAME")
    end

    def middle_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.R_MNAME")
    end

    def last_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.R_LNAME")
    end

    # PROGRAMMER INSTRUCTIONS:
    #   IF EVENT_TYPE = PREGNANCY VISIT 1, OR
    # - IF EVENT_TYPE = BIRTH, AND PREGNANCY VISIT 1 NOT SET TO COMPLETE, GO TO MAIDEN_NAME.
    # - OTHERWISE, GO PROGRAMMER INSTRUCTIONS FOLLOWING (NICKNAME_1)/ (NICKNAME_2).
    def should_show_maiden_name_and_nicknames?(question)
      ri = false
      event_type_code = event.try(:event_type_code).to_i
      case event_type_code
      when 13
        ri = true
      when 18
        pv1_events = person.contact_links.select do |cl|
          cl.event.try(:event_type_code) == 13
        end.map(&:event).uniq
        ri = pv1_events.last && !pv1_events.last.try(:completed?)
      end
      answer_for(question, ri)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF PERSON_DOB COMPLETED DURING PREVIOUS INTERVIEW FOR CURRENT
    #   (R_FNAME)(R_MNAME)(R_LNAME) AND VALID RESPONSE PROVIDED,
    #   GO TO PROGRAMMER INSTRUCTIONS FOLLOWING PERSON_DOB.
    # - OTHERWISE, GO TO PERSON_DOB.
    def has_dob_been_previously_collected?(question)
      ri = false
      if person.person_dob_date
        ri = true
      elsif most_recent_response = person.responses_for("PARTICIPANT_VERIF.PERSON_DOB").last
        ri = true unless %w(neg_1 neg_2).include?(most_recent_response.try(:answer).try(:reference_identifier).to_s)
      elsif person.person_dob_date.nil?
        ri = false
      end
      answer_for(question, ri)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF (C_FNAME)(C_LNAME) COLLECTED DURING PREVIOUS INTERVIEW AND VALID RESPONSE PROVIDED,
    #   PRELOAD C_FNAME FROM PREVIOUS INTERVIEW, AND GO TO
    #   PROGRAMMER INSTRUCTIONS FOLLOWING (C_FNAME)/(C_LNAME).
    def should_show_child_name?(question)
      ri = ((participant.person.try(:first_name) && participant.person.try(:last_name)) ||
            (child_first_name_response_exists? && child_last_name_response_exists?)) ? false : true
      answer_for(question, ri)
    end

    def child_first_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF_CHILD.C_FNAME")
    end

    def child_last_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF_CHILD.C_LNAME")
    end

    # PROGRAMMER INSTRUCTIONS:
    # -   IF CHILD_DOB COLLECTED DURING PREVIOUS INTERVIEW AND VALID DATE OF BIRTH PROVIDED,
    #     GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CHILD_DOB.
    # -   OTHERWISE, GO TO CHILD_DOB.
    def should_show_child_dob?(question)

      ri = true
      if participant.person.try(:person_dob_date)
        ri = "false"
      elsif valid_response_exists?("PARTICIPANT_VERIF_CHILD.CHILD_DOB")
        ri = "false"
      end
      question.answers.select { |a| a.reference_identifier == ri }.first

      ri = (participant.person.try(:person_dob_date) ||
            valid_response_exists?("PARTICIPANT_VERIF_CHILD.CHILD_DOB")) ? false : true
      answer_for(question, ri)
    end

    #  PROGRAMMER INSTRUCTIONS:
    #  - IF CHILD_SEX COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CHILD_SEX.
    #  - OTHERWISE, GO TO CHILD_SEX.
    def should_show_child_sex?(question)
      ri = (participant.person.try(:sex_code).to_i > 0 ||
            valid_response_exists?("PARTICIPANT_VERIF_CHILD.CHILD_SEX")) ? false : true
      answer_for(question, ri)
    end

    # Is the participant assciated with response set the first child
    def is_first_child?(question)
      answer_for(question, participant.person.is_first_child?)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF RESP_GUARD COLLECTED DURING PREVIOUS INTERVIEW WITH (R_FNAME)(R_MNAME)(R_LNAME)
    #   AND VALID RESPONSE PROVIDED, GO TO RESP_GUARD_CONF.
    # - OTHERWISE, IF RESP_GUARD NOT COLLECTED DURING PREVIOUS INTEVIEW WITH (R_FNAME)(R_MNAME)(R_LNAME)
    #   OR VALID RESPONSE NOT PROVIDED, GO RESP_GUARD.
    def resp_guard_previously_collected?(question)
      answer_for(question, valid_response_exists?("PARTICIPANT_VERIF.RESP_GUARD"))
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF RESP_PCARE COLLECTED DURING PREVIOUS INTERVIEW FOR CURRENT (R_FNAME)(R_MNAME)(R_LNAME)
    #   AND VALID RESPONSE PROVIDED, PRELOAD RESP_PCARE,
    #   AND GO TO PROGRAMMER INSTRUCTIONS FOLLOWING RESP_PCARE.
    # - OTHERWISE, GO TO RESP_PCARE.
    def should_show_resp_pcare?(question)
      answer_for(question, !valid_response_exists?("PARTICIPANT_VERIF.RESP_PCARE"))
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF RESP_PCARE = 1 FOR CURRENT OR PREVIOUS INTERVIEW,
    #   GO TO PROGRAMMER INSTRUCTIONS FOLLOWING (P_FNAME)(P_MNAME)(P_LNAME).
    # - OTHERWISE, GO TO (P_FNAME)(P_MNAME)(P_LNAME).
    def resp_pcare_equals_one?(question)
      previous_responses = person.responses_for("PARTICIPANT_VERIF.RESP_PCARE").all
      ri = previous_responses.detect{ |r| r.answer.try(:reference_identifier).to_i == 1 } ? true : false
      answer_for(question, ri)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF PCARE_REL COLLECTED DURING PREVIOUS INTERVIEW AND VALID RESPONSE PROVIDED,
    #   GO TO PROGRAMMER INSTRUCTIONS FOLLOWING OCARE_CHILD.
    # - OTHERWISE, GO TO PCARE_REL.
    def pcare_rel_previously_collected?(question)
      answer_for(question, valid_response_exists?("PARTICIPANT_VERIF.PCARE_REL"))
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF OCARE_CHILD COLLECTED DURING PREVIOUS INTERVIEW AND OCARE_CHILD = 1, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING OCARE_CHILD.
    #  OTHERWISE, GO TO OCARE_CHILD.
    def ocare_child_previously_collected_and_equals_one?(question)
      answer_for(question, ocare_child_response_is_one?)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF RESP_PCARE = 1, DISPLAY “yourself”.
    # - OTHERWISE, DISPLAY “the primary caregiver”.
    # - IF OCARE_CHILD = 1 FOR PREVIOUS INTERVIEW AND (O_FNAME)(O_MNAME))(O_LNAME) COLLECTED DURING PREVIOUS INTERVIEW
    #   AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING (O_FNAME)(O_MNAME)(O_LNAME).
    # - IF OCARE_CHILD = 2, -1, OR -2 FOR CURRENT INTERVIEW, GO TO PV051.
    # - OTHERWISE, GO TO (O_FNAME)/(O_MNAME)/(O_LNAME).
    def ocare_child_equal_one_and_other_caregiver_name_previously_collected?(question)
      ri = ocare_child_response_is_one? &&
           o_fname_response_exists? && o_mname_response_exists? && o_lname_response_exists?
      answer_for(question, ri)
    end

    def ocare_child_response_is_one?
      previous_responses = person.responses_for("PARTICIPANT_VERIF.OCARE_CHILD").all
      previous_responses.detect{ |r| r.answer.try(:reference_identifier).to_i == 1 } ? true : false
    end

    def o_fname_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.O_FNAME")
    end

    def o_mname_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.O_MNAME")
    end

    def o_lname_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.O_LNAME")
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF OCARE_REL COLLECTED DURING PREVIOUS INTERVIEW AND VALID RESPONSE PROVIDED, GO TO PV051.
    # - OTHERWISE, GO TO OCARE_REL.
    def ocare_rel_previously_collected?(question)
      answer_for(question, valid_response_exists?("PARTICIPANT_VERIF.OCARE_REL"))
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF CHILD_TIME COLLECTED DURING PREVIOUS INTERVIEW AND VALID RESPONSE PROVIDED, PRELOAD CHILD_TIME,
    #   AND GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CHILD_TIME.
    # - OTHERWISE GO TO CHILD_TIME.
    def child_time_previously_collected?(question)
      answer_for(question, valid_response_exists?("PARTICIPANT_VERIF.CHILD_TIME"))
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF CHILD_TIME COLLECTED PREVIOUSLY AND CHILD_TIME = 1, -1, OR -2 FOR MOST RECENT INTERVIEW, DISPLAY FIRST OCCURRENCE OF “still.”
    # - IF CHILD_TIME COLLECTED PREVIOUSLY AND CHILD_TIME = 2 FOR MOST RECENT INTERVIEW, DISPLAY SECOND OCCURRENCE OF “still.”
    # - IF CHILD PRIMARY ADDRESS VARIABLES COLLECTED PREVIOUSLY FOR C_FNAME AND VALID RESPONSE PROVIDED, GO TO CHILD_PRIMARY_ADDRESS_CONFIRM_NEW.
    # - OTHERWISE, IF CHILD PRIMARY ADDRESS VARIABLES NOT COLLECTED PREVIOUSLY FOR C_FNAME OR VALID RESPONSE NOT PROVIDED, GO TO CHILD PRIMARY ADDRESS VARIABLES.
    def child_primary_address_variables_previously_collected?(question)
      ri = !participant.person.primary_address.to_s.blank? || valid_response_exists?("PARTICIPANT_VERIF.C_ADDRESS_1")
      answer_for(question, ri)
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF PA_PHONE COLLECTED DURING PREVIOUS INTERVIEW AND VALID PHONE NUMBER PROVIDED,
    #   GO TO PROGRAMMER INSTRUCTIONS FOLLOWING PA_PHONE.
    # - OTHERWISE, GO PA_PHONE.
    def pa_phone_previously_collected?(question)
      answer_for(question, valid_response_exists?("PARTICIPANT_VERIF.PA_PHONE"))
    end

    # PROGRAMMER INSTRUCTIONS:
    #   - IF CHILD_TIME = 1, -1, OR -2 AND:
    #     - CHILD_NUM = 1, OR
    #     - IF CHILD_NUM > 1, AND CHILD_QNUM = CHILD_NUM
    #   - GO TO TIME_STAMP_PV_ET.
    #     - IF CHILD_NUM > 1, AND CHILD_QNUM < CHILD_NUM, GO TO SAME_CONTACT_MULT_CHILD.
    #   - OTHERWISE, GO TO PV059.
    def should_show_secondary_address_questions?(question)
      # TODO: determine what this needs to return
    end

    # PROGRAMMER INSTRUCTIONS:
    #   - IF CHILD SECONDARY ADDRESS VARIABLES = -7, AND
    #     - IF CHILD_TIME = 1, -1, OR -2, AND
    #     - IF CHILD_NUM = 1, OR
    #     - IF CHILD_NUM > 1, AND CHILD_QNUM = CHILD_NUM
    #   - GO TO TIME_STAMP_PV_ET.
    #     - OTHERWISE, IF CHILD_NUM > 1, AND CHILD_QNUM < CHILD_NUM, GO TO SAME_CONTACT_MULT_CHILD.
    #   - OTHERWISE, IF CHILD SECONDARY ADDRESS VARIABLES FOR CURRENT INTERVIEW ≠ -7, AND
    #     - IF SA_PHONE COLLECTED DURING PREVIOUS INTERVIEW AND VALID PHONE NUMBER PROVIDED, GO TO SA_PHONE_CONFIRM.
    #     - IF SA_PHONE NOT COLLECTED DURING PREVIOUS INTERVIEW OR VALID PHONE NUMBER NOT PROVIDED, GO TO SA_PHONE.
    def child_secondary_address_variables_previously_collected?(question)
      answer_for(question, valid_response_exists?("PARTICIPANT_VERIF.S_ADDRESS_1"))
    end

    # PROGRAMMER INSTRUCTIONS:
    #   - PRELOAD SECONDARY PHONE NUMBER FROM MOST RECENT INTERVIEW.
    #   - IF SA_PHONE_CONFIRM =1 AND
    #     - IF CHILD_NUM = 1, GO TO TIME_STAMP_PV_ET.
    #     - IF CHILD_QNUM > 1, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING SA_PHONE.
    #   - OTHERWISE, GO TO SA_PHONE.
    def sa_phone_previously_collected?(question)
      answer_for(question, valid_response_exists?("PARTICIPANT_VERIF.SA_PHONE"))
    end
  end
end
