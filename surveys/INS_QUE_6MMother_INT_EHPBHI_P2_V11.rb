survey "INS_QUE_6MMother_INT_EHPBHI_P2_V1.1" do
  section "Interview introduction", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    label "We are about to begin the interview portion of today’s home visit, which will take about 25 minutes to complete. 
    Your answers are important to us. There are no right or wrong answers. There are questions about your child’s health and health 
    care as well as your child’s behaviors, such as sleeping and eating. We will also ask you about some of your own experiences and 
    feelings, as well as your day to day routines. You can skip over any question or stop the interview at any time. We will keep 
    everything that you tell us confidential."
  end
  section "Interviewer completed questions", :reference_identifier=>"6MMother_INT" do
    label "Do not administer these questions to the participant."
    
    q_MULT_CHILD "Is there more than one child of this mother eligible for the 6 month visit today?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.MULT_CHILD"
    a_1 "Yes"
    a_2 "No"
    
    q_CHILD_NUM "How many children of this mother are eligible for the 6-month visit today?",
    :data_export_identifier=>"SIX_MTH_MOTHER.CHILD_NUM"
    a "Number of children", :integer
    dependency :rule=>"A"
    condition_A :q_MULT_CHILD, "==", :a_1
    
# TODO    
    # PROGRAMMER INSTRUCTION:
    # • IF MULT_CHILD = 1; COMPLETE ENTIRE QUESTIONNAIRE FOR FIRST CHILD.  THEN LOOP THROUGH INTERVIEWER-COMPLETED 
    # QUESTIONS STARTING AT CHILD_QNUM, CHILD DEVELOPMENT AND PARENTING, SLEEP, HEALTH AND MEDICAL CONDITIONS, 
    # HEALTH CARE, HEALTH INSURANCE, CHILDCARE ARRANGEMENTS,  AND HOMECARE SECTIONS FOR EACH ADDITIONAL ELIGIBLE 
    # CHILD RECORDED IN CHILD_NUM.
    
    q_CHILD_QNUM "Which number child is this questionnaire for?",
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.CHILD_QNUM"
    a_which_child "Number", :integer
    dependency :rule=>"A"
    condition_A :q_MULT_CHILD, "==", :a_1    
    
    # TODO
    #     PROGRAMMER INSTRUCTION:
    #     •	CHILD_QNUM CANNOT BE GREATER THAN CHILD_NUM.
    q_CHILD_SEX "Is CHILD_QNUM a male or female?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_3 "Both"

    # TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • IF CHILD_SEX =1 , DISPLAY “his” AND “he” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 2, DISPLAY “her” AND “she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 3, DISPLAY “him/her” AND “he/she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
  end
  section "Participant verification", :reference_identifier=>"6MMother_INT" do
    label "First, we’d like to make sure we have your child’s correct name and birth date."

