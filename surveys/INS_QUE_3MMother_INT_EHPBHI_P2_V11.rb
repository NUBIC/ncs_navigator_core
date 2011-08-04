survey "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1" do
  section "INTERVIEW INTRODUCTION", :reference_identifier=>"THREE_MTH_MOTHER" do

    q_time_stamp_1 "INSERT DATE/TIME STAMP", :data_export_identifier=>"THREE_MTH_MOTHER.TIME_STAMP_1"
    a :datetime

    label "Hello. I’m [INTERVIEWER NAME] calling from the National Children’s Study. I’m calling today to ask you 
    some questions about you and your baby. We realize that you are busy, and this call should take only about 20 minutes. 
    I will ask you questions about your baby’s health and behavior and your household. Your answers are very important to us. 
    There are no right or wrong answers. You can skip over any question or stop the interview at any time. We will keep 
    everything that you tell us confidential."
  end
  section "INTERVIEWER COMPLETED QUESTIONS", :reference_identifier=>"THREE_MTH_MOTHER" do
    q_mult_child "IS THERE MORE THAN ONE CHILD IN THIS HOUSEHOLD ELIGIBLE FOR THE 3-MONTH CALL TODAY?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER.MULT_CHILD"
    a_1 "YES"
    a_2 "NO"
    
    q_CHILD_NUM "HOW MANY CHILDREN IN THIS HOUSEHOLD ARE ELIGIBLE FOR THE 3-MONTH CALL TODAY?", 
    :data_export_identifier=>"THREE_MTH_MOTHER.CHILD_NUM"
    a "NUMBER OF CHILDREN", :integer
    
    # PROGRAMMER INSTRUCTION: 
    # • CHILD_QNUM CANNOT BE GREATER THAN CHILD_NUM
        
    q_CHILD_QNUM "WHICH NUMBER CHILD IS THIS QUESTIONNAIRE FOR?", 
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_QNUM"
    a "NUMBER", :integer
    
    q_CHILD_SEX "IS THE CHILD A MALE OR FEMALE?",:pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_SEX"
    a_1 "MALE"
    a_2 "FEMALE"
    a_3 "BOTH"
    
    # PROGRAMMER INSTRUCTIONS: 
    # • IF CHILD_SEX = 1, DISPLAY “his” AND “he” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT
    # • IF CHILD_SEX = 2, DISPLAY “her” AND “she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 3, DISPLAY “him/her” AND “he/she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    
    q_RESP_REL "WHAT IS THE RELATIONSHIP OF PARTICIPANT TO CHILD?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.RESP_REL"
    a_1 "MOTHER"
    a_2 "FATHER"
    a_3 "OTHER"
    
    q_RESP_REL_OTH "OTHER RELATIONSHIP", 
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.RESP_REL_OTH"
    a_1 "SPECIFY", :string
    dependency :rule=>"A"
    condition_A :q_RESP_REL, "==", :a_3
  end
  section "PARTICIPANT VERIFICATION", :reference_identifier=>"THREE_MTH_MOTHER" do
    label "First, we’d like to make sure we have your child’s correct name and birth date."
    
    q_prepopulated_baby_name "Baby's name:"
    a :string
    
    q_CNAME_CONFIRM "Is that your baby’s name?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CNAME_CONFIRM"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    label "What is your baby’s full name?
    <br><br><b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT REFUSES TO PROVIDE INFORMATION, RE-STATE CONFIDENTIALITY 
    PROTECTIONS, ASK FOR INITIALS OR SOME OTHER NAME SHE WOULD LIKE HER CHILD TO BE CALLED.<br><br>
    - CONFIRM SPELLING OF FIRST NAME IF NOT PREVIOUSLY COLLECTED AND OF LAST NAME FOR ALL CHILDREN."
    
    q_C_FNAME "FIRST NAME", :pick => :one, 
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.C_FNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_name_confirm, "!=", :a_1

    q_C_LNAME "LAST NAME", :pick => :one, 
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.C_LNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_name_confirm, "!=", :a_1
    
    # PROGRAMMER INSTRUCTION:
    # •	IF C_FNAME AND C_LNAME = -1 or -2, SUBSTITUTE “YOUR CHILD” FOR C_FNAME IN REMAINER OF QUESTIONNAIRE.
    
    
    q_prepopulated_childs_birth_date "Child's birth date"
    a :string
    
    # TODO: Is {C_FNAME/YOUR CHILD}’S birth date {CHILD’S DATE OF BIRTH}
    q_CDOB_CONFIRM "Is this YOUR CHILD’S birth date?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CDOB_CONFIRM"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    label "<br><br><b>INTERVIEWER INSTRUCTION:</b><br> 
    - IF PARTICIPANT REFUSES TO PROVIDE INFORMATION, RE-STATE CONFIDENTIALITY PROTECTIONS AND 
    THAT DOB HELPS DETERMINE ELIGIBILITY."    
    
    # PROGRAMMER INSTRUCTIONS:
    #     • PRELOAD CHILD_DOB COLLECTED AT BIRTH INTERVIEWAS MM/DD/YYYY.
    #     •	IF CDOB_CONFIRM =1, SET CHILD_DOB TO KNOWN VALUE.
    
    q_CHILD_DOB "What is {C_FNAME/YOUR CHILD}’s date of birth?",
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_DOB"
    a :date
    
    label "<b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT REFUSES TO PROVIDE INFORMATION, RE-STATE CONFIDENTIALITY PROTECTIONS AND THAT DOB HELPS DETERMINE ELIGIBILITY.
    - ENTER A TWO-DIGIT MONTH, TWO-DIGIT DAY, AND A FOUR-DIGIT YEAR.
    - IF RESPONSE WAS DETERMINED TO BE INVALID, ASK QUESTION AGAIN AND PROBE FOR VALID RESPONSE.
    "
    
    # TODO:
    #     PROGRAMMER INSTRUCTIONS:
    #     • INCLUDE A SOFT EDIT/WARNING IF CALCULATED AGE IS LESS THAN 2 MONTHS OR GREATER THAN 5 MONTHS.
    #     •	FORMAT CHILD_DOB AS YYYYMMDD.
    q_calculated_age "<b>INTERVIEWER INSTRUCTIONS:</b><br>CALCULATED AGE (months)?"
    a :integer
    
    label "IT APPEARS THAT THE CALCULATED AGE OF THE BABY IS LESS THAN 2 MONTHS OR GREATER THAN 5 MONTHS. PLEASE VERIFY"

    q_time_stamp_2 "INSERT DATE/TIME STAMP", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.TIME_STAMP_2"
    a :datetime
    
    # TODO:
    # PROGRAMMER INSTRUCTIONS:
    # • IF CHILD_NUM = 1 AND  NO PRIOR MATERNAL QUESTIONNAIRES WERE COMPLETED OR THE MOTHER WAS FIRST IDENTIFIED AT 
    # THE BIRTH VISIT, GO TO MARISTAT.
    # • IF CHILD_NUM > 1 AND NO PRIOR MATERNAL QUESTIONNAIRES WERE COMPLETED, OR THE MOTHER WAS FIRST IDENTIFIED AT 
    # THE BIRTH VISIT, GO TO MARISTAT AND COMPLETE QUESTIONNAIRE FOR FIRST CHILD.  THEN BEGINNING AT CHILD_QNUM, 
    # LOOP THROUGH INTERVIEWER-COMPLETED SECTIONS: SLEEP, CRYING PATTERNS, CHILD DEVELOPMENT AND PARENTING, CHILDCARE 
    # ARRANGEMENTS HEALTHCARE, FOR EACH SUBSEQUENT CHILD.
    # • IF CHILD_NUM =1 AND MOTHER WAS ENROLLED PRIOR TO OR DURING PREGNANCY AND HAS COMPLETED AT LEAST ONE QUESTIONNAIRE 
    # BEFORE BIRTH, GO TO TIME_STAMP_3.
    # • IF CHILD_NUM =1 AND MOTHER WAS ENROLLED PRIOR TO OR DURING PREGNANCY AND HAS COMPLETED AT LEAST ONE QUESTIONNAIRE 
    # BEFORE BIRTH, GO TO TIME_STAMP_3 AND COMPLETE QUESTIONNAIRE FOR FIRST CHILD.  THEN BEGINNING AT CHILD_QNUM, 
    # LOOP THROUGH INTERVIEWER-COMPLETED SECTIONS: SLEEP, CRYING PATTERNS, CHILD DEVELOPMENT AND PARENTING, CHILDCARE 
    # ARRANGEMENTS HEALTHCARE, FOR EACH SUBSEQUENT CHILD.
    # 
    q_prev_questionare "<b>INTERVIEWER INSTRUCTIONS: WAS MOTHER ENROLLED PRIOR TO OR DURING PREGNANCY 
    AND HAS COMPLETED AT LEAST ONE QUESTIONNAIRE BEFORE BIRTH </b>", :pick => :one
    a_1 "YES"
    a_2 "NO"
  end
  section "DEMOGRAPHICS", :reference_identifier=>"THREE_MTH_MOTHER" do
    q_MARISTAT "I’d like to ask about your marital status. Are you:
    <b>INTERVIEWER INSTRUCTION: </b><br>
      RECORD THE PARTICIPANT’S <u>CURRENT</u> MARITAL STATUS", :pick => :one, 
    :data_export_identifier=>"THREE_MTH_MOTHER.MARISTAT"
    a_1 "Married,"
    a_2 "Not married but living together with a partner"
    a_3 "Never been married,"
    a_4 "Divorced,"
    a_5 "Separated, or"
    a_6 "Widowed?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_using_showcards "<b>INTERVIEWER INSTRUCTION:</b>DOES INTERVIEWER USE SHOWCARDS?", :pick => :one
    a_1 "YES"
    a_2 "NO"
    
    q_EDUC_no_showcard "What is the highest degree or level of school you have completed?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>
    - IF USING SHOWCARDS, REFER PARTICIPANT TO APPROPRIATE SHOWCARD.  OTHERWISE, READ RESPONSE CATEGORIES TO PARTICIPANT.",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER.EDUC"
    a_1 "Less Than a High School Diploma or GED"
    a_2 "High School Diploma or GED"
    a_3 "Some College but No Degree"
    a_4 "Associate Degree"
    a_5 "Bachelor’s Degree (for example, BA, BS)"
    a_6 "Post Graduate Degree (for example, Masters or Doctoral)"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_using_showcards, "==", :a_2
    
    q_EDUC_showcard "What is the highest degree or level of school you have completed?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>
    - IF USING SHOWCARDS, REFER PARTICIPANT TO APPROPRIATE SHOWCARD.  OTHERWISE, READ RESPONSE CATEGORIES TO PARTICIPANT.",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER.EDUC"
    a_1 "LESS THAN A HIGH SCHOOL DIPLOMA OR GED"
    a_2 "HIGH SCHOOL DIPLOMA OR GED"
    a_3 "SOME COLLEGE BUT NO DEGREE"
    a_4 "ASSOCIATE DEGREE"
    a_5 "BACHELOR'S DEGREE (FOR EXAMPLE, BA, BS)"
    a_6 "POST GRADUATE DEGREE (FOR EXAMPLE, MASTERS OR DOCTORAL)"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_using_showcards, "==", :a_1
    
    q_ETHNICITY "Do you consider yourself to be Hispanic, or Latina?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER.ETHNICITY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_RACE "What race do you consider yourself to be? You may select one or more.<br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - PROBE: Anything else?<br>
    - CODE “OTHER” ONLY IF VOLUNTEERED.<br>
    SELECT ALL THAT APPLY", :pick => :any,
    :data_export_identifier=>"THREE_MTH_MOTHER_RACE.RACE"
    a_1 "White,"
    a_2 "Black or African American,"
    a_3 "American Indian or Alaska Native"
    a_4 "Asian, or"
    a_5 "Native Hawaiian or Other Pacific Islander"
    a_6 "Multi Racial"
    a_neg_5 "SOME OTHER RACE?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
     
    q_RACE_OTH "OTHER RACE", 
    :pick=>:one, 
    :data_export_identifier=>"THREE_MTH_MOTHER_RACE.RACE_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B or C)"
    condition_A :q_RACE, "==", :a_neg_5
    condition_B :q_RACE, "!=", :a_neg_1
    condition_C :q_RACE, "!=", :a_neg_2    
    
    # TODO:
    # {CURRENT YEAR – 1}    
    label "Now I’m going to ask a few questions about your income. Family income is important in understanding 
    the information we collect and is often used in scientific studies to compare groups of people who are similar. 
    Please remember that all the information you share with us is confidential.<br>
    Please think about your total combined family income during {CURRENT YEAR – 1} for all members of the family. "

    q_enter_HH_MEMBERS "How many household members are supported by your total combined family income?", 
    :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_HH_MEMBERS "NUMBER HOUSEHOLD MEMBERS SUPPORTED BY TOTAL COMBINED FAMILY INCOME", 
    :data_export_identifier=>"THREE_MTH_MOTHER.HH_MEMBERS"
    a "SPECIFY", :integer
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_hh_members, "==", :a_1

    label "The value you provided is outside the suggested range. (Range = 1 to 15) This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_hh_members, "<", {:integer_value => "1"}
    condition_B :q_hipv1_2_hh_members, ">", {:integer_value => "15"}

    q_enter_num_child "How many of those people are children? Please include anyone under 18 years or anyone 
    older than 18 years and in high school.", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_enter_HH_MEMBERS, "==", :a_1
    condition_B :q_HH_MEMBERS, ">", {:integer_value => "1"}
    condition_C :q_HH_MEMBERS, "<", {:integer_value => "15"}    

