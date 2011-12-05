survey "INS_QUE_LIHIConversion_INT_HILI_P2_V1.0" do
  # TODO
  #   Low-Intensity Invitation to High-Intensity Conversion Script (HI, LI)
  #
  #   PROGRAMMER INSTRUCTIONS:
  #   • IF PARTICIPANT IS BEING CALLED, GO TO THE OUTBOUND CALLING SCRIPT OUT_ANSWER.
  #
  #   •	IF PARTICIPANT IS CALLING IN RESPONSE TO THE “NCS MAILING”, GO TO THE INBOUND CALLING SCRIPT IN_INTRO.
  section "Outbound calling script", :reference_identifier=>"LIHIConversion_INT" do
    q_OUT_ANSWER "Did someone answer the phone?",
    :help_text => "Code case status and follow up as appropriate",
    :pick => :one,
    :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_ANSWER"
    a_1 "Yes"
    a_2 "No (Code case status. Try calling at another time.)"
    a_3 "Answering machine"
    a_neg_5 "Other/specify"

    q_OUT_ANSWER_OTH "Other",
    :help_text => "Code case status and follow up as appropriate.",
    :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_ANSWER_OTH"
    a "Specify", :string
    dependency :rule => "A"
    condition_A :q_OUT_ANSWER, "==", :a_neg_5

    # TODO
    #   Preload [PARTICIPANT NAME]
    q_OUT_SPEAK "Hello, may I speak with [PARTICIPANT NAME]?",
    :pick => :one,
    :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_SPEAK"
    a_1 "Person available"
    a_2 "Person not available"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_OUT_ANSWER, "==", :a_1

    q_OUT_AVAIL "My name is [INTERVIEWER’S NAME] and I am calling from [LOCAL STUDY AFFILIATE] about the National Children’s Study.
    I’d like to thank you again for taking part in the National Children’s Study and for recently answering some questions.
    I’m calling today to tell you that we are starting the next part of the Study. Do you have a few minutes to talk with me?",
    :pick => :one,
    :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_AVAIL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_OUT_SPEAK, "==", :a_1

    group "Introduction" do
      dependency :rule => "A"
      condition_A :q_OUT_AVAIL, "==", :a_1

      label_OUT_INTRO "The next part of the Study includes visits by our staff with you, if you are pregnant or trying to get pregnant.
      Staff would come to your home a few times a year, and ask you more detailed questions about your health,
      [IF PREGNANT: your pregnancy], home, work, and neighborhood. If you do not want to meet at your home, you could come
      to our office, or we could meet with you at another place that you choose. During the first visit, we would give you
      some more details about this part of the Study and see if you are interested and willing to take part in the visits.
      At future visits, we may ask you to consider giving us a blood sample or other samples, such as water or soil from your home.
      The visits are important to the Study because the information will help us learn about how the environment influences
      children’s health, development, and quality of life.

      Our staff will visit with you at a time that is good for you and your household. The first visit should take about an hour.
      Your taking part in the visits will be very helpful to the Study, but it is, of course, your choice. Even if you choose
      not to be in this part of the Study, you can continue being in the Study just as you have been. We really appreciate you
      taking part in the Study.

      If you are interested in considering this part of the Study, I would like to schedule a visit with you for one of our
      staff to talk about the Study, to get your permission, in writing, for you to take part in the visits, and to have you
      answer some more detailed questions."


      q_OUT_VISIT "Would you like to schedule a visit?",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_VISIT"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      # TODO
      # What is this question below? Is there dependency?
      q_OUT_VISIT_UCLA "[For UCLA: Would you like to schedule a visit?]",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_VISIT_UCLA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    end

    label_OUT_YES "Great. We really appreciate that you are willing to take the time to learn more about this part
    of the Study. Before we schedule the visit, I just have a few questions.",
    :help_text => "[For UCLA: We will have a staff member call you back to schedule the visit]"
    dependency :rule => "A or B"
    condition_A :q_OUT_VISIT, "==", :a_1
    condition_B :q_OUT_VISIT_UCLA, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • CHECK PARTICIPANT’S PPG STATUS.
    # • GO TO PPG SCRIPT PPG_CONFIRM.

    label_OUT_NO "That’s fine. I understand. As I said before, we so appreciate you taking part in the Study. Even
    if you choose not to take part in the visits, you can, of course, continue being in the Study just like you have been.
    We will contact you in a few months and ask you some questions just like those that you answered before. Thank you
    again. Goodbye.",
    :help_text => "End call and code case status"
    dependency :rule => "A or B"
    condition_A :q_OUT_VISIT, "!=", :a_1
    condition_B :q_OUT_VISIT_UCLA, "!=", :a_1

    q_OUT_TALK "Is there a better time when we could talk?",
    :pick => :one,
    :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_TALK"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_OUT_AVAIL, "!=", :a_1

    group "Call setup" do
      dependency :rule => "A"
      condition_A :q_OUT_TALK, "==", :a_1

      q_R_BEST_TTC_1 "What would be a better time for you?",
      :help_text => "Enter in hour and minute values",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.R_BEST_TTC_1"
      a_time "Time", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # DAY_WEEK_2 doesn't present in MDES2 spreadsheet
      q_DAY_WEEK_2 "What would be a good day to reach her?",
      :help_text => "Enter in day(s) of week",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.DAY_WEEK_2"
      a_days_of_week "Day(s) of the week", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_R_BEST_TTC_2 "Select AM or PM",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.R_BEST_TTC_2"
      a_am "AM"
      a_pm "PM"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_R_BEST_TTC_3 "Additional info",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.R_BEST_TTC_3"
      a_am "After time reported"
      a_pm "Before time reported"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_R_BEST_TTC4 "Thank you. I will try again later.",
      :help_text => "End call and code case status."
    end

    label_OUT_REF "That’s fine. I understand. As I said before, we so appreciate you taking part in the Study. Even if you
    choose not to take part in the visits, you can, of course, continue being in the Study just like you have been. We will
    contact you in a few months and ask you some questions just like those that you answered before. Thank you again. Goodbye.",
    :help_text => "Use refusal conversion techniques if participant has particular concerns. End call and code case status."
    dependency :rule => "A"
    condition_A :q_OUT_TALK, "!=", :a_1

    # TODO
    # Prepopulate [PARTICIPANT PHONE NUMBER]
    q_OUT_UNAVAIL "Is [PARTICIPANT PHONE NUMBER] the best number to reach her?",
    :pick => :one,
    :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_UNAVAIL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_OUT_SPEAK, "!=", :a_1

    group "Call information" do
      dependency :rule => "A"
      condition_A :q_OUT_UNAVAIL, "==", :a_1

      q_BEST_TTC_1 "What would be a good time to reach her?",
      :help_text => "Enter in hour and minute values",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.BEST_TTC_1"
      a_time "Time", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # DAY_WEEK_1 doesn't present in MDES2 spreadsheet
            # :data_export_identifier=>"LOW_HIGH_SCRIPT.DAY_WEEK_1"
      q_DAY_WEEK_1 "What would be a good day to reach her?",
      :help_text => "Enter in day(s) of week",
      :pick => :one
      a_days_of_week "Day(s) of the week", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BEST_TTC_2 "Select AM or PM",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.BEST_TTC_2"
      a_am "AM"
      a_pm "PM"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BEST_TTC_3 "Additional info",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.BEST_TTC_3"
      a_am "After time reported"
      a_pm "Before time reported"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label_BEST_TCC_4 "Thank you. I will try again later.",
      :help_text => "End call and code case status"
    end

    group "Phone number information" do
      dependency :rule => "A"
      condition_A :q_OUT_UNAVAIL, "!=", :a_1

      q_OUT_NEXTPH "What would be the best number to reach her?",
      :help_text => "Record best number to reach participant.",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_NEXTPH"
      a_phone "Phone number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label_OUT_NEXTPH "Thank you. I will try that number.",
      :help_text => "End call and code case status."
    end

    label_OUT_ANSMC "Hello, this message is for [PARTICIPANT’S NAME]. This is [INTERVIEWER’S NAME] calling
    from [LOCAL STUDY AFFILIATE] about the National Children’s Study. We will call back again within the next day or so,
    or you may call us, toll-free, at [TOLL-FREE NUMBER]. Thank you.",
    :help_text => "Code case status. Try calling at another time."
    dependency :rule => "A"
    condition_A :q_OUT_ANSWER, "==", :a_3
  end
  section "Inbound calling script", :reference_identifier=>"LIHIConversion_INT" do
    label_IN_INTRO "Thank you for calling us. I’d like to take a couple of minutes to tell you about the next part of the Study.
    The next part of the Study includes visits by our staff with you, if you are pregnant or trying to get pregnant.
    Staff would come to your home a few times a year, and ask you more detailed questions about your health,
    [IF PREGNANT: your pregnancy], home, work, and neighborhood. If you do not want to meet at your home, you could come
    to our office, or we could meet with you at another place that you choose. During the first visit, we would give you
    some more details about this part of the Study and see if you are interested and willing to take part in the visits.
    At future visits, we may ask you to consider giving us a blood sample or other samples, such as water or soil, from
    your home. The visits are important to the Study because the information will help us learn about how the environment
    influences children’s health, development, and quality of life.

    Our staff will visit with you at a time that is good for you and your household. The first visit should take about one hour.
    Your taking part in the visits will be very helpful to the Study, but it is, of course, your choice. Even if you choose not
    to take part in the visits, you can continue being in the Study just like you have been. We really appreciate you taking part
    in the Study.

    If you are interested in the visit part of the Study, I would like to schedule a visit with you for one of our staff to talk
    about the Study, to get your permission, in writing, for you to take part in the visits, and to have you answer some more
    detailed questions."

    q_IN_VISIT "Would you like to schedule a visit now?",
    :pick => :one,
    :data_export_identifier=>"LOW_HIGH_SCRIPT.IN_VISIT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    # TODO
    # What is this question below? Is there dependency?
    q_IN_VISIT_UCLA "[For UCLA: Would you like to schedule a visit?]",
    :pick => :one,
    :data_export_identifier=>"LOW_HIGH_SCRIPT.IN_VISIT_UCLA"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    label_IN_YES "Great. We really appreciate that you are willing to take the time to learn more about the visit part of the Study.
    Before we schedule the visit, I just have a few questions. [For UCLA: We will have a staff member call you back
    to schedule the visit].",
    :help_text => "If necessary, ask the participant for her name, address, and reference number (found on the WOO letter)
    in order to locate information on the participant’s PPG status."
    dependency :rule => "A or B"
    condition_A :q_IN_VISIT, "==", :a_1
    condition_B :q_IN_VISIT_UCLA, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • ALLOW CATI TO IDENTIFY PARTICIPANT SO MOST RECENT OF PPG_FIRST OR PPG_STATUS CAN BE DISPLAYED.
    # • GO TO PPG SCRIPT/ PPG_CONFIRM.

    label_OUT_NO "That’s fine. I understand. As I said before, we so appreciate you taking part in the Study. Even if you choose
    not to take part in the visits, you can continue being in the Study just like you have been. We will contact you in a few
    months and ask you some questions just like those that you answered before. Thank you again. Goodbye.",
    :help_text => "End call and code case status"
    dependency :rule => "A or B"
    condition_A :q_IN_VISIT, "!=", :a_1
    condition_B :q_IN_VISIT_UCLA, "!=", :a_1
  end
  section "Pregnancy probability group (PPG) script", :reference_identifier=>"LIHIConversion_INT" do
    group "Pregnancy questions" do
      dependency :rule => "A or B or C or D"
      condition_A :q_IN_VISIT, "==", :a_1
      condition_B :q_IN_VISIT_UCLA, "==", :a_1
      condition_C :q_OUT_VISIT, "==", :a_1
      condition_D :q_OUT_VISIT_UCLA, "==", :a_1

      q_PPG_CONFIRM "Are you pregnant now?",
      :help_text => "If participant is known to be pregnant, add [Just to confirm,]",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.PPG_CONFIRM"
      a_1 "Yes"
      a_2 "No, no additional information"
      a_3 "No, recently gave birth"
      a_4 "No, recent pregnancy loss"
      a_5 "No, recent pregnancy loss and currently trying to become pregnant"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      # TODO
      # MOST RECENT OF EITHER (PPG FIRST ) FROM PREGNANCY SCREENER INSTRUMENT (HI,LI) V1.1
      # OR (PPG_STATUS) FROM PREGNANCY PROBABILITY GROUP FOLLOW-UP INSTRUMENT V 1.1
      # Prepopulate the ppg_status
      q_prepopulated_ppg_status "PPG Status"
      a_ppg_status "PPG status", :integer
    end

    # TODO - verify - not sure if it's part of PPG002
    # Nataliya's comment - not sure if that is correct dependnency
    group "Appt 1" do
      dependency :rule => "(A and B) or (C and D)"
      condition_A :q_PPG_CONFIRM, "==", :a_1
      condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}
      condition_C :q_PPG_CONFIRM, "==", :a_2
      condition_D :q_prepopulated_ppg_status, "==", {:integer_value => "2"}

      label_PPG002 "Good. I’d like to go ahead and schedule a visit with you to talk about the next part of the Study."

      # TODO - verify - not sure if it's part of PPG002
      # Nataliya's comment - not sure if that is correct dependnency
      q_PPG002 "When would be a good time for you?",
      :help_text => "Set an appointment"
      a :text

      # TODO
      # PPG003 NOT REFERED ANYWHERE IN THE DOCUMENT. PUTTING THE SAME DEPENDENCIES AS ABOVE -- HAVE TO VERIFY!!!
      # according to ncs helpdesk - ppg003 should follow ppg002
      label_PPG003 "Thank you again for taking part in the Study. A member of our staff will be visiting with you on
      [SCHEDULED APPOINTMENT DATE AND TIME] at [HOME, OUR OFFICE, OTHER PLACE]. If you have any questions at all, please
      call our toll-free number, [TOLL-FREE NUMBER]. Thank you again. Goodbye.",
      :help_text => "End call. Code case status."
    end

    group "Folloup 1" do
      dependency :rule => "A and (B or C)"
      condition_A :q_PPG_CONFIRM, "==", :a_4
      condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}
      condition_C :q_prepopulated_ppg_status, "==", {:integer_value => "2"}

      q_FOLLOWUP_1 "Thank you for taking the time to answer these questions today. However, at this time, we are only
      making visits to women who are pregnant or who are trying to get pregnant. Based on what I thought I heard you say,
      I understand that you are not pregnant or trying to get pregnant at this time. Is this correct?",
      :help_text => "You may say [I’m sorry to hear you’ve lost your baby – I know this can be a hard time.]
      if social cues indicate it is appropriate.",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.FOLLOWUP_1"
      a_1 "Yes (not pregnant, not trying)"
      a_2 "No (SP is trying)"
      a_3 "No (SP is pregnant)"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      label_PREGTRY_1 "Thank you. Because you are not pregnant or trying to get pregnant, we won’t ask you to
      take part in the visit part of the Study at this time. But, we will contact you again in a few months to ask you some
      questions just like those that you answered before. Thank you again. Goodbye.",
      :help_text => "End call and code case status. Send case back to PPG Follow up for 6 months;"
      dependency :rule => "A or B or C "
      condition_A :q_FOLLOWUP_1, "==", :a_1
      condition_B :q_FOLLOWUP_1, "==", :a_neg_1
      condition_C :q_FOLLOWUP_1, "==", :a_neg_2
    end

    group "Folloup 2" do
      dependency :rule => "A and (B or C)"
      condition_A :q_PPG_CONFIRM, "==", :a_5
      condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}
      condition_C :q_prepopulated_ppg_status, "==", {:integer_value => "2"}

      q_FOLLOWUP_2 "Because you are trying to get pregnant, I’d like to go ahead and schedule a visit to talk with you
      about the next part of the Study. When would be a good time for you?",
      :help_text => "You may say [I’m sorry to hear you’ve lost your baby – I know this can be a hard time.] if social cues indicate it is appropriate.
      Set an appointment."

      label_PPG010 "Thank you again for taking part in the Study. A member of our staff will be visiting with you on
      [SCHEDULED APPOINTMENT DATE AND TIME] at [HOME, OUR OFFICE, OTHER PLACE]. If you have any questions at all, please
      call our toll-free number, [TOLL-FREE NUMBER]. Thank you again. Goodbye.",
      :help_text => "End call. Code case status."
    end

    group "Folloup 3" do
      dependency :rule => "A and B"
      condition_A :q_PPG_CONFIRM, "==", :a_2
      condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}

      q_FOLLOWUP_3 "Thank you for taking the time to answer these questions today. However, at this time, we
      are only making visits to women who are pregnant or who are trying to get pregnant. Based on what I think
      I heard you say, I understand that you are not pregnant or trying to get pregnant at this time. Is this correct?",
      :pick => :one,
      :data_export_identifier=>"LOW_HIGH_SCRIPT.FOLLOWUP_3"
      a_1 "Yes (not pregnant, not trying)"
      a_2 "No (SP is trying)"
      a_3 "No (SP is pregnant)"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      label_PREGTRY_2 "Thank you. Because you are not pregnant or trying to get pregnant at this time, we won’t ask
      you to take part in the visit part of the Study at this time. But, we will contact you again in a few months to
      ask you some questions just like those that you answered before. Thank you again. Goodbye.",
      :help_text => "End call and code case status."
      dependency :rule => "A or B or C "
      condition_A :q_FOLLOWUP_3, "==", :a_1
      condition_B :q_FOLLOWUP_3, "==", :a_neg_1
      condition_C :q_FOLLOWUP_3, "==", :a_neg_2
    end

    q_FOLLOWUP_4 "That’s fine. I understand. As I said before, we so appreciate you taking part in the Study. We will
    contact you in a few months and ask you some questions just like those that you answered before. Thank you again. Goodbye.",
    :help_text => "Use refusal conversion techniques if participant has particular concerns"
    dependency :rule => "A or B"
    condition_A :q_PPG_CONFIRM, "==", :a_neg_1
    condition_B :q_PPG_CONFIRM, "==", :a_neg_2

    # TODO
    # HAVE TO VERIFY DEPENDENCIES -- WHAT DOES THIS FIELD REFER TO???
    group "Appt 2" do
      dependency :rule => "A or B or (C and D) or E"
      condition_A :q_FOLLOWUP_1, "==", :a_3
      condition_B :q_FOLLOWUP_3, "==", :a_3
      condition_C :q_PPG_CONFIRM, "==", :a_1
      condition_D :q_prepopulated_ppg_status, "==", {:integer_value => "2"}
      condition_E :q_PPG_CONFIRM, "==", :a_3

      label_PPG005 "[Congratulations]. I’d like to go ahead and schedule a visit with you to talk about the next part of the Study."

      q_PPG005 "When would be a good time for you?",
      :help_text => "Set an appointment"
      a :text

      label_PPG006 "Thank you again for taking part in the Study. A member of our staff will be visiting with you
      on [SCHEDULED APPOINTMENT DATE AND TIME] at [HOME, OUR OFFICE, OTHER PLACE]. If you have any questions at all, please call
      our toll-free number, [TOLL-FREE NUMBER]. Thank you again. Goodbye.",
      :help_text => "End call. Code case status."

    end

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • IF NO CHANGE IN (PPG STATUS), DISPLAY SAME STATUS AS PREVIOUSLY:
    # Nataliya's comment -- the label_PPG001 should change PPG Status
    label_PPG001_STATUS_1 "PPG Status = 1"
    dependency :rule => "(A and (B or C)) or D or E"
    condition_A :q_PPG_CONFIRM, "==", :a_1
    condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}
    condition_C :q_prepopulated_ppg_status, "==", {:integer_value => "2"}
    condition_D :q_FOLLOWUP_3, "==", :a_3
    condition_E :q_FOLLOWUP_1, "==", :a_3

    label_PPG001_STATUS_2 "PPG Status = 2"
    dependency :rule => "(A and (B or C)) or (F and C) or G or H"
    condition_A :q_PPG_CONFIRM, "==", :a_5
    condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}
    condition_C :q_prepopulated_ppg_status, "==", {:integer_value => "2"}
    condition_F :q_PPG_CONFIRM, "==", :a_2
    condition_G :q_FOLLOWUP_3, "==", :a_2
    condition_H :q_FOLLOWUP_1, "==", :a_2

    label_PPG_001_STATUS_3 "PPG Status = 3"
    dependency :rule => "A or B or C or D or E or F or G or H or I"
    condition_A :q_FOLLOWUP_1, "==", :a_1
    condition_B :q_FOLLOWUP_1, "==", :a_neg_1
    condition_C :q_FOLLOWUP_1, "==", :a_neg_2
    condition_D :q_FOLLOWUP_2, "==", :a_1
    condition_E :q_FOLLOWUP_2, "==", :a_neg_1
    condition_F :q_FOLLOWUP_2, "==", :a_neg_2
    condition_G :q_FOLLOWUP_3, "==", :a_1
    condition_H :q_FOLLOWUP_3, "==", :a_neg_1
    condition_I :q_FOLLOWUP_3, "==", :a_neg_2

    label_PPG001_STATUS_4 "PPG Status = 4"
    dependency :rule => "A and (B or C)"
    condition_A :q_PPG_CONFIRM, "==", :a_3
    condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}
    condition_C :q_prepopulated_ppg_status, "==", {:integer_value => "2"}
  end
end

