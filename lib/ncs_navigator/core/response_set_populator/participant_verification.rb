# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class ParticipantVerification < Base
    def reference_identifiers
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
        "prepopulated_resp_guard_previously_collected"
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

          answer = question.answers.first
          answer = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    prepopulated_mode_of_contact(question)
                  when "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification"
                    is_pv1_or_pv2_or_father?(question)
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
                  else
                    # TODO: handle other prepopulated fields
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
    def is_pv1_or_pv2_or_father?(question)
      event_type_code = event.try(:event_type_code).to_i
      # If event is PV1, PV2, or Father
      ri = [13, 15, 19].include?(event_type_code) ? "true" : "false"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF CHILD_QNUM = 1 AND (R_FNAME)(R_MNAME)(R_LNAME) COLLECTED FOR PARENT/CAREGIVER DURING PREVIOUS INTERVIEW AND VALID
    #   RESPONSE PROVIDED, GO TO NAME_CONFIRM.
    # - IF CHILD_QNUM > 1 AND (R_FNAME)(R_MNAME)(R_LNAME) COLLECTED FOR PREVIOUS CHILD_QNUM, GO TO PROGRAMMER INSTRUCTIONS
    #   FOLLOWING PERSON_DOB.
    # - OTHERWISE, GO TO (R_FNAME) (R_MNAME) (R_LNAME).
    def has_name_been_collected?(question)
      ri = "false"
      if person.full_name_exists?
        ri = "true"
      elsif person.only_middle_name_missing?
        ri = "true" if middle_name_response_exists?
      else
        ri = "true" if first_name_response_exists? && middle_name_response_exists? && last_name_response_exists?
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    def middle_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.R_MNAME")
    end

    def first_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.R_FNAME")
    end

    def last_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.R_LNAME")
    end

    # PROGRAMMER INSTRUCTIONS:
    #   IF EVENT_TYPE = PREGNANCY VISIT 1, OR
    # - IF EVENT_TYPE = BIRTH, AND PREGNANCY VISIT 1 NOT SET TO COMPLETE, GO TO MAIDEN_NAME.
    # - OTHERWISE, GO PROGRAMMER INSTRUCTIONS FOLLOWING (NICKNAME_1)/ (NICKNAME_2).
    def should_show_maiden_name_and_nicknames?(question)
      ri = "false"
      event_type_code = event.try(:event_type_code).to_i
      case event_type_code
      when 13
        ri = "true"
      when 18
        pv1_events = person.contact_links.select do |cl|
          cl.event.try(:event_type_code) == 13
        end.map(&:event).uniq
        ri = "true" if pv1_events.last && !pv1_events.last.try(:disposition_complete?)
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF PERSON_DOB COMPLETED DURING PREVIOUS INTERVIEW FOR CURRENT
    #   (R_FNAME)(R_MNAME)(R_LNAME) AND VALID RESPONSE PROVIDED,
    #   GO TO PROGRAMMER INSTRUCTIONS FOLLOWING PERSON_DOB.
    # - OTHERWISE, GO TO PERSON_DOB.
    def has_dob_been_previously_collected?(question)
      ri = "false"
      if person.person_dob_date
        ri = "true"
      else
        most_recent_response = person.responses_for("PARTICIPANT_VERIF.PERSON_DOB").last
        ri = "true" unless ["neg_1", "neg_2"].include?(most_recent_response.try(:answer).try(:reference_identifier).to_s)
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF (C_FNAME)(C_LNAME) COLLECTED DURING PREVIOUS INTERVIEW AND VALID RESPONSE PROVIDED, PRELOAD C_FNAME FROM PREVIOUS INTERVIEW, AND GO TO
    #   PROGRAMMER INSTRUCTIONS FOLLOWING (C_FNAME)/(C_LNAME).
    def should_show_child_name?(question)
      ri = "true"
      if participant.person.try(:first_name) && participant.person.try(:last_name)
        ri = "false"
      elsif child_first_name_response_exists? && child_last_name_response_exists?
        ri = "false"
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    def child_first_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.C_FNAME")
    end

    def child_last_name_response_exists?
      valid_response_exists?("PARTICIPANT_VERIF.C_LNAME")
    end

    # PROGRAMMER INSTRUCTIONS:
    # -   IF CHILD_DOB COLLECTED DURING PREVIOUS INTERVIEW AND VALID DATE OF BIRTH PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CHILD_DOB.
    # -   OTHERWISE, GO TO CHILD_DOB.
    def should_show_child_dob?(question)
      ri = "true"
      if participant.person.try(:person_dob_date)
        ri = "false"
      elsif valid_response_exists?("PARTICIPANT_VERIF.CHILD_DOB")
        ri = "false"
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    #  PROGRAMMER INSTRUCTIONS:
    #  - IF CHILD_SEX COLLECTED PREVIOUSLY AND VALID RESPONSE PROVIDED, GO TO PROGRAMMER INSTRUCTIONS FOLLOWING CHILD_SEX.
    #  - OTHERWISE, GO TO CHILD_SEX.
    def should_show_child_sex?(question)
      ri = "true"
      if participant.person.try(:sex_code).to_i > 0
        ri = "false"
      elsif valid_response_exists?("PARTICIPANT_VERIF.CHILD_SEX")
        ri = "false"
      end
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    # Is the participant assciated with response set the first child
    def is_first_child?(question)
      ri = participant.person.is_first_child? ? "true" : "false"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

    # PROGRAMMER INSTRUCTIONS:
    # - IF RESP_GUARD COLLECTED DURING PREVIOUS INTERVIEW WITH (R_FNAME)(R_MNAME)(R_LNAME) AND VALID RESPONSE PROVIDED, GO TO RESP_GUARD_CONF.
    # - OTHERWISE, IF RESP_GUARD NOT COLLECTED DURING PREVIOUS INTEVIEW WITH (R_FNAME)(R_MNAME)(R_LNAME) OR VALID RESPONSE NOT PROVIDED, GO RESP_GUARD.
    def resp_guard_previously_collected?(question)
      ri = valid_response_exists?("PARTICIPANT_VERIF.RESP_GUARD") ? "true" : "false"
      question.answers.select { |a| a.reference_identifier == ri }.first
    end

  end
end