# TODO == • DISPLAY  HARD EDIT IF RESPONSE > HH_MEMBERS 
    q_NUM_CHILD "NUMBER OF CHILDREN 
    <br><br> <b>INTERVIEWER INSTRUCTION: </b>
    Check the entry field for this question with the answer above. If response is higher, ask the question again", 
    :data_export_identifier=>"THREE_MTH_MOTHER.NUM_CHILD"
    a "SPECIFY", :integer
    dependency :rule=>"A and B"
    condition_A :q_enter_HH_MEMBERS, "==", :a_1
    condition_B :q_HH_MEMBERS, ">", {:integer_value => "1"}

    label "The value you provided is outside the suggested range. (Range = 0 to 10) This value is admissible, but you may wish to verify."
    dependency :rule=>"A"
    condition_A :q_NUM_CHILD, ">", {:integer_value => "10"}

    q_using_showcards_for_income "<b>INTERVIEWER INSTRUCTION:</b>DOES INTERVIEWER USE SHOWCARDS?", :pick => :one
    a_1 "YES"
    a_2 "NO"

    # PROGRAMMER INSTRUCTION:
    # • IF USING SHOWCARDS, DISPLAY RESPONSE CATEGORIES IN ALL CAPITAL LETTERS.  OTHERWISE, DISPLAY RESPONSE CATEGORIES AS MIXED UPPER/LOWER CASE PER BELOW.

    q_INCOME_4CAT_no_showcards "Of these income groups, which category best represents your combined family income during the 
    last calendar year?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>
    -IF USING SHOWCARDS, REFER PARTICIPANT TO APPROPRIATE SHOWCARD.  
    OTHERWISE, READ RESPONSE CATEGORIES TO PARTICIPANT.", :pick=>:one, 
    :data_export_identifier=>"THREE_MTH_MOTHER.INCOME_4CAT"
    a_1 "LESS THAN $30,000"
    a_2 "$30,000 - $49,999"
    a_3 "$50,000 - $99,999"
    a_4 "$100,000 or more"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_using_showcards_for_income, "==", :a_2
    
    q_INCOME_4CAT_showcards "Of these income groups, which category best represents your combined family income during the 
    last calendar year?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>
    -IF USING SHOWCARDS, REFER PARTICIPANT TO APPROPRIATE SHOWCARD.  
    OTHERWISE, READ RESPONSE CATEGORIES TO PARTICIPANT.", :pick=>:one, 
    :data_export_identifier=>"THREE_MTH_MOTHER.INCOME_4CAT"
    a_1 "LESS THAN $30,000"
    a_2 "$30,000 - $49,999"
    a_3 "$50,000 - $99,999"
    a_4 "$100,000 OR MORE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_using_showcards_for_income, "==", :a_1    
    
    q_TIME_STAMP_3 "INSERT DATE/TIME STAMP", :data_export_identifier=>"THREE_MTH_MOTHER.TIME_STAMP_3"
    a :datetime    
    
    q_HH_PRIMARY_LANG "What is the primary language spoken in your home?", :pick => :any, 
    :data_export_identifier=>"THREE_MTH_MOTHER.HH_PRIMARY_LANG"
    a_1 "ENGLISH"
    a_2 "SPANISH"
    a_3 "ARABIC"
    a_4 "CHINESE"
    a_5 "FRENCH"
    a_6 "FRENCH CREOLE"
    a_7 "GERMAN"
    a_8 "ITALIAN"
    a_9 "KOREAN"
    a_10 "POLISH"
    a_11 "RUSSIAN"
    a_12 "TAGALOG"
    a_13 "VIETNAMESE"
    a_14 "URDU"
    a_15 "PUNJABI"
    a_16 "BENGALI"
    a_17 "FARSI"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
   
    q_PERSON_LANG_OTH "OTHER PRIMARY LANGUAGES THAT ARE SPOKEN IN YOUR HOME", 
    :pick=>:one, 
    :data_export_identifier=>"THREE_MTH_MOTHER.PERSON_LANG_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_HH_PRIMARY_LANG , "==", :a_neg_5
    condition_B :q_HH_PRIMARY_LANG , "!=", :a_neg_1
    condition_C :q_HH_PRIMARY_LANG , "!=", :a_neg_2    
  end
  section "SLEEP", :reference_identifier=>"THREE_MTH_MOTHER" do
    label "Now, I’ll begin by asking you about {C_FNAME/YOUR CHILD}’s sleeping habits."
    
    q_SLEEP_PLACE_1 "Does your baby usually sleep in your bedroom or in a different room at night?", :pick =>:one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_1"
    a_1 "IN PARTICIPANT’S ROOM"
    a_2 "IN A DIFFERENT ROOM"
    a_3 "BOTH IN PARTICIPANT’S ROOM AND A DIFFERENT ROOM"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SLEEP_PLACE_2 "What does {C_FNAME/YOUR CHILD} sleep in at night?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_2"
    a_1 "A bassinette,"
    a_2 "A crib,"
    a_3 "A co-sleeper,"
    a_4 "In the bed or other place with you, or"
    a_neg_5 "In something else?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SLEEP_PLACE_2_OTH "OTHER SLEEPING ARRANGEMENT", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_2_OTH"
    a "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SLEEP_POSITION_NIGHT "In what position do you most often lay {C_FNAME/YOUR CHILD} down to sleep at night? On his/her.",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_POSITION_NIGHT"
    a_1 "Stomach,"
    a_2 "Back, or"
    a_3 "Side?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SLEEP_HRS_DAY "Approximately how many hours does {C_FNAME/YOUR CHILD} sleep during the day?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_HRS_DAY"
    a "HOURS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SLEEP_HRS_NIGHT "Approximately how many hours does {C_FNAME/YOUR CHILD} sleep at night?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_HRS_NIGHT"
    a "HOURS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"    
    
    q_SLEEP_DIFFICULT "How often is your baby difficult when {he/she} is put to bed?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_DIFFICULT"
    a_1 "Most of the time,"
    a_2 "Often,"
    a_3 "Sometimes,"
    a_4 "Rarely, or"
    a_5 "Never?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
  end
  section "CRYING PATTERNS", :reference_identifier=>"THREE_MTH_MOTHER" do 
    label "All babies fuss and cry sometimes. I’m now going to ask you some questions to get a better 
    idea of your baby’s crying patterns." 
    
    q_CRY_MORE "Compared to other babies, do you think {C_FNAME/YOUR CHILD} cries more, the same or less?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_MORE"
    a_1 "MORE"
    a_2 "THE SAME"
    a_3 "LESS"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_CRY_CONSOLE "Can you usually calm or console {C_FNAME/YOUR CHILD} when {he/she} cries?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_CONSOLE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_CRY_COLIC "Does {C_FNAME/YOUR CHILD} have episodes of colic, or times when {he/she} cries and can’t be calmed or consoled?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_COLIC"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_COLIC_FREQ "How often does {C_FNAME/YOUR CHILD} have episodes of colic, or times when {he/she} cries and can’t be 
    calmed or consoled:",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.COLIC_FREQ"
    a_1 "Every day,"
    a_2 "Most days,"
    a_3 "Sometimes, or"
    a_4 "Rarely?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_CRY_COLIC, "==", :a_1
    
    q_CRY_PROBLEM "Are you finding {C_FNAME/YOUR CHILD}’s crying to be a problem or upsetting?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_PROBLEM"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
  end
  section "CHILD DEVELOPMENT AND PARENTING", :reference_identifier=>"THREE_MTH_MOTHER" do 
    label "Even though {C_FNAME/YOUR CHILD} is only {AGE OF CHILD IN MONTHS} months old, 
    {he/she} may show emotions or other actions. Overall, would you describe your baby as:"
   
    # TODO:
    #     PROGRAMMER INSTRUCTION: 
    #     •	USING CHILD_DOB CALCULATE CHILD’S AGE TO THE NEAREST MONTH AND PRELOAD.
    
    q_calculated_child_age "<b>INTERVIEWER INSTRUCTION:</b><br>- USING CHILD_DOB CALCULATE CHILD’S AGE TO THE NEAREST MONTH"
    a "HOW MANY MONTHS?", :integer
    
    q_CALM "Calm?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CALM"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_WORRIED "Worried?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.WORRIED"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SOCIAL "Sociable or outgoing?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SOCIAL"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_ANGRY "Angry?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.ANGRY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"

    q_SHY"Shy or quiet?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SHY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"

    q_STUBBORN "Stubborn?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.STUBBORN"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_HAPPY "Happy?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HAPPY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    label "I’d like to ask about {C_FNAME/YOUR CHILD} and you. I will read you a list of things {C_FNAME/YOUR CHILD} 
    may already do or may start doing when {he/she} gets older. Does {C_FNAME/YOUR CHILD}:"
    
    q_EYES_FOLLOW "Follow you with {his/her} eyes?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.EYES_FOLLOW"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SMILE "Smile when you smile at {him/her}?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SMILE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_REACH_1 "Try to get a toy that is out of reach?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.REACH_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"                
    
    q_FEED "Feed {him/herself} a cracker or cereal?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.FEED"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_WAVE "Wave goodbye?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.WAVE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_REACH_2 "Reach for toys or food held to {him/her}",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.REACH_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_GRAB "Grab an object like a block or rattle from you?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.GRAB"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"             
    
    q_SWITCH_HANDS "Move a toy or block from one hand to the other?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SWITCH_HANDS"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_PICKUP "Pick up a small object like a Cheerio or raisin?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.PICKUP"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_HOLD "Hold two toys or blocks at a time, one in each hand?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HOLD"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"        
    
    q_SOUND_2 "Turn towards a sound?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SOUND_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SOUND_3 "Turn toward someone when they’re speaking?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SOUND_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SPEAK_1 "Make sounds as though {he/she} is trying to speak?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SPEAK_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_SPEAK_2 "Say mama or dada?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SPEAK_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"   
    
    q_HEADUP "Keep head steady when sitting or held up?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HEADUP"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_ROLL_1 "Roll over from stomach to back?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.ROLL_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_ROLL_2 "Roll from back to stomach?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.ROLL_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"  
    
    q_time_stamp_4 "INSERT DATE/TIME STAMP", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.TIME_STAMP_4"
    a :datetime                           
  end
  section "CHILD CARE ARRANGEMENTS", :reference_identifier=>"THREE_MTH_MOTHER" do 
    label "Next, I’d like to ask you about different types of child care {C_FNAME/YOUR CHILD} may receive from someone 
    other than parents or guardians. This includes regularly scheduled care arrangements with relatives and non-relatives, 
    and day care or early childhood programs, whether or not there is a charge or fee, but not occasional baby-sitting."
    
    q_CHILDCARE "Does {C_FNAME/YOUR CHILD} currently receive any regularly scheduled care from someone other than a parent or guardian. For example, from relatives, non-relatives, or a child care center or program?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CHILDCARE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_FAMILY_CARE_HRS "I’d like you to think about all the care {C_FNAME/YOUR CHILD} receives from relatives. 
    For example, from grandparents, brothers or sisters, or any other relatives. (This includes all regularly scheduled 
    care arrangements with relatives that happen at least weekly, but does not include occasional baby-sitting.)<br>
    Including all of these regular arrangements, how many total hours each week does {C_FNAME/YOUR CHILD} receive 
    care from relatives?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.FAMILY_CARE_HRS"
    a "HOURS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1
    
    q_HOMECARE_HRS "I’d like you to think about all the regularly scheduled care your child receives on a weekly basis 
    from non-relatives in a home setting. (This includes all regularly scheduled care arrangements with non-relatives that 
    happen at least weekly, including home child care providers, regularly scheduled sitter arrangements, or neighbors. 
    This does not include day care centers, early childhood programs, or occasional babysitting.)<br>
    Including all of these arrangements, how many total hours each week does {C_FNAME/YOUR CHILD} receive care from 
    non-relatives in a home setting?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HOMECARE_HRS"
    a "HOURS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1
    
    q_time_stamp_5 "INSERT DATE/TIME STAMP", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.TIME_STAMP_5"
    a :datetime
  end  
  section "HEALTH CARE", :reference_identifier=>"THREE_MTH_MOTHER" do 
    q_C_HEALTH "Since {C_FNAME/YOUR CHILD} was born, would you say {his/her} health has been poor, fair, good, excellent?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HOMECARE_HRS"
    a_1 "POOR"
    a_2 "FAIR"
    a_3 "GOOD"
    a_4 "EXCELLENT"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"

    label "The next questions are about where {C_FNAME/YOUR CHILD} goes for health care."
    
    q_R_HCARE "First, what kind of place does {C_FNAME/YOUR CHILD} usually go to when {he/she} needs routine or 
    well-child care, such as a check-up or well-baby shots (immunizations)?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.R_HCARE"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "DOESN'T GO TO ONE PLACE MOST OFTEN"
    a_7 "DOESN'T GET WELL-CHILD CARE ANYWHERE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_LAST_VISIT "What was the date of {C_FNAME/YOUR CHILD}’s most recent well-child visit or check-up?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.LAST_VISIT"
    a :date
    a_neg_7 "HAS NOT HAD A VISIT"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2
    
    q_enter_VISIT_WT "What was {C_FNAME/YOUR CHILD}’s weight at that visit?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.VISIT_WT"
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_LAST_VISIT, "!=", :a_neg_7
    condition_B :q_LAST_VISIT, "!=", :a_neg_1
    condition_C :q_LAST_VISIT, "!=", :a_neg_2
    
    q_VISIT_WT "WEIGHT IN POUNDS",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.VISIT_WT"
    a "Pounds", :integer
    dependency :rule=>"A and B and C"
    condition_A :q_enter_VISIT_WT, "==", :a_1

    label "The appropriate range for weight is >8 and < 21 pounds. This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_VISIT_WT, "<", {:integer_value => "8"}
    condition_B :q_VISIT_WT, ">", {:integer_value => "21"}
    
    q_SAME_CARE "If {C_FNAME/YOUR CHILD} is sick or if you have concerns about {his/her} health, does {he/she} go to 
    the same place as for well-child visits?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SAME_CARE"    
    a_1 "YES"
    a_2 "NO"
    a_neg_7 "HAS NOT BEEN SICK"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_HCARE_SICK "What kind of place does {C_FNAME/YOUR CHILD} usually go to when {he/she} is sick, doesn’t feel well, 
    or if you have concerns about {his/her} health?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HCARE_SICK"    
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "DOESN'T GO TO ONE PLACE MOST OFTEN"
    a_neg_7 "HAS NOT BEEN SICK"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule => "A or B"
    condition_A :q_SAME_CARE, "!=", :a_1
    condition_B :q_SAME_CARE, "!=", :a_neg_7
    
    q_HOSPITAL "After coming home from the hospital the first time, has your child spent at least one night in the hospital?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HOSPITAL"    
    a_1 "YES"
    a_2 "NO"
    a_neg_7 "HAS NOT BEEN SICK"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_DIAGNOSIS "Did a doctor or other health care provider give your child a diagnosis?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.DIAGNOSIS"    
    a_1 "YES"
    a_2 "NO"
    a_neg_7 "HAS NOT BEEN SICK"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule => "A"
    condition_A :q_HOSPITAL, "==", :a_1
    
    q_DIAGNOSIS_SPECIFY "What was the diagnosis?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.DIAGNOSIS_SPECIFY"
    a "DIAGNOSES", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_time_stamp_6 "INSERT DATE/TIME STAMP", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.TIME_STAMP_6"
    a :datetime
    
    label "Thank you for your time and for being a part of this important research study. This is the end of our interview.<br>
    LOCATION-SPECIFIC CLOSE-OUT AND SCHEDULING TEXT – include information about next contact (6 month home visit) 
    and verification of contact information."
  end
end