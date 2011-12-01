survey "INS_QUE_PPGFollUp_INT_EHPBHILI_P2_V1.2" do
  section "CATI", :reference_identifier=>"PPGFollUp_INT" do
    q_TIME_STAMP_1 "Insert date/time stamp",
    :data_export_identifier=>"PPG_CATI.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Hello. My name is [INTERVIEWER FIRST AND LAST NAME] from the National Children’s Study. It’s been a few months since we
    have spoken with you. We’re following up with women of childbearing age and our first questions are always about pregnancy. We first
    want to know..."
  end
  section "Pregnancy screener", :reference_identifier=>"PPGFollUp_INT" do
    q_PREGNANT "Are you pregnant now?",
    :help_text => "Enter \"Yes\" even if respondent is unsure that she is pregnant",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.PREGNANT"
    a_1 "Yes"
    a_2 "No, no additional information provided"
    a_3 "No, recently lost pregnancy (miscarriage/abortion) - (if volunteered by participant)"
    a_4 "No, recently gave birth  - (if volunteered by participant)"
    a_5 "No, unable to have children  (hysterectomy, tubal ligation)  - (if volunteered by participant)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_TRYING "Are you currently trying to become pregnant?",
    :help_text => "Do not define \"trying to become pregnant\"",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.TRYING"
    a_1 "Yes"
    a_2 "No"
    a_3 "Recently lost pregnancy (miscarriage or abortion)"
    a_4 "Recently gave birth"
    a_5 "Unable to have children (e.g., hysterectomy, tubal ligation)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A or B or C"
    condition_A :q_PREGNANT, "==", :a_2
    condition_B :q_PREGNANT, "==", :a_neg_1
    condition_C :q_PREGNANT, "==", :a_neg_2

    q_PPG_DUE_DATE_1 "Congratulations. When is your baby due?",
    :help_text => "Verify if date is more than nine months after current date, or if date is more than 1 month before current date",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.PPG_DUE_DATE_1"
    a_date "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PREGNANT, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • SOFT EDIT:
    # o IF DATE IS MORE THAN NINE MONTHS AFTER CURRENT DATE, DISPLAY, “You have entered a date that is more than nine months from today. Confirm date and re-enter it.”
    # • HARD EDIT:
    # o IF DATE IS MORE THAN TEN MONTHS AFTER CURRENT DATE, DISPLAY, “You have entered a date that is more than ten months from today. Re-enter date.”
    # o IF DATE IS MORE THAN 1 MONTH BEFORE CURRENT DATE, DISPLAY, “You have entered a date that occurred more than a month before today. Re-enter date.”
    #
    # • IF DATE IS COMPLETE, SET PPG_DUE_DATE_2 TO DATE PROVIDED; GO TO STATUS
    #
    # • IF DATE IS INCOMPLETE, GO TO DATE_PERIOD

    q_DATE_PERIOD "What was the first day of your last menstrual period?",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.DATE_PERIOD"
    a_date "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PPG_DUE_DATE_1, "!=", :a_date

    # TODO
    # • IF VALID DATE IS PROVIDED IN PPG_DUE_DATE_1, SKIP TO STATUS
    # • HARD EDIT:
    # o IF DATE IS MORE THAN TEN MONTHS BEFORE CURRENT DATE, DISPLAY, “You have entered a date that was more than ten months before today. Confirm date. If this date is correct, enter ‘Don’t Know’ to continue with duration questions.”
    # o IF DATE IS AFTER TODAY’S DATE, DISPLAY “You have entered a date that has not occurred yet. Re-enter date.”
    #
    # • IF DATE IS COMPLETE, CALCULATE DUE DATE FROM FIRST DATE OF LAST MENSTRUAL PERIOD, WHERE PPG_DUE_DATE_2 = DATE_PERIOD + 280 DAYS ;
    # ELSE GO TO WEEKS_PREG.

    q_WEEKS_PREG "How many weeks pregnant are you now? If you’re not sure, please make your best guess.",
    :help_text => "Reject responses that are either < 1 week or greater than 44 weeks. If response was determined to be invalid,
    ask question again and probe for valid response.",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.WEEKS_PREG"
    a_weeks "Number of weeks", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_DATE_PERIOD , "!=", :a_date

    # TODO
    # IF NUMBER OF WEEKS PREGNANT IS COMPLETE, CALCULATE DUE DATE FROM NUMBER OF WEEKS PREGNANT, WHERE
    # PPG_DUE_DATE_2 = TODAY’S DATE + (280 DAYS – WEEKS_PREG*7); ELSE GO TO MONTH_PREG.

    q_MONTH_PREG "About how many months pregnant are you? If you’re not sure, please make your best guess.",
    :pick => :one,
    :help_text => "Reject responses that are either < 1 month or greater than 12 months. If response was determined to be invalid,
    ask question again and probe for valid response.",
    :data_export_identifier=>"PPG_CATI.MONTH_PREG"
    a_months "Number of months", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_WEEKS_PREG, "!=", :a_weeks

    # TODO
    #     • IF NUMBER OF MONTHS PREGNANT IS COMPLETE, CALCULATE DUE DATE FROM NUMBER OF MONTHS PREGNANT, WHERE
    #     PPG_DUE_DATE_2 = TODAY’S DATE + (280 DAYS – MONTH_PREG*30 - 15) ; ELSE GO TO TRIMESTER.

    q_TRIMESTER "Are you currently in your First, Second, or Third trimester?",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.TRIMESTER"
    a_1 "1st (1 to 3 months pregnant)"
    a_2 "2nd (4 to 6 months pregnant)"
    a_3 "3rd (7 to 9 months pregnant)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_MONTH_PREG, "!=", :a_months

    # TODO
    #    PROGRAMMER INSTRUCTIONS:
    #    •  REFERENCE CODE LIST: TRIMESTER_CL1
    #
    #    •  CALCULATE DUE DATE FROM TRIMESTER,
    #    o  IF TRIMESTER = 1 THEN: PPG_DUE_DATE_2 = TODAY’S DATE + (280 DAYS – 46 DAYS).
    #    o  IF TRIMESTER = 2 THEN: PPG_DUE_DATE_2 = TODAY’S DATE + (280 DAYS – 140 DAYS).
    #    o  IF TRIMESTER = 3 THEN: PPG_DUE_DATE_2 = TODAY’S DATE + (280 DAYS – 235 DAYS).
    #    o  IF TRIMESTER = -1 OR -2 THEN: PPG_DUE_DATE_2 = TODAY’S DATE + (280 DAYS – 140 DAYS) .

    q_MED_UNABLE "Do any of the following apply to you? Have you had: A hysterectomy, Both ovaries removed, Your tubes tied,
    Gone through menopause or Any other medical reason why you cannot become pregnant?",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.MED_UNABLE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A or B or C or D or E"
    condition_A :q_PREGNANT, "==", :a_5
    condition_B :q_TRYING, "==", :a_2
    condition_C :q_TRYING, "==", :a_5
    condition_D :q_TRYING, "==", :a_neg_1
    condition_E :q_TRYING, "==", :a_neg_2

    # TODO
    # • PRELOAD LOCAL SC  TOLL-FREE NUMBER AND NAME OF LOCAL SC
    q_prepopulated_sc_phone_number "Local SC toll-free number"
    a :string

    q_prepopulated_local_sc "Local SC"
    a :string

    group "PPG Group = 1" do
      dependency :rule=> "A"
      condition_A :q_PREGNANT, "==", :a_1

      label_STATUS_PREG "Status: Pregnant and Eligible"

      label "Thank you for taking time to answer these questions. [Congratulations again on your pregnancy.]  We would like to set up a
      time to talk about the National Children’s Study.  If you have any other questions before that time, please
      call xxx-xxx-xxxx, which is XXX’s local toll free National Children’s Study office."
    end

    group "PPG Group = 2" do
      dependency :rule=> "A"
      condition_A :q_TRYING, "==", :a_1

      label_STATUS_TRYING "Status: High probability - trying to conceive"

      label "Thank you for taking time to answer these questions.
      You are able to take part in this important study because you are currently trying to become pregnant.
      We would like to set up a time to talk about the National Children’s Study.  If you have any other questions or find out that
      you’re pregnant before our next call, please call xxx-xxx-xxxx, which is XXX’s local toll free National Children’s Study office."
    end

    group "PPG Group = 3" do
      dependency :rule=> "A and B"
      condition_A :q_PREGNANT, "==", :a_3
      condition_B :q_TRYING, "==", :a_3

      label_STATUS_RECENT_LOSS "Status: high probability - recent loss"

      label "[I’m so sorry to hear that you’ve lost your baby.  I know this can be a hard time.]  Because your address is in the study
      area, we may be back in touch at a later time to update your household information.  If you have any other questions before that
      time, please call xxx-xxx-xxxx, which is XXX’s local toll free National Children’s Study office.  Thank you for taking time to answer
      these questions.  "
    end

    group "PPG Group = 4" do
      dependency :rule=> "(A and B) or C"
      condition_A :q_PREGNANT, "==", :a_4
      condition_B :q_TRYING, "==", :a_4
      condition_C :q_MED_UNABLE, "!=", :a_1

      label_STATUS_OTHER_PROBABILITY "Status: other probability – not pregnant and not trying"

      label "Thank you for taking time to answer these questions.
      We will call you again in a couple of months to ask a few quick questions.  If you have any other questions before that time,
      please call xxx-xxx-xxxx, which is XXX’s local toll free National Children’s Study office."
    end

    group "PPG Group = 5" do
      dependency :rule=> "A"
      condition_A :q_MED_UNABLE, "==", :a_1

      label_STATUS_INELIGIBLE "Status: ineligible- unable to conceive"

      label "Thank you for taking time to answer these questions.  Based on what you’ve told me, we will not ask you to take part
      in the study at this time. We may be back in touch at a later time to update your household information.  If you have any other
      questions before that time, please call xxx-xxx-xxxx, which is XXX’s local toll free National Children’s Study office."
    end

    q_TIME_STAMP_2 "Insert date/time stamp",
    :data_export_identifier=>"PPG_CATI.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
  end
  section "Tracing questions", :reference_identifier=>"PPGFollUp_INT" do
    q_BST_NMBR "Just to confirm, is this the best phone number to reach you?",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.BST_NMBR"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_PHONE_NBR "What is the best phone number to reach you?",
    :help_text => "Enter phone number and confirm",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.PHONE_NBR"
    a_phone "Phone number: ", :string
    a_neg_7 "Respondent has no telephone"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A"
    condition_A :q_BST_NMBR, "==", :a_2

    q_PHONE_TYPE "Is that your home, work, cell, or another phone number?",
    :help_text => "Confirm if known.",
    :pick => :one,
    :data_export_identifier=>"PPG_CATI.PHONE_TYPE"
    a_1 "Home"
    a_2 "Work"
    a_3 "Cell"
    a_4 "Friend/relative"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A"
    condition_A :q_PHONE_NBR, "==", :a_phone

    label_END "Thank you taking the time to answer our questions."

    q_TIME_STAMP_3 "Insert date/time stamp",
    :data_export_identifier=>"PPG_CATI.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
  end
end
