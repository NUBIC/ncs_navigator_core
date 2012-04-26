# encoding: utf-8

survey "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0" do
  section "Interviewer-completed questions", :reference_identifier=>"LIPregNotPreg_INT" do
    label "[Completion of low-intensity consent must be obtained first; assume completion of low-intensity cati
    pregnancy screener or return of PPG self-administered questionnaire]"

    q_time_stamp_1 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_1"
    a :datetime

    q_type_of_call "What type of call is this?",
    :pick => :one
    a_inbound "Inbound call to study center from consented participant."
    a_outbound "Outbound call from study center to consented participant."

    label "Thank you for calling the National Children’s Study"
    dependency :rule => "A"
    condition_A :q_type_of_call, "==", :a_inbound

    # TODO
    #     PROGRAMMER INSTRUCTION:
    #     •	PRELOAD LOCAL STUDY CENTER NAME AND NAME OF CONSENTED PARTICIPANT.
    q_FEMALE_1 "Hello, my name is [DATA COLLECTOR’S NAME]. I’m calling from the {LOCAL STUDY CENTER NAME}.
    I’d like to speak with {NAME OF CONSENTED WOMAN}. Is she available?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.FEMALE_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A"
    condition_A :q_type_of_call, "==", :a_outbound

    q_BEST_TTC_1 "What would be a good time to reach her?",
    :help_text => "Enter in hour and minute values",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.BEST_TTC_1"
    a_time "Time HH:MM", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_FEMALE_1, "!=", :a_1

    q_BEST_TTC_2 "Select AM or PM",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.BEST_TTC_2"
    a_am "AM"
    a_pm "PM"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_FEMALE_1, "!=", :a_1

    q_BEST_TTC_3 "Additional info",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.BEST_TTC_3"
    a_am "After time reported"
    a_pm "Before time reported"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_FEMALE_1, "!=", :a_1

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • PRELOAD NAME OF CONSENTED PARTICIPANT
    q_PHONE "Is this a good phone number to reach {NAME}?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.PHONE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_FEMALE_1, "!=", :a_1

    q_PHONE_NBR "Would you please tell me a telephone number where she can be reached? ",
    :help_text => "Enter in hour and minute values",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.PHONE_NBR"
    a_phone "Phone number", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    a_neg_7 "Participant has no telephone/not applicable"
    dependency :rule => "A"
    condition_A :q_PHONE, "!=", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • PRELOAD LOCAL SC TOLL-FREE NUMBER.
    label_END_UNAVAIL "Thank you again for speaking with me today. Please ask her to call us at {LOCAL SC TOLL-FREE NUMBER}.",
    :help_text => "End interview and disposition case as appropriate."
    dependency :rule => "A"
    condition_A :q_FEMALE_1, "!=", :a_1

    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_2"
    a :datetime
    dependency :rule => "A or B"
    condition_A :q_FEMALE_1, "==", :a_1
    condition_B :q_type_of_call, "==", :a_inbound
  end
  section "Pregnancy screener", :reference_identifier=>"LIPregNotPreg_INT" do
    q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_10"
    a :datetime
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    label "We would now like to take a few minutes to ask some questions about your experience in the study."
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    label "How important was each of the following in your decision to take part in the National Children’s Study?"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_LEARN "[How important was...] Learning more about my health or the health of my child?",
    :help_text => "Re-read introductory statement as needed.",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.LEARN"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_HELP "[How important was...] Feeling as if I can help children now and in the future?",
    :help_text => "Re-read introductory statement as needed.",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.HELP"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_INCENT "[How important was...] Receiving money or gifts for taking part in the study?",
    :help_text => "Re-read introductory statement as needed.",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.INCENT"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_RESEARCH "[How important was...] Helping doctors and researchers learn more about children and their health?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.RESEARCH"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_ENVIR "[How important was...] Helping researchers learn how the environment may affect children’s health?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.ENVIR"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_COMMUNITY "[How important was...] Feeling part of my community?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.COMMUNITY"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_KNOW_OTHERS "[How important was...] Knowing other women in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.KNOW_OTHERS"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_FAMILY "[How important was...] Having family members or friends support my choice to take part in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.FAMILY"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_DOCTOR "[How important was...] Having my doctor or health care provider support my choice to take part in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.DOCTOR"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    label_EV004 "How negative or positive do each of the following people feel about you taking part in the National Children’s Study?"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_OPIN_SPOUSE "Your spouse or partner",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_SPOUSE"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_neg_7 "Not Applicable"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_OPIN_FAMILY "Other family members",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_FAMILY"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_neg_7 "Not Applicable"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_OPIN_FRIEND "Your friends",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_FRIEND"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_neg_7 "Not Applicable"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_OPIN_DR "Your doctor or health care provider",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_DR"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_neg_7 "Not Applicable"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_EXPERIENCE "In general, has your experience with the National Children’s Study been",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.EXPERIENCE"
    a_1 "Mostly negative"
    a_2 "Somewhat negative"
    a_3 "Neither negative nor positive"
    a_4 "Somewhat positive"
    a_5 "Mostly positive"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_IMPROVE "In your opinion, how much do you think the National Children’s Study will help improve the health
    of children now and in the future?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.IMPROVE"
    a_1 "Not at all"
    a_2 "A little"
    a_3 "Some"
    a_4 "A lot"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_INT_LENGTH "Did you think the interview was",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.INT_LENGTH"
    a_1 "Too short"
    a_2 "Too long, or"
    a_3 "Just about right?"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_INT_STRESS "Do you think the interview was",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.INT_STRESS"
    a_1 "Not at all stressful"
    a_2 "A little stressful"
    a_3 "Somewhat stressful, or"
    a_4 "Very stressful?"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5

    q_INT_REPEAT "If you were asked, would you participate in an interview like this again?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_LI_2.INT_REPEAT"
    a_1 "Yes"
    a_2 "No"
    dependency :rule => "A or B"
    condition_A :q_PREGNANT, "!=", :a_4
    condition_B :q_PREGNANT, "!=", :a_5
  end
  section "Conclusion", :reference_identifier=>"PREG_VISIT_LI_2" do
    q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_11"
    a :datetime

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • PRELOAD LOCAL AGE OF MAJORITY AND STUDY CENTER TOLL-FREE NUMBER.

    label_END1 "Thank you for participating in the National Children’s Study and for taking the time to answer our
    questions. We will contact you in about 6 months to ask you some more questions. If there are any other women
    in your household age {LOCAL AGE OF MAJORITY} - 49, [please have her] contact us at {STUDY CENTER TOLL-FREE NUMBER}."
    dependency :rule => "A"
    condition_A :q_PREGNANT, "!=", :a_4

    label_END2 "Thank you for taking the time to answer these questions. Based on what you’ve told me, you are not
    eligible to take part in the study."
    dependency :rule => "A"
    condition_A :q_PREGNANT, "!=", :a_4

    q_TIME_STAMP_12 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_12"
    a :datetime
  end
end