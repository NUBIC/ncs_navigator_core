survey "INS_QUE_24MMother_INT_EHPBHI_P2_V1.0" do
  section "Interview introduction", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Thank you again for agreeing to participate in the National Children’s Study. We are about to begin
    the interview portion of today’s contact, which will take about 30 minutes to complete. Your answers are important
    to us. There are no right or wrong answers. During this interview, we will ask about yourself, your {CHILD/CHILDREN},
    your health, where you live, and your feelings about being a part of the National Children’s Study. You can skip over
    any questions or stop the interview at any time. We will keep everything that you tell us confidential."
  end
  section "Interviewer-completed questions", :reference_identifier=>"24MMother_INT" do
    q_MULT_CHILD "Is there more than one child of this mother eligible for the 24 month visit today?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.MULT_CHILD"
    a_1 "Yes"
    a_2 "No"

    q_CHILD_NUM "How many children of this mother are eligible for the 24 month visit today?",
    :help_text => "Enter number value",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CHILD_NUM"
    a :integer
    dependency :rule=>"A"
    condition_A :q_MULT_CHILD, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • IF MULT_CHILD = 1 LOOP THROUGH QUESTIONNAIRE FOR EACH ELIGIBLE CHILD RECORDED IN CHILD_NUM THROUGH SMOKE_HOURS.
    # •  IF CHILD_QNUM>1,
    # o COMPLETE CHILD_QNUM AND ASK CHILD_SEX.
    # o COMPLETE PARTICIPANT VERIFICATION SECTION OF QUESTIONANIRE THROUGH CDOB_CONFIRM/CHILD_DOB.
    # o SKIP TO SL013.
    # o ASK THE FOLLOWING SECTIONS OF THE QUESTIONNAIRE: SLEEP, CHILD CARE ARRANGEMENTS, HEALTH CARE, MEDICAL CONDITIONS,
    # MEDICATIONS, HEALTH INSURANCE, PRODUCT USE.
    # o SKIP TO SMOKE_HOURS.
    # o IF CHILD_NUM>1, GO TO CHILD_QNUM AND LOOP THROUGH QUESTIONAIRE FROM CHILD_QNUM THROUGH SMOKE_HOURS
    # FOR EACH CHILD UNTIL CHILD_NUM=CHILD_QNUM. THEN GO TO DRINK.
    #     o LOOP THROUGH ROOM_MOLD_CHILD UNTIL CHILD_NUM=CHILD_QNUM.


    q_CHILD_QNUM "Which number child is this questionnaire for?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_DETAIL.CHILD_QNUM"
    a_which_child "Number", :integer
    dependency :rule=>"A"
    condition_A :q_MULT_CHILD, "==", :a_1

    # TODO
    #     PROGRAMMER INSTRUCTION:
    #     •	CHILD_QNUM CANNOT BE GREATER THAN CHILD_NUM.

    q_CHILD_SEX "Is (CHILD_QNUM) a male or female?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_DETAIL.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_3 "Both"

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF CHILD_SEX =1 , DISPLAY “his” AND “he” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 2, DISPLAY “her” AND “she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
    # • IF CHILD_SEX = 3, DISPLAY “him/her” AND “he/she” IN APPROPRIATE FIELDS THROUGHOUT INSTRUMENT.
  end
  section "Participant verification", :reference_identifier=>"24MMother_INT" do
    label "I’d like to ask about your next child"
    dependency :rule => "A"
    condition_A :q_CHILD_QNUM, ">", {:integer_value => "1"}

    label "First, we’d like to make sure we have your child’s correct name and birth date."

    #     TODO - the name should be pre-populated
    q_prepopulated_name "Name:"
    a :string

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • PRELOAD CHILD’S NAME IF COLLECTED PREVIOUSLY.
    # • IF CHILD’S NAME NOT COLLECTED PREVIOUSLY, GO TO C_FNAME C_LNAME.

    q_CNAME_CONFIRM "Is your child’s name {C_FNAME/C_LNAME}?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_DETAIL.CNAME_CONFIRM", :pick=>:one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Child's information" do
      dependency :rule=>"A"
      condition_A :q_CNAME_CONFIRM, "!=", :a_1

      label "What is your child’s full name?",
      :help_text => "If participant refuses to provide information, re-state confidentiality
      protections, ask for initials or some other name she would like her child to be called.
      Confirm spelling of first name if not previously collected and of last name for all children."

      # TODO
      # PROGRAMMER INSTRUCTION:
      # • IF PARTICIPANT REFUSES TO PROVIDE NAME, INITIALS OR IDENTIFIER C_FNAME AND C_LNAME=-1, USE “YOUR CHILD” FOR C_FNAME IN REMAINDER
      # OF QUESTIONNAIRE.

      q_C_FNAME "First name", :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_DETAIL.C_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_LNAME "Last name", :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_DETAIL.C_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • PRELOAD CHILD’S DOB CHILD_DOB IF KNOWN AS MM/DD/YYYY
    # • IFCDOB_CONFIRM = 1, SET CHILD_DOB TO KNOWN VALUE
    q_prepopulated_childs_birth_date "Child's birth date"
    a :string

    # TODO: Is {C_FNAME or YOUR CHILD}’S birth date  {CHILD’S DATE OF BIRTH}
    q_CDOB_CONFIRM "Is {C_FNAME or YOUR CHILD}’s birth date [INSERT CHILD’S DATE OF BIRTH/ CHILD_DOB]?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and
    that DOB helps determine eligibility.",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_DETAIL.CDOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CHILD_DOB "What is {C_FNAME/YOUR CHILD}’s date of birth?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and
    that DOB helps determine eligibility. If response was determined to be invalid, ask question again and probe for valid response.",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_DETAIL.CHILD_DOB",
    :pick => :one
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_CDOB_CONFIRM, "!=", :a_1

    # TODO:
    #     PROGRAMMER INSTRUCTIONS:
    # • INCLUDE A SOFT EDIT/WARNING IF CALCULATED AGE IS LESS THAN 23 MONTHS OR GREATER THAN 28 MONTHS.
    # • FORMAT CHILD_DOB AS YYYYMMDD

    # TODO
    # • IF CHILD_QNUM >1, GO TO SL013.

    q_PREGNANT "Are you pregnant now?",
    :help_text => "If adult is known to be pregnant, add [Just to confirm,]",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.PREGNANT"
    a_1 "Yes"
    a_2 "No, no additional information provided"
    a_3 "No, recently lost pregnancy (miscarriage/abortion) - (if volunteered by participant)"
    a_4 "No, recently gave birth  - (if volunteered by participant) "
    a_5 "No, unable to have children (hysterectomy, tubal ligation) - (if volunteered by participant)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    label "I’m so sorry for your loss. Please accept our sincere wishes at this difficult time"
    dependency :rule =>"A"
    condition_A :q_PREGNANT, "==", :a_3

    q_ORIG_DUE_DATE "[Congratulations.] When is your baby due?",
    :help_text => "If response was determined to be invalid, ask question again and probe for valid response.",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.ORIG_DUE_DATE",
    :pick => :one
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule =>"A"
    condition_A :q_PREGNANT, "==", :a_1

    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
  end
  section "Demographics", :reference_identifier=>"24MMother_INT" do
    q_HHCOMP_CHANGE "Have there been any changes in your household members since we contacted you last?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.HHCOMP_CHANGE",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    #     INTERVIEWER INSTRUCTION:
    #     [ALLOW UP TO 250 ALPHANUMERIC CHARACTERS.]
    q_HHCOMP_CHANGE_SPECIFY "Please explain.",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.HHCOMP_CHANGE_SPECIFY",
    :pick => :one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_HHCOMP_CHANGE, "==", :a_1
  end
  section "Sleep", :reference_identifier=>"24MMother_INT" do
    label "I’m now going to ask you about {C_FNAME or YOUR CHILD}’s sleeping habits"

    q_SLEEP_HRS_DAY "Approximately how many hours does {C_FNAME or YOUR CHILD} sleep during the day?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SLEEP_HRS_DAY",
    :pick => :one
    a "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_HRS_NIGHT "Approximately how many hours does {C_FNAME or YOUR CHILD} sleep at night?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SLEEP_HRS_NIGHT",
    :pick => :one
    a "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_TIME_NIGHT "On a normal day, what time in the evening does {C_FNAME or YOUR CHILD} go to sleep?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SLEEP_TIME_NIGHT",
    :pick => :one
    a "Time", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_TIME_WAKE "On a normal day, what time does {C_FNAME or YOUR CHILD} wake up in the morning?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SLEEP_TIME_WAKE",
    :pick => :one
    a "Time", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_DIFFICULT "How often is {C_FNAME or YOUR CHILD} difficult when {he/she} is put to bed?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SLEEP_DIFFICULT",
    :pick => :one
    a_1 "Most of the time"
    a_2 "Often"
    a_3 "Sometimes"
    a_4 "Rarely"
    a_5 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SLEEP_THROUGH "How often does {C_FNAME or YOUR CHILD} wake at night?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SLEEP_THROUGH",
    :pick => :one
    a_1 "Never"
    a_2 "Occasionally"
    a_3 "Most nights"
    a_4 "Every night"
    a_5 "More than once per night"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_TV_FREQ_HRS "Over the past 30 days, on average, how many hours per day did {C_FNAME or YOUR CHILD} sit and
    watch TV and/or DVDs? Would you say",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.TV_FREQ_HRS",
    :pick => :one
    a_1 "Less than 1 hour,"
    a_2 "2 hours"
    a_3 "3 hours"
    a_4 "4 hours"
    a_5 "5 hours or more"
    a_6 "None, {C_FNAME or YOUR CHILD} does not watch TV or DVDs"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
  section "Child care arrangements", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"

    q_CHILDCARE_CHANGE "Has there been a change in your childcare arrangements since our last interview?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.CHILDCARE_CHANGE",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Childcare information" do
      dependency :rule => "A"
      condition_A :q_CHILDCARE_CHANGE, "==", :a_1

      label "I’d like to ask you about different types of child care {C_FNAME or YOUR CHILD} may receive from someone other
      than parents or guardians. This includes regularly scheduled care arrangements with relatives and non-relatives, and day
      care or early childhood programs, whether or not there is a charge or fee, but not occasional baby-sitting."

      q_CHILDCARE "Does {C_FNAME or YOUR CHILD} currently receive any regularly scheduled care from someone other than a parent
      or guardian, for example from relatives, friends or other non-relatives, or a child care center or program?",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.CHILDCARE",
      :pick => :one
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    q_FAMILY_CARE "Does {C_FNAME or YOUR CHILD} receive any care from relatives, for example, from grandparents, brothers or
    sisters, or any other relatives. This includes all regularly scheduled care arrangements with relatives that happen at least
    weekly, but does not include occasional baby-sitting.",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.FAMILY_CARE",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_CHILDCARE, "==", :a_1

    q_FAMILY_CARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care from relatives?",
    :help_text => "Please verify if response exceeds 50 hours per week",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.FAMILY_CARE_HRS",
    :pick => :one
    a "Number of hours per week", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_FAMILY_CARE, "==", :a_1

    group "Care information" do
      dependency :rule => "A"
      condition_A :q_CHILDCARE, "==", :a_1

      label "Now I’d like to ask you about any regularly scheduled care {C_FNAME or YOUR CHILD} receives from someone not related
      to {him/her}, either in your home or someone else’s home. This includes all regularly scheduled care arrangements with
      non-relatives that happen at least weekly, including home child care providers, regularly scheduled sitter arrangements,
      or neighbors. This does not include day care centers, early childhood programs, or occasional babysitting."

      q_HOMECARE "Does {C_FNAME or YOUR CHILD} receive any regularly scheduled care either in your home or someone else’s home
      from someone not related to {him/her}?",
      :help_text =>"If necessary read \"This includes arrangements with non-relatives including home child care providers,
      regularly scheduled sitter arrangements, or neighbors. This does not include day care centers, early childhood programs,
      or occasional babysitting.\"",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.HOMECARE",
      :pick => :one
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HOMECARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care in a home from non-relatives?",
      :help_text => "Please verify if response exceeds 50 hours per week",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.HOMECARE_HRS",
      :pick => :one
      a "Number of hours per week", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_HOMECARE, "==", :a_1

      label "Now I want to ask you about child care centers {C_FNAME or YOUR CHILD} may attend on a regular basis. Such centers
      include day care centers, early learning centers, nursery schools, and preschools."

      q_DAYCARE "Does {C_FNAME or YOUR CHILD} receive any care in child care centers? Such centers include day care centers,
      early learning centers, nursery schools, and preschools.",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.DAYCARE",
      :pick => :one
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DAYCARE_HRS "Approximately how many total hours each week does {C_FNAME or YOUR CHILD} receive care in child care centers?",
      :help_text => "Please verify if response exceeds 50 hours per week",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.DAYCARE_HRS",
      :pick => :one
      a "Number of hours per week", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_DAYCARE, "==", :a_1
    end
  end
  section "Health care", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.TIME_STAMP_4"
    a :datetime, :custom_class => "datetime"

    label "The next questions are about where {C_FNAME or YOUR CHILD} goes for health care."

    q_R_HCARE "First, what kind of place does {C_FNAME or YOUR CHILD} usually go to when {he/she} needs routine or well-child care,
    such as a check-up or well-baby shots (immunizations)?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.R_HCARE"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "Doesn't go to one place most often"
    a_7 "Doesn't get well-child care anywhere"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_C_HEALTH "Would you say {C_FNAME or YOUR CHILD}’s health is poor, fair, good, or excellent?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.C_HEALTH"
    a_1 "Poor"
    a_2 "Fair"
    a_3 "Good"
    a_4 "Excellent"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_USE_IC_LOG "Are you using the Infant and Child Health Care Log? This is the booklet that you or your health care
    provider (pediatrician or family medicine doctor, specialist (like a surgeon, heart, allergy, or skin doctor), nurse
    practitioner, physician assistant, nurse, social worker/counselor, etc.) uses to record information about your child’s
    medical visits.",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.USE_IC_LOG",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_REASON_NO_IC_LOG "Is that because",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.REASON_NO_IC_LOG",
    :pick => :one
    a_1 "Your child hasn’t had a medical visit since our last interview,"
    a_2 "You’ve misplaced the log"
    a_3 "You’ve forgotten to bring it to your child’s medical visits"
    a_4 "The log was too much trouble to complete, or"
    a_5 "The log was too difficult to understand?"
    a_6 "Other (specify):"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_USE_IC_LOG, "==", :a_2

    q_REASON_NO_IC_LOG_OTH "Other reason",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.REASON_NO_IC_LOG_OTH"
    a "Specify", :string
    dependency :rule => "A"
    condition_A :q_REASON_NO_IC_LOG, "==", :a_6

    label "We’ll get another Infant and Child Health Care Log in the mail to you today."
    dependency :rule => "A"
    condition_A :q_REASON_NO_IC_LOG, "==", :a_2

    label "This information is very important to the study. Please keep the log in a safe place and bring the log with
    you to all of your child’s medical visits. "
    dependency :rule => "A or B or C or D"
    condition_A :q_REASON_NO_IC_LOG, "==", :a_3
    condition_B :q_REASON_NO_IC_LOG, "==", :a_4
    condition_C :q_REASON_NO_IC_LOG, "==", :a_neg_1
    condition_D :q_REASON_NO_IC_LOG, "==", :a_neg_2

    group "Providers information" do
      dependency :rule => "A"
      condition_A :q_USE_IC_LOG, "==", :a_1

      q_NUM_PROV_IC_LOG "How many health care providers has your child seen since using this Infant and Child Health Care Log?",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.NUM_PROV_IC_LOG",
      :pick => :one
      a "Number of providers", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NUM_PROV_REC "Of those providers that your child has seen, how many providers have you recorded their contact information
      such as address or phone number?",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.NUM_PROV_REC",
      :pick => :one
      a "Number of contacts", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "I am now going to ask some questions about your child’s visits to a doctor or other health care provider
      (pediatrician or family medicine doctor, specialist (like a surgeon, heart, allergy, or skin doctor). It would be helpful
      if you referred to the Infant and Child Health Care Log that you received as part of this study or to any other personal
      record or calendar that you keep that would help you to remember the dates of these visits. If you have this information
      available, please go and get it now."
    end

    label "I am now going to ask some questions about your child’s visits to a doctor or other health care provider
    (pediatrician or family medicine doctor, specialist (like a surgeon, heart, allergy, or skin doctor). It would be helpful
    if you referred to the Infant and Child Health Care Log that you received as part of this study or to any other personal
    record or calendar that you keep that would help you to remember the dates of these visits. If you have this information
    available, please go and get it now."
    dependency :rule => "A"
    condition_A :q_USE_IC_LOG, "!=", :a_1

    q_LAST_VISIT "What was the date of {C_FNAME or YOUR CHILD}’s most recent well-child visit or checkup?",
    :help_text => "Show calendar to assist in date recall.",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.LAST_VISIT",
    :pick => :one
    a_date "Date", :string, :custom_class => "date"
    a_neg_7 "Has not had a visit"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_VISIT_WT "What was {C_FNAME or YOUR CHILD}’s weight at that visit?",
    :help_text => "Please verify if weight < 15 or > 30 pounds",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.VISIT_WT",
    :pick => :one
    a "Pounds", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_LAST_VISIT, "==", :a_date

    label "If you haven’t yet, please put a check mark in the box next to the visit you just told me about in your Infant
    and Child Health Care Log."
    dependency :rule => "A or B or C or D"
    condition_A :q_REASON_NO_IC_LOG, "!=", :a_2
    condition_B :q_REASON_NO_IC_LOG, "!=", :a_6
    condition_C :q_REASON_NO_IC_LOG, "!=", :a_neg_1
    condition_D :q_REASON_NO_IC_LOG, "!=", :a_neg_2

    q_HOSPITAL "Since our last interview, has {C_FNAME or YOUR CHILD} spent at least one night in the hospital?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.HOSPITAL",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Hospital information" do
      dependency :rule => "A"
      condition_A :q_HOSPITAL, "==", :a_1

      q_ADMIN_DATE "What was the admission date of {C_FNAME or YOUR CHILD}’s most recent hospital stay?",
      :help_text => "Show calendar to assist in date recall.",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.ADMIN_DATE",
      :pick => :one
      a_1 "Date", :string, :custom_class => "date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HOSP_NIGHTS "How many nights did {C_FNAME or YOUR CHILD} stay in the hospital during this hospital stay?",
      :help_text => "Confirm response",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.HOSP_NIGHTS",
      :pick => :one
      a "Number of nights", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DIAGNOSE "Did a doctor or other health care provider give you a diagnosis for {C_FNAME or YOUR CHILD} during this hospital stay?",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.DIAGNOSE",
      :pick => :one
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DIAGNOSE_OTH "What was the diagnosis?",
      :help_text => "Enter all diagnoses in field separated by commas or an \"and\". Probe: \"Anything else?\"",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.DIAGNOSE_OTH",
      :pick => :one
      a "Diagnoses", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_DIAGNOSE, "==", :a_1
    end

    label "If you haven’t yet, please put a check mark in the box next to the visit you just told me about in your Infant and
    Child Health Care Log."
    dependency :rule => "A or B or C or D"
    condition_A :q_REASON_NO_IC_LOG, "!=", :a_2
    condition_B :q_REASON_NO_IC_LOG, "!=", :a_6
    condition_C :q_REASON_NO_IC_LOG, "!=", :a_neg_1
    condition_D :q_REASON_NO_IC_LOG, "!=", :a_neg_2
  end
  section "Medical conditions", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.TIME_STAMP_5"
    a :datetime, :custom_class => "datetime"

    label "Now I’d like to ask about {C_FNAME or YOUR CHILD}’s health and about some illnesses {he/she} may have had in
    the last 3 months."

    q_COND "During the past 3 months, has {C_FNAME or YOUR CHILD} had any of the following conditions?",
    :help_text => "Probe: \"Anything else?\"",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_COND.COND",
    :pick => :any
    a_1 "Three or more ear infections"
    a_2 "Wheezing or whistling in the chest"
    a_3 "Frequent or repeated diarrhea"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_FEVER "In the past 3 months, on how many days has {C_FNAME or YOUR CHILD} had a fever over 101 degrees, not related
    to receiving immunizations? ",
    :help_text => "If necessary read \"or 38.3 degrees Celsius?\". Enter \"0\" if none",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.FEVER"
    a "Number of days", :integer
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    label "Now I have some questions about specific conditions or health problems {C_FNAME or YOUR CHILD} may have."

    q_ASTHMA "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has asthma?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.ASTHMA",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_EYESIGHT "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has difficulty seeing, including nearsightedness or
    farsightedness?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.EYESIGHT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=> "A"
    condition_A :q_BLIND, "!=", :a_1

    q_DEAF "Has a doctor ever told you that {C_FNAME or YOUR CHILD} has difficulty hearing or deafness? Do not include
    a temporary loss of hearing due to a cold or congestion.",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.DEAF"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_IHMOB "Does {C_FNAME or YOUR CHILD} have an impairment or health problem that limits {his/her} ability to crawl,
    walk, run, or play?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.IHMOB"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
  section "Medications", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_6 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.TIME_STAMP_6"
    a :datetime, :custom_class => "datetime"

    label "Now, I’d like to ask about medications that may have been prescribed by a doctor or other healthcare provider
    for {C_FNAME or YOUR CHILD}. "

    q_PRESCR_TAKE "In the past 30 days, has {C_FNAME or YOUR CHILD} used or taken any medication for which a prescription is needed?
    Include only those products prescribed by a health professional such as a doctor or dentist.",
    :help_text => "Do not include prescription vitamins or minerals.",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.PRESCR_TAKE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • LOOP THROUGH PRESCRMED, PRESCR_ADMIN THROUGH PRESCRIP_FREQ/PRESCRIP_FREQ_UNIT FOR EACH PRESCRIPTION.
    # • IF FIRST LOOP, DISPLAY INTRO_PRESCRMED_1. OTHERWISE, DISPLAY INTRO_PRESCRMED_2_10.
    # • FOR INTRO_PRESCRMED_1, INTRO_PRESCRMED_2_10, PRESCR_ADMIN, PRESCR_TAKESTILL AND PRESCRIP_FREQ INSERT CORRECT MEDICATION
    # PRESCRMED FOR APPROPRIATE CYCLE.
    # Repeaters allow multiple responses to a question or set of questions

    label "Please list the name of all prescription medicines taken in the past 30 days:",
    :help_text => "Enter up to 10 medications; if more than 10 medications provided, enter first 10 provided by participant.
    Probe: Anything else?"
    dependency :rule => "A"
    condition_A :q_PRESCR_TAKE, "==", :a_1


# TODO
# MED004A/(INTRO_PRESCRMED_1). Let’s first talk about the {PRESCRMED}.
# MED004B/(INTRO_PRESCRMED_2_10). Now let’s talk about the {PRESCRMED}.

    repeater "Information on prescription medicines:" do
      dependency :rule => "A"
      condition_A :q_PRESCR_TAKE, "==", :a_1

      q_PRESCRMED "What is the name of the drug?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_PRESCR.PRESCRMED"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PRESCR_ADMIN "How is the {PRESCRMED} taken?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_PRESCR.PRESCR_ADMIN"
      a_1 "By mouth"
      a_2 "Inhaled either by mouth or nose,"
      a_3 "Injected,"
      a_4 "Applied to the skin, such as a patch or creams, or"
      a_5 "Some other way?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PRESCR_ADMIN_OTH "Specify other way",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_PRESCR.PRESCR_ADMIN_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PRESCR_TAKESTILL "Is {C_FNAME or YOUR CHILD} still taking the {PRESCRMED}?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_PRESCR.PRESCR_TAKESTILL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PRESCRIP_FREQ "How often did/does {C_FNAME or YOUR CHILD} use or take {PRESCRMED}?",
      :help_text => "Indicate frequency",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_PRESCR.PRESCRIP_FREQ"
      a "Enter number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PRESCRIP_FREQ_UNIT "Unit of how often did/does {C_FNAME or YOUR CHILD} use or take {PRESCRMED}?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_PRESCR.PRESCRIP_FREQ_UNIT"
      a_1 "Per day"
      a_2 "Per week"
      a_3 "Per month"
      a_4 "Per year"
      a_5 "As needed"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    label "Now I’d like to ask about non-prescription medications, over the counter medications, and dietary supplements
    that {C_FNAME or YOUR CHILD} may have taken in the last 30 days."

    q_OTC_TAKE "Has {C_FNAME or YOUR CHILD} used or taken any non-prescription medicines in the past 30 days?
    Include only those products purchased over the counter that do not require a prescription.",
    :help_text =>  "Do not include over-the-counter vitamins or minerals.",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.OTC_TAKE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • LOOP THROUGH OTCMED, OTC_ADMIN THROUGH OTC_FREQ/OTC_FREQ_UNIT FOR EACH OVER-THE-COUNTER MEDICATION.
    # • IF FIRST LOOP, DISPLAY INTRO_OTCMED_1. OTHERWISE, DISPLAY INTRO_OTCMED_2_10.
    # • FOR INTRO_OTCMED_1, INTRO_OTCMED_2_10, OTC_ADMIN, OTC_TAKESTILL AND OTC_FREQ INSERT CORRECT MEDICATION OTCMED FOR
    # APPROPRIATE CYCLE.


    label "Please list the name of all non-prescription medicines taken in the past 30 days:",
    :help_text => "Enter up to 10 medications; if more than 10 medications provided, enter first 10 provided by participant.
    Probe: Anything else?"
    dependency :rule => "A"
    condition_A :q_OTC_TAKE, "==", :a_1

    # TODO
    # MED010A/(INTRO_OTCMED_1). Let’s first talk about the {OTCMED}.
    # MED0010B/(INTRO_OTCMED_2_10). Now let’s talk about the {OTCMED}.

    repeater "Information on non-prescription medicines:" do
      dependency :rule => "A"
      condition_A :q_OTC_TAKE, "==", :a_1

      q_OTCMED "What is the name of the drug?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_OTC.OTCMED"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_OTC_ADMIN "How is the {OTCMED} taken?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_OTC.OTC_ADMIN"
      a_1 "By mouth"
      a_2 "Inhaled either by mouth or nose,"
      a_3 "Injected,"
      a_4 "Applied to the skin, such as a patch or creams, or"
      a_5 "Some other way?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_OTC_ADMIN_OTH "Specify other way",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_OTC.OTC_ADMIN_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_OTC_TAKESTILL "Is {C_FNAME or YOUR CHILD} still taking the {OTCMED}?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_OTC.OTC_TAKESTILL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_OTC_FREQ "How often did/does {C_FNAME or YOUR CHILD} use or take {OTCMED}?",
      :help_text => "Indicate frequency",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_OTC.OTC_FREQ"
      a "Enter number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_OTC_FREQ_UNIT "Unit of how often did/does {C_FNAME or YOUR CHILD} use or take {OTCMED}?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_OTC.OTC_FREQ_UNIT"
      a_1 "Per day"
      a_2 "Per week"
      a_3 "Per month"
      a_4 "Per year"
      a_5 "As needed"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    label "Now I would like to ask about dietary supplements."

    q_SUPPL_TAKE "Has {C_FNAME or YOUR CHILD} used or taken any vitamins, minerals, herbals, or other dietary supplements in
    the past 30 days? Include only those supplements purchased over the counter that do not require a prescription.",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SUPPL_TAKE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • LOOP THROUGH SUPPLMED, SUPPL_ADMIN THROUGH SUPPL_FREQ /SUPPL_FREQ_UNIT FOR EACH SUPPLEMENT IN SUPPL_LIST
    # • IF FIRST LOOP, DISPLAY INTRO_SUPPLMED_1. OTHERWISE, DISPLAY SUPPLMED_2_10.
    # • FOR INTRO_SUPPLMED_1, INTRO_SUPPLMED_2_10, SUPPL_ADMIN, SUPPL_TAKESTILL AND SUPPL_FREQ INSERT CORRECT MEDICATION
    # SUPPL MED FOR APPROPRIATE CYCLE.

    label "Please list the names of all vitamins, minerals, herbals, and other dietary supplements taken in the past 30 days:",
    :help_text => "Enter up to 10 supplements; if more than 10 supplements provided, enter first 10 provided by participant.
    Probe: Anything else?"
    dependency :rule => "A"
    condition_A :q_OTC_TAKE, "==", :a_1

    # TODO
    # MED016A/(INTRO_SUPPLMED_1). Let’s first talk about the {SUPPLMED}.
    # MED016B/(INTRO_SUPPLMED_2_10). Now let’s talk about the {SUPPLMED}.

    repeater "Information on supplements:" do
      dependency :rule => "A"
      condition_A :q_SUPPL_TAKE, "==", :a_1

      q_SUPPLMED "What is the name of the drug?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_SUPPL.SUPPLMED"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_SUPPL_ADMIN "How is the {SUPPLMED} taken?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_SUPPL.SUPPL_ADMIN"
      a_1 "By mouth"
      a_2 "Inhaled either by mouth or nose,"
      a_3 "Injected,"
      a_4 "Applied to the skin, such as a patch or creams, or"
      a_5 "Some other way?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_SUPPL_ADMIN_OTH "Specify other way",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_SUPPL.SUPPL_ADMIN_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_SUPPL_TAKESTILL "Is {C_FNAME or YOUR CHILD} still taking the {SUPPLMED}?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_SUPPL.SUPPL_TAKESTILL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_SUPPL_FREQ "How often did/does {C_FNAME or YOUR CHILD} use or take {SUPPLMED}?",
      :help_text => "Indicate frequency",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_SUPPL.SUPPL_FREQ"
      a "Enter number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_SUPPL_FREQ_UNIT "Unit of how often did/does {C_FNAME or YOUR CHILD} use or take {SUPPLMED}?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SUPPLE_FREQ_UNIT"
      a_1 "Per day"
      a_2 "Per week"
      a_3 "Per month"
      a_4 "Per year"
      a_5 "As needed"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Health insurance", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_7 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.TIME_STAMP_7"
    a :datetime, :custom_class => "datetime"

    label "Now I’m going to switch to another subject and ask about health insurance."

    q_INSURE "Is {C_FNAME or YOUR CHILD} currently covered by any kind of health insurance or some other kind of health care plan?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.INSURE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    group "Insurance information" do
      dependency :rule => "A"
      condition_A :q_INSURE, "==", :a_1

      label "Now I’ll read a list of different types of insurance. Please tell me which types {C_FNAME or YOUR CHILD } currently has.
      Is {C_FNAME or YOUR CHILD} currently covered by",
      :help_text => "Re-read introductory statement in parentheses as needed."

      q_INS_EMPLOY "Private insurance, that is health insurance obtained through employment or unions or purchased directly?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      q_INS_MEDICAID "Medicaid or the State Children’s Health Insurance Program, S-CHIP? In this state, the program is
      sometimes called [FILL MEDICAID NAME, SCHIP NAME]?",
      :help_text => "Provide examples of local medicaid/s-chip programs",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_TRICARE "TRICARE, VA, or other military health care?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_IHS "Indian Health Service?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_OTH "Any other type of health insurance or health coverage plan?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Product use", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_8 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.TIME_STAMP_8"
    a :datetime, :custom_class => "datetime"

    label "The next questions ask about lice exposure and treatment."

    q_LICE_1 "In the past 6 months, have you treated {C_FNAME or YOUR CHILD} or other people in your home for lice or scabies?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.LICE_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_LICE_2 "Who did you treat, was it {C_FNAME or YOUR CHILD}, someone else, or both?",
    :help_text => "Probe: \"Anyone else?\". Select all that apply",
    :pick => :any,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.LICE_2"
    a_1 "{C_FNAME or YOUR CHILD}"
    a_2 "Someone else"
    a_3 "Both {C_FNAME or YOUR CHILD} and someone else"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_LICE_1, "==", :a_1

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • GO TO PROGRAMMER INSTRUCTIONS AT START OF “MATERNAL BEHAVIORS” SECTION.
    # Nataliya's comment - what does it mean?? Coded along 12MMother_INT instructions

    q_LICE_OTH_1  "Other: specify",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.LICE_OTH_1"
    a "Specify: ", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "(A and B and G and D and E) or (B and D and E and F and G) or (B and C and F and D and E) or (A and B and C and D and E)"
    condition_A :q_LICE_2, "==", :a_1
    condition_B :q_LICE_2, "==", :a_2
    condition_C :q_LICE_2, "==", :a_3
    condition_D :q_LICE_2, "!=", :a_neg_1
    condition_E :q_LICE_2, "!=", :a_neg_2
    condition_F :q_LICE_2, "!=", :a_1
    condition_G :q_LICE_2, "!=", :a_3

    q_LICE_OTH_2  "Other: specify",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.LICE_OTH_2"
    a "Specify: ", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "(C and D and E and F and G) or (A and C and D and E and G) or (B and C and F and D and E) or (A and B and C and D and E)"
    condition_A :q_LICE_2, "==", :a_1
    condition_B :q_LICE_2, "==", :a_2
    condition_C :q_LICE_2, "==", :a_3
    condition_D :q_LICE_2, "!=", :a_neg_1
    condition_E :q_LICE_2, "!=", :a_neg_2
    condition_F :q_LICE_2, "!=", :a_1
    condition_G :q_LICE_2, "!=", :a_2
  end
  section "Maternal behaviors", :reference_identifier=>"24MMother_INT" do
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF CHILD_QNUM =1, GO TO TIME_STAMP_9
    # • IF CHILD_QNUM > 1, THEN GO TO SMOKE_HOURS
    # Nataliya's comment - impelemented, but won't work until the numeric value is fixed

    group "Maternal behaviors information" do
      dependency :rule=>"A"
      condition_A :q_CHILD_QNUM, "==", {:integer_value => "1"}

      q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"

      label "The next questions are about your experiences, since our last interview. First, I’d like to ask some questions
      about work. People’s work situations sometimes change after having a baby."

      q_WORK_LAST_CONTACT "Since our last interview, have you been employed at a job or business?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WORK_LAST_CONTACT"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_WORK_CURRENTLY "Are you currently employed?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WORK_CURRENTLY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_WORK_LAST_CONTACT, "==", :a_1

      q_WORK_HRS "How many hours per week do you work?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WORK_HRS"
      a_1 "Hours", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_WORK_CURRENTLY, "==", :a_1

      q_R_SMOKE "Do you currently smoke cigarettes or use any other tobacco product?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.R_SMOKE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NUM_SMOKER "How many smokers live in your home now?",
      :help_text => "Enter \"0\" if none",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NUM_SMOKER"
      a "Number of smokers", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_R_SMOKE, "!=", :a_1

      q_NUM_SMOKER_INCL "How many smokers live in your home now, including yourself?",
      :help_text => "Response to num_smoker must be ≥ 1",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NUM_SMOKER"
      a "Number of smokers", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_R_SMOKE, "==", :a_1

      q_SMOKE_RULES "Which of the following statements describes the rules about smoking inside your home now?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.SMOKE_RULES"
      a_1 "No one is allowed to smoke anywhere inside my home"
      a_2 "Smoking is allowed in some rooms at some times"
      a_3 "Smoking is permitted anywhere inside my home"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    q_SMOKE_HOURS "On average, about how many hours per day do people smoke in the same room as {C_FNAME or YOUR CHILD},
    or near enough that {he/she} can see or smell the smoke? Please consider all the places {C_FNAME or YOUR CHILD} is during the day,
    including at home, at daycare, or some other place.",
    :help_text => "If {he/she} is not exposed to smoke, enter \"0\".",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_HABITS.SMOKE_HOURS"
    a "Hours", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    # PROGRAMMER_INSTRUCTIONS:
    # • If CHILD_NUM =1, GO TO DRINK.
    # • IF CHILD_NUM >1, GO TO CHILD_QNUM AND LOOP THROUGH QUESTIONAIRE FROM CHILD_QNUM THROUGH SMOKE_HOURS FOR EACH
    # CHILD UNTIL CHILD_NUM=CHILD_QNUM. THEN GO TO DRINK.

    q_DRINK "Do you drink any type of alcoholic beverage?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.DRINK"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_DRINK_NOW "How often do you currently drink alcoholic beverages?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.DRINK_NOW"
    a_1 "5 or more times a week"
    a_2 "2-4 times a week"
    a_3 "Once a week"
    a_4 "1-3 times a month"
    a_5 "Less than once a month"
    a_6 "Never"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_DRINK, "==", :a_1

    q_DRINK_NOW_5 "How often do you have 5 or more drinks within a couple of hours:",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.DRINK_NOW_5"
    a_1 "Never"
    a_2 "About once a month"
    a_3 "About once a week"
    a_4 "About once a day"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A or B or C"
    condition_A :q_DRINK_NOW, "!=", :a_6
    condition_B :q_DRINK_NOW, "!=", :a_neg_1
    condition_C :q_DRINK_NOW, "!=", :a_neg_2
  end
  section "Pets", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_10"
    a :datetime, :custom_class => "datetime"

    label "Now I’d like to ask about any pets you may have in your home."

    q_PETS "Are there any pets that spend any time inside your home?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.PETS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    group "Pet's information" do
      dependency  :rule => "A"
      condition_A :q_PETS, "==", :a_1

      q_PET_TYPE "What kind of pets are these?",
      :help_text => "Select all that apply. Probe for multiple responses: \"Any others?\"",
      :pick => :any,
      :data_export_identifier=>"TWENTY_FOUR_MTH_PET_TYPE.PET_TYPE"
      a_1 "Dog"
      a_2 "Cat"
      a_3 "Small mammal (rabbit, gerbil, hamster, guinea pig, ferret, mouse)"
      a_4 "Bird"
      a_5 "Fish or reptile (turtle, snake, lizard)"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      q_PET_TYPE_OTH "Other types of pets",
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_PET_TYPE.PET_TYPE_OTH"
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
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.PET_MEDS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      q_PET_MED_TIME "When were any of these last used on any of your pets?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.PET_MED_TIME"
      a_1 "Within the last month"
      a_2 "1-3 months ago"
      a_3 "4-6 months ago"
      a_4 "More than 6 months ago"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      dependency :rule=>"A"
      condition_A :q_PET_MEDS, "==", :a_1
    end
  end
  section "In-home exposures", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_11"
    a :datetime, :custom_class => "datetime"

    label "Do you use any methods to \"allergy-proof\" your home? Please answer \"yes\" or \"no\" to each method I describe"

    q_COVERS "Impermeable mattress and or pillow covers on your child’s bed or crib?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.COVERS"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_VACUUM "Use a special vacuum such as a HEPA vacuum?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.VACUUM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_REMOVAL "Intentionally removed rugs or upholstered furniture?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.REMOVAL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_METHOD "Any other methods?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.METHOD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_METHOD_OTH "Other method",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.METHOD_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_METHOD, "==", :a_1

    q_AIR_FILTER "Does your furnace or air conditioning system use a special HEPA (High Efficiency Particulate Air) or other
    type of allergy filter to filter the air?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.AIR_FILTER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_OPEN_WINDOW "Thinking about the past 7 days, approximately how many hours a day did you keep the windows or doors open
    in your home (for ventilation or to let air in)? Was it",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.OPEN_WINDOW"
    a_1 "Less than 1 hour per day"
    a_2 "1-3 hours per day"
    a_3 "4-12 hours per day"
    a_4 "More than 12 hours per day"
    a_5 "Not at all"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    label "I would now like to ask you about cockroaches"

    q_ROACH "In the last 6 months, have you seen cockroaches in your home?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.ROACH"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the
    ceiling or walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof,
    or floods."

    q_WATER "In the last 6 months, have you seen any water damage inside your home?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WATER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_MOLD "In the last 6 months, have you seen any mold or mildew on walls or other surfaces, other than the shower or bathtub,
    inside your home?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.MOLD"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Mold information" do
      dependency :rule => "A"
      condition_A :q_MOLD, "==", :a_1

      q_ROOM_MOLD "In which rooms have you seen the mold or mildew?",
      :help_text => "Select all that apply. Probe: Any other rooms?",
      :pick => :any,
      :data_export_identifier=>"TWENTY_FOUR_MTH_ROOM_MOLD.ROOM_MOLD"
      a_1 "Kitchen"
      a_2 "Living room"
      a_3 "Hall/landing"
      a_4 "{YOUR CHILD }’s bedroom"
      a_5 "Other bedroom"
      a_6 "Bathroom/toilet"
      a_7 "Basement"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ROOM_MOLD_OTH "Other rooms",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_ROOM_MOLD.ROOM_MOLD_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A and B and C"
      condition_A :q_ROOM_MOLD, "==", :a_neg_5
      condition_B :q_ROOM_MOLD, "!=", :a_neg_1
      condition_C :q_ROOM_MOLD, "!=", :a_neg_2

      q_ROOM_MOLD_CHILD "Was the mold in {C_FNAME or YOUR CHILD} bedroom?",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER_MOLD.ROOM_MOLD_CHILD"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A and B"
      condition_A :q_ROOM_MOLD, "!=", :a_neg_1
      condition_B :q_ROOM_MOLD, "!=", :a_neg_2
    end

    label "The next few questions ask about any recent additions or renovations to your home."

    q_RENOVATE "In the last 6 months, have any additions been built onto your home to make it bigger or renovations or other
    construction been done in your home? Include only major projects. Do not count smaller projects, such as painting, wallpapering,
    carpeting or re-finishing floors.",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.RENOVATE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Renovation information" do
      dependency :rule => "A"
      condition_A :q_RENOVATE, "==", :a_1

      q_RENOVATE_ROOM "Which rooms were renovated?",
      :help_text => "Probe: Any others? Select all that apply.",
      :pick => :any,
      :data_export_identifier=>"TWENTY_FOUR_MTH_RENOVATE_ROOM.RENOVATE_ROOM"
      a_1 "Kitchen"
      a_2 "Living room"
      a_3 "Hall/landing"
      a_4 "{C_FNAME or YOUR CHILD}’s bedroom"
      a_5 "Other bedroom"
      a_6 "Bathroom/toilet"
      a_7 "Basement"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_RENOVATE_ROOM_OTH "Other room",
      :pick => :one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_RENOVATE_ROOM.RENOVATE_ROOM_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A and B and C"
      condition_A :q_RENOVATE_ROOM, "==", :a_neg_5
      condition_B :q_RENOVATE_ROOM, "!=", :a_neg_1
      condition_C :q_RENOVATE_ROOM, "!=", :a_neg_2
    end
  end
  section "Housing characteristics", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_12 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_12"
    a :datetime, :custom_class => "datetime"

    label "Now I’d like to find out more about your living situation."

    q_RECENT_MOVE "Have you moved or changed your housing situation since we contacted you last?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.RECENT_MOVE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    group "Move information" do
      dependency :rule=>"A"
      condition_A :q_RECENT_MOVE, "==", :a_1

      q_AGE_HOME "Can you tell us, which of these categories do you think best describes when your home or building was built?",
      :help_text => "If using showcards, refer participant to appropriate showcard. Otherwise, read response categories to participant.", :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.AGE_HOME"
      a_1 "2001 to present"
      a_2 "1981 to 2000"
      a_3 "1961 to 1980"
      a_4 "1941 to 1960"
      a_5 "1940 or before"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_LENGTH_RESIDE "How long have you lived in this home? Number (e.g., 5)",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.LENGTH_RESIDE"
      a "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_LENGTH_RESIDE_UNIT "How long have you lived in this home? Unit (e.g., months)",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.LENGTH_RESIDE_UNIT"
      a_1 "Weeks"
      a_2 "Months"
      a_3 "Years"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_WATER_DRINK "What water source in your home do you use most of the time for drinking? ",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WATER_DRINK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_WATER_DRINK_OTH "Other source of drinking",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WATER_DRINK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_WATER_DRINK, "==", :a_neg_5

      q_WATER_COOK "What water source in your home is used most of the time for cooking?",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WATER_COOK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_WATER_COOK_OTH "Other source of cooking water",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.WATER_COOK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_WATER_COOK, "==", :a_neg_5

      label "Neighborhood characteristics"

      label "Now I’d like to ask a few questions about your neighborhood."

      q_NEIGH_DEFN "When you are talking to someone about your neighborhood, what do you mean? Is it",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_DEFN"
      a_1 "The block or street you live on,"
      a_2 "Several blocks or streets in each direction,"
      a_3 "The area within a 15 minute walk from your house,"
      a_4 "An area larger than a 15 minute walk from your house?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_FAM "How many of your relatives or in-laws live in your neighborhood? Would you say",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_FAM"
      a_1 "None"
      a_2 "A few"
      a_3 "Many"
      a_4 "Most"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_FRIEND "How many of your friends live in your neighborhood? Would you say",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_FRIEND"
      a_1 "None"
      a_2 "A few"
      a_3 "Many"
      a_4 "Most"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGHBORS "About how many adults do you recognize or know by sight in this neighborhood? Would you say you recognize",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGHBORS"
      a_1 "None"
      a_2 "A few"
      a_3 "Many"
      a_4 "Most"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # Have to calculate DATE 30 DAYS AGO
      q_NEIGH_NUM_TALK "In the past 30 days, that is since [INSERT DATE 30 DAYS AGO], how many of your neighbors have you
      talked with for 10 minutes of more? Would you say",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_NUM_TALK"
      a_1 "None"
      a_2 "1 or 2"
      a_3 "3 to 5"
      a_4 "6 or more"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_HELP "About how often do you and people in your neighborhood do favors for each other? By favors, we mean such
      things as watching each other’s children, helping with shopping, lending garden or house tools.",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_HELP"
      a_1 "Often"
      a_2 "Sometimes"
      a_3 "Rarely"
      a_4 "Never"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_TALK "How often do you and other people in your neighborhood visit in each other’s homes or speak with each
      other on the street?",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_TALK"
      a_1 "Often"
      a_2 "Sometimes"
      a_3 "Rarely"
      a_4 "Never"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_WATCH_1 "If children were skipping school and hanging out, how likely is it that your neighbors would do something
      about it? Would you say it is",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_WATCH_1"
      a_1 "Very Likely,"
      a_2 "Likely,"
      a_3 "Unlikely,"
      a_4 "Very Unlikely"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_WATCH_2 "If children were showing disrespect to an adult, how likely is it that your neighbors would do something
      about it? Would you say it is",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_WATCH_2"
      a_1 "Very Likely,"
      a_2 "Likely,"
      a_3 "Unlikely,"
      a_4 "Very Unlikely"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Please tell me if you agree or disagree with the following statements."

      q_NEIGH_CLOSE "This is a close-knit neighborhood. Would you say you.",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_CLOSE"
      a_1 "Strongly agree,"
      a_2 "Agree,"
      a_3 "Disagree,"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_TRUST "People in this neighborhood can be trusted. Would you say you",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_TRUST"
      a_1 "Strongly agree,"
      a_2 "Agree,"
      a_3 "Disagree,"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_SAFE_1 "I feel safe walking in my neighborhood, day or night.",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_SAFE_1"
      a_1 "Strongly agree,"
      a_2 "Agree,"
      a_3 "Disagree,"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_SAFE_2 "Violence is not a problem in my neighborhood.",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_SAFE_2"
      a_1 "Strongly agree,"
      a_2 "Agree,"
      a_3 "Disagree,"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NEIGH_SAFE_3 "My neighborhood is safe from crime.",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.NEIGH_SAFE_3"
      a_1 "Strongly agree,"
      a_2 "Agree,"
      a_3 "Disagree,"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Tracing questions", :reference_identifier=>"24MMother_INT" do
    q_TIME_STAMP_13 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_13"
    a :datetime, :custom_class => "datetime"

    label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember that
    all the information you provide is confidential and will not be provided to anyone outside the National Children’s Study."

    q_COMM_EMAIL "When we last spoke, we asked questions about communicating with you through your personal email.
    Has your email address or your preferences regarding use of your personal email changed since then?", :pick=>:one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.COMM_EMAIL"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_HAVE_EMAIL "Do you have an email address?", :pick=>:one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.HAVE_EMAIL"
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
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.EMAIL_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EMAIL_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?",
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.EMAIL_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EMAIL "What is the best email address to reach you?", :pick=>:one,
      :help_text=>"Show example of valid email address such as maryjane@email.com",
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.EMAIL"
      a_1 "Enter e-mail address:", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    q_COMM_CELL "When we last spoke, we asked questions about communicating with you through your personal cell
    phone number. Has your cell phone number or your preferences regarding use of your personal cell phone number
    changed since then?", :pick=>:one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.COMM_CELL"
    a_1 "Yes"
    a_2 "No"
    a_3 "Don't remember"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CELL_PHONE_1 "Do you have a personal cell phone?", :pick=>:one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CELL_PHONE_1"
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
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CELL_PHONE_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CELL_PHONE_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CELL_PHONE_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CELL_PHONE_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CELL_PHONE_4"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CELL_PHONE "What is your personal cell phone number?", :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CELL_PHONE"
      a_1 "Phone number", :string
      a_neg_7 "Participant has no cell phone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    q_TIME_STAMP_14 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_14"
    a :datetime, :custom_class => "datetime"

    q_COMM_CONTACT "Sometimes if people move or change their telephone number, we have difficulty reaching them. At our last visit,
    we asked for contact information for two friends or relatives not living with you who would know where you could be reached in case we
    have trouble contacting you. Has that information changed since our last visit?",
    :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.COMM_CONTACT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CONTACT_1 "Could I have the name of a friend or relative not currently living with you who should know where you could be reached
    in case we have trouble contacting you?",
    :pick=>:one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_1"
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
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names",
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_FNAME_1"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_LNAME_1 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names",
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_LNAME_1"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE_1 "What is his/her relationship to you?",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_RELATE_1"
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
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_RELATE1_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CONTACT_RELATE_1, "==", :a_neg_5

      label "What is his/her address?",
      :help_text => "Prompt as necessary to complete information"

      q_C_ADDR1_1 "Address 1 - street/PO Box",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ADDR1_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ADDR_2_1 "Address 2",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ADDR_2_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_UNIT_1 "Unit",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_UNIT_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_CITY_1 "City",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_CITY_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_STATE_1 "State", :display_type=>:dropdown,
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_STATE_1"
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
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ZIPCODE_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ZIP4_1 "ZIP+4",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ZIP4_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_PHONE_1 "What is his/her telephone number?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_PHONE_1"
      a_1 "Phone number", :string
      a_neg_7 "Contact has no telephone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Now I’d like to collect information on a second contact who does not currently live with you.
      What is the person's name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names"

      q_CONTACT_FNAME_2 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names",
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_FNAME_2"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_LNAME_2 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names",
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_LNAME_2"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_RELATE_2 "What is his/her relationship to you?", :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_RELATE_2"
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
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_RELATE2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_CONTACT_RELATE_2, "==", :a_neg_5

      label "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_C_ADDR1_2 "Address 1 - street/PO Box",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ADDR1_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ADDR_2_2 "Address 2",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ADDR_2_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_UNIT_2 "Unit",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_UNIT_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_CITY_2 "City",
      :pick=>:one
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_STATE_2 "State", :display_type=>:dropdown,
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_STATE_2"
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
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ZIPCODE_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_C_ZIP4_2 "ZIP+4",
      :pick=>:one,
      :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.C_ZIP4_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CONTACT_PHONE_2 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls",
      :pick=>:one, :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.CONTACT_PHONE_2"
      a_1 "Phone number", :string
      a_7 "Contact has no phone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey.
    This concludes the interview portion of our visit.",
    :help_text => "Explain SAQs and return process"

    q_hipv1_TIME_STAMP_15 "Insert date/time stamp", :data_export_identifier=>"TWENTY_FOUR_MTH_MOTHER.TIME_STAMP_15"
    a :datetime, :custom_class => "datetime"
  end
end

