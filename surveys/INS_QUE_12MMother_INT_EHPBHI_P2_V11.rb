survey "INS_QUE_12MMother_INT_EHPBHI_P2_V1.1" do
  section "Interview introduction", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Thank you for agreeing to participate in the National Children’s Study. This interview will take about 30 minutes to 
    complete. Your answers are important to us. There are no right or wrong answers, just those that help us understand your 
    situation. During this interview, we will ask you about yourself, your {CHILD/ CHILDREN}, your health, where you live, and 
    your feelings about being a part of the National Children’s Study. You can skip over any questions or stop the interview at 
    any time. We will keep everything that you tell us confidential."
  end
  section "Interview introduction", :reference_identifier=>"12MMother_INT" do
    q_MULT_CHILD "Is there more than one child of this mother eligible for the 12 month visit today?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.MULT_CHILD"
    a_1 "Yes"
    a_2 "No"
    
    q_CHILD_NUM "How many children of this mother are eligible for the 12-month visit today?",
    :data_export_identifier=>"TWELVE_MTH_MOTHER.CHILD_NUM"
    a "Number of children", :integer
    dependency :rule=>"A"
    condition_A :q_MULT_CHILD, "==", :a_1  
    
# TODO
#     PROGRAMMER INSTRUCTION: 
#     • IF MULT_CHILD = 1; COMPLETE QUESTIONNAIRE FOR EACH ELIGIBLE CHILD RECORDED IN CHILD_NUM:
#     o COMPLETE CHILD_SEX, PARTICIPANT VERIFICATION, CHILD DEVELOPMENT AND PARENTING, CHILD CARE ARRANGEMENTS, HEALTH CARE, MEDICAL 
#       CONDITIONS, HEALTH INSURANCE, PRODUCT USE
#     o SKIP TO SMOKE_HOURS
#     o LOOP BACK TO CHILD_QNUM
#     o IF CHILD_QNUM > 1, GO TO CHILD_QNUM AND LOOP THROUGH QUESTIONNIARE THROUGH HB012 SMOKE_HOURS FOR EACH CHILD UNTIL 
#       CHILD_NUM = CHILD_QNUM. THEN GO TO END.
      
    q_CHILD_QNUM "Which number child is this questionnaire for?",
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.CHILD_QNUM"
    a_which_child "Number", :integer
    dependency :rule=>"A"
    condition_A :q_MULT_CHILD, "==", :a_1    

# TODO
#     PROGRAMMER INSTRUCTION: 
#     • CHILD_QNUM CANNOT BE GREATER THAN CHILD_NUM

    q_CHILD_SEX "Is CHILD_QNUM a male or female?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_3 "Both"

# TODO
# PROGRAMMER INSTRUCTION: 
# • USE CHILD_SEX TO CODE {his/her} AND {he/she} FIELDS AS APPROPRIATE THROUGHOUT INSTRUMENT

  end 
  section "Participant verification", :reference_identifier=>"12MMother_INT" do

    label "I’d like to ask about your next child."
    dependency :rule=>"A"
    condition_A :q_CHILD_QNUM, ">", {:integer_value => "1"}
    
    label "First, we’d like to make sure we have your child’s correct name and birth date."
    
    q_prepopulated_name "Name:"
    a :string