#     TODO - the name should be pre-populated    
    q_prepopulated_name "Name:"
    a :string

    # TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • PRELOADCHILD’S NAME IF COLLECTED PREVIOUSLY.
    # • IF CNAME_CONFIRM= 1, SET C_FNAME/C_LNAME TO KNOWN VALUE.

    q_CNAME_CONFIRM "Is your child’s name {INAME}]?", 
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.CNAME_CONFIRM", :pick=>:one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    # TODO
    #     PROGRAMMER INSTRUCTION:
    #     • IF PARTICIPANT REFUSES TO PROVIDE NAME, INITIALS OR IDENTIFIER C_FNAME AND C_LNAME=1, USE “YOUR CHILD” FOR 
    #     C_FNAME IN REMAINDER OF QUESTIONNAIRE.

    group "Child's information" do
    dependency :rule=>"A"
    condition_A :q_CNAME_CONFIRM, "!=", :a_1  

      label "What is your child’s full name?",
      :help_text => "If participant refuses to provide information, re-state confidentiality 
      protections, ask for initials or some other name she would like her child to be called. 
      Confirm spelling of first name if not previously collected and of last name for all children."
    
      q_C_FNAME "First name", :pick => :one, 
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.C_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_LNAME "Last name", :pick => :one, 
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.C_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    # TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • IF PARTICIPANT REFUSES TO PROVIDE NAME, INITIALS OR IDENTIFIER C_FNAME AND C_LNAME=-1, USE “YOUR CHILD” FOR C_FNAME 
    # IN REMAINDER OF QUESTIONNAIRE.
    
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # •  PRELOAD CHILD’S DOB IF COLLECTED PREVIOUSLY AS MM/DD/YYYY.
    # • IF CDOB_CONFIRM = 1, SET CHILD_DOBTO KNOWN VALUE, FORMAT AS YYYYMMDD.
    q_prepopulated_childs_birth_date "Child's birth date"
    a :string
    
    # TODO: Is {C_FNAME or YOUR CHILD}’S birth date  {CHILD’S DATE OF BIRTH}
    q_CDOB_CONFIRM "Is {C_FNAME or YOUR CHILD}’S birth date {CHILD’S DATE OF BIRTH}?", 
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and 
    that DOB helps determine eligibility.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.CDOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
     
    q_CHILD_DOB "What is {C_FNAME/YOUR CHILD}’s date of birth?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and 
    that DOB helps determine eligibility. If response was determined to be invalid, ask question again and probe for valid response. 
    Please verify if calculated age in months is less than 4 months or greater than 9 months",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.CHILD_DOB"
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_CDOB_CONFIRM, "!=", :a_1
    
    # TODO:
    #     PROGRAMMER INSTRUCTIONS:
    # • INCLUDE A SOFT EDIT/WARNING IF CALCULATED AGE IS LESS THAN 9 MONTHS OR GREATER THAN 15 MONTHS
    # • FORMAT CHILD_DOB AS YYYYMMDD
  end
  section "Child development and parenting", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
    
    label "First, I’d like to ask about {C_FNAME or YOUR CHILD} and you. I will read you a list of things {C_FNAME or YOUR CHILD} 
    may already do or may start doing when {he/she} gets older. Does {C_FNAME or YOUR CHILD }..."
      
    q_EYES_FOLLOW "... Follow you with {his/her} eyes?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.EYES_FOLLOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SMILE "... Smile when you smile at {him/her}?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SMILE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_REACH_1 "... Try to get a toy that is out of reach?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.REACH_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FEED "... Feed {him/herself} a cracker or cereal?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.FEED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_WAVE "... Wave goodbye?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.WAVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_REACH_2 "... Reach for toys or food held to {him/her}",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.REACH_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRAB "... Grab an object like a block or rattle from you?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.GRAB"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"             
    
    q_SWITCH_HANDS "... Move a toy or block from one hand to the other?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SWITCH_HANDS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PICKUP "... Pick up a small object like a Cheerio or raisin?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.PICKUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_HOLD "... Hold two toys or blocks at a time, one in each hand?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.HOLD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SOUND_2 "... Turn towards a sound?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SOUND_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
        
    q_SOUND_3 "... Turn toward someone when they’re speaking?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SOUND_3"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SPEAK_1 "... Make sounds as though {he/she} is trying to speak?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SPEAK_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SPEAK_2 "... Say mama or dada?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SPEAK_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"   
    
    q_HEADUP "... Keep head steady when sitting or held up?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.HEADUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ROLL_1 "... Roll over from stomach to back?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.ROLL_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ROLL_2 "... Roll from back to stomach?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.ROLL_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SITUP "... Sit up by {himself/herself}?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SITUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_STAND "... Stand while holding onto something?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.STAND"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
  section "Sleep", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
    
    label "Now I’ll ask you about {C_FNAME or YOUR CHILD}’s sleeping."
    
    q_SLEEP_PLACE_1 "Does {C_FNAME or YOUR CHILD} usually sleep in your bedroom or in a different room at night?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_PLACE_1"
    a_1 "In participant’s room"
    a_2 "In a different room"
    a_3 "Both in participant’s room and a different room..."
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_PLACE_2 "What does {C_FNAME or YOUR CHILD} sleep in at night?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_PLACE_2"
    a_1 "A bassinette"
    a_2 "A crib"
    a_3 "A co-sleeper"
    a_4 "In the bed or other place with you"
    a_neg_5 "In something else"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_PLACE_2_OTH "Other sleeping arrangements:",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_PLACE_2_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_SLEEP_PLACE_2, "==", :a_neg_5
    
    q_SLEEP_POSITION_NIGHT "In what position do you most often lay {C_FNAME or YOUR CHILD} down to sleep at night? On the",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_POSITION_NIGHT"
    a_1 "Stomach"
    a_2 "Back"
    a_3 "Side"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"	
    
    q_SLEEP_POSITION_NAP "In what position do you most often lay {C_FNAME or YOUR CHILD} down for naps? On the",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_POSITION_NAP"
    a_1 "Stomach"
    a_2 "Back"
    a_3 "Side"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_ROUTINE "Does {C_FNAME or YOUR CHILD} have a regular sleeping routine now?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_ROUTINE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_HRS_DAY "Approximately how many hours does {C_FNAME or YOUR CHILD} sleep during the day?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_HRS_DAY"
    a "Hours", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_HRS_NIGHT "Approximately how many hours does {C_FNAME or YOUR CHILD} sleep at night?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_HRS_NIGHT"
    a "Hours", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_TIME_NIGHT "On a normal day, what time in the evening does {C_FNAME or YOUR CHILD} go to sleep?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_TIME_NIGHT"
    a "Time", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_TIME_WAKE "On a normal day, what time does {C_FNAME or YOUR CHILD} wake up in the morning?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_TIME_WAKE"
    a "Time", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_SLEEP_DIFFICULT "How often is {C_FNAME or YOUR CHILD} difficult when {he/she} is put to bed?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SLEEP_DIFFICULT"
    a_1 "Most of the time"
    a_2 "Often"
    a_3 "Sometimes"
    a_4 "Rarely"
    a_5 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
  end
  section "Health and medical conditions", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.TIME_STAMP_4"
    a :datetime, :custom_class => "datetime"
    
    label "Now I’d like to change the subject and ask about {C_FNAME or YOUR CHILD}’s health and about some medical 
    conditions {he/she} may have had."
    
    q_C_HEALTH "Since {C_FNAME or YOUR CHILD} was born, would you say {his/her} health has been poor, fair, good, or excellent?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.C_HEALTH"
    a_1 "Poor"
    a_2 "Fair"
    a_3 "Good"
    a_4 "Excellent"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COLD "Has {C_FNAME or YOUR CHILD} ever had a runny nose, cough, or cold?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.COLD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"    
    
    q_COLD_AGE "How old was {he/she or YOUR CHILD} when {he/she or YOUR CHILD} first had a runny nose, cough, or cold?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.COLD_AGE"
    a_1 "Number", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_COLD, "==", :a_1
    
    q_COLD_AGE_UNIT "Unit for the age when {he/she or YOUR CHILD} first had a runny nose, cough, or cold?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.COLD_AGE_UNIT"
    a_1 "Days"
    a_2 "Weeks"
    a_3 "Months"
    dependency :rule => "A"
    condition_A :q_COLD_AGE, "==", :a_1
    
    q_EAR_INFECTION "Has {C_FNAME or YOUR CHILD} ever had an ear infection?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.EAR_INFECTION"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_EAR_INFECTION_AGE "How old was {he/she or YOUR CHILD} when {he/she or YOUR CHILD} first had an ear infection?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.EAR_INFECTION_AGE"
    a_1 "Number", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_EAR_INFECTION, "==", :a_1
    
    q_EAR_INFECTION_AGE_UNIT "Unit for the age when {he/she or YOUR CHILD} first had an ear infection?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.EAR_INFECTION_AGE_UNIT"
    a_1 "Days"
    a_2 "Weeks"
    a_3 "Months"
    dependency :rule => "A"
    condition_A :q_EAR_INFECTION_AGE, "==", :a_1
    
    q_GASTRO "Has {C_FNAME or YOUR CHILD} ever had diarrhea or vomiting?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.GASTRO"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_GASTRO_AGE "How old was {he/she or YOUR CHILD} when {he/she or YOUR CHILD} first had diarrhea or vomiting?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.GASTRO_AGE"
    a_1 "Number", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_GASTRO, "==", :a_1
    
    q_GASTRO_AGE_UNIT "Unit for the age when {he/she or YOUR CHILD} first had diarrhea or vomiting?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.GASTRO_AGE_UNIT"
    a_1 "Days"
    a_2 "Weeks"
    a_3 "Months"
    dependency :rule => "A"
    condition_A :q_GASTRO_AGE, "==", :a_1
    
    q_RESPIRATORY "Has {C_FNAME or YOUR CHILD} ever had wheezing or whistling in the chest?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.RESPIRATORY"
    a_1 "Number", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_RESPIRATORY_AGE "How old was {he/she or YOUR CHILD} when {he/she or YOUR CHILD} first had wheezing or whistling in the chest?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.RESPIRATORY_AGE"
    a_1 "Number", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A"
    condition_A :q_RESPIRATORY, "==", :a_1
    
    q_RESPIRATORY_AGE_UNIT "Unit for the age when {he/she or YOUR CHILD} first had wheezing or whistling in the chest?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.RESPIRATORY_AGE_UNIT"
    a_1 "Days"
    a_2 "Weeks"
    a_3 "Months"
    dependency :rule => "A"
    condition_A :q_RESPIRATORY_AGE, "==", :a_1    
    
    q_FEVER "Since {C_FNAME or YOUR CHILD} was born, on how many days has {he/she} had a fever over 101 degrees, not related 
    to receiving immunizations?",
    :help_text => "If needed: \"or 38.3 degrees Celsius?\". Enter \"0\" if none",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.FEVER"
    a "Number of days", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FAIL_THRIVE "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has failure to thrive, or any other concern about proper growth?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.FAIL_THRIVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
  end
  section "Health care", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.TIME_STAMP_5"
    a :datetime, :custom_class => "datetime"
    
    label "The next questions are about where {C_FNAME or YOUR CHILD } goes for health care."

    q_R_HCARE "First, what kind of place does {C_FNAME or YOUR CHILD} usually go to when {he/she} needs routine or well-child care, 
    such as a check-up or well-baby shots (immunizations)?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.R_HCARE"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_7 "Doesn't get well-child care anywhere"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_LAST_VISIT "What was the date of {C_FNAME or YOUR CHILD}’s most recent well-child visit or checkup?",
    :help_text => "Show calendar to assist in date recall.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.LAST_VISIT"
    a_date "Date", :string, :custom_class => "date"
    a_neg_7 "Has not had a visit"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A and B and C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2      
  
    q_VISIT_WT "What was {C_FNAME or YOUR CHILD}’s weight at that visit?",
    :help_text => "Verify if weight < 10 and > 25 pounds.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.VISIT_WT"
    a_weight "Pounds", :integer
    a_neg_7 "Has not had a visit"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A"
    condition_A :q_LAST_VISIT, "==", :a_date      
    
    q_SAME_CARE "If {C_FNAME or YOUR CHILD} is sick or if you have concerns about {his/her or YOUR CHILD’S} health, 
    does {he/she or YOUR CHILD} go to the same place as for well-child visits?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SAME_CARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    a_neg_7 "Not applicable / has not been sick"
    dependency  :rule => "A and B and C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2    
    
    q_HCARE_SICK "What kind of place does {C_FNAME or YOUR CHILD} usually go to when {he/she or YOUR CHILD} is sick, doesn’t 
    feel well, or if you have concerns about {his/her or YOUR CHILD’S} health?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.HCARE_SICK"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    a_neg_7 "Not applicable / has not been sick"
    dependency :rule => "A or B or C or D or E"
    condition_A :q_SAME_CARE, "!=", :a_1
    condition_B :q_SAME_CARE, "!=", :a_neg_7
    condition_C :q_R_HCARE, "==", :a_7
    condition_D :q_R_HCARE, "==", :a_neg_1
    condition_E :q_R_HCARE, "==", :a_neg_2
  end
  section "Health insurance", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_6 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.TIME_STAMP_6"
    a :datetime, :custom_class => "datetime"
    
    label "Now I’m going to ask about health insurance. We have asked about this before. Sometimes, it changes, so we are going to ask again."
    
    q_INSURE "Is {C_FNAME or YOUR CHILD} currently covered by any kind of health insurance or some other kind of health care plan?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.INSURE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    group "Insurance information" do
      dependency :rule => "A"
      condition_A :q_INSURE, "==", :a_1
            
      label "Now I’ll read a list of different types of insurance. Please tell me which types {C_FNAME or YOUR CHILD } currently has. 
      (Does {C_FNAME or YOUR CHILD } currently have...)",
      :help_text => "Re-read introductory statement in parentheses as needed."
    
      q_INS_EMPLOY "Insurance through an employer or union either through yourself or another family member?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_INS_MEDICAID "Medicaid or any government-assistance plan for those with low incomes or a disability?",
      :help_text => "Provide examples of local medicaid programs.",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_INS_TRICARE "TRICARE, VA, or other military health care?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_INS_IHS "Indian Health Service?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_INS_MEDICARE "Medicare, for people with certain disabilities?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.INS_MEDICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_INS_OTH "Any other type of health insurance or health coverage plan?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    end
  end
  section "Child care arrangements", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_7 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.TIME_STAMP_7"
    a :datetime, :custom_class => "datetime"
    
    label "Next, I’d like to ask you about different types of child care {C_FNAME or YOUR CHILD} may receive from 
    someone other than parents or guardians. This includes regularly scheduled care arrangements with relatives and 
    non-relatives, and day care or early childhood programs, whether or not there is a charge or fee, but not occasional baby-sitting."
    
    q_CHILDCARE "Does {C_FNAME or YOUR CHILD} currently receive any regularly scheduled care from someone other than a parent or guardian, 
    for example from relatives, friends or other non-relatives, or a child care center or program?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.CHILDCARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_FAMILY_CARE "Does {C_FNAME or YOUR CHILD} receive any care from relatives, for example, from grandparents, brothers or sisters, 
    or any other relatives. This includes all regularly scheduled care arrangements with relatives that happen at least weekly, 
    but does not include occasional baby-sitting.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.FAMILY_CARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A"
    condition_A :q_CHILDCARE, "==", :a_1    
    
    q_FAMILY_CARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care from relatives?",
    :help_text => "Verify if response exceeds 50 hours per week.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.FAMILY_CARE_HRS"
    a_number "Number of hours per week", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A"
    condition_A :q_FAMILY_CARE, "==", :a_1
  end
  section "Home care", :reference_identifier=>"6MMother_INT" do
    
    label "Now I’d like to ask you about any regularly scheduled care {C_FNAME or YOUR CHILD} receives from someone not related 
    to {him/her}, either in your home or someone else’s home. This includes all regularly scheduled care arrangements with 
    non-relatives that happen at least weekly, including home child care providers, regularly scheduled sitter arrangements, or neighbors. 
    This does not include day care centers, early childhood programs, or occasional babysitting."
    
    q_HOMECARE "Does {C_FNAME or YOUR CHILD} receive any regularly scheduled care either in your home or someone else’s home 
    from someone not related to {him/her}?",
    :help_text => "If necessary read: \"This includes arrangements with non-relatives including home child care providers, regularly 
    scheduled sitter arrangements, or neighbors. This does not include day care centers, early childhood programs, or occasional 
    babysitting.\"",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.HOMECARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_HOMECARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care in a home from non-relatives?",
    :help_text => "Verify if response exceeds 50 hours per week.",    
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.HOMECARE_HRS"
    a_number "Number of hours per week", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A"
    condition_A :q_HOMECARE, "==", :a_1
    
    label "Now I want to ask you about child care centers {C_FNAME or YOUR CHILD} may attend on a regular basis. Such centers 
    include day care centers, early learning centers, nursery schools, and preschools. "
    
    q_DAYCARE "Does {C_FNAME or YOUR CHILD} receive any care in child care centers? Such centers include day care centers, early 
    learning centers, nursery schools, and preschools.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.DAYCARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_DAYCARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care in child care centers?",
    :help_text => "Verify if response exceeds 50 hours per week.",    
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.DAYCARE_HRS"
    a_number "Number of hours per week", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A"
    condition_A :q_DAYCARE, "==", :a_1
  end    
  section "Pets", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_8 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_8"
    a :datetime, :custom_class => "datetime" 
    
    # TODO:
    # PROGRAMMER INSTRUCTION:
    # • THIS SECTION SHOULD ONLY BE ASKED FOR THE FIRST ELIGIBLE CHILD. IF CHILD_QNUM > 1, GO TO SMOKE_HOURS.
    label "Now I’d like to ask about any pets you may have in your home."
    
    q_PETS "Are there any pets that spend any time inside your home?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.PETS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    group "Pets information" do
      dependency  :rule => "A"
      condition_A :q_PETS, "==", :a_1
    
      q_PET_TYPE "What kind of pets are these?",
      :help_text => "Select all that apply. Probe for multiple responses: \"Any others?\"",    
      :pick => :any,
      :data_export_identifier=>"SIX_MTH_MOTHER_PET.PET_TYPE"
      a_1 "Dog"
      a_2 "Cat"
      a_3 "Small mammal (rabbit, gerbil, hamster, guinea pig, ferret, mouse)"
      a_4 "Bird"
      a_5 "Fish or reptile (turtle, snake, lizard)"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_PET_TYPE_OTH "Other types of pets", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER_PET.PET_TYPE_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_PET_TYPE, "==", :a_neg_5
      condition_B :q_PET_TYPE, "!=", :a_neg_1
      condition_C :q_PET_TYPE, "!=", :a_neg_2
    
      q_PET_MEDS "Are any products ever used on your pets to control fleas, ticks, or mites? This includes flea collars, 
      flea and tick powders, shampoos, or other flea, tick and mite control products. (This does not include pills given to your 
      pet to control for fleas or other insects.)",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER.PET_MEDS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_PET_MED_TIME "When were any of these last used on any of your pets?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_MOTHER.PET_MED_TIME"
      a_1 "Within the last month"
      a_2 "1-3 months ago"
      a_3 "4-6 months ago"
      a_4 "More than 6 months ago"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      dependency  :rule => "A"
      condition_A :q_PET_MEDS, "==", :a_1
    end
  end
  section "In-home exposures", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_9"
    a :datetime, :custom_class => "datetime"
    
    label "I would now like to ask about whether you have seen signs of rodents or seen cockroaches in your home in the last 6 months."
    
    q_RODENT "In the last 6 months, have you seen signs of mice, rats, or other rodents in your home (not including pets)?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.RODENT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_ROACH "Since {C_FNAME or YOUR CHILD} was born, have you seen cockroaches in your home?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.ROACH"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
  end
  section "Maternal behaviors", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_10"
    a :datetime, :custom_class => "datetime"  
  
    label "The next questions are about your experiences, since {C_FNAME or YOUR CHILD } was born. First, I’d like to ask 
    some questions about work. People’s work situations sometimes change after having a baby."
    
    q_WORK_PREG "Just before you gave birth to {C_FNAME or YOUR CHILD}, were you employed at a job or business?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.STAND"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_WORK_NOW "Have you returned to work, or are you currently on maternity leave from this job? Please look at this card and 
    tell me which category best describes your work situation.",
    :help_text => "Show response options on card to participant.", 
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.WORK_NOW"
    a_1 "Returned to work"
    a_2 "Unpaid leave"
    a_3 "Paid leave"
    a_4 "Left the position"
    a_5 "Looking for work"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_WORK_PREG, "==", :a_1
    
    q_WORK_NOW_OTH "Other:",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.WORK_NOW_OTH"
    a_1 "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_WORK_NOW, "==", :a_neg_5
    
    q_WORK_HRS "How many hours per week do you work?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.WORK_HRS"
    a_hours "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A"
    condition_A :q_WORK_NOW, "==", :a_1
    
    q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_11"
    a :datetime, :custom_class => "datetime"
    
    label "The next questions ask about smoking in your household."
    
    q_CIG_NOW "Do you currently smoke cigarettes or use any other tobacco product?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.CIG_NOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NUM_SMOKER "How many smokers live in your home now?",
    :help_text => "Enter \"0\" if none",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.NUM_SMOKER"
    a "Number of smokers", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_CIG_NOW, "!=", :a_1
    
    q_NUM_SMOKER_INCL "How many smokers live in your home now, including yourself?",
    :help_text => "Response to num_smoker must be ≥ 1",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.NUM_SMOKER"   
    a "Number of smokers", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_CIG_NOW, "==", :a_1
    
    q_SMOKE_INSIDE "Does anyone smoke inside the house?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.SMOKE_INSIDE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"	
    
    q_SMOKE_RULES "Which of the following statements describes the rules about smoking inside your home now?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.SMOKE_RULES"    
    a_1 "No one is allowed to smoke anywhere inside my home"
    a_2 "Smoking is allowed in some rooms at some times"
    a_3 "Smoking is permitted anywhere inside my home"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SMOKE_HOURS "On average, about how many hours per day do people smoke in the same room as {C_FNAME or YOUR CHILD}, 
    or near enough that {he/she} can see or smell the smoke? Please consider all the places {C_FNAME or YOUR CHILD} is during the day, 
    including at home, at daycare, or some other place.",
    :help_text => "If {he/she} is not exposed to smoke, enter \"0\".",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER_DETAIL.SMOKE_HOURS"
    a "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF CHILD_QNUM=CHILD_NUM, GO TO TIME_STAMP_17.
    # • IF CHILD_QNUM<CHILD_NUM, RETURN TO CHILD_QNUM (to ask questionnaire for next child).
  end
  section "Financial security", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_12 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_12"
    a :datetime, :custom_class => "datetime"  
    
    label "The next few questions are about whether you feel you have enough money for yourself and the people in your house."
    
    q_PAY_BILLS "How difficult is it for you and your family to pay your bills? Would you say it is...",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.PAY_BILLS"
    a_1 "Very difficult"
    a_2 "Somewhat difficult"
    a_3 "Not very difficult"
    a_4 "Not difficult at all"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_WIC "Since {C_FNAME or YOUR CHILD} was born, did you receive benefits from the WIC program, that is, the Women, 
    Infants and Children program?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.WIC"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FOOD_STAMP "Since {C_FNAME or YOUR CHILD} was born, did you or any members of your household receive Food Stamps 
    (which includes a food stamp card or voucher, or cash grants from the state for food)?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.FOOD_STAMP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_TANF "Since {C_FNAME or YOUR CHILD} was born, have you or any members of your household received TANF or welfare?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.TANF"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
  section "Household composition and demographics", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_13 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_13"
    a :datetime, :custom_class => "datetime"
    
    label "The next question is about the language spoken to your baby."
    
    q_NONENGLISH_FREQ "How often do you use a language other than English in speaking to {C_FNAME or YOUR CHILD}? Would you say...",
    :help_text => "Probe: \"We just need to know in general?\"",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.NONENGLISH_FREQ"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Often"
    a_4 "Very often"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_TIME_STAMP_14 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_14"
    a :datetime, :custom_class => "datetime"
    
    label "Family income is important in analyzing the data we collect and is often used in scientific studies to compare groups 
    of people who are similar. Please remember that all the data you provide is confidential."
    
    # TODO
    # PROGRAMMER INSTRUCTION:
    # • PRELOAD CURRENT YEAR MINUS 1.
    q_INCOME "Of these income groups, which category best represents your total combined family income during {CURRENT YEAR – 1}?",
    :help_text => "Read if necessary - Remember, a family is a group of two or more people who live together and who are 
    related by birth, marriage, or adoption. Show response options on card to participant.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.INCOME"
    a_1 "Less than $4,999"
    a_2 "$5,000-$9,999"
    a_3 "$10,000-$19,999"
    a_4 "$20,000-$29,999"
    a_5 "$30,000-$39,999"
    a_6 "$40,000-$49,999"
    a_7 "$50,000-$74,999"
    a_8 "$75,000-$99,999"
    a_9 "$100,000-$199,999"
    a_10 "$200,000 or more"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    # TODO
    # PROGRAMMER INSTRUCTION:
    # • PRELOAD LAST CALENDAR YEAR.
    q_INCOME2 "Thinking about all your family’s sources of income, what was your total family income in {LAST CALENDAR YEAR} 
    before taxes? Please note, a family is a group of two or more people who live together and who are related by birth, 
    marriage, or adoption.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.INCOME2"
    a_1 "$20,000 or more"
    a_2 "Less than $20,000"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A or B"
    condition_A :q_INCOME, "==", :a_neg_1
    condition_B :q_INCOME, "==", :a_neg_2
    
    q_FAM_SUPPORT "Are there any other family members, not living in this household, who are also supported by this income?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.FAM_SUPPORT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A or B"
    condition_A :q_INCOME2, "!=", :a_neg_1
    condition_B :q_INCOME2, "!=", :a_neg_2
        
    q_FAM_SUPPORT_NUM "How many other family members, not living in this household, are supported by this income?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_MOTHER.FAM_SUPPORT_NUM"
    a "Number", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_FAM_SUPPORT, "==", :a_1
    
    label "Thank you for answering these questions."
    dependency :rule => "A"
    condition_A :q_FAM_SUPPORT, "==", :a_1
  end
  section "Tracing questions", :reference_identifier=>"6MMother_INT" do
    q_TIME_STAMP_15 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_15"
    a :datetime, :custom_class => "datetime"
    
    label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember that all 
    the information you provide is confidential and will not be provided to anyone outside the National Children’s Study." 
    
    q_COMM_EMAIL "When we last spoke, we asked questions about communicating with you through your personal email. 
    Has your email address or your preferences regarding use of your personal email changed since then?", :pick=>:one,
    :data_export_identifier=>"SIX_MTH_MOTHER.COMM_EMAIL"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_HAVE_EMAIL "Do you have an email address?", :pick=>:one, 
    :data_export_identifier=>"SIX_MTH_MOTHER.HAVE_EMAIL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_COMM_EMAIL, "!=", :a_2
    
    group "Email information" do
      dependency :rule=>"A"
      condition_A :q_HAVE_EMAIL, "==", :a_1      

      q_EMAIL_2 "May we use your personal email address to make future study appointments or send appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.EMAIL_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EMAIL_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.EMAIL_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EMAIL "What is the best email address to reach you?", 
      :pick=>:one, 
      :help_text=>"Show example of valid email address such as janedoe@email.com", 
      :data_export_identifier=>"SIX_MTH_MOTHER.EMAIL"
      a_1 "Enter e-mail address:", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    q_COMM_CELL "When we last spoke, we asked questions about communicating with you through your personal cell 
    phone number. Has your cell phone number or your preferences regarding use of your personal cell phone number 
    changed since then?", :pick=>:one, 
    :data_export_identifier=>"SIX_MTH_MOTHER.COMM_CELL"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CELL_PHONE_1 "Do you have a personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"SIX_MTH_MOTHER.CELL_PHONE_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_COMM_CELL, "!=", :a_2

    q_CELL_PHONE_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
    :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.CELL_PHONE_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CELL_PHONE_1, "==", :a_1

    q_CELL_PHONE_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"SIX_MTH_MOTHER.CELL_PHONE_3"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CELL_PHONE_1, "==", :a_1      

    q_CELL_PHONE_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
    :data_export_identifier=>"SIX_MTH_MOTHER.CELL_PHONE_4"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CELL_PHONE_3, "==", :a_1 

    q_CELL_PHONE "What is your personal cell phone number?", :pick=>:one,
    :data_export_identifier=>"SIX_MTH_MOTHER.CELL_PHONE"
    a_1 "Phone number", :string
    a_neg_7 "Participant has no cell phone"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A and B" 
    condition_A :q_COMM_CELL, "!=", :a_2
    condition_B :q_CELL_PHONE_1, "==", :a_1

    q_TIME_STAMP_16 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_16"
    a :datetime, :custom_class => "datetime"
    
    q_COMM_CONTACT "Sometimes if people move or change their telephone number, we have difficulty reaching them. At our last visit, 
    we asked for contact information for two friends or relatives not living with you who would know where you could be reached in case we 
    have trouble contacting you. Has that information changed since our last visit?", 
    :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.COMM_CONTACT"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CONTACT_1 "Could I have the name of a friend or relative not currently living with you who should know where you could be reached 
    in case we have trouble contacting you?", 
    :pick=>:one, 
    :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_COMM_CONTACT, "!=", :a_2
    
    group "First contact information" do
      dependency :rule=>"A"
      condition_A :q_CONTACT_1, "!=", :a_1
          
      q_CONTACT_FNAME_1 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_FNAME_1"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_LNAME_1 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_LNAME_1"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE_1 "What is his/her relationship to you?", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_RELATE_1"
      a_1 "Mother/father"
      a_2 "Brother/sister"
      a_3 "Aunt/uncle"
      a_4 "Grandparent"
      a_5 "Neighbor"
      a_6 "Friend"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_CONTACT_RELATE1_OTH "Other relationship of contact", 
      :pick=>:one,
      :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_RELATE1_OTH"      
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CONTACT_RELATE_1, "==", :a_neg_5

      label "What is his/her address?",
      :help_text => "Prompt as necessary to complete information"

      q_C_ADDR1_1 "Address 1 - street/PO Box", 
      :pick=>:one,
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ADDR1_1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ADDR_2_1 "Address 2", 
      :pick=>:one,
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ADDR_2_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_UNIT_1 "Unit", 
      :pick=>:one,
      :data_export_identifier=>"SIX_MTH_MOTHER.C_UNIT_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_CITY_1 "City", 
      :pick=>:one,      
      :data_export_identifier=>"SIX_MTH_MOTHER.C_CITY_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_STATE_1 "State", 
      :pick=>:one,
      :display_type=>"dropdown", 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_STATE_1"
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

      q_C_ZIPCODE_1 "ZIP Code", 
      :pick=>:one,      
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ZIPCODE_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ZIP4_1 "ZIP+4", 
      :pick=>:one,      
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ZIP4_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_PHONE_1 "What is his/her telephone number?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_PHONE_1"
      a_1 "Phone number", :string
      a_neg_7 "Contact has no telephone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    group "Second contact name information" do 
      dependency :rule=>"A and B"
      condition_A :q_COMM_CONTACT, "!=", :a_2
      condition_A :q_CONTACT_1, "==", :a_1
      
      label "Now I’d like to collect information on a second contact who does not currently live with you.",
      :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_2"

      q_CONTACT_FNAME_2 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_FNAME_2"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_LNAME_2 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_LNAME_2"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    group "Second contact additional information" do 
      dependency :rule=>"A and B"
      condition_A :q_CONTACT_FNAME_2, "==", :a_1
      condition_A :q_CONTACT_LNAME_2, "==", :a_1
      
      q_CONTACT_RELATE_2 "What is his/her relationship to you?", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_RELATE_2"
      a_1 "Mother/father"
      a_2 "Brother/sister"
      a_3 "Aunt/uncle"
      a_4 "Grandparent"
      a_5 "Neighbor"
      a_6 "Friend"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE2_OTH "Other relationship of second contact", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_RELATE_2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CONTACT_RELATE_2, "==", :a_neg_5
    
      label "What is his/her address?",
      :help_text => "Prompt as necessary to complete information"

      q_C_ADDR1_2 "Address 1 - street/PO Box", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ADDR1_2"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_C_ADDR_2_2 "Address 2", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ADDR_2_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_C_UNIT_2 "Unit", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_UNIT_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_C_STATE_2 "City", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_CITY_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_C_STATE_2 "State", 
      :pick=>:one, 
      :display_type=>"dropdown", 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_STATE_2"
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

      q_C_ZIPCODE_2 "ZIP Code", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ZIPCODE_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_C_ZIP4_2 "ZIP+4", 
      :pick=>:one, 
      :data_export_identifier=>"SIX_MTH_MOTHER.C_ZIP4_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_CONTACT_PHONE_2 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, :data_export_identifier=>"SIX_MTH_MOTHER.CONTACT_PHONE_2"
      a_1 "Phone number", :string
      a_7 "Contact has no phone"    
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
    end 
    q_hipv1_TIME_STAMP_17 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_MOTHER.TIME_STAMP_17"
    a :datetime, :custom_class => "datetime"
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.",
    :help_text => "Explain SAQs and return process",
    :data_export_identifier=>"SIX_MTH_MOTHER.END"
  end
end