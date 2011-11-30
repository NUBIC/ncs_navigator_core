survey "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1" do
  section "Interview introduction", :reference_identifier=>"THREE_MTH_MOTHER" do

    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"THREE_MTH_MOTHER.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Hello. I’m [INTERVIEWER NAME] calling from the National Children’s Study. I’m calling today to ask you
    some questions about you and your baby. We realize that you are busy, and this call should take only about 20 minutes.
    I will ask you questions about your baby’s health and behavior and your household. Your answers are very important to us.
    There are no right or wrong answers. You can skip over any question or stop the interview at any time. We will keep
    everything that you tell us confidential."
  end
  section "Interviewer completed questions", :reference_identifier=>"THREE_MTH_MOTHER" do
    q_MULT_CHILD "Is there more than one child in this household eligible for the 3-month call today?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER.MULT_CHILD"
    a_1 "Yes"
    a_2 "No"

    q_CHILD_NUM "How many children in this household are eligible for the 3-month call today?",
    :data_export_identifier=>"THREE_MTH_MOTHER.CHILD_NUM"
    a_number "Number of children", :integer

    # PROGRAMMER INSTRUCTION:
    # • CHILD_QNUM CANNOT BE GREATER THAN CHILD_NUM

    q_CHILD_QNUM "Which number child is this questionnaire for?",
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_QNUM"
    a "Number", :integer

    q_CHILD_SEX "Is the child a male or female?",:pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_3 "Both"

    # PROGRAMMER INSTRUCTIONS:
    # • IF CHILD_SEX = 1, DISPLAY “his” AND “he” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT
    # • IF CHILD_SEX = 2, DISPLAY “her” AND “she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 3, DISPLAY “him/her” AND “he/she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.

    q_RESP_REL "What is the relationship of participant to child?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.RESP_REL"
    a_1 "Mother"
    a_2 "Father"
    a_3 "Other"

    q_RESP_REL_OTH "Other relationship",
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.RESP_REL_OTH"
    a_1 "Specify", :string
    dependency :rule=>"A"
    condition_A :q_RESP_REL, "==", :a_3
  end
  section "Participant verification", :reference_identifier=>"THREE_MTH_MOTHER" do
    label "First, we’d like to make sure we have your child’s correct name and birth date."

    q_prepopulated_baby_name "Baby's name:"
    a :string

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • PRELOADCHILD’S NAME IF BABY_NAME COLLECTED AT BIRTH INTERVIEW.
    # • IF CNAME_CONFIRM = 1, SET C_FNAME C_LNAME TO KNOWN VALUE.

    q_CNAME_CONFIRM "Is that your baby’s name?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CNAME_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Baby's information" do
    dependency :rule=>"A"
    condition_A :q_CNAME_CONFIRM , "!=", :a_1

      label "What is your baby’s full name?",
      :help_text => "If participant refuses to provide information, re-state confidentiality
      protections, ask for initials or some other name she would like her child to be called.
      Confirm spelling of first name if not previously collected and of last name for all children."

      q_C_FNAME "First name",
      :pick => :one,
      :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.C_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_LNAME "Last name",
      :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.C_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    # PROGRAMMER INSTRUCTION:
    # •	IF C_FNAME AND C_LNAME = -1 or -2, SUBSTITUTE “YOUR CHILD” FOR C_FNAME IN REMAINER OF QUESTIONNAIRE.

    q_prepopulated_childs_birth_date "Child's birth date"
    a :string

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • PRELOAD CHILD_DOB COLLECTED AT BIRTH INTERVIEWAS MM/DD/YYYY.
    # • IF CDOB_CONFIRM =1, SET CHILD_DOB TO KNOWN VALUE.

    # TODO: Is {C_FNAME/YOUR CHILD}’S birth date {CHILD’S DATE OF BIRTH}
    q_CDOB_CONFIRM "Is this {C_FNAME/YOUR CHILD}’s birth date?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and
    that DOB helps determine eligibility.",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CDOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # PROGRAMMER INSTRUCTIONS:
    #     • PRELOAD CHILD_DOB COLLECTED AT BIRTH INTERVIEWAS MM/DD/YYYY.
    #     •	IF CDOB_CONFIRM =1, SET CHILD_DOB TO KNOWN VALUE.

    q_CHILD_DOB "What is {C_FNAME/YOUR CHILD}’s date of birth?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and
    that DOB helps determine eligibility. If response was determined to be invalid, ask question again and probe for valid response.
    Please verify if calculated age in months is less than 2 months or greater than 5 months",
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_DOB"
    a :string
    dependency :rule=>"A"
    condition_A :q_CDOB_CONFIRM , "!=", :a_1

    # TODO:
    #     PROGRAMMER INSTRUCTIONS:
    #     • INCLUDE A SOFT EDIT/WARNING IF CALCULATED AGE IS LESS THAN 2 MONTHS OR GREATER THAN 5 MONTHS.
    #     •	FORMAT CHILD_DOB AS YYYYMMDD.

    q_time_stamp_2 "Insert date/time stamp", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"

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
        # Nataliya's comment ont the statement above - should it be IF CHILD_NUM>1

    q_prev_questionare "Interviewer instructions: was mother enrolled prior to or during pregnancy
    and has completed at least one questionnaire before birth", :pick => :one
    a_1 "Yes"
    a_2 "No"
  end
  section "Demographics", :reference_identifier=>"THREE_MTH_MOTHER" do
    group "Demographics Info" do
    dependency :rule => "A"
    condition_A :q_prev_questionare, "==", :a_2

      q_MARISTAT "I’d like to ask about your marital status. Are you:",
      :help_text => "Record the participant’s current marital status", :pick => :one,
      :data_export_identifier=>"THREE_MTH_MOTHER.MARISTAT"
      a_1 "Married,"
      a_2 "Not married but living together with a partner"
      a_3 "Never been married,"
      a_4 "Divorced,"
      a_5 "Separated, or"
      a_6 "Widowed?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EDUC "What is the highest degree or level of school you have completed?",
      :help_text => "If using showcards, refer participant to appropriate showcard. Otherwise, read response categories to participant.",
      :pick => :one,
      :data_export_identifier=>"THREE_MTH_MOTHER.EDUC"
      a_1 "Less than a high school diploma or GED"
      a_2 "High school diploma or GED"
      a_3 "Some college but no degree"
      a_4 "Associate degree"
      a_5 "Bachelor's degree (for example, BA, BS)"
      a_6 "Post graduate degree (for example, MAsters Or Doctoral)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ETHNICITY "Do you consider yourself to be Hispanic, or Latina?", :pick => :one,
      :data_export_identifier=>"THREE_MTH_MOTHER.ETHNICITY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_RACE "What race do you consider yourself to be? You may select one or more.",
      :help_text => "Probe: Anything else? Code \"Other\" only if volunteered. Select all that apply", :pick => :any,
      :data_export_identifier=>"THREE_MTH_MOTHER_RACE.RACE"
      a_1 "White,"
      a_2 "Black or African American,"
      a_3 "American Indian or Alaska Native"
      a_4 "Asian, or"
      a_5 "Native Hawaiian or Other Pacific Islander"
      a_6 "Multi Racial"
      a_neg_5 "Some other race?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_RACE_OTH "Other race",
      :pick=>:one,
      :data_export_identifier=>"THREE_MTH_MOTHER_RACE.RACE_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
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

      q_HH_MEMBERS "How many household members are supported by your total combined family income?",
      :help_text => "Please verify if response < 0 or > 15",
      :pick=>:one,
      :data_export_identifier=>"THREE_MTH_MOTHER.HH_MEMBERS"
      a_1 "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NUM_CHILD "How many of those people are children? Please include anyone under 18 years or anyone
      older than 18 years and in high school.",
      :help_text => "Please verify if responce is higher than the answer above. The suggested range is > 0 and < 10",
      :pick=>:one,
      :data_export_identifier=>"THREE_MTH_MOTHER.NUM_CHILD"
      a_1 "Enter response", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # PROGRAMMER INSTRUCTION:
      # • IF USING SHOWCARDS, DISPLAY RESPONSE CATEGORIES IN ALL CAPITAL LETTERS.  OTHERWISE, DISPLAY RESPONSE CATEGORIES AS MIXED UPPER/LOWER CASE PER BELOW.

      q_INCOME_4CAT "Of these income groups, which category best represents your combined family income during the
      last calendar year?",
      :help_text => "If using showcards, refer participant to appropriate showcard. Otherwise, read response categories to participant.",
      :pick=>:one,
      :data_export_identifier=>"THREE_MTH_MOTHER.INCOME_4CAT"
      a_1 "Less than $30,000"
      a_2 "$30,000 - $49,999"
      a_3 "$50,000 - $99,999"
      a_4 "$100,000 or more"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"THREE_MTH_MOTHER.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"

    q_HH_PRIMARY_LANG "What is the primary language spoken in your home?", :pick => :any,
    :data_export_identifier=>"THREE_MTH_MOTHER.HH_PRIMARY_LANG"
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
    a_neg_2 "Don't know"

    q_PERSON_LANG_OTH "Other primary languages that are spoken in your home",
    :pick=>:one,
    :data_export_identifier=>"THREE_MTH_MOTHER.PERSON_LANG_OTH"
    a_1 "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A and (B and C)"
    condition_A :q_HH_PRIMARY_LANG , "==", :a_neg_5
    condition_B :q_HH_PRIMARY_LANG , "!=", :a_neg_1
    condition_C :q_HH_PRIMARY_LANG , "!=", :a_neg_2
  end
  section "Sleep", :reference_identifier=>"THREE_MTH_MOTHER" do
    label "Now, I’ll begin by asking you about {C_FNAME/YOUR CHILD}’s sleeping habits."

    q_SLEEP_PLACE_1 "Does your baby usually sleep in your bedroom or in a different room at night?", :pick =>:one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_1"
    a_1 "In participant’s room"
    a_2 "In a different room"
    a_3 "Both in participant’s room and a different room"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_PLACE_2 "What does {C_FNAME/YOUR CHILD} sleep in at night?", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_2"
    a_1 "A bassinette,"
    a_2 "A crib,"
    a_3 "A co-sleeper,"
    a_4 "In the bed or other place with you, or"
    a_neg_5 "In something else?"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_PLACE_2_OTH "Other sleeping arrangement", :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_2_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_SLEEP_PLACE_2, "==", :a_neg_5

    q_SLEEP_POSITION_NIGHT "In what position do you most often lay {C_FNAME/YOUR CHILD} down to sleep at night? On his/her.",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_POSITION_NIGHT"
    a_1 "Stomach,"
    a_2 "Back, or"
    a_3 "Side?"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_HRS_DAY "Approximately how many hours does {C_FNAME/YOUR CHILD} sleep during the day?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_HRS_DAY"
    a "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_HRS_NIGHT "Approximately how many hours does {C_FNAME/YOUR CHILD} sleep at night?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_HRS_NIGHT"
    a "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_DIFFICULT "How often is your baby difficult when {he/she} is put to bed?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_DIFFICULT"
    a_1 "Most of the time,"
    a_2 "Often,"
    a_3 "Sometimes,"
    a_4 "Rarely, or"
    a_5 "Never?"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
  section "Crying patterns", :reference_identifier=>"THREE_MTH_MOTHER" do
    label "All babies fuss and cry sometimes. I’m now going to ask you some questions to get a better
    idea of your baby’s crying patterns."

    q_CRY_MORE "Compared to other babies, do you think {C_FNAME/YOUR CHILD} cries more, the same or less?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_MORE"
    a_1 "More"
    a_2 "The same"
    a_3 "Less"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CRY_CONSOLE "Can you usually calm or console {C_FNAME/YOUR CHILD} when {he/she} cries?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_CONSOLE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CRY_COLIC "Does {C_FNAME/YOUR CHILD} have episodes of colic, or times when {he/she} cries and can’t be calmed or consoled?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_COLIC"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_COLIC_FREQ "How often does {C_FNAME/YOUR CHILD} have episodes of colic, or times when {he/she} cries and can’t be
    calmed or consoled:",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.COLIC_FREQ"
    a_1 "Every day,"
    a_2 "Most days,"
    a_3 "Sometimes, or"
    a_4 "Rarely?"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CRY_COLIC, "==", :a_1

    q_CRY_PROBLEM "Are you finding {C_FNAME/YOUR CHILD}’s crying to be a problem or upsetting?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CRY_PROBLEM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
  section "Child development and parenting", :reference_identifier=>"THREE_MTH_MOTHER" do
    # TODO:
    #     PROGRAMMER INSTRUCTION:
    #     •	USING CHILD_DOB CALCULATE CHILD’S AGE TO THE NEAREST MONTH AND PRELOAD.
    label "Even though {C_FNAME/YOUR CHILD} is only {AGE OF CHILD IN MONTHS} months old,
    {he/she} may show emotions or other actions. Overall, would you describe your baby as:",
    :help_text => "Interviewer instruction: Using child_dob calculate child’s age to the nearest month"

    q_CALM "Calm?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CALM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_WORRIED "Worried?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.WORRIED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SOCIAL "Sociable or outgoing?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SOCIAL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ANGRY "Angry?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.ANGRY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SHY "Shy or quiet?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SHY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_STUBBORN "Stubborn?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.STUBBORN"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_HAPPY "Happy?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HAPPY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    label "I’d like to ask about {C_FNAME/YOUR CHILD} and you. I will read you a list of things {C_FNAME/YOUR CHILD}
    may already do or may start doing when {he/she} gets older. Does {C_FNAME/YOUR CHILD}:"

    q_EYES_FOLLOW "Follow you with {his/her} eyes?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.EYES_FOLLOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SMILE "Smile when you smile at {him/her}?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SMILE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_REACH_1 "Try to get a toy that is out of reach?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.REACH_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_FEED "Feed {him/herself} a cracker or cereal?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.FEED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_WAVE "Wave goodbye?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.WAVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_REACH_2 "Reach for toys or food held to {him/her}",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.REACH_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_GRAB "Grab an object like a block or rattle from you?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.GRAB"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SWITCH_HANDS "Move a toy or block from one hand to the other?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SWITCH_HANDS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_PICKUP "Pick up a small object like a Cheerio or raisin?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.PICKUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_HOLD "Hold two toys or blocks at a time, one in each hand?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HOLD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SOUND_2 "Turn towards a sound?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SOUND_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SOUND_3 "Turn toward someone when they’re speaking?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SOUND_3"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SPEAK_1 "Make sounds as though {he/she} is trying to speak?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SPEAK_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SPEAK_2 "Say mama or dada?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SPEAK_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_HEADUP "Keep head steady when sitting or held up?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HEADUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ROLL_1 "Roll over from stomach to back?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.ROLL_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ROLL_2 "Roll from back to stomach?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.ROLL_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.TIME_STAMP_4"
    a :datetime, :custom_class => "datetime"
  end
  section "Child care arrangements", :reference_identifier=>"THREE_MTH_MOTHER" do

    label "Next, I’d like to ask you about different types of child care {C_FNAME/YOUR CHILD} may receive from someone
    other than parents or guardians. This includes regularly scheduled care arrangements with relatives and non-relatives,
    and day care or early childhood programs, whether or not there is a charge or fee, but not occasional baby-sitting."

    q_CHILDCARE "Does {C_FNAME/YOUR CHILD} currently receive any regularly scheduled care from someone other than a parent or guardian.
    For example, from relatives, non-relatives, or a child care center or program?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.CHILDCARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Childcare Information" do
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1

      q_FAMILY_CARE_HRS "I’d like you to think about all the care {C_FNAME/YOUR CHILD} receives from relatives.
      For example, from grandparents, brothers or sisters, or any other relatives. (This includes all regularly scheduled
      care arrangements with relatives that happen at least weekly, but does not include occasional baby-sitting.)
      Including all of these regular arrangements, how many total hours each week does {C_FNAME/YOUR CHILD} receive
      care from relatives?",
      :pick => :one,
      :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.FAMILY_CARE_HRS"
      a "Hours", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"


      q_HOMECARE_HRS "I’d like you to think about all the regularly scheduled care your child receives on a weekly basis
      from non-relatives in a home setting. (This includes all regularly scheduled care arrangements with non-relatives that
      happen at least weekly, including home child care providers, regularly scheduled sitter arrangements, or neighbors.
      This does not include day care centers, early childhood programs, or occasional babysitting.)
      Including all of these arrangements, how many total hours each week does {C_FNAME/YOUR CHILD} receive care from
      non-relatives in a home setting?",
      :pick => :one,
      :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HOMECARE_HRS"
      a "Hours", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DAYCARE_HRS "I’d like you to think about all the care your child receives from child care centers. For example,
      day care centers, early learning centers, nursery schools, and preschools. (This includes all regularly scheduled care
      arrangements in child care centers that happen at least weekly.) Including all of these arrangements, how many total
      hours each week does {C_FNAME/YOUR CHILD} receive care at child care centers?",
      :pick => :one,
      :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.DAYCARE_HRS"
      a "Hours", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    q_time_stamp_5 "Insert date/time stamp", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.TIME_STAMP_5"
    a :datetime, :custom_class => "datetime"
  end
  section "Health care", :reference_identifier=>"THREE_MTH_MOTHER" do
    q_C_HEALTH "Since {C_FNAME/YOUR CHILD} was born, would you say {his/her} health has been poor, fair, good, excellent?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.C_HEALTH"
    a_1 "Poor"
    a_2 "Fair"
    a_3 "Good"
    a_4 "Excellent"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

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
    a_6 "Doesn't go to one place most often"
    a_7 "Doesn't get well-child care anywhere"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_LAST_VISIT "What was the date of {C_FNAME/YOUR CHILD}’s most recent well-child visit or check-up?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.LAST_VISIT"
    a_date "Date", :string, :custom_class => "date"
    a_neg_7 "Has not had a visit"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A and B and C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2

    q_VISIT_WT "What was {C_FNAME/YOUR CHILD}’s weight at that visit?",
    :help_text => "Please verify if response < 8 or > 21 pounds.",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.VISIT_WT"
    a_pounds "Pounds", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency  :rule => "A"
    condition_A :q_LAST_VISIT, "==", :a_date

    q_SAME_CARE "If {C_FNAME/YOUR CHILD} is sick or if you have concerns about {his/her} health, does {he/she} go to
    the same place as for well-child visits?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SAME_CARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_7 "Has not been sick"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency  :rule => "A and B and C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2

    q_HCARE_SICK "What kind of place does {C_FNAME/YOUR CHILD} usually go to when {he/she} is sick, doesn’t feel well,
    or if you have concerns about {his/her} health?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HCARE_SICK"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_neg_7 "Has not been sick"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A or B or C or D or E"
    condition_A :q_SAME_CARE, "!=", :a_1
    condition_B :q_SAME_CARE, "!=", :a_neg_7
    condition_C :q_R_HCARE, "==", :a_7
    condition_D :q_R_HCARE, "==", :a_neg_1
    condition_E :q_R_HCARE, "==", :a_neg_2

    q_HOSPITAL "After coming home from the hospital the first time, has your child spent at least one night in the hospital?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.HOSPITAL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_DIAGNOSIS "Did a doctor or other health care provider give your child a diagnosis?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.DIAGNOSIS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_HOSPITAL, "==", :a_1

    q_DIAGNOSIS_SPECIFY "What was the diagnosis?",
    :pick => :one,
    :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.DIAGNOSIS_SPECIFY"
    a "DIAGNOSES", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_DIAGNOSIS, "==", :a_1

    q_time_stamp_6 "Insert date/time stamp", :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.TIME_STAMP_6"
    a :datetime, :custom_class => "datetime"

    # TODO - questionare for the second baby


    label "Thank you for your time and for being a part of this important research study. This is the end of our interview.",
    :help_text => "Include information about next contact (6 month home visit) and verification of contact information."
  end
end
