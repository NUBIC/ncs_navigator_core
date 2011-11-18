survey "INS_QUE_PregScreen_INT_HILI_P2_V2.0" do
  section "CATI", :reference_identifier=>"PregScreen_INT" do
    label "Assumptions: Potential LOW INTENSITY respondents will be calling into study centers at will. 
    Scripts in this document represent this inbound calling scenario. "
    
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    q_INCOMING "Telephone number from caller ID", 
    :help_text => "If possible, collect telephone number from caller id and record",
    :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_1"
    a :string
  end
  section "Initial conversation with incoming caller", :reference_identifier=>"PregScreen_INT" do
    # TODO
    # PROGRAMMER INSTRUCTION: 
    # • PRELOAD NAME OF LOCAL ACADEMIC INSTITUTION.
    # 
    label "Thank you for calling the National Children’s Study. I’d like to tell you a bit about the Study and see if 
    you are able to take part. I will just need a few minutes of your time. [Name of local academic institution] is part 
    of this important research study aimed at improving the health and well-being of children."
  end
  section "Verbal permission to screening for study eligibility", :reference_identifier=>"PregScreen_INT" do    
    label "I would like to ask you some questions to determine if you may be able to take part in the Study. Is this 
    alright with you? You can skip over any question I ask or you can stop the interview at any time. The Information we 
    collect from you is protected by law and we will keep all of it private. "
  end
  section "Eligibility questions", :reference_identifier=>"PregScreen_INT" do        
    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
    
    q_R_GENDER "Is respondent male or female?", 
    :help_text => "Select by observation/listening. If unable to determine, ask \"Just to confirm, are you male or female?\"",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.R_GENDER"
    a_1 "Male"
    a_2 "Female"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    # TODO 
    #     PROGRAMMER INSTRUCTION: 
    #     •	PRELOAD LOCAL AGE OF MAJORITY.
    
    q_MALE_R "We are speaking with women who are pregnant or may become pregnant in the future. Are there any women living 
    in your household who are pregnant or who are {LOCAL AGE OF MAJORITY} years or older?",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.MALE_R"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    
    dependency :rule=>"A"
    condition_A :q_R_GENDER, "!=", :a_2
    
    label_MALE_END_1 "Right now we are speaking only with women. In the future we may be speaking to other members of households 
    also. Thank you again for your call and please contact us again in the future if your household membership changes"
    dependency :rule=>"A"
    condition_A :q_MALE_R, "!=", :a_1
    
    q_FEMALE_1 "Is she available to speak with me at this time?",
    :help_text => "If there is more than one woman in household, ask to speak to the pregnant one first. 
    If not available, ask if others are available.",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.FEMALE_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    
    dependency :rule=>"A"
    condition_A :q_MALE_R, "==", :a_1
    
    group "Additional information" do
      dependency :rule=>"A"
      condition_A :q_FEMALE_1, "!=", :a_1
      
      label "I would like to speak with her to see if she is eligible to take part in the Study."

      q_FIRST_NAME "Would you please tell me her first name?",
      :help_text => "If respondent refuses to provide first name, ask for initials.",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.FIRST_NAME"
      a "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_R_PHONE_1 "Would you please tell me a telephone number where she can be reached?",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.R_PHONE_1"
      a "Telephone number", :string
      a_neg_7 "Respondent has no telephone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      # TODO
      #    PROGRAMMER INSTRUCTION: 
      #    •  PRELOAD LOCAL SC TOLL-FREE NUMBER.

      label "Thank you again for your call. Please ask her to call us at {LOCAL SC TOLL-FREE NUMBER}.",
      :help_text => "End interview"
    end
 
    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
    dependency :rule=>"A"
    condition_A :q_FEMALE_1, "==", :a_1
    
    group "Participant information" do
      dependency :rule=>"A or B"
      condition_A :q_FEMALE_1, "==", :a_1
      condition_B :q_R_GENDER, "==", :a_2      
    
      label "Hello. I am [INTERVIEWER NAME] with the National Children’s Study. I would like to ask you some questions to 
      determine if you may be eligible to participate in the Study. You can skip over any question I ask or you can stop 
      the interview at any time. The information we collect from you is protected by law and we will keep all of it private.",
      :help_text => "[When speaking to a new female respondent] "

      label "What is your full name?"
        
      q_R_FNAME "First name",
      :help_text => "Confirm spelling. If respondent refuses to provide first name, ask for initials.",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.R_FNAME"
      a "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
    
      q_R_LNAME "Last name",
      :help_text => "Confirm spelling. If respondent refuses to provide first name, ask for initials.",    
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.R_LNAME"
      a "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
    
      q_PERSON_DOB "What is your date of birth?",
      :help_text => "Please verify if calculated age is less than local age of majority or greater than 49.",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.PERSON_DOB"
      a "Date of birth", :string, :custom_class => "date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
    
      # TODO
      # PROGRAMMER INSTRUCTIONS: 
      # • INCLUDE A SOFT EDIT/WARNING IF CALCULATED AGE IS LESS THAN LOCAL AGE OF MAJORITY OR GREATER THAN 49.
      # • FORMAT PERSON_DOB AS YYYYMMDD.
      # • CALCULATE AGE AND AGE_RANGE BASED ON RESPONSE; SKIP TO AGE_ELIG.
      # • IF ONLY MONTH AND YEAR ARE PROVIDED, CALCULATE AGE AND AGE_RANGE AND SKIP TO AGE_ELIG.
    
      q_AGE "How old are you?",
      :help_text => "Enter age at last birthday in years. Please verify if entered age is less than 10 or greater than 49. 
      Calculate age_range based on response.",    
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.AGE"
      a_age "Age", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
    
      q_AGE_RANGE "Which range best describes your age? Would you say...",
      :help_text => "Describe how the answer to this question determines her eligibility and that all data are kept confidential and secure.",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.AGE_RANGE"
      a_1 "Less than 18"
      a_2 "18-24"
      a_3 "25-34"
      a_4 "35-44"
      a_5 "45-49"
      a_6 "50-64"
      a_7 "65 or older"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_AGE, "!=", :a_age
    
      # TODO
      #     PROGRAMMER INSTRUCTIONS: 
      #     • BASED ON REPORTED AGE OF RESPONDENT, DETERMINE WHETHER SHE IS CONSIDERED A MINOR BASED ON LOCAL REQUIREMENTS AGE_ELIG = 2. 
      #     •	IF RESPONDENT IS DETERMINED TO BE A MINOR, SET PPG_FIRST = 5. 
    
      q_AGE_ELIG "Is participant age-eligible? ", 
      :help_text => "Based on reported age of respondent, determine whether she is considered a minor based on local requirements ",
      :pick=>:one, 
      :data_export_identifier=>"PREG_SCREEN_HI_2.AGE_ELIG"
      a_1 "Participant is age eligible"
      a_2 "Participant is younger than age of majority"
      a_3 "Participant is over 49"
      a_neg_6 "Age eligibility is unknown"

    
      q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_4"
      a :datetime, :custom_class => "datetime"    
    
      label "What is your address?",
      :help_text => "If respondent refuses/don’t know: describe how her eligibility is determined by her residential 
      address and that all data are kept confidential and secure. "

      q_ADDRESS_1 "Address 1 - street/PO Box", 
      :help_text => "Street number. Pre-directional. Street name. Street type. Post directional.",
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.ADDRESS_1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ADDRESS_2 "Address 2", 
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.ADDRESS_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_UNIT "Unit", 
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.UNIT",
      :help_text => "Unit type. Unit number"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CITY "City", 
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.CITY"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_STATE "State", :display_type=>:dropdown, 
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.STATE"
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

      q_ZIP "ZIP Code", 
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.ZIP"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ZIP4 "ZIP+4", 
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.ZIP4"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_DU_ELIG_CONFIRM "Interviewer instructions: Confirm Dwelling Unit",
      :help_text => "This question is used to flag eligibility.",
      :pick=>:one, 
      :data_export_identifier=>"PREG_SCREEN_HI_2.DU_ELIG_CONFIRM"
      a_1 "Respondent lives in an eligible dwelling unit"
      a_2 "Respondent does not live in an eligible dwelling unit"
      a_3 "Dwelling unit eligibility is unknown"
    end
  end
  section "Familiarity with the national children’s study.", :reference_identifier=>"PregScreen_INT" do        
    q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_5"
    a :datetime, :custom_class => "datetime"
    dependency :rule=>"A or B"
    condition_A :q_FEMALE_1, "==", :a_1
    condition_B :q_R_GENDER, "==", :a_2
    
    q_KNOW_NCS "Before today, had you heard about the National Children’s Study?",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.KNOW_NCS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A or B"
    condition_A :q_FEMALE_1, "==", :a_1
    condition_B :q_R_GENDER, "==", :a_2
    
    q_HOW_KNOW_NCS "How did you hear about the National Children’s Study?",
    :help_text => "Select all that apply and probe for any other means.",
    :pick => :any,
    :data_export_identifier=>"PREG_SCREEN_HI_KNOW_NCS_2.HOW_KNOW_NCS"
    a_1 "Advance letter mailed by NCS"
    a_2 "Household enumeration"
    a_3 "Continuous tracking of DU – new member of existing household"
    a_4 "Continuous tracking of DU – new household"
    a_5 "Prenatal care provider"
    a_6 "Other health care provider"
    a_7 "Other NCS respondent"
    a_8 "Friend"
    a_9 "Neighbor"
    a_10 "Family member"
    a_11 "Co-worker"
    a_12 "Self/respondent referral"
    a_13 "School"
    a_14 "WIC or other social agency"
    a_15 "Religious organization"
    a_16 "Community partners/outreach event"
    a_17 "Media: print media"
    a_18 "Media: TV"
    a_19 "Media: radio"
    a_20 "Social networking media (e.g., internet, facebook, myspace, blogs, etc.)"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_KNOW_NCS, "==", :a_1
    
    q_HOW_KNOW_NCS_OTH "Other - specify",
    :pick => :any,
    :data_export_identifier=>"PREG_SCREEN_HI_KNOW_NCS_2.HOW_KNOW_NCS_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A and B and C"
    condition_A :q_HOW_KNOW_NCS, "==", :a_neg_5
    condition_B :q_HOW_KNOW_NCS, "!=", :a_neg_1
    condition_C :q_HOW_KNOW_NCS, "!=", :a_neg_2
    
    # TODO
    # FA008/(ELIG). PROGRAMMER INSTRUCTION: 
    # • PROGRAM SKIP PATTERNS ACCORDING TO TABLE BELOW:
    # -- Nataliya's comment -- Programmed PPG_FIRST and used dependencies on where to go next, without ELIG question...
    
    # SHOULD BE HIDDEN VALUE
    label_ELIG "Skip value 9333-93-93T93:93:93 (Legitimate Skip)",
    :data_export_identifier=>"PREG_SCREEN_HI_2.ELIG"
  end
  section "Pregnancy screener", :reference_identifier=>"PregScreen_INT" do
    
    group "Pregnancy information" do 
      dependency :rule=>"(A or B or C) and (D or E)"
      condition_A :q_DU_ELIG_CONFIRM, "==", :a_1
      condition_B :q_DU_ELIG_CONFIRM, "==", :a_2
      condition_C :q_DU_ELIG_CONFIRM, "==", :a_3
      condition_D :q_AGE_ELIG, "==", :a_1
      condition_E :q_AGE_ELIG, "==", :a_3
      
      q_TIME_STAMP_6 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_6"
      a :datetime, :custom_class => "datetime"
    
      label "We are asking women of childbearing age a few questions about pregnancy. Not all women who answer 
      these questions will be able to take part in the National Children’s Study now, but almost every woman who 
      answers these questions will have a chance to take part in some way in the future. We first want to know..."
    
      q_PREGNANT "Are you pregnant now?",
      :help_text => "If adult is known to be pregnant, add \"Just to confirm,\"",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.PREGNANT"
      a_1 "Yes"
      a_2 "No, no additional information provided"
      a_3 "No, recently lost pregnancy (miscarriage/abortion) - (if volunteered by respondent)"
      a_4 "No, recently gave birth - (if volunteered by respondent)"
      a_5 "No, unable to have children (hysterectomy, tubal ligation) - (if volunteered by respondent)" 
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    end
    
    # TODO
    # PROGRAMMER INSTRUCTION:
    # • CHECK REPORTED DUE DATE AGAINST CURRENT DATE; DISPLAY APPROPRIATE MESSAGE:
    # - IF DATE IS MORE THAN 9 MONTHS AFTER CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE 
    # THAT IS MORE THAN 9 MONTHS FROM TODAY. RE-ENTER DATE.” 
    # - IF DATE IS MORE THAN 1 MONTH BEFORE CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE 
    # THAT OCCURRED MORE THAN A MONTH BEFORE TODAY. RE-ENTER DATE.” 
    
    q_ORIG_DUE_DATE "Congratulations. When is your baby due?",
    :help_text => "Check reported due date against current date. If response was determined to be invalid, ask question 
    again and probe for valid response. Reject responses that are either more than 9 months after current date or 
    more than 1 month before current date.",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.ORIG_DUE_DATE"
    a_1 "Due date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PREGNANT, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF RESPONDENT PROVIDED VALID DATE IN ORIG_DUE_DATE SKIP TO TIME_STAMP_8.
    # • CHECK REPORTED MENSTRUAL DATE AGAINST CURRENT DATE; DISPLAY APPROPRIATE MESSAGE:
    # - IF DATE IS MORE THAN 10 MONTHS BEFORE CURRENT DATE, DISPLAY 
    # INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT IS MORE THAN 10 MONTHS BEFORE TODAY. CONFIRM DATE. IF DATE IS CORRECT, ENTER ‘DON’T KNOW’.” 
    # - IF DATE IS AFTER CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT HAS NOT OCCURRED YET. RE-ENTER DATE.” 
    # -   IF VALID DATE WAS PROVIDED, CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET ORIG_DUE_DATE YYYYMMDD = DATE_PERIOD + 280 DAYS; GO TO /TIME_STAMP_8; SET PPG_FIRST = 1
    # - IF NO VALID DATE IS GIVEN → GO TO WEEKS_PREG.

    q_DATE_PERIOD "What was the first day of your last menstrual period?",
    :help_text => "Check reported menstrual date against current date. If response was determined to be invalid, ask question 
    again and probe for valid response. Reject responses that are either > 10 months or after current date.",    
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.DATE_PERIOD"
    a_1 "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PREGNANT, "==", :a_1
    
    # TODO
    #     PROGRAMMER INSTRUCTIONS:
    #     • REJECT RESPONSES THAT ARE EITHER < 1 WEEK OR GREATER THAN 43 WEEKS.
    #     • IF VALID RESPONSE WAS PROVIDED, CALCULATE ORIG_DUE_DATE YYYYMMDD=TODAY’S DATE + 280 DAYS – WEEKS_PREG *7; GO TO TIME_STAMP_8; SET PPG_FIRST = 1.
    #     • IF NO VALID DATE IS CALCULABLE → GO TO MONTH_PREG
    
    q_WEEKS_PREG "How many weeks pregnant are you now? If you’re not sure, please make your best guess.",
    :help_text => "Reject responses that are either < 1 week or greater than 43 weeks. If response was determined to be invalid, 
    ask question again and probe for valid response.",    
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.WEEKS_PREG"
    a_1 "Number of weeks", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_DATE_PERIOD, "!=", :a_1
    
    # TODO
    #     PROGRAMMER INSTRUCTIONS:
    #     • REJECT RESPONSES THAT ARE EITHER < 1 MONTH OR GREATER THAN 12 MONTHS
    #     • IF VALID RESPONSE WAS PROVIDED, CALCULATE DUE DATE AS FROM NUMBER OF MONTHS PREGNANT WHERE 
    # ORIG_DUE_DATEYYYYMMDD=TODAY’S DATE + 280 DAYS –MONTH_PREG*30 -15; GO TO DE001/TIME_STAMP_8; SET PPG_FIRST = 1
    #     •	IF NO VALID RESPONSE IS CALCULABLE → GO TO PS011 TRIMESTER.
    
    q_MONTH_PREG "How many months pregnant are you now? If you’re not sure, please make your best guess.",
    :help_text => "Reject responses that are either < 1 month or greater than 12 months. If response was determined to be invalid, 
    ask question again and probe for valid response.",    
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.MONTH_PREG"
    a_1 "Number of months", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_WEEKS_PREG, "!=", :a_1
    
    # TODO
    # PROGRAMMER INSTRUCTION: 
    # • CALCULATE DUE DATE AS FROM REPORTED TRIMESTER 
    # • 1ST TRIMESTER: ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 46 DAYS).
    # • 2ND TRIMESTER: ORIG_DUE_DATE = TODAY’S DATE +(280 DAYS – 140 DAYS).
    # • 3RD TRIMESTER: ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 235 DAYS).
    # • DON’T KNOW/REFUSED: ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS).
    # • SET ORIG_DUE_DATE = YYYYMMDD AS CALCULATED.
    # • SET PPG_FIRST = 1.
    
    q_TRIMESTER "Are you currently in your First, Second, or Third trimester?",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.TRIMESTER"
    a_1 "1st trimester (1-3 months pregnant)"
    a_2 "2nd trimester (4-6 months pregnant)"
    a_3 "3rd trimester (7-9 months pregnant)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_MONTH_PREG, "!=", :a_1

    group "Additional questions" do
      dependency :rule=>"(A and (B or C or D))"
      condition_A :q_AGE_ELIG, "==", :a_1
      condition_B :q_PREGNANT, "==", :a_2
      condition_C :q_PREGNANT, "==", :a_neg_1
      condition_D :q_PREGNANT, "==", :a_neg_2
      
      q_TIME_STAMP_7 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_7"
      a :datetime, :custom_class => "datetime"

      q_TRYING "Are you currently trying to become pregnant?",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.TRYING"
      a_1 "Yes"
      a_2 "No, no additional information provided"
      a_3 "No, recently lost pregnancy (miscarriage or abortion)"
      a_4 "No, recently gave birth"
      a_5 "No, unable to have children (hysterectomy, tubal ligation)"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    end
    
    q_HYSTER "Do any of the following apply to you? Have you had your uterus removed, sometimes called a hysterectomy?",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.HYSTER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A or B or C or D) or (E and F)"
    condition_A :q_TRYING, "==", :a_2
    condition_B :q_TRYING, "==", :a_5
    condition_C :q_TRYING, "==", :a_neg_1
    condition_D :q_TRYING, "==", :a_neg_2
    condition_E :q_PREGNANT, "==", :a_5
    condition_F :q_AGE_ELIG, "==", :a_1
    
    q_OVARIES "Both ovaries removed?",
    :help_text => "Read if necessary: Have you had...",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.OVARIES"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_HYSTER, "!=", :a_1
    
    q_TUBES_TIED "Your tubes tied?",
    :help_text => "Read if necessary: Have you had...",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.TUBES_TIED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_OVARIES, "!=", :a_1
    
    q_MENOPAUSE "Stopped having your period or gone through menopause?",
    :help_text => "Read if necessary: Have you had...",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.MENOPAUSE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_TUBES_TIED, "!=", :a_1
    
    q_MED_UNABLE "Is there any other medical reason why you believe you cannot become pregnant?",
    :help_text => "Read if necessary: Have you had...",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.MED_UNABLE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_MENOPAUSE, "!=", :a_1
    
    q_MED_UNABLE_OTH "Specify other medical reason",
    :pick => :one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.MED_UNABLE_OTH"
    a_1 "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_MED_UNABLE, "==", :a_1
  end
  section "Demographic questions", :reference_identifier=>"PregScreen_INT" do 
    group "Demographic information" do
      dependency :rule=>"(A or B or C) and (D or E)"
      condition_A :q_DU_ELIG_CONFIRM, "==", :a_1
      condition_B :q_DU_ELIG_CONFIRM, "==", :a_2
      condition_C :q_DU_ELIG_CONFIRM, "==", :a_3
      condition_D :q_AGE_ELIG, "==", :a_1
      condition_E :q_AGE_ELIG, "==", :a_3

      q_TIME_STAMP_8 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_8"
      a :datetime, :custom_class => "datetime"
    
      label "I’m so sorry about your loss. I have some additional questions to ask if that is okay.", 
      :help_text => "If using showcards, refer respondent to appropriate showcard. Otherwise, read response categories to respondent."
      dependency :rule => "(A and B) or C"
      condition_A :q_PREGNANT, "==", :a_3
      condition_B :q_AGE_ELIG, "==", :a_1
      condition_C :q_TRYING, "==", :a_3
    
      q_MARISTAT "I’d like to ask about your marital status. Are you:",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.MARISTAT"
      a_1 "Married,"
      a_2 "Not married but living together with a partner"
      a_3 "Never been married"
      a_4 "Divorced,"
      a_5 "Separated"
      a_6 "Widowed,"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_EDUC "What is the highest degree or level of school you have completed?",
      :help_text => "If using showcards, refer respondent to appropriate showcard. Otherwise, read response categories to respondent.",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.EDUC"
      a_1 "Less Than a High School Diploma or GED"
      a_2 "High School Diploma or GED"
      a_3 "Some College But No Degree"
      a_4 "Associate Degree"
      a_5 "Bachelor’s Degree (e.g., BA, BS)"
      a_6 "Post Graduate Degree (E.g., Masters or Doctoral)"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_EMPLOY "Last week were you working full time, part time, going to school, keeping house, or something else?",
      :help_text => "Probe as needed.",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.EMPLOY"
      a_1 "Working full time"
      a_2 "Working part time"
      a_3 "With a job, but not at work because of temporary illness, vacation, strike"
      a_4 "Unemployed/laid off/looking for work"
      a_5 "Retired"
      a_6 "In school"
      a_7 "Keeping house"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_EMPLOY_OTH "Other emplyment",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.EMPLOY_OTH"    
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      dependency :rule=>"A"
      condition_A :q_EMPLOY, "==", :a_5
    
      q_ETHNICITY "Do you consider yourself to be Hispanic, or Latina?",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.ETHNICITY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_RACE "What race do you consider yourself to be? You may select one or more.", 
      :help_text => "If using showcards, refer respondent to appropriate showcard. 
      Otherwise, read response categories to respondent.
      Select all that apply. Probe: Anything else? Code \"Other\" only if volunteered.",
      :pick => :any,
      :data_export_identifier=>"PREG_SCREEN_HI_RACE_2.RACE"
      a_1 "White,"
      a_2 "Black or African American,"
      a_3 "American Indian or Alaska Native,"
      a_4 "Asian, or"
      a_5 "Native Hawaiian or Other Pacific Islander?"
      a_6 "Multi-Racial"
      a_neg_5 "Some Other Race?"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_RACE_OTH "Other race",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_RACE_2.RACE_OTH"    
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      dependency :rule=>"A or B or C"
      condition_A :q_RACE, "==", :a_neg_5
      condition_B :q_RACE, "==", :a_neg_1
      condition_C :q_RACE, "==", :a_neg_2
    
      q_PERSON_LANG "What is the primary language spoken in your home?",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.PERSON_LANG"
      a_1 "English"
      a_2 "Spanish"
      a_3 "Arabic"
      a_4 "Chinese"
      a_5 "French"
      a_6 "French creole"
      a_7 "German"
      a_8 "Italian"
      a_9 "Korean"
      a_10 "Polish"
      a_11 "Russian"
      a_12 "Tagalog"
      a_13 "Vietnamese"
      a_14 "Urdu"
      a_15 "Punjabi"
      a_16 "Bengali"
      a_17 "Farsi"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_PERSON_LANG_OTH "Other primary language", 
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.PERSON_LANG_OTH"    
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      dependency :rule=>"A"
      condition_A :q_PERSON_LANG, "==", :a_neg_5
    
      q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"
    
      # TODO
      # PROGRAMMER INSTRUCTION: 
      #       • PRELOAD CURRENT YEAR – 1.
    
      label "Now I’m going to ask a few questions about your income. Family income is important in analyzing the data we collect and 
      is often used in scientific studies to compare groups of people who are similar. Please remember that all the information you 
      provide is confidential. Please think about your total combined family income during {CURRENT YEAR – 1} for all members of the family."
    
      q_HH_MEMBERS "How many household members are supported by your total combined family income?",
      :help_text => "Response must be > 0 and < 15",
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.HH_MEMBERS"    
      a_1 "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      # TODO
      # THE VALIDATION BELOW SHOULD TAKE PLACE, BUT WE DON'T SUPPORT INTEGER FORMAT IN ANSWERS YET
      q_NUM_CHILD "How many of those people are children? Please include anyone under 18 years or anyone 
      older than 18 years and in high school.", 
      :help_text => "Double check if the entry field for this question > than the answer above, or if responce is > 10",
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.NUM_CHILD"
      a_1 "Number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_INCOME_4CAT "Of these income groups, which category best represents your total combined family income during the last calendar year?",
      :help_text => "If using showcards, refer respondent to appropriate showcard. Otherwise, read response categories to respondent.",
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.INCOME_4CAT"
      a_1 "Less than $30,000"
      a_2 "$30,000 - $49,999"
      a_3 "$50,000 - $99,999"
      a_4 "$100,000 or more"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    end
  end
  section "Tracing questions", :reference_identifier=>"PregScreen_INT" do  
    group "Tracing questions" do
      dependency :rule=>"(A or B or C) and (D or E)"
      condition_A :q_DU_ELIG_CONFIRM, "==", :a_1
      condition_B :q_DU_ELIG_CONFIRM, "==", :a_2
      condition_C :q_DU_ELIG_CONFIRM, "==", :a_3
      condition_D :q_AGE_ELIG, "==", :a_1
      condition_E :q_AGE_ELIG, "==", :a_3
      
      q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_10"
      a :datetime, :custom_class => "datetime"
    
      label "These next few questions will help us to contact you again in the future."
    
      q_PHONE_NBR "What is the best phone number to reach you?",
      :help_text => "Enter phone number and confirm.",
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.PHONE_NBR"
      a_number "Phone number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      a_neg_7 "Respondent has no telephone/not applicable"
    end
    
    q_PHONE_NBR_OTH "Other phone number", 
    :help_text => "If respondent does not have a telephone number, ask where respondent receives telephone calls, 
    even if she does not have her own phone. Ask for and record that number",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.PHONE_NBR_OTH"    
    a_number "Phone number", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PHONE_NBR, "==", :a_neg_7
    
    q_PHONE_TYPE "Is that your home, work, cell, or another phone number?", 
    :help_text => "Confirm if known.",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.PHONE_TYPE"    
    a_1 "Home"
    a_2 "Work"
    a_3 "Cell"
    a_4 "Friend/relative"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A or B"
    condition_A :q_PHONE_NBR, "==", :a_number
    condition_B :q_PHONE_NBR_OTH, "==", :a_number
    
    q_PHONE_TYPE_OTH "Other - specify",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.PHONE_TYPE_OTH"     
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PHONE_TYPE, "==", :a_neg_5

    q_HOME_PHONE "What is your home phone number?",
    :help_text => "Enter phone number and confirm.",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.HOME_PHONE"
    a_number "Phone number", :string
    a_neg_7 "No home number"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PHONE_TYPE, "!=", :a_1
    
    q_CELL_PHONE_1 "Do you have a personal cell phone?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.CELL_PHONE_1"    
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PHONE_TYPE, "!=", :a_3
    
    q_CELL_PHONE_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.CELL_PHONE_2"    
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A or B"
    condition_A :q_CELL_PHONE_1, "==", :a_1
    condition_B :q_PHONE_TYPE, "==", :a_3
    
    q_CELL_PHONE_3 "Do you send and receive text messages on your personal cell phone?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.CELL_PHONE_3"    
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A or B"
    condition_A :q_CELL_PHONE_1, "==", :a_1
    condition_B :q_PHONE_TYPE, "==", :a_3
    
    q_CELL_PHONE_4 "May we send text messages to make future study appointments  or for appointment reminders?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.CELL_PHONE_4"    
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_CELL_PHONE_3, "==", :a_1
    
    q_CELL_PHONE "What is your personal cell phone number?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.CELL_PHONE"
    a_number "Phone number", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A and B"
    condition_A :q_PHONE_TYPE, "!=", :a_3
    condition_B :q_CELL_PHONE_1, "==", :a_1
    
    q_SAME_ADDR "Is your mailing address the same as your street address?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.SAME_ADDR"    
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A or B or C) and (D or E)"
    condition_A :q_DU_ELIG_CONFIRM, "==", :a_1
    condition_B :q_DU_ELIG_CONFIRM, "==", :a_2
    condition_C :q_DU_ELIG_CONFIRM, "==", :a_3
    condition_D :q_AGE_ELIG, "==", :a_1
    condition_E :q_AGE_ELIG, "==", :a_3
    
    group "Address information" do
      dependency :rule=>"A"
      condition_A :q_SAME_ADDR, "!=", :a_1      
    
      label "What is your mailing address?",
      :help_text => "Prompt as necessary to complete information"

      q_MAIL_ADDRESS1 "Address 1 - street/PO Box", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.MAIL_ADDRESS1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_MAIL_ADDRESS2 "Address 2", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.MAIL_ADDRESS2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_MAIL_UNIT "Unit", :data_export_identifier=>"PREG_SCREEN_HI_2.MAIL_UNIT"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_MAIL_CITY "City", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.MAIL_CITY"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_MAIL_STATE "State", :display_type=>:dropdown, 
      :pick=>:one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.MAIL_STATE"
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

      q_MAIL_ZIP "ZIP Code", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.MAIL_ZIP"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_MAIL_ZIP4 "ZIP+4", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.MAIL_ZIP4"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    q_HAVE_EMAIL "Do you have an email address?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.HAVE_EMAIL"    
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A or B or C) and (D or E)"
    condition_A :q_DU_ELIG_CONFIRM, "==", :a_1
    condition_B :q_DU_ELIG_CONFIRM, "==", :a_2
    condition_C :q_DU_ELIG_CONFIRM, "==", :a_3
    condition_D :q_AGE_ELIG, "==", :a_1
    condition_E :q_AGE_ELIG, "==", :a_3
    
    q_EMAIL "What is the best email address to reach you?",
    :help_text => "Show example of valid email address such as maryjane@email.com.",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.EMAIL"    
    a_email "Enter e-mail address:", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_HAVE_EMAIL, "==", :a_1
    
    q_EMAIL_TYPE "Is that your personal e-mail, work e-mail, or a family or shared e-mail address?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.EMAIL_TYPE"
    a_1 "Personal"
    a_2 "Work"
    a_3 "Family/shared"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_EMAIL, "==", :a_email
    
    # TODO
    # PROGRAMMER INSTRUCTION: 
    # IF RESPONDENT REPORTED A SHARED EMAIL ADDRESS IN EMAIL_TYPE, SET EMAIL_SHARE AS APPROPRIATE THEN GO TO TR016/PLAN_MOVE.
    
    # --- My comment --- WHY DO WE NEED EMAIL_SHARE IF IT'S ANSWERED IN EMAIL_TYPE
    q_EMAIL_SHARE "Is shared?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.EMAIL_SHARE"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_EMAIL_TYPE, "==", :a_3
    
    q_PLAN_MOVE "Do you plan on moving from your present address in the next few months?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.PLAN_MOVE"
    a_1 "Yes"
    a_2 "No"   
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A or B or C) and (D or E)"
    condition_A :q_DU_ELIG_CONFIRM, "==", :a_1
    condition_B :q_DU_ELIG_CONFIRM, "==", :a_2
    condition_C :q_DU_ELIG_CONFIRM, "==", :a_3
    condition_D :q_AGE_ELIG, "==", :a_1
    condition_E :q_AGE_ELIG, "==", :a_3
    
    q_WHERE_MOVE "Do you know where you will be moving?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.WHERE_MOVE"
    a_1 "Yes"
    a_2 "No"   
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PLAN_MOVE, "==", :a_1
    
    q_MOVE_INFO "What is the address of your new home?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.MOVE_INFO"
    a_1 "Address known"
    a_2 "Out of the country"
    a_3 "PO Box address only"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_WHERE_MOVE, "==", :a_1
    
    group "New address information" do
      dependency :rule=>"A or B"
      condition_A :q_MOVE_INFO, "==", :a_1
      condition_B :q_MOVE_INFO, "==", :a_3

      q_NEW_ADDRESS_VARIABLES "Enter address",
      :help_text => "Probe and enter as much information as R knows.",
      :pick => :one
      a_1 "Enter response"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEW_ADDRESS1 "Address 1 - street/PO Box", 
      :pick => :one,
      :data_export_identifier=>"PREG_SCREEN_HI_2.NEW_ADDRESS1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEW_ADDRESS2 "Address 2", 
      :pick => :one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.NEW_ADDRESS2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEW_UNIT "Unit", 
      :pick => :one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.NEW_UNIT"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEW_CITY "City", 
      :pick => :one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.NEW_CITY"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEW_STATE "State", :display_type=>:dropdown, 
      :pick => :one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.NEW_STATE"
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

      q_NEW_ZIP "ZIP Code", 
      :pick => :one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.NEW_ZIP"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEW_ZIP4 "ZIP+4", 
      :pick => :one,    
      :data_export_identifier=>"PREG_SCREEN_HI_2.NEW_ZIP4"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    q_WHEN_MOVE "Do you know when you will be moving?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.WHEN_MOVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PLAN_MOVE, "==", :a_1
    
    q_DATE_MOVE "When will you move?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.DATE_MOVE"
    a_date "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_WHEN_MOVE, "==", :a_1
  end
  section "Closing statements", :reference_identifier=>"PregScreen_INT" do        
    q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_11"
    a :datetime, :custom_class => "datetime"
    dependency :rule=>"A"
    condition_A :q_AGE_ELIG, "!=", :a_neg_6    
    
    # TODO
    #     PROGRAMMER INSTRUCTION:
    #     • IF DU_ELIG_CONFIRM = 3 UNKNOWN AND NEW INFORMATION IS RECORDED IN MAILING ADDRESS VARIABLES 
    #     OR NEW ADDRESS VARIABLES UPDATE DU_ELIG_CONFIRM TO REFLECT THIS INFORMATION.
    
    group "PPG First = 1" do
      dependency :rule=> "A"
      condition_A :q_PREGNANT, "==", :a_1
      
      label_PPG_FIRST_STATUS_PREG_1 "Status: Pregnant and Eligible",
      :data_export_identifier=>"PREG_SCREEN_HI_2.PPG_FIRST"

      label "Thank you for taking the time to answer these questions. You are able to be part of this important study. 
      I would like to tell you more about it and give you all the information you need to decide if you would like 
      to be part of the study. "
    end

    group "PPG First = 2" do
      dependency :rule=> "A and B"
      condition_A :q_PREGNANT, "==", :a_2
      condition_B :q_TRYING, "==", :a_1
      
      label_PPG_FIRST_STATUS_TRYING_2 "Status: High probability - trying to conceive",
      :data_export_identifier=>"PREG_SCREEN_HI_2.PPG_FIRST"

      label "Thank you for taking the time to answer these questions. You are able to be part of this important study 
      because you are currently trying to become pregnant. I would like to tell you more about it and give you all the 
      information you need to decide if you would like to be part of the study"
    end

    group "PPG First = 3" do
      dependency :rule=> "(A and B) or C"
      condition_A :q_PREGNANT, "==", :a_3
      condition_B :q_AGE_ELIG, "==", :a_1    
      condition_C :q_TRYING, "==", :a_3

      label_PPG_FIRST_STATUS_RECENT_LOSS_3 "Status: High probability – recent pregnancy loss",
      :data_export_identifier=>"PREG_SCREEN_HI_2.PPG_FIRST"

      label "[I’m so sorry to hear that you’ve lost your baby. I know this can be a hard time.] Because your address 
      is in the study area, we may be back in touch at a later time to update your household information. Thank you 
      for taking the time to answer these questions. "
    end

    group "PPG First = 4" do 
      dependency :rule=> "(A and B) or C or D or E or F or G"
      condition_A :q_PREGNANT, "==", :a_4
      condition_B :q_AGE_ELIG, "==", :a_1 
      condition_C :q_TRYING, "==", :a_4
      condition_D :q_MED_UNABLE, "==", :a_1
      condition_E :q_MED_UNABLE, "==", :a_2
      condition_F :q_MED_UNABLE, "==", :a_neg_1
      condition_G :q_MED_UNABLE, "==", :a_neg_2
      
      label_PPG_FIRST_STATUS_OTHER_PROBABILITY_4 "Status: other probability – not pregnant and not trying",
      :data_export_identifier=>"PREG_SCREEN_HI_2.PPG_FIRST"

      label "Thank you for taking the time to answer these questions. We will contact you again in about three months 
      to ask a few quick questions and update your household information. "
    end
    
    group "PPG First = 5" do
      dependency :rule=> "A or (B and C) or D or E or F or G"
      condition_A :q_AGE_ELIG, "==", :a_2
      condition_B :q_AGE_ELIG, "==", :a_3
      condition_C :q_PREGNANT, "!=", :a_1
      condition_D :q_HYSTER, "==", :a_1
      condition_E :q_OVARIES, "==", :a_1
      condition_F :q_TUBES_TIED, "==", :a_1
      condition_G :q_MENOPAUSE, "==", :a_1
      
      label_PPG_FIRST_STATUS_INELIGIBLE_5 "Status: unable to conceive, age-ineligible",
      :data_export_identifier=>"PREG_SCREEN_HI_2.PPG_FIRST"
      
      label "Thank you for taking the time to answer these questions. Based on what you’ve told me, we will not ask you 
      to take part in the study. Because your address is in the study area, we may be back in touch at a later time to 
      update your household information."
    end

    group "PPG First = 6" do
      dependency :rule=> "A"
      condition_A :q_DU_ELIG_CONFIRM, "==", :a_2

      label_PPG_FIRST_STATUS_INELIGIBLE_UNIT_6 "Status: ineligible dwelling unit",
      :data_export_identifier=>"PREG_SCREEN_HI_2.PPG_FIRST"
    
      label "Thank you for taking the time to answer these questions. Based on what you’ve told me, we will not ask you 
      to take part in the study. Thank you for your time. "
    end
    
    q_BIO_FATHER_HOME "Does the biological father live with you?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.BIO_FATHER_HOME"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A"
    condition_A :q_PREGNANT, "==", :a_1
    
    q_PARTNER_TRYING "Since you say you are currently trying to become pregnant, do you have a husband with 
    whom you are trying to become a parent?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.PARTNER_TRYING"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A and B"
    condition_A :q_MARISTAT, "==", :a_1
    condition_B :q_TRYING, "==", :a_1
    
    q_PARTNER_TRYING_ALT "Since you say you are currently trying to become pregnant, do you have a husband with 
    whom you are trying to become a parent?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.PARTNER_TRYING"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A and B"
    condition_A :q_MARISTAT, "!=", :a_1    
    condition_B :q_TRYING, "==", :a_1
    
    q_BIOFATHER_RAISE "Will the biological father be living close by and participating 
    in the care and raising of this child?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.BIOFATHER_RAISE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A or B or C"
    condition_A :q_BIO_FATHER_HOME, "!=", :a_1
    condition_B :q_PARTNER_TRYING, "==", :a_1
    condition_C :q_PARTNER_TRYING_ALT, "==", :a_1
    
    q_BIOFATHER_RAISE_ALT "If you become pregnant, will the biological father be living close by and participating 
    in the care and raising of this child?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.BIOFATHER_RAISE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A or B or C"
    condition_A :q_BIO_FATHER_HOME, "!=", :a_1
    condition_B :q_PARTNER_TRYING, "!=", :a_1
    condition_C :q_PARTNER_TRYING_ALT, "!=", :a_1
    
    q_SOCFATHER_RAISE "Do you have a partner or significant other who will be participating in the care and 
    raising of this child?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.SOCFATHER_RAISE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A or B or C"
    condition_A :q_BIOFATHER_RAISE, "!=", :a_1
    condition_B :q_PARTNER_TRYING, "==", :a_1
    condition_C :q_PARTNER_TRYING_ALT, "==", :a_1
    
    q_SOCFATHER_RAISE_ALT "If you become pregnant, do you have a partner or significant other who will be participating 
    in the care and raising of this child?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.SOCFATHER_RAISE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A or B or C"
    condition_A :q_BIOFATHER_RAISE, "!=", :a_1
    condition_B :q_PARTNER_TRYING, "!=", :a_1
    condition_C :q_PARTNER_TRYING_ALT, "!=", :a_1
    
    q_FATHER_AVAIL "We would like to invite your husband to participate in the next interview. Will your husband be 
    available and willing to talk to us when we return to further discuss the National Children’s Study with you?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.FATHER_AVAIL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A and (B or C)"
    condition_A :q_MARISTAT, "==", :a_1
    condition_B :q_BIOFATHER_RAISE, "==", :a_1
    condition_C :BIO_FATHER_HOME, "==", :a_1
    
    q_FATHER_AVAIL_ALT "We would like to invite your partner or significant other to participate 
    in the next interview. Will your partner or significant other be available and willing to talk to us when we 
    return to further discuss the National Children’s Study with you?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.FATHER_AVAIL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A or B or C or D"
    condition_A :q_SOCFATHER_RAISE, "==", :a_1
    condition_B :q_SOCFATHER_RAISE_ALT, "==", :a_1
    condition_C :q_BIOFATHER_RAISE, "==", :a_1
    condition_D :BIO_FATHER_HOME, "==", :a_1
  end
  section "Conclusion", :reference_identifier=>"PregScreen_INT" do        
    q_TIME_STAMP_12 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_12"
    a :datetime, :custom_class => "datetime"
    dependency :rule => "A or B"
    condition_A :q_MALE_R, "==", :a_1 
    condition_B :q_R_GENDER, "==", :a_2 
    # TODO
    # PROGRAMMER INSTRUCTION: 
    # • PRELOAD LOCAL AGE OF MAJORITY.
    q_OTHER_FEMALE "Finally, are there any other women in your household who are age [LOCAL AGE OF MAJORITY] to 49 or pregnant?",
    :pick=>:one,
    :data_export_identifier=>"PREG_SCREEN_HI_2.OTHER_FEMALE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A or B"
    condition_A :q_MALE_R, "==", :a_1 
    condition_B :q_R_GENDER, "==", :a_2  

    # TODO
    #     PROGRAMMER INSTRUCTION: 
    #     •	IF OTHER_FEMALE = YES; LOOP BACK TO FEMALE_1 AND ATTEMPT TO COMPLETE ANOTHER PREGNANCY SCREENER 
    # WITH OTHER HOUSEHOLD MEMBER. REPEAT FOR EACH IDENTIFIED FEMALE.
    
    label_FEMALE_END_1 "Thank you again for your time."
    dependency :rule=> "A"
    condition_A :q_OTHER_FEMALE, "==", :a_2
 end
 section "Final interviewer-completed questions", :reference_identifier=>"PregScreen_INT" do        
   q_TIME_STAMP_13 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_13"
   a :datetime, :custom_class => "datetime"
   
   q_ENGLISH "Was this data collection session conducted in english?",
   :pick=>:one,
   :data_export_identifier=>"PREG_SCREEN_HI_2.ENGLISH"
   a_1 "Yes"
   a_2 "No"
   
   q_CONTACT_LANG "What other language was used to conduct this session?",
   :pick=>:one,
   :data_export_identifier=>"PREG_SCREEN_HI_2.CONTACT_LANG"
   a_1 "Spanish"
   a_2 "Arabic"
   a_3 "Chinese"
   a_4 "French"
   a_5 "French creole"
   a_6 "German"
   a_7 "Italian"
   a_8 "Korean"
   a_9 "Polish"
   a_10 "Russian"
   a_11 "Tagalog"
   a_12 "Vietnamese"
   a_13 "Urdu"
   a_14 "Punjabi"
   a_15 "Bengali"
   a_16 "Farsi"
   a_neg_5 "Other"
   dependency :rule=> "A"
   condition_A :q_ENGLISH, "==", :a_2
   
   q_CONTACT_LANG_OTH "Other language",
   :data_export_identifier=>"PREG_SCREEN_HI_2.CONTACT_LANG_OTH"
   a "Specify", :string
   dependency :rule=> "A"
   condition_A :q_CONTACT_LANG, "==", :a_neg_5
   
   q_INTERPRET "Was an interpreter used?",
   :pick=>:one,
   :data_export_identifier=>"PREG_SCREEN_HI_2.INTERPRET"
   a_1 "Yes"
   a_2 "No"
   
   q_CONTACT_INTERPRET "What type of interpreter was used?",
   :pick=>:one,
   :data_export_identifier=>"PREG_SCREEN_HI_2.CONTACT_INTERPRET"
   a_1 "Bilingual interviewer"
   a_2 "In-person professional interpreter"
   a_3 "In-person family member interpreter"
   a_4 "Language-line interpreter"
   a_5 "Video interpreter"
   a_6 "Sign language interpreter"
   a_neg_5 "Other"
   dependency :rule=> "A"
   condition_A :q_INTERPRET, "==", :a_1
   
   q_CONTACT_INTERPRET_OTH "Other type of interpreter",
   :data_export_identifier=>"PREG_SCREEN_HI_2.CONTACT_INTERPRET_OTH"
   a "Specify", :string
   dependency :rule=> "A"
   condition_A :q_CONTACT_INTERPRET, "==", :a_neg_5
   
   q_TIME_STAMP_14 "Insert date/time stamp", :data_export_identifier=>"PREG_SCREEN_HI_2.TIME_STAMP_14"
   a :datetime, :custom_class => "datetime"
   
   # TODO
   # PROGRAMMER INSTRUCTION:
   # •  IF DU_ELIG_CONFIRM = 3 (UNKNOWN) AND NEW INFORMATION IS RECORDED IN MAILING ADDRESS VARIABLES OR NEW 
   # ADDRESS VARIABLES, UPDATE DU_ELIG_CONFIRM TO REFLECT THIS INFORMATION.
   # 
   # PROGRAMMER INSTRUCTION: 
   # •  ATTEMPT TO ENROLL WOMEN WHO ARE PREGNANT OR TRYING TO BECOME PREGNANT, AND MEET AGE AND RESIDENCE ELIGIBILITY REQUIREMENTS.
   # o  IF PPG_FIRST = 1 AND AGE_ELIG = 1 OR 3 AND DU_ELIG_CONFIRM = 1 à GO TO APPROPRIATE CONSENT FORM FOR PREGNANT WOMEN.
   # o  IF PPG_FIRST = 2 AND AGE_ELIG = 1 AND DU_ELIG_CONFIRM = 1 → GO TO APPROPRIATE CONSENT FORM FOR NON-PREGNANT WOMEN.
 end
end