#     TODO - the name should be pre-populated
    q_CNAME_CONFIRM "Is this your child’s name?", 
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.CNAME_CONFIRM", :pick=>:one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    # TODO
    # PROGRAMMER INSTRUCTION: 
    # • INSERT CHILD’S NAME IF KNOWN. IF CHILD’S NAME NOT KNOWN, GO TO C_FNAME/C_LNAME.

    group "Child's information" do
      dependency :rule=>"A"
      condition_A :q_CNAME_CONFIRM, "!=", :a_1
      
      label "What is your child’s full name?",
      :help_text => "If participant refuses to provide information, re-state confidentiality 
      protections, ask for initials or some other name she would like her child to be called. 
      Confirm spelling of first name if not previously collected and of last name for all children."
    
      q_C_FNAME "First name", :pick => :one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.C_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_LNAME "Last name", :pick => :one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.C_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    # TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • IF PARTICIPANT REFUSES TO PROVIDE NAME, INITIALS OR IDENTIFIER C_FNAME AND C_LNAME=-1, USE “YOUR CHILD” FOR C_FNAME 
    # IN REMAINDER OF QUESTIONNAIRE.
    
    # TODO
    #     PROGRAMMER INSTRUCTIONS: 
    #     • PRELOAD CHILD’S DOB IF KNOWN AS MM/DD/YYYY.
    #     • CDOB_CONFIRM =1, SET CHILD_DOB TO KNOWN VALUE.
    #     
    q_prepopulated_childs_birth_date "Child's birth date"
    a :string
    
    # TODO: Is {C_FNAME/YOUR CHILD}’S birth date {CHILD’S DATE OF BIRTH}
    q_CDOB_CONFIRM "Is this {C_FNAME or YOUR CHILD}’S birth date?", 
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and 
    that DOB helps determine eligibility.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.CDOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_CHILD_DOB "What is {C_FNAME/YOUR CHILD}’s date of birth?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and 
    that DOB helps determine eligibility. If response was determined to be invalid, ask question again and probe for valid response. 
    Please verify if calculated age in months is less than 9 months or greater than 15 months",
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.CHILD_DOB",
    :pick => :one
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
  section "Child development and parenting", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_2 "Insert date/time stamp", 
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
    
    label "First, I’d like to ask about {C_FNAME or YOUR CHILD} and you. You may notice your baby’s personality developing a bit more now 
    that he or she is twelve months old."
    
    q_CALM "Overall, would you describe your baby as calm?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.CALM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_WORRIED "Worried?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.WORRIED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SOCIAL "Sociable or outgoing?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SOCIAL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ANGRY "Angry?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.ANGRY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SHY"Shy or quiet?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SHY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_STUBBORN "Stubborn?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.STUBBORN"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_HAPPY "Happy?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.HAPPY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_C_HEALTH "Would you say {C_FNAME or YOUR CHILD}’s health is poor, fair, good, or excellent?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.C_HEALTH"
    a_1 "Poor"
    a_2 "Fair"
    a_3 "Good"
    a_4 "Excellent"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "I will read you a list of things {C_FNAME or YOUR CHILD} may already do or may start doing when 
    {he/she} gets older. Does your baby"
    
    q_EYES_FOLLOW "Follow you with {his/her} eyes?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.EYES_FOLLOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SMILE "Smile when you smile at {him/her}?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SMILE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_REACH_1 "Try to get a toy that is out of reach?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.REACH_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"                
    
    q_FEED "Feed {him/herself} a cracker or cereal?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.FEED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_WAVE "Wave goodbye?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.WAVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_REACH_2 "Reach for toys or food held to {him/her}",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.REACH_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRAB "Grab an object like a block or rattle from you?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.GRAB"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"             
    
    q_SWITCH_HANDS "Move a toy or block from one hand to the other?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SWITCH_HANDS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PICKUP "Pick up a small object like a Cheerio or raisin?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.PICKUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_HOLD "Hold two toys or blocks at a time, one in each hand?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.HOLD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"        
    
    q_SOUND_1 "Startle or react to a sound?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SOUND_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SOUND_2 "Turn towards a sound?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SOUND_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
        
    q_SOUND_3 "Turn toward someone when they’re speaking?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SOUND_3"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SPEAK_1 "Make sounds as though {he/she} is trying to speak?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SPEAK_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SPEAK_2 "Say mama or dada?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SPEAK_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"   
    
    q_HEADUP "Keep head steady when sitting or held up?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.HEADUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ROLL_1 "Roll over from stomach to back?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.ROLL_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ROLL_2 "Roll from back to stomach?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.ROLL_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SITUP "Sit up by {himself/herself}?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SITUP"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_STAND "Stand while holding onto something?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.STAND"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_STAND_ALONE "Stand alone, without holding onto something?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.STAND_ALONE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_WALK "Walk by {himself/herself}, without holding onto something?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.WALK"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SCRIBBLE "Scribble or draw with a pencil, crayon, or marker?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SCRIBBLE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FORK_SPOON "Try to use a fork or spoon when eating?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.FORK_SPOON"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "These next questions are about different things you may do as a parent. How often do you feel the following ways or 
    do the following things?",
    :help_text => "Use show card with categories for the next five questions"
    
    q_TALK_ABOUT "How often do you talk a lot about {C_FNAME or YOUR CHILD} to friends and family? Would you say",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TALK_ABOUT"    
    a_1 "All of the time"
    a_2 "Some of the time"
    a_3 "Rarely"
    a_4 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_PICTURES "How often do you carry pictures of {C_FNAME or YOUR CHILD} with you wherever you go?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.PICTURES"    
    a_1 "All of the time"
    a_2 "Some of the time"
    a_3 "Rarely"
    a_4 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_THINKOF "How often do you find yourself thinking about {C_FNAME or YOUR CHILD}?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.THINKOF"    
    a_1 "All of the time"
    a_2 "Some of the time"
    a_3 "Rarely"
    a_4 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_HOLD_FUN "How often do you think holding and cuddling {C_FNAME or YOUR CHILD} is fun?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.HOLD_FUN"    
    a_1 "All of the time"
    a_2 "Some of the time"
    a_3 "Rarely"
    a_4 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GIVE_FUN "How often do you think it’s more fun to get {C_FNAME or YOUR CHILD} something new than to get yourself something new?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.GIVE_FUN"    
    a_1 "All of the time"
    a_2 "Some of the time"
    a_3 "Rarely"
    a_4 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_READ "Do you read to or look at books with {C_FNAME or YOUR CHILD}?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.READ"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_READ_FREQ "How often do you read or look at books with {C_FNAME or YOUR CHILD}?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.READ_FREQ"
    a_1 "Every day"
    a_2 "5-6 days a week"
    a_3 "2-4 days a week"
    a_4 "Once a week or less"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A"
    condition_A :q_READ, "==", :a_1
    
    q_WATCH_TV "Does {C_FNAME or YOUR CHILD} watch TV and/or DVDs?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.WATCH_TV"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_TV_FREQ "How often does {C_FNAME or YOUR CHILD} watch TV and/or DVDs?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TV_FREQ"
    a_1 "Every day"
    a_2 "5-6 days a week"
    a_3 "2-4 days a week"
    a_4 "Once a week or less"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=> "A"
    condition_A :q_WATCH_TV, "==", :a_1
    
    q_PLAY_FREQ "How often do you play with toys with {C_FNAME or YOUR CHILD}?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.PLAY_FREQ"
    a_1 "Every day"
    a_2 "5-6 days a week"
    a_3 "2-4 days a week"
    a_4 "Once a week or less"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_WALKS "How often do you go for walks with {C_FNAME or YOUR CHILD}?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.WALKS"
    a_1 "Every day"
    a_2 "5-6 days a week"
    a_3 "2-4 days a week"
    a_4 "Once a week or less"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
  end   
  section "Child Care Arrangements", :reference_identifier=>"12MMother_INT" do        
    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime" 
    
    label "Next, I’d like to ask you about different types of child care {C_FNAME or YOUR CHILD} may receive from someone other 
    than parents or guardians. This includes regularly scheduled care arrangements with relatives and non-relatives, and day care or 
    early childhood programs, whether or not there is a charge or fee, but not occasional baby-sitting."
    
    q_CHILDCARE "Does {C_FNAME or YOUR CHILD} currently receive any regularly scheduled care from someone other than a parent 
    or guardian, for example from relatives, friends or other non-relatives, or a child care center or program?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.CHILDCARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FAMILY_CARE "Does {C_FNAME or YOUR CHILD} receive any care from relatives, for example, from grandparents, brothers or sisters, 
    or any other relatives. This includes all regularly scheduled care arrangements with relatives that happen at least weekly, but 
    does not include occasional baby-sitting.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.FAMILY_CARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1    

    q_FAMILY_CARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care from relatives?",
    :help_text => "Please verify if the response exceeds 50 hours per week",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.FAMILY_CARE_HRS"
    a "Number of hours per week", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_FAMILY_CARE, "==", :a_1    
    
    label "Now I’d like to ask you about any regularly scheduled care {C_FNAME or YOUR CHILD} receives from someone not related 
    to {him/her}, either in your home or someone else’s home. This includes all regularly scheduled care arrangements with non-relatives 
    that happen at least weekly, including home child care providers, regularly scheduled sitter arrangements, or neighbors. This does 
    not include day care centers, early childhood programs, or occasional babysitting."
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1
    
    q_HOMECARE "Does {C_FNAME or YOUR CHILD} receive any regularly scheduled care either in your home or someone else’s home from 
    someone not related to {him/her}?",
    :help_text => "If necessary read \"This includes arrangements with non-relatives including home child care providers, 
    regularly scheduled sitter arrangements, or neighbors. This does not include day care centers, early childhood programs, 
    or occasional babysitting.\"",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.HOMECARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1    
    
    q_HOMECARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care in a home from non-relatives?",
    :help_text => "Please verify if the response exceeds 50 hours per week",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.HOMECARE_HRS"
    a "Number of hours per week", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=> "A"
    condition_A :q_HOMECARE, "==", :a_1
    
    label "Now I want to ask you about child care centers {C_FNAME} may attend on a regular basis. Such centers include day care centers, 
    early learning centers, nursery schools, and preschools."
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1
    
    q_DAYCARE "Does {C_FNAME or YOUR CHILD} receive any care in child care centers? Such centers include day care centers, early 
    learning centers, nursery schools, and preschools.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.DAYCARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CHILDCARE, "==", :a_1    
    
    q_DAYCARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care in child care centers?",
    :help_text => "Please verify if the response exceeds 50 hours per week",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.DAYCARE_HRS"
    a "Number of hours per week", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_DAYCARE, "==", :a_1    
  end  
  section "Health care", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TIME_STAMP_4"
    a :datetime, :custom_class => "datetime"
    
    label "The next questions are about where {C_FNAME or YOUR CHILD} goes for health care."
    
    q_R_HCARE "First, what kind of place does {C_FNAME or YOUR CHILD} usually go to when {he/she} needs routine or well-child care, 
    such as a check-up or well-baby shots (immunizations)?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.R_HCARE"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_7 "Doesn't get well-child care anywhere"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_LAST_VISIT "What was the date of {C_FNAME or YOUR CHILD}’s most recent well-child visit or checkup?",
    :help_text => "Show calendar to assist in date recall.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.LAST_VISIT"
    a_date "Date", :string, :custom_class => "date"
    a_neg_7 "Has not had a visit"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A and B and C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2
    
    q_VISIT_WT "What was {C_FNAME or YOUR CHILD}’s weight at that visit?",
    :help_text => "Please verify if weight < 15 or > 30 pounds",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.VISIT_WT"
    a_weight "Pounds", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency  :rule => "A"
    condition_A :q_LAST_VISIT, "==", :a_date    

    q_SAME_CARE "If {C_FNAME or YOUR CHILD} is sick or if you have concerns about {his/her} health, does {he/she} go to 
    the same place as for well-child visits?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SAME_CARE"
    a_1 "Yes"
    a_2 "No"
    a_neg_7 "Has not been sick"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency  :rule => "A and B and C"
    condition_A :q_R_HCARE, "!=", :a_7
    condition_B :q_R_HCARE, "!=", :a_neg_1
    condition_C :q_R_HCARE, "!=", :a_neg_2    
    
    q_HCARE_SICK "What kind of place does {C_FNAME or YOUR CHILD} usually go to when {he/she} is sick, doesn’t feel 
    well, or if you have concerns about {his/her} health?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.HCARE_SICK"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_7 "Has not been sick"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "(A or B or C) or (D and E)"
    condition_A :R_HCARE, "==", :a_7
    condition_B :R_HCARE, "==", :a_neg_1
    condition_C :R_HCARE, "==", :a_neg_2
    condition_D :q_SAME_CARE, "!=", :a_1
    condition_E :q_SAME_CARE, "!=", :a_neg_7
  end
  section "Medical conditions", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TIME_STAMP_5"
    a :datetime, :custom_class => "datetime"
    
    label "Now I’d like to ask about some illnesses {C_FNAME or YOUR CHILD} may have had in the last 3 months."
    
    q_EAR_INFECTION "In the past 3 months, has {C_FNAME or YOUR CHILD} had an ear infection?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.EAR_INFECTION"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GASTRO "In the past 3 months, has {C_FNAME or YOUR CHILD} had diarrhea or vomiting?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.GASTRO"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_RESPIRATORY "In the past 3 months, has {C_FNAME or YOUR CHILD} had wheezing or whistling in the chest?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.RESPIRATORY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FEVER "In the past 3 months, on how many days has {C_FNAME or YOUR CHILD} had a fever over 101 degrees, not related to 
    receiving immunizations?",
    :help_text => "If necessary read \"or 38.3 degrees Celsius?\". Enter \"0\" if none",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.FEVER"
    a "Number of days", :integer
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "Now I have some questions about specific conditions or health problems {C_FNAME or YOUR CHILD} may have."
    
    q_BLIND "Has a doctor ever told you that {C_FNAME or YOUR CHILD} is blind?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.BLIND"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_EYESIGHT "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has difficulty seeing, including nearsightedness or farsightedness?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.EYESIGHT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=> "A"
    condition_A :q_BLIND, "!=", :a_1
    
    q_DEAF "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has difficulty hearing or deafness? Do not include 
    a temporary loss of hearing due to a cold or congestion.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.DEAF"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_BIRTH_DEFECT "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has any congenital anomaly or birth defect such as 
    a cleft lip or palate, heart defect, or spina bifida?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.BIRTH_DEFECT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_DEFECT_TYPE "What type of congenital anomaly or birth defect have you been told {C_FNAME or YOUR CHILD} has?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.DEFECT_TYPE"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_BIRTH_DEFECT, "==", :a_1
    
    q_GENETIC "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has Down Syndrome, Turner Syndrome, or other inherited or genetic 
    condition?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.GENETIC"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GENETIC_TYPE "What type of condition have you been told {C_FNAME or YOUR CHILD} has?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.GENETIC_TYPE"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_GENETIC, "==", :a_1
    
    q_FAIL_THRIVE "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has failure to thrive, or concern about proper growth?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.FAIL_THRIVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
  section "Health insurance", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_6 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TIME_STAMP_6"
    a :datetime, :custom_class => "datetime" 
    
    label "Now I’m going to switch to another subject and ask about health insurance."
    
    q_INSURE "Is {C_FNAME or YOUR CHILD} currently covered by any kind of health insurance or some other kind of health care plan?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.INSURE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Insurance information" do
      dependency :rule => "A"
      condition_A :q_INSURE, "==", :a_1
      
      label "Now I’ll read a list of different types of insurance. Please tell me which types {C_FNAME or YOUR CHILD} currently has. 
      Does {C_FNAME or YOUR CHILD}  currently have",
      :help_text => "Re-read introductory statement as needed"
    
      q_INS_EMPLOY "Insurance through an employer or union either through yourself or another family member?",
      :pick => :one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_INS_MEDICAID "Medicaid or any government-assistance plan for those with low incomes or a disability?",
      :help_text => "Provide examples of local medicaid programs",
      :pick => :one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_INS_TRICARE "TRICARE, VA, or other military health care?",
      :pick => :one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_IHS "Indian Health Service?",
      :pick => :one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_INS_MEDICARE "Medicare, for people with certain disabilities?",
      :pick => :one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.INS_MEDICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_INS_OTH "Any other type of health insurance or health coverage plan?",
      :pick => :one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Product use", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_7 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.TIME_STAMP_7"
    a :datetime, :custom_class => "datetime" 
    
    label "The next questions ask about lice exposure and treatment."
    
    q_LICE_1 "In the past 6 months, have you treated {C_FNAME or YOUR CHILD} or other people in your home for lice or scabies?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.LICE_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_LICE_2 "Who did you treat, was it {C_FNAME or YOUR CHILD}, someone else, or both?",
    :help_text => "Probe: \"Anyone else?\". Select all that apply",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.LICE_2"
    a_1 "{C_FNAME or YOUR CHILD}"
    a_2 "Someone else"
    a_3 "Both {C_FNAME or YOUR CHILD} and someone else"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_LICE_1, "==", :a_1
    
    q_LICE_OTH_1  "Other: specify",
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.LICE_OTH_1"
    a "Specify: ", :string
    dependency :rule => "(A and B and G and D and E) or (B and D and E and F and G) or (B and C and F and D and E) or (A and B and C and D and E)"
    condition_A :q_LICE_2, "==", :a_1
    condition_B :q_LICE_2, "==", :a_2
    condition_C :q_LICE_2, "==", :a_3
    condition_D :q_LICE_2, "!=", :a_neg_1
    condition_E :q_LICE_2, "!=", :a_neg_2
    condition_F :q_LICE_2, "!=", :a_1
    condition_G :q_LICE_2, "!=", :a_3
    
    q_LICE_OTH_2  "Other: specify",
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.LICE_OTH_2"
    a "Specify: ", :string
    dependency :rule => "(C and D and E and F and G) or (A and C and D and E and G) or (B and C and F and D and E) or (A and B and C and D and E)"
    condition_A :q_LICE_2, "==", :a_1
    condition_B :q_LICE_2, "==", :a_2
    condition_C :q_LICE_2, "==", :a_3
    condition_D :q_LICE_2, "!=", :a_neg_1
    condition_E :q_LICE_2, "!=", :a_neg_2
    condition_F :q_LICE_2, "!=", :a_1
    condition_G :q_LICE_2, "!=", :a_2
  end

  # TODO
  # • THIS SECTION SHOULD ONLY BE ASKED FOR THE FIRST ELIGIBLE CHILD. IF CHILD_QNUM > 1, THEN GO TO SMOKE_HOURS
  section "In-home exposures", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_8 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_8"
    a :datetime, :custom_class => "datetime" 
    
    label "Do you use any methods to \"allergy-proof\" your home? Please answer \"yes\" or \"no\" to each method I describe"
  
    q_TANNIC_ACID "Tannic acid or other mite control chemicals?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.TANNIC_ACID"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COVERS "Impermeable mattress and/ or pillow covers on your child’s bed or crib?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.COVERS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_VACUUM "Use a special vacuum such as a HEPA vacuum?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.VACUUM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_REMOVAL "Intentionally removed rugs or upholstered furniture?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.REMOVAL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_METHOD "Any other methods?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.METHOD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_METHOD_OTH "Other method",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.METHOD_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_METHOD, "==", :a_1
    
    q_AIR_FILTER "Does your furnace or air conditioning system use a special HEPA (High Efficiency Particulate Air) or other 
    type of allergy filter to filter the air?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.AIR_FILTER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_OPEN_WINDOW "Thinking about the past 7 days, approximately how many hours a day did you keep the windows or doors open 
    in your home (for ventilation or to let air in)? Was it",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.OPEN_WINDOW"
    a_1 "Less than 1 hour per day"
    a_2 "1-3 hours per day"
    a_3 "4-12 hours per day"
    a_4 "More than 12 hours per day"
    a_5 "Not at all"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "I would now like to ask about whether you have seen signs of rodents or seen cockroaches in your home in the last 6 months."
    
    q_RODENT "In the last 6 months, have you seen signs of mice, rats, or other rodents in your home (not including pets)?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.RODENT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ROACH "In the last 6 months, have you seen cockroaches in your home?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.ROACH"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the ceiling or 
    walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof, or floods."
    
    q_WATER "In the last 6 months, have you seen any water damage inside your home?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.WATER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_MOLD "In the last 6 months, have you seen any mold or mildew on walls or other surfaces, other than the shower or bathtub, inside your home?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.MOLD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ROOM_MOLD "In which rooms have you seen the mold or mildew?",
    :help_text => "Probe: Any other rooms? Select all that apply",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_ROOM_MOLD.ROOM_MOLD"
    a_1 "Kitchen"
    a_2 "Living room"
    a_3 "Hall/landing"
    a_4 "{C_FNAME}’s bedroom"
    a_5 "Other bedroom"
    a_6 "Bathroom/toilet"
    a_7 "Basement"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_MOLD, "==", :a_1
    
    q_ROOM_MOLD_OTH "Other rooms",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_ROOM_MOLD.ROOM_MOLD_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A and B and C"
    condition_A :q_ROOM_MOLD, "==", :a_neg_5
    condition_B :q_ROOM_MOLD, "!=", :a_neg_1
    condition_C :q_ROOM_MOLD, "!=", :a_neg_2
    
    q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_9"
    a :datetime, :custom_class => "datetime"

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF CHILD_NUM =1, GO TO TIME_STAMP_10.
    
    label "The next few questions ask about any recent additions or renovations to your home."

    q_RENOVATE "In the last 6 months, have any additions been built onto your home to make it bigger or renovations or other 
    construction been done in your home? Include only major projects. Do not count smaller projects, such as painting, wallpapering, 
    carpeting or re-finishing floors.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.RENOVATE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_RENOVATE_ROOM "Which rooms were renovated?",
    :help_text => "Probe: Any others? Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_RENOVATE_ROOM.RENOVATE_ROOM"
    a_1 "Kitchen"
    a_2 "Living room"
    a_3 "Hall/landing"
    a_4 "{C_FNAME}’s bedroom"
    a_5 "Other bedroom"
    a_6 "Bathroom/toilet"
    a_7 "Basement"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_RENOVATE, "==", :a_1
    
    q_RENOVATE_ROOM_OTH "Other room",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_RENOVATE_ROOM.RENOVATE_ROOM_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A and B and C"
    condition_A :q_RENOVATE_ROOM, "==", :a_neg_5
    condition_B :q_RENOVATE_ROOM, "!=", :a_neg_1
    condition_C :q_RENOVATE_ROOM, "!=", :a_neg_2
  end
  section "Health behaviors", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_10"
    a :datetime, :custom_class => "datetime"
    
    q_CIG_NOW "Do you currently smoke cigarettes or use any other tobacco product?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.CIG_NOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NUM_SMOKER "How many smokers live in your home now?",
    :help_text => "Enter \"0\" if none",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NUM_SMOKER"
    a "Number of smokers", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_CIG_NOW, "!=", :a_1
    
    q_NUM_SMOKER_INCL "How many smokers live in your home now, including yourself?",
    :help_text => "Response to num_smoker must be ≥ 1",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NUM_SMOKER"   
    a "Number of smokers", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_CIG_NOW, "==", :a_1
    
    q_SMOKE_RULES "Which of the following statements describes the rules about smoking inside your home now?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.SMOKE_RULES"    
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
    :data_export_identifier=>"TWELVE_MTH_MOTHER_DETAIL.SMOKE_HOURS"
    a "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    # TODO
    # INTERVIEWER INSTRUCTON: 
    # • IF CHILD_QNUM > 1, GO TO CHILD_QNUM AND LOOP THROUGH QUESTIONNIARE THROUGH HB012 SMOKE_HOURS FOR EACH 
    # CHILD UNTIL CHILD_NUM = CHILD_QNUM. THEN GO TO END
        
    q_DRINK "Do you drink any type of alcoholic beverage?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.DRINK"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_DRINK_NOW "How often do you currently drink alcoholic beverages?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.DRINK_NOW"
    a_1 "5 or more times a week"
    a_2 "2-4 times a week"
    a_3 "Once a week"
    a_4 "1-3 times a month"
    a_5 "Less than once a month"
    a_6 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_DRINK, "!=", :a_2
    
    q_DRINK_NOW_5 "How often do you have 5 or more drinks within a couple of hours:",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.DRINK_NOW_5"
    a_1 "Never"
    a_2 "About once a month"
    a_3 "About once a week"
    a_4 "About once a day"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A and B and C"
    condition_A :q_DRINK_NOW, "!=", :a_6
    condition_B :q_DRINK_NOW, "!=", :a_neg_1
    condition_C :q_DRINK_NOW, "!=", :a_neg_2
  end
  section "Neighborhood characteristics", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_11"
    a :datetime, :custom_class => "datetime"
    
    label "Now I’d like to ask a few questions about your neighborhood."
    
    q_NEIGH_DEFN "When you are talking to someone about your neighborhood, what do you mean? Is it",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_DEFN"
    a_1 "The block or street you live on"
    a_2 "Several blocks or streets in each direction"
    a_3 "The area within a 15 minute walk from your house"
    a_4 "An area larger than a 15 minute walk from your house"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_FAM "How many of your relatives or in-laws live in your neighborhood? Would you say",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_FAM"
    a_1 "None"
    a_2 "A few"
    a_3 "Many"
    a_4 "Most"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    
    
    q_NEIGH_FRIEND "How many of your friends live in your neighborhood? Would you say",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_FRIEND"
    a_1 "None"
    a_2 "A few"
    a_3 "Many"
    a_4 "Most"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGHBORS "About how many adults do you recognize or know by sight in this neighborhood? Would you say you recognize",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGHBORS"
    a_1 "None"
    a_2 "A few"
    a_3 "Many"
    a_4 "Most"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_NUM_TALK "In the past 30 days, that is since [INSERT DATE 30 DAYS AGO], how many of your neighbors have you talked 
    with for 10 minutes or more? Would you say",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_NUM_TALK"
    a_1 "None"
    a_2 "1 or 2"
    a_3 "3 to 5"
    a_4 "6 or more"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_HELP "About how often do you and people in your neighborhood do favors for each other? By favors, we mean such 
    things as watching each other’s children, helping with shopping, lending garden or house tools.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_HELP"
    a_1 "Often"
    a_2 "Sometimes"
    a_3 "Rarely"
    a_4 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_TALK "How often do you and other people in your neighborhood visit in each other’s homes or speak with each other on the street?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_TALK"
    a_1 "Often"
    a_2 "Sometimes"
    a_3 "Rarely"
    a_4 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_WATCH_1 "If children were skipping school and hanging out, how likely is it that your neighbors would do something 
    about it? Would you say it is",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_WATCH_1"
    a_1 "Very Likely"
    a_2 "Likely"
    a_3 "Unlikely"
    a_4 "Very Unlikely"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_WATCH_2 "If children were showing disrespect to an adult, how likely is it that your neighbors would do 
    something about it? Would you say it is",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_WATCH_2"
    a_1 "Very Likely"
    a_2 "Likely"
    a_3 "Unlikely"
    a_4 "Very Unlikely"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "Please tell me if you agree or disagree with the following statements."
    
    q_NEIGH_CLOSE "This is a close-knit neighborhood. Would you say you.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_CLOSE"
    a_1 "Strongly agree"
    a_2 "Agree"
    a_3 "Disagree"
    a_4 "Strongly disagree"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_TRUST "People in this neighborhood can be trusted. Would you say you",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_TRUST"
    a_1 "Strongly agree"
    a_2 "Agree"
    a_3 "Disagree"
    a_4 "Strongly disagree"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_SAFE_1 "I feel safe walking in my neighborhood, day or night.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_SAFE_1"
    a_1 "Strongly agree"
    a_2 "Agree"
    a_3 "Disagree"
    a_4 "Strongly disagree"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_SAFE_2 "Violence is not a problem in my neighborhood.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_SAFE_2"
    a_1 "Strongly agree"
    a_2 "Agree"
    a_3 "Disagree"
    a_4 "Strongly disagree"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_NEIGH_SAFE_3 "My neighborhood is safe from crime.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.NEIGH_SAFE_3"
    a_1 "Strongly agree"
    a_2 "Agree"
    a_3 "Disagree"
    a_4 "Strongly disagree"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"        
  end
  section "Tracing questions", :reference_identifier=>"12MMother_INT" do
    q_TIME_STAMP_12 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_12"
    a :datetime, :custom_class => "datetime"
    
    label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember that all the 
    information you provide is confidential and will not be provided to anyone outside the National Children’s Study."
    
    q_COMM_EMAIL "When we last spoke, we asked questions about communicating with you through your personal email. 
    Has your email address or your preferences regarding use of your personal email changed since then?", :pick=>:one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER.COMM_EMAIL"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_HAVE_EMAIL "Do you have an email address?", :pick=>:one, 
    :data_export_identifier=>"TWELVE_MTH_MOTHER.HAVE_EMAIL"
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
      :pick=>:one, :data_export_identifier=>"TWELVE_MTH_MOTHER.EMAIL_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EMAIL_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
      :pick=>:one, :data_export_identifier=>"TWELVE_MTH_MOTHER.EMAIL_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EMAIL "What is the best email address to reach you?", :pick=>:one, 
      :help_text=>"Show example of valid email address such as janedoe@email.com", 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.EMAIL"
      a_1 "Enter e-mail address:", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
      
    q_COMM_CELL "When we last spoke, we asked questions about communicating with you through your personal cell 
    phone number. Has your cell phone number or your preferences regarding use of your personal cell phone number 
    changed since then?", :pick=>:one, 
    :data_export_identifier=>"TWELVE_MTH_MOTHER.COMM_CELL"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CELL_PHONE_1 "Do you have a personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"TWELVE_MTH_MOTHER.CELL_PHONE_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_COMM_CELL, "!=", :a_2

    group "Cell phone information" do
      dependency :rule=>"A"
      condition_A :q_CELL_PHONE_1, "==", :a_1
            
      q_CELL_PHONE_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"TWELVE_MTH_MOTHER.CELL_PHONE_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CELL_PHONE_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CELL_PHONE_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CELL_PHONE_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CELL_PHONE_4"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CELL_PHONE_3, "==", :a_1 

      q_CELL_PHONE "What is your personal cell phone number?", :pick=>:one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CELL_PHONE"
      a_1 "Phone number", :string
      a_neg_7 "Participant has no cell phone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    q_TIME_STAMP_13 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_13"
    a :datetime, :custom_class => "datetime"

    q_COMM_CONTACT "Sometimes if people move or change their telephone number, we have difficulty reaching them. At our last visit, 
    we asked for contact information for two friends or relatives not living with you who would know where you could be reached in case we 
    have trouble contacting you. Has that information changed since our last visit?", 
    :pick=>:one, :data_export_identifier=>"TWELVE_MTH_MOTHER.COMM_CONTACT"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CONTACT_1 "Could I have the name of a friend or relative not currently living with you who should know where you could be reached 
    in case we have trouble contacting you?", 
    :pick=>:one, 
    :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_COMM_CONTACT, "!=", :a_2
    
    group "Contact information" do
      dependency :rule=>"A"
      condition_A :q_CONTACT_1, "==", :a_1
            
      q_CONTACT_FNAME_1 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_FNAME_1"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_LNAME_1 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_LNAME_1"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE_1 "What is his/her relationship to you?", 
      :pick=>:one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_RELATE_1"
      a_1 "Mother/father"
      a_2 "Brother/sister"
      a_3 "Aunt/uncle"
      a_4 "Grandparent"
      a_5 "Neighbor"
      a_6 "Friend"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE1_OTH "Other relationship of contact", :pick=>:one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_RELATE1_OTH"      
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CONTACT_RELATE_1, "==", :a_neg_5

      label "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_C_ADDR1_1 "Address 1 - street/PO Box", 
      :pick=>:one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ADDR1_1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      
      q_C_ADDR_2_1 "Address 2", 
      :pick=>:one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ADDR_2_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      
      q_C_UNIT_1 "Unit", 
      :pick=>:one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_UNIT_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_CITY_1 "City", 
      :pick=>:one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_CITY_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_STATE_1 "State", :display_type=>:dropdown, 
      :pick=>:one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_STATE_1"
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
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ZIPCODE_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ZIP4_1 "ZIP+4", 
      :pick=>:one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ZIP4_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_PHONE_1 "What is his/her telephone number?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_PHONE_1"
      a_1 "Phone number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      a_neg_7 "Contact has no telephone"

      label "Now I’d like to collect information on a second contact who does not currently live with you."

      label "What is the person's name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names"

      q_CONTACT_FNAME_2 "What is the person's first name?",
      :pick=>:one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_FNAME_2"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_LNAME_2 "What is the person's last name?",
      :pick=>:one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_LNAME_2"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE_2 "What is his/her relationship to you?", :pick=>:one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_RELATE_2"
      a_1 "Mother/father"
      a_2 "Brother/sister"
      a_3 "Aunt/uncle"
      a_4 "Grandparent"
      a_5 "Neighbor"
      a_6 "Friend"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE2_OTH "Other relationship of second contact", :pick=>:one, 
      :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_RELATE2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CONTACT_RELATE_2, "==", :a_neg_5

      label "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_C_ADDR1_2 "Address 1 - street/PO Box",
      :pick => :one,       
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ADDR1_2"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ADDR_2_2 "Address 2", 
      :pick => :one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ADDR_2_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_UNIT_2 "Unit", 
      :pick => :one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_UNIT_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_CITY_2 "City", 
      :pick => :one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_CITY_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_STATE_2 "State", :display_type=>:dropdown,
      :pick => :one,
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_STATE_2"
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
      :pick => :one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ZIPCODE_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ZIP4_2 "ZIP+4", 
      :pick => :one,      
      :data_export_identifier=>"TWELVE_MTH_MOTHER.C_ZIP4_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_PHONE_2 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, :data_export_identifier=>"TWELVE_MTH_MOTHER.CONTACT_PHONE_2"
      a_1 "Phone number", :string
      a_7 "Contact has no phone"    
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    # TODO
    # • IF CHILD_QNUM > 1, GO TO CHILD_QNUM AND LOOP THROUGH QUESTIONS FOR NEXT ELIGIBLE CHILD
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.", 
    :help_text => "Explain SAQs and return process"
    
    q_hipv1_TIME_STAMP_14 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_MOTHER.TIME_STAMP_14"
    a :datetime, :custom_class => "datetime"    
  end    
end