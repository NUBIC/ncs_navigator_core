survey "INS_QUE_9MMother_INT_EHPBHI_P2_V1.1" do
  section "Interview introduction", :reference_identifier=>"9MMother_INT" do
    q_time_stamp_1 "Insert date/time stamp", :data_export_identifier=>"NINE_MTH_MOTHER.TIME_STAMP_1"
    a :datetime
    
    label "Hello. I’m [INTERVIEWER NAME] calling from the National Children’s Study. I’m calling today to ask you 
    some questions about you and your baby. We realize that you are busy, and this call should take only about 10 minutes. 
    I will ask you questions about your baby’s health and behavior. Your answers are very important to us. There are no 
    right or wrong answers. You can skip over any question or stop the interview at any time. We will keep everything that 
    you tell us confidential. "
  end
  section "Interviewer completed questions", :reference_identifier=>"9MMother_INT" do
    label "Do not administer these questions to the participant."

    q_MULT_CHILD "Is there more than one child of this mother eligible for the 9-month call today?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER.MULT_CHILD"
    a_1 "Yes"
    a_2 "No"

    q_CHILD_NUM "How many children in this household are eligible for the 9-month call today?",
    :data_export_identifier=>"NINE_MTH_MOTHER.CHILD_NUM"
    a "Number of children", :integer
    dependency :rule=>"A"
    condition_A :q_MULT_CHILD, "==", :a_1

# TODO    
    # PROGRAMMER INSTRUCTION:
    # • IF MULT_CHILD = 1, COMPLETE ENTIRE QUESTIONNAIRE FOR FIRST CHILD.  THEN LOOP THROUGH INTERVIEWER-COMPLETED QUESTIONS 
    # STARTING AT CHILD_QNUM AND PROCEED THROUGH THE REMAINDER OF THE QUESTIONNAIRE FOR EACH ELIGIBLE CHILD RECORDED IN CHILD_NUM.

    q_CHILD_QNUM "Which number child is this questionnaire for?",
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.CHILD_QNUM"
    a_which_child "Number", :integer

    # TODO
    #     PROGRAMMER INSTRUCTION:
    #     •	CHILD_QNUM CANNOT BE GREATER THAN CHILD_NUM.
    q_CHILD_SEX "Is {CHILD_QNUM} a male or a female?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_3 "Both"
    
    # TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • IF CHILD_SEX = 1, DISPLAY “his” AND “he” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 2, DISPLAY “her” AND “she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 3, DISPLAY “him/her” AND “he/she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    
    q_RESP_REL "What is the relationship of participant to child?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.RESP_REL"
    a_1 "Mother"
    a_2 "Father"
    a_3 "Other"
    
    q_RESP_REL_OTH "Other relationship?", 
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.RESP_REL_OTH"
    a "Specify", :string
    dependency :rule=>"A"
    condition_A :q_RESP_REL, "==", :a_3
  end
  section "Participant verification", :reference_identifier=>"6MMother_INT" do
    label "First, we’d like to make sure we have your child’s correct name and birth date."
    
