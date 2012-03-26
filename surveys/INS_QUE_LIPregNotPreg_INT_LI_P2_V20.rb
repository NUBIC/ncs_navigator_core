survey "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0" do
  section "Interviewer-completed questions", :reference_identifier=>"LIPregNotPreg_INT" do
    label "[Completion of low-intensity consent must be obtained first; assume completion of low-intensity cati
    pregnancy screener or return of PPG self-administered questionnaire]"

    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

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

    group "Time and phone interview setup" do
      dependency :rule => "A"
      condition_A :q_FEMALE_1, "!=", :a_1

      q_BEST_TTC_1 "What would be a good time to reach her?",
      :help_text => "Enter in hour and minute values",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.BEST_TTC_1"
      a_time "Time", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BEST_TTC_2 "Select AM or PM",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.BEST_TTC_2"
      a_am "AM"
      a_pm "PM"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BEST_TTC_3 "Additional info",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.BEST_TTC_3"
      a_am "After time reported"
      a_pm "Before time reported"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

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

      q_PHONE_NBR "Would you please tell me a telephone number where she can be reached? ",
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
    end

    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
    dependency :rule => "A or B"
    condition_A :q_FEMALE_1, "==", :a_1
    condition_B :q_type_of_call, "==", :a_inbound
  end
  section "Pregnancy screener", :reference_identifier=>"LIPregNotPreg_INT" do
    group "Pregnancy information" do
      dependency :rule => "A or B"
      condition_A :q_FEMALE_1, "==", :a_1
      condition_B :q_type_of_call, "==", :a_inbound

      label "[When speaking to consented participant]"

      label "We are asking women of childbearing age a few questions about pregnancy. Not all women who answer these questions will be
      able to take part in the National Children’s Study now, but almost every woman who answers these questions will have a chance to
      take part in some way in the future. We first want to know..."

      q_PREGNANT "Are you pregnant now?",
      :help_text => "If adult is known to be pregnant, add [Just to confirm,]",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.PREGNANT"
      a_1 "Yes"
      a_2 "No, no additional information provided"
      a_3 "No, recently lost pregnancy (miscarriage/abortion) -- ( if volunteered by participant)"
      a_4 "No, recently gave birth -- ( if volunteered by participant)"
      a_5 "No, unable to have children (hysterectomy, tubal ligation) -- ( if volunteered by participant)"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      # TODO
      # need to know the CURRENT PPG_STATUS
      q_prepopulated_ppg_status "PPG Status"
      a_ppg_status "PPG status", :integer

    end

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • IF NO CHANGE IN (PPG STATUS), DISPLAY SAME STATUS AS PREVIOUSLY:
    # Nataliya's comment -- the label_PPG001 should change PPG Status
    label_PPG_FIRST_1 "PPG First = 1"
    dependency :rule => "A"
    condition_A :q_PREGNANT, "==", :a_1

    label_PPG_FIRST_3 "PPG First = 3"
    dependency :rule => "A"
    condition_A :q_PREGNANT, "==", :a_3

    label_PPG_FIRSTS_4 "PPG First = 4"
    dependency :rule => "A"
    condition_A :q_PREGNANT, "==", :a_4

    label_PPG_FIRST_5 "PPG First = 5"
    dependency :rule => "A"
    condition_A :q_PREGNANT, "==", :a_5

    label_PPG_STATUS_3 "PPG Status = 3"
    dependency :rule => "A and B"
    condition_A :q_PREGNANT, "==", :a_2
    condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "1"}

    label_PPG_STATUS_2 "PPG Status = 2"
    dependency :rule => "A and B"
    condition_A :q_PREGNANT, "==", :a_2
    condition_B :q_prepopulated_ppg_status, "==", {:integer_value => "2"}
  end
  section "Current pregnancy information", :reference_identifier=>"LIPregNotPreg_INT" do
    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
    dependency :rule => "A or B or (C and D)"
    condition_A :q_PREGNANT, "==", :a_1
    condition_B :q_PREGNANT, "==", :a_3
    condition_C :q_PREGNANT, "==", :a_2
    condition_D :q_prepopulated_ppg_status, "==", {:integer_value => "1"}

    label_CPI001 "We’ll begin by asking some questions about you, your health, and your health history.
    First, I’ll ask about your current pregnancy"
    dependency :rule => "A"
    condition_A :q_PREGNANT, "==", :a_1

    group "Loss case" do
      dependency :rule => "A or (B and C)"
      condition_A :q_PREGNANT, "==", :a_3
      condition_B :q_PREGNANT, "==", :a_2
      condition_C :q_prepopulated_ppg_status, "==", {:integer_value => "1"}

      label_CPI001A "I’m so sorry to hear that you’ve lost your baby. I know this can be a hard time.",
      :help_text => "Use social cues and professional judgment in response. If SC has pregnancy loss information
      to disseminate,
      offer to participant"

      q_LOSS_INFO "Did participant request additional information on coping with pregnancy loss?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.LOSS_INFO"
      a_1 "Yes"
      a_2 "No"
    end

    q_DUE_DATE "What is your current due date? ", :pick => :one,
    :help_text => "Verify if date is more than 9 months after current date, or if date is more than 1 month before current date
    If response was determined to be invalid, ask question again and probe for valid response",
    :data_export_identifier=>"PREG_VISIT_LI_2.DUE_DATE"
    a_date "Due Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=> "A"
    condition_A :q_PREGNANT, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • CHECK REPORTED DUE DATE AGAINST CURRENT DATE.
    # • DISPLAY APPROPRIATE MESSAGE:
    # - IF DATE IS MORE THAN 9 MONTHS AFTER CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION:
    # “YOU HAVE ENTERED A DATE THAT IS MORE THAN 9 MONTHS FROM TODAY. RE-ENTER DATE.”
    #   IF DATE IS MORE THAN 1 MONTH BEFORE CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION:
    # “YOU HAVE ENTERED A DATE THAT OCCURRED MORE THAN A MONTH BEFORE TODAY. RE-ENTER DATE.”
    # - IF VALID DUE DATE WAS PROVIDED, SET DUE_DATE = YYYYMMDD AS REPORTED ; GO TO KNOW_DATE.
    # - IF NO VALID DATE IS GIVEN → GO TO DATE_PERIOD.
    #TODO - have to be able to calculate the labels below - put the request in surveyor to address the issue

    # Nataliya's comment - possible code
    # q_DATE_CHECK "Calculation: number of months between reported due date and 'TODAY'",
    # :help_text => "Can not be (1) on or before 'TODAY' or (2) more than 9 months after 'TODAY'.
    # If response was determined to be invalid, ask question again and probe for valid response",
    # :pick => :one
    # a_on_or_before_today "On or before 'TODAY'"
    # a_more_than_9_months_after_today "More than 9 months after 'TODAY'"
    # a_valid "Valid due date"
    # a_invalid "No valid date is given"
    # dependency :rule=> "A"
    # condition_A :q_DUE_DATE, "==", :a_1
    #
    # label "You have entered a date that is more than 9 months from today. Re-enter date"
    # dependency :rule=>"A"
    # condition_A :q_DATE_CHECK, "==", :a_more_than_9_months_after_today
    #
    # label "You have entered a date that occurred more than a month before today. Re-enter date"
    # dependency :rule=>"A"
    # condition_A :q_DATE_CHECK, "==", :a_on_or_before_today

    q_KNOW_DATE "How did you find out your due date?",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_LI_2.KNOW_DATE"
    a_1 "Figured it out myself"
    a_2 "Had an ultrasound to figure it out"
    a_3 "Doctor or other provider told me without an ultrasound"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_DUE_DATE, "==", :a_date

    q_DATE_PERIOD "What was the first day of your last menstrual period?",
    :help_text => "Verify if date is more than 10 months before current date, or if date is after current date.
    Code day as '15' if participant is unsure/unable to estimate day.
    If response was determined to be invalid, ask question again and probe for valid response.",
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_LI_2.DATE_PERIOD"
    a_date "Specify", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=> "A"
    condition_A :q_PREGNANT, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • CHECK REPORTED MENSTRUAL DATE AGAINST CURRENT DATE; DISPLAY APPROPRIATE MESSAGE:
    # - IF DATE IS MORE THAN 10 MONTHS BEFORE CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION:
    # “YOU HAVE ENTERED A DATE THAT IS MORE THAN 10 MONTHS BEFORE TODAY. CONFIRM DATE. IF DATE IS CORRECT,
    # ENTER ‘DON’T KNOW’.”
    # - IF DATE IS AFTER CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT HAS
    # NOT OCCURRED YET. RE-ENTER DATE.”
    # - IF VALID DATE WAS PROVIDED, CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET
    # DUE_DATE (YYYYMMDD) = DATE_PERIOD + 280 DAYS; GO TO KNEW_DATE.

    #these labels have to be calculated automatically
    # Nataliya's comment - possible code
    # q_DATE_PERIOD_CHECK "Calculation: number of months between reported date of first day of last menstrual period and 'TODAY'",
    # :help_text => "Verify if date is more than 10 months before current date, or if date is after current date. If response was determined
    # to be invalid, ask question again and probe for valid response"
    # a_after_today "Is after 'TODAY'"
    # a_more_than_10_months_before_today "Is more than 10 months before 'TODAY'"
    # a_valid "Valid"
    # dependency :rule=>"A"
    # condition_A :q_DATE_PERIOD, "==", :a_date
    #
    # label "You have entered a date that is more than 10 months before today. Confirm date. If date is
    # correct, enter \"Don’t know\""
    # dependency :rule=>"A"
    # condition_A :q_DATE_PERIOD_CHECK, "==", :a_more_than_10_months_before_today
    #
    # label "You have entered a date that has not occurred yet. Re-enter date."
    # dependency :rule=>"A"
    # condition_A :q_DATE_PERIOD_CHECK, "==", :a_after_today
    #
    # q_CALCULATED_DUE_DATE "Due date from the first date of last menstrual period",
    # :help_text => "Set due_date (YYYYMMDD) = Date_period + 280 days",
    # :data_export_identifier=>"PREG_VISIT_LI_2.DUE_DATE"
    # a :string
    # dependency :rule=>"A"
    # condition_A :q_DATE_PERIOD_CHECK, "==", :a_valid

    q_KNEW_DATE "Did participant give date?",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_LI_2.KNEW_DATE"
    a_1 "Participant gave complete date"
    a_2 "Interviewer entered 15 for day"
    dependency :rule=>"A"
    condition_A :q_DATE_PERIOD, "==", :a_date

    group "Pregnancy information" do
      dependency :rule => "A"
      condition_A :q_PREGNANT, "==", :a_1

      q_TIME_STAMP_4 "Current date & time", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_4"
      a :datetime, :custom_class => "datetime"

      q_HOME_TEST "Did you use a home pregnancy test to help find out you were pregnant?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HOME_TEST"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BIRTH_PLAN "Where do you plan to deliver your baby?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.BIRTH_PLAN"
      a_1 "In a hospital"
      a_2 "A birthing center"
      a_3 "At home, or"
      a_neg_5 "Some other place?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BIRTH_PLAN_OTH "Other",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.BIRTH_PLAN_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_BIRTH_PLAN, "==", :a_neg_5
    end

    group "Birth place information" do
      dependency :rule=>"A or B or C"
      condition_A :q_BIRTH_PLAN, "==", :a_1
      condition_B :q_BIRTH_PLAN, "==", :a_2
      condition_C :q_BIRTH_PLAN, "==", :a_neg_5

      label "What is the name and address of the place where you are planning to deliver your baby?"

      q_BIRTH_PLACE "Name of birth hospital/birthing center",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.BIRTH_PLACE"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_B_ADDRESS_1 "Address 1 - STREET/PO Box",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.B_ADDRESS_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_B_ADDRESS_2 "Address 2",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.B_ADDRESS_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_B_CITY "City",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.B_CITY"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_B_STATE "State", :display_type=>:dropdown,
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.B_STATE"
      a_1 "AL"
      a_2 "AK"
      a_3 "AZ"
      a_4 "AR"
      a_5 "CA"
      a_6 "CO"
      a_7 "CT"
      a_8 "DE"
      a_9 "DC"
      a_10 "FL"
      a_11 "GA"
      a_12 "HI"
      a_13 "ID"
      a_14 "IL"
      a_15 "IN"
      a_16 "IA"
      a_17 "KS"
      a_18 "KY"
      a_19 "LA"
      a_20 "ME"
      a_21 "MD"
      a_22 "MA"
      a_23 "MI"
      a_24 "MN"
      a_25 "MS"
      a_26 "MO"
      a_27 "MT"
      a_28 "NE"
      a_29 "NV"
      a_30 "NH"
      a_31 "NJ"
      a_32 "NM"
      a_33 "NY"
      a_34 "NC"
      a_35 "ND"
      a_36 "OH"
      a_37 "OK"
      a_38 "OR"
      a_39 "PA"
      a_40 "RI"
      a_41 "SC"
      a_42 "SD"
      a_43 "TN"
      a_44 "TX"
      a_45 "UT"
      a_46 "VT"
      a_47 "VA"
      a_48 "WA"
      a_49 "WV"
      a_50 "WI"
      a_51 "WY"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_B_ZIPCODE "ZIP CODE",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.B_ZIPCODE"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    group "Additional pregnancy information" do
      dependency :rule => "A"
      condition_A :q_PREGNANT, "==", :a_1

      q_PN_VITAMIN "In the month before you became pregnant, did you regularly take multivitamins, prenatal
      vitamins, folate, or folic acid?",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.PN_VITAMIN"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PREG_VITAMIN "Since you’ve become pregnant, have you regularly taken multivitamins, prenatal vitamins, folate, or folic acid?",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.PREG_VITAMIN"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DATE_VISIT "What was the date of your most recent doctor’s visit or checkup since you’ve become pregnant?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DATE_VISIT"
      a :string, :custom_class => "date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      a_neg_7 "Have not had a visit/not applicable"

      label_CPI014 "At this visit or at any time during your pregnancy, did the doctor or other health care
      provider tell you that you have any of the following conditions?",
      :help_text => "Re-read introductory statement as needed for remainder of questions in this section.
      If valid date for date_visit is provided, display \"At this visit or at\". Otherwise, display \"At\"."

      q_DIABETES_1 "Diabetes? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DIABETES_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HIGHBP_PREG "High blood pressure? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HIGHBP_PREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_URINE "Protein in your urine? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.URINE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PREECLAMP "Preeclampsia or toxemia? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.PREECLAMP"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EARLY_LABOR "Early or premature labor? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.EARLY_LABOR"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ANEMIA "Anemia or low blood count? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.ANEMIA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NAUSEA "Severe nausea or vomiting (hyperemesis)? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.NAUSEA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_KIDNEY "Bladder or kidney infection? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.KIDNEY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_RH_DISEASE "Rh disease or isoimmunization? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.RH_DISEASE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_GROUP_B "Infection with bacteria called Group B strep?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.GROUP_B"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HERPES "Infection with a Herpes virus? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HERPES"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_VAGINOSIS "Infection of the vagina with bacteria (bacterial vaginosis?)", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.VAGINOSIS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_OTH_CONDITION "Any other serious condition? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.OTH_CONDITION"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ENTER_CONDITION_OTH "Can you please specify the other serious conditions? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.CONDITION_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_OTH_CONDITION, "==", :a_1
    end
  end
  section "Medical history", :reference_identifier=>"LIPregNotPreg_INT" do
    group "Medical history information" do
      dependency :rule => "A and B"
      condition_A :q_PREGNANT, "!=", :a_4
      condition_B :q_PREGNANT, "!=", :a_5

      q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_5"
      a :datetime, :custom_class => "datetime"

      label "I have some additional questions to ask if that is okay."
      dependency :rule => "A"
      condition_A :q_PREGNANT, "==", :a_3

      label_MD001 "This next question is about your health when you are not pregnant."

      q_HEALTH "Would you say your health in general is...", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HEALTH"
      a_1 "Excellent"
      a_2 "Very good,"
      a_3 "Good,"
      a_4 "Fair, or"
      a_5 "Poor?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "How tall are you without shoes?"

      # TODO
      # PROGRAMMER INSTRUCTIONS:
      # • INCLUDE A SOFT EDIT IF HEIGHT_FT > 7 OR < 4.
      # • IF HEIGHT_FT IS PROVIDED INCLUDE A SOFT EDIT IF HT_INCH > 12.
      # • IF HEIGHT_FT IS NOT PROVIDED INCLUDE A SOFT EDIT IF HT_INCH > 84 OR < 48.

      q_HEIGHT_FT "Portion of height in whole feet (e.g., 5)",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HEIGHT_FT"
      a :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Provided value is outside of the suggested range (4 to 7 feet). This value is admissible, but you
      may wish to verify."
      dependency :rule=>"A or B"
      condition_A :q_HEIGHT_FT, "<", {:integer_value => "4"}
      condition_B :q_HEIGHT_FT, ">", {:integer_value => "7"}

      q_HT_INCH "Additional portion of height in inches (e.g., 7)",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HT_INCH"
      a :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Provided value is outside of the suggested range (0 to 11 inches when \"feet\" value is specified and
      48 to 84 inches, when \"feet\" value is blank. This value is admissible, but you may wish to verify."
      dependency :rule=>"A or B or C or D"
      condition_A :q_HT_INCH, "<", {:integer_value => "0"}
      condition_B :q_HT_INCH, ">", {:integer_value => "11"}
      condition_C :q_HT_INCH, ">", {:integer_value => "84"}
      condition_D :q_HT_INCH, "<", {:integer_value => "48"}

      # TODO
      #       PROGRAMMER INSTRUCTIONS:
      #       • INCLUDE A SOFT EDIT IF WEIGHT < 90 OR > 400.
      #       • IF PREGNANT=2 or 3, DISPLAY “How Much do you weigh?”
      #       •	IF PREGNANT=1, DISPLAY: “What was your weight just before you became pregnant?”

      q_WEIGHT "How much do you weigh?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.WEIGHT"
      a_pounds "Pounds", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A or B"
      condition_A :q_PREGNANT, "==", :a_2
      condition_B :q_PREGNANT, "==", :a_3

      q_WEIGHT_ALT "What was your weight just before you became pregnant?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.WEIGHT"
      a_pounds "Pounds", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A and B"
      condition_A :q_PREGNANT, "!=", :a_2
      condition_B :q_PREGNANT, "!=", :a_3

      label "Provided value is outside of the suggested range (90 to 400 lbs). This value is admissible, but you may wish
      to verify."
      dependency :rule=>"A or B or C or D"
      condition_A :q_WEIGHT, "<", {:integer_value => "90"}
      condition_B :q_WEIGHT, ">", {:integer_value => "400"}
      condition_C :q_WEIGHT_ALT, "<", {:integer_value => "90"}
      condition_D :q_WEIGHT_ALT, ">", {:integer_value => "400"}

      label "The next questions are about medical conditions or health problems you might have now or may have had in the past."

      q_ASTHMA "Have you ever been told by a doctor or other health care provider that you had asthma? ",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.ASTHMA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HIGHBP_NOTPREG "Have you ever been told by a doctor or other health care provider that you had
      Hypertension or high blood pressure when you’re not pregnant?",
      :help_text => "Re-read introductory statement \"Have you ever been told by a doctor or other health care provider
      that you had\"as needed.",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HIGHBP_NOTPREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DIABETES_NOTPREG "Have you ever been told by a doctor or other health care provider that you had
      High blood sugar or Diabetes when you're not pregnant?",
      :help_text => "Re-read introductory statement \"Have you ever been told by a doctor or other health care provider
      that you had\"as needed.",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DIABETES_NOTPREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DIABETES_2 "Have you taken any medicine or received other medical treatment for diabetes in the past 12 months? ",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DIABETES_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_DIABETES_NOTPREG, "==", :a_1

      q_DIABETES_3 "Have you ever taken insulin?",
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_LI_2.DIABETES_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_DIABETES_NOTPREG, "==", :a_1

      q_THYROID_1 "(Have you ever been told by a doctor or other health care provider that you had)
      Hypothyroidism, that is, an under active thyroid?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.THYROID_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_THYROID_2 "Have you taken any medicine or received other medical treatment for a thyroid problem in the past 12 months?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.THYROID_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_THYROID_1, "==", :a_1

      label_MD012 "This next question is about where you go for routine health care."

      q_HLTH_CARE "What kind of place do you usually go to when you need routine or preventive care, such as a physical
      examination or check-up?",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HLTH_CARE"
      a_1 "Clinic or health center"
      a_2 "Doctor's office or Health Maintenance Organization (HMO)"
      a_3 "Hospital emergency room"
      a_4 "Hospital outpatient department"
      a_5 "Some other place"
      a_6 "Doesn't go to one place most often"
      a_7 "Doesn't get preventive care anywhere"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Health insurance", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Insurance introduction" do
      dependency :rule => "A and B"
      condition_A :q_PREGNANT, "!=", :a_4
      condition_B :q_PREGNANT, "!=", :a_5

      q_TIME_STAMP_6 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_6"
      a :datetime, :custom_class => "datetime"

      label_HI001 "Now I'm going to switch to another subject and ask about health insurance."

      q_INSURE "Are you currently covered by any kind of health insurance or some other kind of health care plan?",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INSURE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Insurance information" do
      dependency :rule=>"A"
      condition_A :q_INSURE, "==", :a_1

      label "Now I'll read a list of different types of insurance. Please tell me which types you currently have. Do you currently have.",
      :help_text => "Re-read introductory statement (Do you currently have...) as needed"

      q_INS_EMPLOY "Insurance through an employer or union either through yourself or another family member? ",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_MEDICAID "Medicaid or any government-assistance plan for those with low incomes or a disability?",
      :help_text => "Provide examples of local medicaid programs", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_TRICARE "TRICARE, VA, or other military health care? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_IHS "Indian Health Service? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_MEDICAIRE "Medicare, for people with certain disabilities? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INS_MEDICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_OTH "Any other type of health insurance or health coverage plan? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Housing characteristics", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Housing information" do
      dependency :rule => "A and B"
      condition_A :q_PREGNANT, "!=", :a_4
      condition_B :q_PREGNANT, "!=", :a_5

      q_TIME_STAMP_7 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_7"
      a :datetime, :custom_class => "datetime"

      label "Now I'd like to find out more about your home.",
      :help_text => "Show response options on card to participant."

      q_AGE_HOME "Can you tell us, which of these categories do you think best describes when your home or building was built?",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.AGE_HOME"
      a_1 "2001 to present"
      a_2 "1981 to 2000"
      a_3 "1961 to 1980"
      a_4 "1941 to 1960"
      a_5 "1940 or before"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_MAIN_HEAT "Which of these types of heat sources best describes the main heating fuel source for your home? Is it...",
      :help_text => "Show response options on card to participant.", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.MAIN_HEAT"
      a_1 "Electric"
      a_2 "Gas - propane or LP"
      a_3 "Oil"
      a_4 "Wood"
      a_5 "Kerosene or diesel"
      a_6 "Coal or coke"
      a_7 "Solar energy"
      a_8 "Heat pump"
      a_9 "No heating source"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_MAIN_HEAT_OTH "Other main heating fuel source", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.MAIN_HEAT_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_MAIN_HEAT, "==", :a_neg_5

      q_COOL "Not including fans, which of the following kinds of cooling systems do you regularly use?",
      :help_text => "Select all that apply", :pick=>:any,
       :data_export_identifier=>"PREG_VISIT_LI_COOL_2.COOL"
      a_1 "Windows or wall air conditioners,"
      a_2 "Central air conditioning,"
      a_3 "Evaporative cooler (swamp cooler), or"
      a_neg_7 "No cooling or air conditioning regularly used"
      a_neg_5 "Some other cooling system"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_COOL_OTH "Other cooling system",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_COOL_2.COOL_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C and D"
      condition_A :q_COOL, "==", :a_neg_5
      condition_B :q_COOL, "!=", :a_neg_7
      condition_C :q_COOL, "!=", :a_neg_1
      condition_D :q_COOL, "!=", :a_neg_2

      label_WATER "Now I'd like to ask about the water in your home."

      q_WATER_DRINK "What water source in your home do you use most of the time for drinking? ",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.WATER_DRINK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_WATER_DRINK_OTH "Other source of drinking", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.WATER_DRINK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_WATER_DRINK, "==", :a_neg_5
    end
  end
  section "Tobacco and alcohol use", :reference_identifier=>"PREG_VISIT_LI_2" do
    group "Tobacco and alcohol use information" do
      dependency :rule => "A and B"
      condition_A :q_PREGNANT, "!=", :a_4
      condition_B :q_PREGNANT, "!=", :a_5

      q_TIME_STAMP_8 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_8"
      a :datetime, :custom_class => "datetime"

      label_TA001 "Now I am going to ask about your use of cigarettes and alcohol."

      q_CIG_NOW "Currently, do you smoke cigarettes?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.CIG_NOW"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CIG_NOW_FREQ "Do you smoke cigarettes...",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.CIG_NOW_FREQ"
      a_1 "Every day"
      a_2 "5 or 6 days a week"
      a_3 "2-4 days a week"
      a_4 "Once a week"
      a_5 "1-3 days a month"
      a_6 "Less than once a month"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CIG_NOW, "==", :a_1

      q_CIG_NOW_NUM "On days that you smoke, how many cigarettes do you smoke per day?",
      :help_text => "If participant answers 1 or less per day, enter \"1.\". Verify if response > 60.
      If response is in packs, calculate 20 cigarettes per pack.",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.CIG_NOW_NUM"
      a_number "Number per day", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CIG_NOW, "==", :a_1

      q_DRINK_NOW "How often do you currently drink alcoholic beverages?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DRINK_NOW"
      a_1 "5 or more times a week"
      a_2 "2-4 times a week"
      a_3 "Once a week"
      a_4 "1-3 times a month"
      a_5 "Less than once a month"
      a_6 "Never"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DRINK_NOW_NUM "Currently, on days that you drink alcoholic beverages, how many did you have per day? ",
      :help_text => "If participant answers less than 1 per day, enter \"1.\"",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DRINK_NOW_NUM"
      a_number "Number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_DRINK_NOW, "!=", :a_6
      condition_B :q_DRINK_NOW, "!=", :a_neg_1
      condition_C :q_DRINK_NOW, "!=", :a_neg_2

      q_DRINK_NOW_5 "Currently, how often do you have 5 or more drinks within a couple of hours:",
      :help_text => "Follow local mandatory reporting requirements.",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DRINK_NOW_5"
      a_1 "Never"
      a_2 "About once a month"
      a_3 "About once a week"
      a_4 "About once a day"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_DRINK_NOW, "!=", :a_6
      condition_B :q_DRINK_NOW, "!=", :a_neg_1
      condition_C :q_DRINK_NOW, "!=", :a_neg_2

      q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"
    end
  end
  section "Evaluation questions", :reference_identifier=>"PREG_VISIT_LI_2" do
    group "Evaluation information" do
      dependency :rule => "A and B"
      condition_A :q_PREGNANT, "!=", :a_4
      condition_B :q_PREGNANT, "!=", :a_5

      q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_10"
      a :datetime, :custom_class => "datetime"

      label "We would now like to take a few minutes to ask some questions about your experience in the study."

      label "How important was each of the following in your decision to take part in the National Children’s Study?"

      q_LEARN "[How important was...] Learning more about my health or the health of my child?",
      :help_text => "Re-read introductory statement as needed.",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.LEARN"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_HELP "[How important was...] Feeling as if I can help children now and in the future?",
      :help_text => "Re-read introductory statement as needed.",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.HELP"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_INCENT "[How important was...] Receiving money or gifts for taking part in the study?",
      :help_text => "Re-read introductory statement as needed.",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INCENT"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_RESEARCH "[How important was...] Helping doctors and researchers learn more about children and their health?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.RESEARCH"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_ENVIR "[How important was...] Helping researchers learn how the environment may affect children’s health?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.ENVIR"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_COMMUNITY "[How important was...] Feeling part of my community?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.COMMUNITY"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_KNOW_OTHERS "[How important was...] Knowing other women in the study?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.KNOW_OTHERS"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_FAMILY "[How important was...] Having family members or friends support my choice to take part in the study?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.FAMILY"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      q_DOCTOR "[How important was...] Having my doctor or health care provider support my choice to take part in the study?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.DOCTOR"
      a_1 "Not at all important"
      a_2 "Somewhat important"
      a_3 "Very important"

      label_EV004 "How negative or positive do each of the following people feel about you taking part in the National Children’s Study?"

      q_OPIN_SPOUSE "Your spouse or partner",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_SPOUSE"
      a_1 "Very Negative"
      a_2 "Somewhat Negative"
      a_3 "Neither Positive or Negative"
      a_4 "Somewhat Positive"
      a_5 "Very Positive"
      a_neg_7 "Not Applicable"

      q_OPIN_FAMILY "Other family members",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_FAMILY"
      a_1 "Very Negative"
      a_2 "Somewhat Negative"
      a_3 "Neither Positive or Negative"
      a_4 "Somewhat Positive"
      a_5 "Very Positive"
      a_neg_7 "Not Applicable"

      q_OPIN_FRIEND "Your friends",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_FRIEND"
      a_1 "Very Negative"
      a_2 "Somewhat Negative"
      a_3 "Neither Positive or Negative"
      a_4 "Somewhat Positive"
      a_5 "Very Positive"
      a_neg_7 "Not Applicable"

      q_OPIN_DR "Your doctor or health care provider",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.OPIN_DR"
      a_1 "Very Negative"
      a_2 "Somewhat Negative"
      a_3 "Neither Positive or Negative"
      a_4 "Somewhat Positive"
      a_5 "Very Positive"
      a_neg_7 "Not Applicable"

      q_EXPERIENCE "In general, has your experience with the National Children’s Study been",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.EXPERIENCE"
      a_1 "Mostly negative"
      a_2 "Somewhat negative"
      a_3 "Neither negative nor positive"
      a_4 "Somewhat positive"
      a_5 "Mostly positive"

      q_IMPROVE "In your opinion, how much do you think the National Children’s Study will help improve the health
      of children now and in the future?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.IMPROVE"
      a_1 "Not at all"
      a_2 "A little"
      a_3 "Some"
      a_4 "A lot"

      q_INT_LENGTH "Did you think the interview was",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INT_LENGTH"
      a_1 "Too short"
      a_2 "Too long, or"
      a_3 "Just about right?"

      q_INT_STRESS "Do you think the interview was",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INT_STRESS"
      a_1 "Not at all stressful"
      a_2 "A little stressful"
      a_3 "Somewhat stressful, or"
      a_4 "Very stressful?"

      q_INT_REPEAT "If you were asked, would you participate in an interview like this again?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_LI_2.INT_REPEAT"
      a_1 "Yes"
      a_2 "No"
    end
  end
  section "Conclusion", :reference_identifier=>"PREG_VISIT_LI_2" do
    group "Conclusion questions" do
      dependency :rule => "A or B"
      condition_A :q_FEMALE_1, "==", :a_1
      condition_B :q_type_of_call, "==", :a_inbound

      q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_11"
      a :datetime, :custom_class => "datetime"

      # TODO
      # PROGRAMMER INSTRUCTION:
      # • PRELOAD LOCAL AGE OF MAJORITY AND STUDY CENTER TOLL-FREE NUMBER.

      label_END1 "Thank you for participating in the National Children’s Study and for taking the time to answer our
      questions. We will contact you in about 6 months to ask you some more questions. If there are any other women
      in your household age {LOCAL AGE OF MAJORITY} - 49, [please have her] contact us at {STUDY CENTER TOLL-FREE NUMBER}."
      dependency :rule => "A"
      condition_A :q_PREGNANT, "!=", :a_5

      label_END2 "Thank you for taking the time to answer these questions. Based on what you’ve told me, you are not
      eligible to take part in the study."
      dependency :rule => "A"
      condition_A :q_PREGNANT, "==", :a_5

      q_TIME_STAMP_12 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_LI_2.TIME_STAMP_12"
      a :datetime, :custom_class => "datetime"
    end
  end
end
