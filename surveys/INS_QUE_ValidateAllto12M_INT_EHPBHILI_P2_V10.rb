survey "INS_QUE_ValidateAllto12M_INT_EHPBHILI_P2_V1.0" do
  section "Interview introduction", :reference_identifier=>"ValidateAllto12M_INT" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    # TODO
    # •	PRELOAD NAME OF PARTICIPANT

    q_INTRO_1 "Hello, my name is [INTERVIEWER’S NAME] and I am calling on behalf of the National
    Children’s Study. May I please speak with [NAME OF PARTICIPANT]?",
    :help_text =>"When speaking to participant -- Repeat as needed. [Hello, my name is [INTERVIEWER’S NAME] and I
    am calling on behalf of the National Children’s Study.]",
    :pick => :one,
    :data_export_identifier=>"VALIDATION_INS.INTRO_1"
    a_1 "Yes"
    a_2 "No"
    a_3 "No such person at address/phone"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    # • INSERT PARTICIPANT BEST TELEPHONE NUMBER.
    q_VER_NUMBER "Just to verify, is this {TELEPHONE NUMBER FOR PARTICIPANT}?",
    :pick => :one,
    :data_export_identifier=>"VALIDATION_INS.VER_NUMBER"
    a_1 "Yes"
    a_2 "No"
    a_3 "No such person at address/phone"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_INTRO_1, "==", :a_3

    group "Additional information" do
      dependency :rule => "A and B"
      condition_A :q_INTRO_1, "!=", :a_1
      condition_B :q_INTRO_1, "!=", :a_3

      q_BEST_TTC_1 "What would be a good time to reach her?",
      :help_text => "Enter in hour and minute values",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.BEST_TTC_1"
      a_time "Time", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DAY_WEEK_1 "What would be a good day to reach her?",
      :help_text => "Enter in day(s) of week",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.DAY_WEEK_1"
      a_days_of_week "Day(s) of the week", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BEST_TTC_2 "Select AM or PM",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.BEST_TTC_2"
      a_am "AM"
      a_pm "PM"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BEST_TTC_3 "Additional info",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.BEST_TTC_3"
      a_am "After time reported"
      a_pm "Before time reported"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      #     PROGRAMMER INSTRUCTION:
      #     • PRELOAD NAME OF PARTICIPANT
      q_PHONE "Is this a good phone number to reach [PARTICIPANT’S NAME]?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PHONE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    q_PHONE_NBR "Would you please tell me a telephone number where she can be reached?",
    :pick => :one,
    :data_export_identifier=>"VALIDATION_INS.PHONE_NBR"
    a_phone "Phone number", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_PHONE, "!=", :a_1

    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
    dependency :rule => "A"
    condition_A :q_INTRO_1, "==", :a_1
  end
  section "Participant identification", :reference_identifier=>"ValidateAllto12M_INT" do

    # TODO
    # [WHEN SPEAKING TO PARTICIPANT]
    # INTERVIEWER INSTRUCTION:
    # • REPEAT AS NEEDED. [Hello, my name is [INTERVIEWER’S NAME] and I am calling on behalf of the National Children’s Study.]
    # Nataliya's comment - I included that into very fisrt question q_INTRO_1 under help_text

    q_INTRO_2 "You recently spoke with one of our staff members. We routinely re-contact some people to see if
    circumstances have changed.",
    :pick => :one,
    :data_export_identifier=>"VALIDATION_INS.INTRO_2"
    a_1 "Continue"
    a_2 "R states that no interview took place"
    dependency :rule => "A"
    condition_A :q_INTRO_1, "==", :a_1

    q_SCHEDULE "I’m sorry for the misunderstanding. May I schedule a time with you to complete that interview?",
    :pick => :one,
    :data_export_identifier=>"VALIDATION_INS.SCHEDULE"
    a_1 "Yes"
    a_2 "No"
    dependency :rule => "A"
    condition_A :q_INTRO_2, "==", :a_2

    # TODO
    #     INTERVIEWER INSTRUCTION:
    #     •	SCHEDULE INTERVIEW WITH PARTICIPANT, THEN SKIP TO TIME_STAMP_17
    # Nataliya's comment - where is that take place? How do they schedule that?

    q_INTRO_3 "Is this a good time to talk?",
    :pick => :one,
    :data_export_identifier=>"VALIDATION_INS.INTRO_3"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_SCHEDULE, "==", :a_1

    group "Schedule information" do
      dependency :rule => "A"
      condition_A :q_INTRO_3, "==", :a_2

      q_R_BEST_TTC_1 "What would be a better time for you?",
      :help_text => "Enter in hour and minute values",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.R_BEST_TTC_1"
      a_time "Time", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DAY_WEEK_2 "What would be a better day to reach her?",
      :help_text => "Enter in day(s) of week",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.DAY_WEEK_2"
      a_days_of_week "Day(s) of the week", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_R_BEST_TTC_2 "Select AM or PM",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.R_BEST_TTC_2"
      a_am "AM"
      a_pm "PM"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_R_BEST_TTC_3 "Additional info",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.R_BEST_TTC_3"
      a_am "After time reported"
      a_pm "Before time reported"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Privacy statement", :reference_identifier=>"ValidateAllto12M_INT" do
    group "Privacy statement" do
      dependency :rule => "A"
      condition_A :q_INTRO_3, "!=", :a_2

      q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_3"
      a :datetime, :custom_class => "datetime"

      label "All information will be kept private and used for Study purposes only. You may refuse to answer
      any question or stop at any time."

      # TODO
      #     PROGRAMMER INSTRUCTION:
      #     •	PRELOAD NAME OF INTERVIEWER AND DAY/DATE OF INTERVIEW
      q_INT_CONFIRM "According to our records, [INTERVIEWER’S NAME] spoke with you on
      [DAY AND DATE OF INTERVIEW]. Do you remember speaking with our staff member?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.INT_CONFIRM"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # PROGRAMMER INSTRUCTION:
      # • SKIP TO NEXT QUESTION BASED ON WHICH INSTRUMENT WAS ADMINISTERED
      #   o HOUSEHOLD ENUMERATION → SKIP TO TIME_STAMP_4
      #   o PREGNANCY SCREENER → SKIP TO TIME_STAMP_5
      #   o INFORMED CONSENT → SKIP TO TIME_STAMP_6
      #   o PPG CALLS → SKIP TO TIME_STAMP_7
      #   o PRE-PREGNANCY → SKIP TO TIME_STAMP_8
      #   o FIRST PREGNANCY → SKIP TO TIME_STAMP_9
      #   o SECOND PREGNANCY → SKIP TO TIME_STAMP_10
      #   o BIRTH → SKIP TO TIME_STAMP_11
      #   o 3-MONTH → SKIP TO TIME_STAMP_12
      #   o 6-MONTH → SKIP TO TIME_STAMP_13
      #   o 9-MONTH → SKIP TO TIME_STAMP_14
      #   o 12-MONTH→ SKIP TO TIME_STAMP_15

      # WORK AROUND
      q_HOUSEHOLD_ENUMERATION "Household enumeration completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_PREGNANCY_SCREENER "Pregnancy screener completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_INFORMED_CONSENT "Informed consent completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_PPG_CALLS "PPG Calls completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_PRE_PREGNANCY "Pre-pregnancy completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_FIRST_PREGNANCY "First pregnancy completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_SECOND_PREGNANCY "Second pregnancy completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_BIRTH "Birth completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_3_MONTH "3-month completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_6_MONTH "6-month completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_9_MONTH "9-month completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"

      q_12_MONTH "12-month completed?",
      :pick => :one
      a_yes "Yes"
      a_no "No"
    end
  end
  section "Visit-specific items", :reference_identifier=>"ValidateAllto12M_INT" do
    group "Visit-specific items for household enumeration" do
      dependency :rule => "A"
      condition_A :q_HOUSEHOLD_ENUMERATION, "==", :a_yes

      q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_4"
      a :datetime, :custom_class => "datetime"

      q_HH_ENUM "Were you asked questions about the number of people who live at this address?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.HH_ENUM"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # PRELOAD [MONTH OF INTERVIEW] and [LOCAL AGE OF MAJORITY]
      q_NUM_FEMALE "In [MONTH OF INTERVIEW], how many women [LOCAL AGE OF MAJORITY] or older were living in your household?
      Please include anyone who usually stays there but was temporarily away on business, vacation, in the hospital,
      on full-time active military duty, or is a student temporarily living away from home. Do not include anyone
      who was in a nursing home or other institution.",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.NUM_FEMALE"
      a_num "Number of adult females", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    group "Visit-specific items for pregnancy screener" do
      dependency :rule => "A"
      condition_A :q_PREGNANCY_SCREENER, "==", :a_yes

      q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_5"
      a :datetime, :custom_class => "datetime"

      q_PREG_SCR "Were you asked if you or others in your household might be pregnant?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PREG_SCR"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_AGE "During [MONTH OF INTERVIEW] how old were you?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.AGE"
      a_age "Age", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    group "Visit-specific items for informed consent" do
      dependency :rule => "A"
      condition_A :q_INFORMED_CONSENT, "==", :a_yes

      q_TIME_STAMP_6 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_6"
      a :datetime, :custom_class => "datetime"

      q_INF_CONSENT "Were you given information about the National Children’s Study and asked if you would like to participate?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.INF_CONSENT"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INF_CONSENT2 "Were you given an opportunity to ask all the questions you had about joining the Study
      before being asked to agree to join?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.INF_CONSENT2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for ppg_calls" do
      dependency :rule => "A"
      condition_A :q_PPG_CALLS, "==", :a_yes

      q_TIME_STAMP_7 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_7"
      a :datetime, :custom_class => "datetime"

      q_PPG_CATI "Were you asked whether or not you were pregnant or trying to become pregnant?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PPG_CATI"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PPG_CATI2 "At that time were you pregnant or trying to become pregnant?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PPG_CATI2"
      a_1 "Yes"
      a_2 "No"
      a_3 "No, recent pregnancy loss"
      a_4 "No, recently gave birth"
      a_5 "No, unable to have children"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for pre-pregnancy" do
      dependency :rule => "A"
      condition_A :q_PRE_PREGNANCY, "==", :a_yes

      q_TIME_STAMP_8 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_8"
      a :datetime, :custom_class => "datetime"

      q_PREPREG "Were you asked if you have ever been pregnant?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PREPREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PREPREG2 "At that time had you ever been pregnant? Please include live births,
      miscarriages, stillbirths, ectopic pregnancies, and pregnancy terminations.",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PREPREG2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for first pregnancy" do
      dependency :rule => "A"
      condition_A :q_FIRST_PREGNANCY, "==", :a_yes

      q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"

      q_PREG1 "During that interview were you asked about your baby’s due date?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PREG1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HOME_TEST "Did you use a home pregnancy test to help find out you were pregnant?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.HOME_TEST"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    group "Visit-specific items for second pregnancy" do
      dependency :rule => "A"
      condition_A :q_SECOND_PREGNANCY, "==", :a_yes

      q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_10"
      a :datetime, :custom_class => "datetime"

      q_PREG2 "During that interview were you asked about where you planned to deliver your baby?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.PREG2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_OWN_HOME "During [MONTH OF INTERVIEW] was the home you were living in:",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.OWN_HOME"
      a_1 "Owned or being bought by you or someone in your household"
      a_2 "Rented by you or someone in your household, or"
      a_3 "Occupied without payment of rent?"
      a_neg_5 "Some other arrangement"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for birth" do
      dependency :rule => "A"
      condition_A :q_BIRTH, "==", :a_yes

      q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_11"
      a :datetime, :custom_class => "datetime"

      q_BIRTH "Were you asked about where in your home you planned for the baby to sleep?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.BIRTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_VACCINE "At that time did you plan for your baby to have well-baby shots or vaccinations?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.VACCINE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for 3 months" do
      dependency :rule => "A"
      condition_A :q_3_MONTH, "==", :a_yes

      q_TIME_STAMP_12 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_12"
      a :datetime, :custom_class => "datetime"

      q_CHILDSLP "Were you asked about your baby’s sleeping habits?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.CHILDSLP"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_VCHILDCARE "Were you asked about your arrangements for child care?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.VCHILDCARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for 6 months" do
      dependency :rule => "A"
      condition_A :q_6_MONTH, "==", :a_yes

      q_TIME_STAMP_13 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_13"
      a :datetime, :custom_class => "datetime"

      q_SIX_MONTH "Were you asked about your baby’s health?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.SIX_MONTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INSURE "During [MONTH OF INTERVIEW] was your baby covered by any kind of health insurance or some other health care plan?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.INSURE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for 9 months" do
      dependency :rule => "A"
      condition_A :q_9_MONTH, "==", :a_yes

      q_TIME_STAMP_14 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_14"
      a :datetime, :custom_class => "datetime"

      q_CHILDSKILL "Were you asked about things that your baby could do like following you with his or her eyes?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.CHILDSKILL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_R_HCARE "At that time, what kind of place did your baby usually go to when your baby needed
      routine or well-child care, such as a check-up or well-baby shots (immunizations)?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.R_HCARE"
      a_1 "Clinic or health center"
      a_2 "Doctor's office or Health Maintenance Organization (HMO)"
      a_3 "Hospital emergency room"
      a_4 "Hospital outpatient department"
      a_5 "Some other place"
      a_6 "Doesn't go to one place most often"
      a_7 "Doesn't get well-child care anywhere"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Visit-specific items for 12 months" do
      dependency :rule => "A"
      condition_A :q_12_MONTH, "==", :a_yes

      q_TIME_STAMP_15 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_15"
      a :datetime, :custom_class => "datetime"

      q_TWELVE_MONTH "Were you asked about your baby’s personality?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.TWELVE_MONTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CHILDCARE "During [MONTH OF INTERVIEW], did your baby receive any regularly scheduled care from someone other
      than a parent or guardian, for example, from relatives, friends, or other non-relatives, or a child care center or program?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.CHILDCARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    q_TIME_STAMP_16 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_16"
    a :datetime, :custom_class => "datetime"
    dependency :rule => "A or B or C or D or E or F or G or H or I or J or K or L"
    condition_A :q_HOUSEHOLD_ENUMERATION, "==", :a_yes
    condition_B :q_PREGNANCY_SCREENER, "==", :a_yes
    condition_C :q_INFORMED_CONSENT, "==", :a_yes
    condition_D :q_PPG_CALLS, "==", :a_yes
    condition_E :q_PRE_PREGNANCY, "==", :a_yes
    condition_F :q_FIRST_PREGNANCY, "==", :a_yes
    condition_G :q_SECOND_PREGNANCY, "==", :a_yes
    condition_H :q_BIRTH, "==", :a_yes
    condition_I :q_3_MONTH, "==", :a_yes
    condition_J :q_6_MONTH, "==", :a_yes
    condition_K :q_9_MONTH, "==", :a_yes
    condition_L :q_12_MONTH, "==", :a_yes
  end
  section "Interviewer quality", :reference_identifier=>"ValidateAllto12M_INT" do
    group "Interviewer quality" do
      dependency :rule => "A or B or C or D or E or F or G or H or I or J or K or L"
      condition_A :q_HOUSEHOLD_ENUMERATION, "==", :a_yes
      condition_B :q_PREGNANCY_SCREENER, "==", :a_yes
      condition_C :q_INFORMED_CONSENT, "==", :a_yes
      condition_D :q_PPG_CALLS, "==", :a_yes
      condition_E :q_PRE_PREGNANCY, "==", :a_yes
      condition_F :q_FIRST_PREGNANCY, "==", :a_yes
      condition_G :q_SECOND_PREGNANCY, "==", :a_yes
      condition_H :q_BIRTH, "==", :a_yes
      condition_I :q_3_MONTH, "==", :a_yes
      condition_J :q_6_MONTH, "==", :a_yes
      condition_K :q_9_MONTH, "==", :a_yes
      condition_L :q_12_MONTH, "==", :a_yes

      q_COMMENT "Would you like to tell me anything else about your experience, the interviewer, or the interview itself?",
      :pick => :one,
      :data_export_identifier=>"VALIDATION_INS.COMMENT"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_COMMENT_OTH "Other comments",
      :help_text => "Enter participant comments as text field",
      :data_export_identifier=>"VALIDATION_INS.COMMENT_OTH"
      a_txt :text
      dependency :rule => "A"
      condition_A :q_COMMENT, "==", :a_1
    end
    q_TIME_STAMP_17 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_17"
    a :datetime, :custom_class => "datetime"
  end
  # • SKIP TO CLOSING STATEMENT BASED ON THE RESPONSES BELOW
  # o IF INTRO_1 = 3 → SKIP TO CS001.
  # o IF PHONE = 1, 2, -1, -2 → SKIP TO CS002.
  # o IF INTRO_2= 2 and SCHEDULE=2→ SKIP TO CS005.IF SCHEDULE = 1 → SKIP TO CS003.
  # o ELSE →SKIP TO CS004.
  section "Closing statements", :reference_identifier=>"ValidateAllto12M_INT" do
    # TODO
    #     PREPOPULATE [LOCAL SC TOLL-FREE NUMBER]
    label "I apologize for bothering you. I have the wrong number. Thank you for your time. If you have any
    questions, please contact us at [LOCAL SC TOLL-FREE NUMBER]."
    dependency :rule => "A"
    condition_A :q_INTRO_1, "==", :a_3

    label "Thank you again for speaking with me today. Please ask her to call us at [LOCAL SC TOLL-FREE NUMBER].
    I will try her at the number you gave me."
    dependency :rule => "(A or B or C or D) and E"
    condition_A :q_PHONE, "==", :a_1
    condition_B :q_PHONE, "==", :a_2
    condition_C :q_PHONE, "==", :a_neg_1
    condition_D :q_PHONE, "==", :a_neg_2
    condition_E :q_PHONE_NBR, "==", :a_phone

    label "Thank you again for speaking with me today. Please ask her to call us at [LOCAL SC TOLL-FREE NUMBER]."
    dependency :rule => "(A or B or C or D) and E"
    condition_A :q_PHONE, "==", :a_1
    condition_B :q_PHONE, "==", :a_2
    condition_C :q_PHONE, "==", :a_neg_1
    condition_D :q_PHONE, "==", :a_neg_2
    condition_E :q_PHONE_NBR, "!=", :a_phone

    label "Thank you for your time. I will call back again. [IF CALLBACK TIME OBTAINED: at the time you requested].
    If you have any questions, please contact us at [LOCAL SC TOLL-FREE NUMBER]. Goodbye."
    dependency :rule => "A and B"
    condition_A :q_INTRO_2, "==", :a_2
    condition_B :q_SCHEDULE, "==", :a_1

    label "Thank you so much for your time. If you have any questions, please contact us at [LOCAL SC TOLL-FREE NUMBER]. Goodbye."
    dependency :rule => "A and B"
    condition_A :q_INTRO_2, "==", :a_2
    condition_B :q_SCHEDULE, "==", :a_2

    label "Those are all the questions I have. Thank you so much for your time and cooperation. If you have any questions,
    please contact us at [LOCAL SC TOLL-FREE NUMBER]. Goodbye."
    dependency :rule => "A and B"
    condition_A :q_INTRO_1, "!=", :a_3
    condition_B :q_INTRO_2, "!=", :a_2

    label "End interview and disposition case as appropriate"

    q_TIME_STAMP_18 "Insert date/time stamp", :data_export_identifier=>"VALIDATION_INS.TIME_STAMP_18"
    a :datetime, :custom_class => "datetime"
  end
end