#     TODO - the name should be pre-populated    
    q_prepopulated_name "Name:"
    a :string

    # TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • PRELOAD CHILD’S NAME IF COLLECTED PREVIOUSLY.
    # • IF CNAME_CONFIRM= 1, SET C_FNAME/C_LNAME TO KNOWN VALUE.

    q_CNAME_CONFIRM "Is your baby’s name {INSERT NAME}?", 
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.CNAME_CONFIRM", :pick=>:one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • IF C_FNAME AND C_LNAME=-1 or -2, SUBSTITUTE “YOUR CHILD” FOR C_FNAME IN REMAINER OF QUESTIONNAIRE.

    label "What is your child’s full name?",
    :help_text => "If participant refuses to provide information, re-state confidentiality 
    protections, ask for initials or some other name she would like her child to be called. 
    Confirm spelling of first name if not previously collected and of last name for all children."

    q_C_FNAME "First name", :pick => :one, 
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.C_FNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CNAME_CONFIRM, "!=", :a_1

    q_C_LNAME "Last name", :pick => :one, 
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.C_LNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CNAME_CONFIRM, "!=", :a_1
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # •  PRELOAD CHILD’S DOB IF COLLECTED PREVIOUSLY AS MM/DD/YYYY.
    # • IF CNAME_CONFIRM = 1, SET C_FNAME C_LNAME TO KNOWN VALUE.
    #   • IF CDOB_CONFIRM = 1, RESPONSE = YES, SET CHILD_DOB TO KNOWN VALUE.
    q_prepopulated_childs_birth_date "Child's birth date"
    a :string
    
    # TODO: Is {C_FNAME or YOUR CHILD}’S birth date  {CHILD’S DATE OF BIRTH}
    q_CDOB_CONFIRM "Is {C_FNAME/YOUR CHILD}’S birth date {CHILD’S DATE OF BIRTH}?", 
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and 
    that DOB helps determine eligibility.",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.CDOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
     
    q_CHILD_DOB "What is {C_FNAME/YOUR CHILD}’s date of birth?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and 
    that DOB helps determine eligibility. If response was determined to be invalid, ask question again and probe for valid response. 
    Format as YYYYMMDD",
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.CHILD_DOB",
    :pick => :one
    a "Date", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    # TODO:
    #     PROGRAMMER INSTRUCTIONS:
    # • INCLUDE A SOFT EDIT/WARNING IF CALCULATED AGE IS LESS THAN 8 MONTHS OR GREATER THAN 11 MONTHS.
    # • FORMAT CHILD_DOB AS YYYYMMDD.
    q_calculated_age "Interviewer instructions: Calculated age (months)?",
    :help_text => "If it appears that the calculated age of the baby is less than 8 months or greater than 11 months, please verify"
    a :integer
    
    q_time_stamp_2 "Insert date/time stamp", :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.TIME_STAMP_2"
    a :datetime       
  end
  section "Child development and parenting", :reference_identifier=>"6MMother_INT" do
    label "First, I will read you a list of things {C_FNAME/YOUR CHILD} may already do or may start 
    doing when {he/she} gets older. Does {C_FNAME/YOUR CHILD}:"  
    
    q_EYES_FOLLOW "Follow you with {his/her} eyes?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.EYES_FOLLOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SMILE "Smile when you smile at {him/her}?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SMILE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_REACH_1 "Try to get a toy that is out of reach?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.REACH_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FEED "Feed {him/herself} a cracker or cereal?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.FEED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_WAVE "Wave goodbye?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.WAVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRAB "Grab an object like a block or rattle from you?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.GRAB"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    

    q_SWITCH_HANDS "Move a toy or block from one hand to the other?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SWITCH_HANDS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PICKUP "Pick up a small object like a Cheerio or raisin?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.PICKUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_HOLD "Hold two toys or blocks at a time, one in each hand?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.HOLD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
        
    q_SOUND_3 "Turn toward someone when they’re speaking?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SOUND_3"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SPEAK_1 "Make sounds as though {he/she} is trying to speak?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SPEAK_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SPEAK_2 "Say mama or dada?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SPEAK_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"   
    
    q_HEADUP "Keep head steady when sitting or held up?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.HEADUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    
   
    q_ROLL_2 "Roll from back to stomach?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.ROLL_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SITUP "Sit up by {himself/herself}?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SITUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_STAND "Stand while holding onto something?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.STAND"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_STAND_ALONE "Stand alone, without holding onto something?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.STAND_ALONE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_WALK "Walk by {himself/herself}, without holding onto something?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.WALK"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SCRIBBLE "Scribble or draw with a pencil, crayon, or marker?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SCRIBBLE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FORK_SPOON "Try to use a fork or spoon when eating?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.FORK_SPOON"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"           
   
    q_time_stamp_3 "Insert date/time stamp", :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.TIME_STAMP_3"
    a :datetime
  end
  section "Health care", :reference_identifier=>"9MMother_INT" do
    q_C_HEALTH "Would you say {C_FNAME/YOUR CHILD}’s health in general is poor, fair, good, or excellent?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.C_HEALTH"
    a_1 "Poor"
    a_2 "Fair"
    a_3 "Good"
    a_4 "Excellent"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "The next questions are about where {C_FNAME} goes for health care."
    
    q_R_HCARE "First, what kind of place does {C_FNAME/YOUR CHILD} usually go to when {he/she} needs routine or well-child care, 
    such as a check-up or well-baby shots (immunizations)?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.R_HCARE"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_7 "Doesn't get well-child care anywhere"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_LAST_VISIT "What was the date of {C_FNAME/YOUR CHILD}’s most recent well-child visit or checkup?",
    :help_text => "Show calendar to assist in date recall. Format as YYYYMMDD",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.LAST_VISIT"
    a_date "Date", :string
    a_neg_7 "Has not had a visit"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A or B or C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2
    
    q_VISIT_WT "What was {C_FNAME/YOUR CHILD}’s weight at that visit?",
    :help_text => "Please verify if weight < 13 or > 26 pounds",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.VISIT_WT"
    a_weight "Pounds", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A or B or C"
    condition_A :q_LAST_VISIT, "==", :a_date
    
    q_SAME_CARE "If {C_FNAME/YOUR CHILD} is sick or if you have concerns about {his/her} health, does {he/she} go to 
    the same place as for well-child visits?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.SAME_CARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_7 "Has not been sick"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule => "A or B or C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2    
    
    q_HCARE_SICK "What kind of place does {C_FNAME/YOUR CHILD} usually go to when {he/she} is sick, doesn’t feel 
    well, or if you have concerns about {his/her} health?",
    :pick => :one,
    :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.HCARE_SICK"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_7 "Has not been sick"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A or B"
    condition_A :q_SAME_CARE, "!=", :a_1
    condition_B :q_SAME_CARE, "!=", :a_neg_7
    
    q_time_stamp_4 "Insert date/time stamp", :data_export_identifier=>"NINE_MTH_MOTHER_DETAIL.TIME_STAMP_4"
    a :datetime
    
    label "Thank you for your time and for being a part of this important research study. This is the end of our interview.",
    :help_text => "Include information about next contact (12-month home visit) and verification of contact information."
  end
end