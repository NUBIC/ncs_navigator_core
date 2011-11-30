survey "INS_QUE_Father_INT_EHPBHI_P2_V1.0" do
  section "Interview introduction", :reference_identifier=>"Father_INT" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Thank you for agreeing to participate in this study. We are about to begin the interview portion
    of today’s visit, which will take about 15 minutes to complete. Your answers are important to us. There
    are no right or wrong answers, just those that help us to understand your situation. There are questions
    about where you work, your health, and your feelings during this interview and you can always refuse to
    answer any question or group of questions."

    q_F_INT_READY "Are you ready to begin?",
    :help_text => "Determine if better time to contact father for interview.",
    :pick => :one,
    :data_export_identifier=>"FATHER_PV1.F_INT_READY"
    a_1 "Yes"
    a_2 "No"
  end
  section "Demographics: Part 1", :reference_identifier=>"Father_INT" do
    group "Demographics: Part 1" do
      dependency :rule => "A"
      condition_A :q_F_INT_READY, "==", :a_1

      q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime"

      label "I’ll begin by asking some questions about you."

      label "What is your full name?",
      :help_text => "If participant refuses to provide information, re-state confidentiality protections, ask for initials
      or some other name she would like to be called. Confirm spelling of first name if not previously collected and of
      last name for all participants."

      q_R_FNAME "First name",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.R_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_R_LNAME "Last name",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.R_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PERSON_DOB "What is your date of birth?",
      :help_text => "If participant refuses to provide information, re-state confidentiality protections and that dob
      is required to determine eligibility. If response was determined to be invalid, ask question again and probe for
      valid response. Verify if calculated age is less than local age of majority.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.PERSON_DOB"
      a "Date", :string, :custom_class => "date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_AGE_ELIG "Is participant age-eligible? ",
      :help_text => "Based on person_dob calculate age. using known local age of majority determine if he is eligible
      (at least age of majority); set age_elig as appropriate. If value is \"Refused\" or \"Don’t know\" flag case
      for supervisor review at SC to confirm age eligibility post-interview.",
      :pick=>:one,
      :data_export_identifier=>"FATHER_PV1.AGE_ELIG"
      a_1 "Participant is age-eligible"
      a_2 "Participant is younger than age of majority"
      a_neg_6 "Age eligibility is unknown"

      label "Case for supervisor review at SC to confirm age eligibility post-interview"
      dependency :rule => "A or B"
      condition_A :q_PERSON_DOB, "==", :a_neg_1
      condition_B :q_PERSON_DOB, "==", :a_neg_2

      # label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey.
      # This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_1_2.END"
      # dependency :rule=> "A"
      # condition_A :q_AGE_ELIG, "==", :a_2
      #
      # label "Interviewer instructions: end the questionare"
      # dependency :rule=>"A"
      # condition_A :q_AGE_ELIG, "==", :a_2

      q_F_RELATE "Are you the child's...",
      :pick=>:one,
      :data_export_identifier=>"FATHER_PV1.F_RELATE"
      a_1 "Birth father,"
      a_2 "Adoptive father,"
      a_3 "Step father,"
      a_4 "Foster father or male guardian, or"
      a_neg_5 "Do you have some other relationship to child?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_F_RELATE_OTH "Specify relationship to child",
      :pick=>:one,
      :data_export_identifier=>"FATHER_PV1.F_RELATE_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_F_RELATE, "==", :a_neg_5

      q_F_MARISTAT "I’d like to ask about your marital status. Are you:",
      :help_text => "Probe for current marital status",
      :pick=>:one,
      :data_export_identifier=>"FATHER_PV1.F_MARISTAT"
      a_1 "Married,"
      a_2 "Not married, but living together with a partner"
      a_3 "Never been married,"
      a_4 "Divorced,"
      a_5 "Separated, or"
      a_6 "Widowed?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_ETHNICITY "Do you consider yourself to be Hispanic, or Latino?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.ETHNICITY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_RACE "What race do you consider yourself to be? You may select one or more.",
      :help_text => "Show response options on card to participant. Only use \"Some other race\" if volunteered.
      Don’t ask. Probe: Anything else? Select all that apply.",
      :pick => :any,
      :data_export_identifier=>"FATHER_PV1_RACE.RACE"
      a_1 "White,"
      a_2 "Black or african american,"
      a_3 "American indian or alaska native,"
      a_4 "Asian, or"
      a_5 "Native hawaiian or other pacific islander?"
      a_6 "Multi-racial"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_EDUC "What is the highest degree or level of school that you have completed?",
      :help_text => "Show response options on card to participant. Select all that apply.",
      :pick => :any,
      :data_export_identifier=>"FATHER_PV1_EDUC.EDUC"
      a_1 "Less than a high school diploma or GED"
      a_2 "High school diploma or GED"
      a_3 "Some college but no degree"
      a_4 "Associate degree"
      a_5 "Bachelor’s degree (e.g., BA, BS)"
      a_6 "Post graduate degree (e.g., Masters or Doctoral)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2
    end
  end
  section "Tobacco use", :reference_identifier=>"Father_INT" do
    group "Tobacco use information" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_3"
      a :datetime, :custom_class => "datetime"

      label "The next question is about your use of cigarettes."

      q_CIG_NOW "Currently do you smoke cigarettes?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.CIG_NOW"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Alcohol use", :reference_identifier=>"Father_INT" do
    group "Alcohol use information" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_4"
      a :datetime, :custom_class => "datetime"

      label "Now I am going to ask about your use of alcohol."

      q_DRINK "Do you drink any type of alcoholic beverage?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.DRINK"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DRINK_NOW "How often do you currently drink alcoholic beverages?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.DRINK_NOW"
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
      :data_export_identifier=>"FATHER_PV1.DRINK_NOW_5"
      a_1 "Never,"
      a_2 "About once a month,"
      a_3 "About once a week,"
      a_4 "About once a day, or"
      a_5 "Less than once a month"
      dependency :rule => "A and B"
      condition_A :q_DRINK_NOW, "!=", :a_neg_1
      condition_B :q_DRINK_NOW, "!=", :a_neg_2
    end
  end
  section "Self rated health", :reference_identifier=>"Father_INT" do
    group "Self rated health information" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_5"
      a :datetime, :custom_class => "datetime"

      label "Now, I have questions about your health and about medical conditions or health problems you have or have had."

      q_F_HEALTH "How would you rate your overall physical health at the present time? Would you say
      it is excellent, very good, good, fair or poor?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_HEALTH"
      a_1 "Excellent"
      a_2 "Very good"
      a_3 "Good"
      a_4 "Fair"
      a_5 "Poor"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_ASTHMA "Have you ever been told by a doctor or other health care provider that you had asthma?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_ASTHMA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_ECZEMA "Have you ever been told by a doctor or other health care provider that you had: Eczema or atopic dermatitis?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_ECZEMA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_ALLERGIES "Have you ever been told by a doctor or other health care provider that you had: Seasonal allergies?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_ALLERGIES"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_HIGHBP "Have you ever been told by a doctor or other health care provider that you had: Hypertension or high blood pressure?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_HIGHBP"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_DIABETES "Have you ever been told by a doctor or other health care provider that you had: Diabetes?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_DIABETES"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_HIGHCHOLEST "Have you ever been told by a doctor or other health care provider that you had: High cholesterol?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_HIGHCHOLEST"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_CANCER "Have you ever been told by a doctor or other health care provider that you had: Any type of cancer?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_CANCER"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_CANCER_TYPE "What type or types of cancer were you diagnosed with?",
      :pick => :any,
      :data_export_identifier=>"FATHER_PV1_CANCER.F_CANCER_TYPE"
      a_1 "Brain"
      a_2 "Breast"
      a_3 "Colon"
      a_4 "Hodgkin’s lymphoma"
      a_5 "Leukemia"
      a_6 "Liver"
      a_7 "Lung"
      a_8 "Non-hodgkin’s lymphoma"
      a_9 "Prostate (male only)"
      a_10 "Skin"
      a_11 "Testicular (male only)"
      a_12 "Thyroid"
      a_13 "Uterine (female only)"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_F_CANCER, "==", :a_1

      q_F_CANCER_TYPE_OTH "Other",
      :data_export_identifier=>"FATHER_PV1.F_CANCER_TYPE_OTH"
      a "Specify", :string
      dependency :rule => "A and B and C"
      condition_A :q_F_CANCER_TYPE, "==", :a_neg_5
      condition_B :q_F_CANCER_TYPE, "!=", :a_neg_1
      condition_C :q_F_CANCER_TYPE, "!=", :a_neg_2

      q_F_SICKLECELL "Have you ever been told by a doctor or other health care provider that you had:
      Sickle cell anemia or sickle cell trait?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_SICKLECELL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_AUTOIMMUNE "Have you ever been told by a doctor or other health care provider that you had:
      An autoimmune disorder such as rheumatoid arthritis, lupus, or scleroderma?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_AUTOIMMUNE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_AUTOIMMUNE_TYPE "What type of autoimmune disorder were you diagnosed with?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_AUTOIMMUNE_TYPE"
      a_1 "Rheumatoid arthritis"
      a_2 "Lupus"
      a_3 "Scleroderma"
      a_4 "Multiple sclerosis"
      a_5 "Graves’ disease"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_F_AUTOIMMUNE, "==", :a_1

      q_F_AUTOIMMUNE_TYPE_OTH "Other",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_AUTOIMMUNE_TYPE_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_F_AUTOIMMUNE_TYPE, "==", :a_neg_5

      q_F_BIRTH_DEFECT "Have you ever been told by a doctor or other health care provider that you had: A birth defect?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_BIRTH_DEFECT"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_DEFECT_TYPE "What birth defect were you diagnosed with?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_DEFECT_TYPE"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_F_BIRTH_DEFECT, "==", :a_1

      q_F_BLIND "Have you ever been told by a doctor or other health care provider that you had:
      Blindness or any severe vision impairment?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_BLIND"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_DEAF "Have you ever been told by a doctor or other health care provider that you had:
      Deafness or any severe hearing impairment?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_DEAF"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_ADD "Have you ever been told by a doctor or other health care provider that you had:
      Attention deficit disorder (ADD) or attention deficit hyperactivity disorder (ADHD)?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_ADD"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_AUTISM "Have you ever been told by a doctor or other health care provider that you had:
      Autism,  Asperger syndrome, or any other autism spectrum disorder?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_AUTISM"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_BIPOLAR "Have you ever been told by a doctor or other health care provider that you had: Bipolar disorder?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_BIPOLAR"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_DEPRESSION "Have you ever been told by a doctor or other health care provider that you had:
      Depression, other than bipolar disorder?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_DEPRESSION"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_ANXIETY "Have you ever been told by a doctor or other health care provider that you had:
      An anxiety disorder, such as generalized anxiety disorder or obsessive compulsive disorder (OCD)?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_ANXIETY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_OTH_CONDITION "Have you ever been told by a doctor or other health care provider that you had:
      Any other chronic or long-lasting conditions?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_OTH_CONDITION"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_CONDITION_OTH "What other chronic condition or conditions were you diagnosed with?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_CONDITION_OTH"
      a "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_F_OTH_CONDITION, "==", :a_1
    end
  end
  section "Occupational/hobby exposures", :reference_identifier=>"Father_INT" do
    group "Occupational/hobby exposures information" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_TIME_STAMP_6 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_6"
      a :datetime, :custom_class => "datetime"

      label "Now I’d like to ask some questions about work and income."

      q_WORKING "Are you currently working any full or part-time jobs?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.WORKING"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_WORK_HRS "How many hours per week do you work?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.WORK_HRS"
      a_hours "Hours", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_WORKING, "==", :a_1

      q_JOB_SATISFIED "All in all, how satisfied are you with your job? Would you say very satisfied,
      somewhat satisfied, somewhat dissatisfied, or very dissatisfied?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.JOB_SATISFIED"
      a_1 "Very satisfied"
      a_2 "Somewhat satisfied"
      a_3 "Somewhat dissatisfied"
      a_4 "Very dissatisfied"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_WORKING, "==", :a_1
    end
  end
  section "Income", :reference_identifier=>"Father_INT" do
    group "Income information" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      label "Now I’m going to ask a few questions about your income. Family income is important in
      analyzing the data we collect and is often used in scientific studies to compare groups of
      people who are similar. Please remember that all the information you provide is confidential.
      Please think about your total combined family income during [CURRENT YEAR – 1] for all members of the family."

      # TODO
      # PROGRAMMER INSTRUCTIONS:
      # • PRELOAD CURRENT YEAR MINUS 1.
      q_HH_MEMBERS "How many household members are supported by your total combined family income?",
      :help_text => "Response must be > 0 and < 15",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.HH_MEMBERS"
      a_num "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # • IF HH_MEMBERS = 1, -1 (REFUSED), or -2 (DON’T KNOW), GO TO INCOME.  OTHERWISE, IF HH_MEMBERS > 1, GO TO NUM_CHILD.
      q_NUM_CHILD "How many of those people are children? Please include anyone under 18 years
      or anyone older than 18 years and in high school.",
      :help_text => "Response must be < 10",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.NUM_CHILD"
      a_num "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_HH_MEMBERS, "==", :a_num

      q_INCOME "Of these income groups, which category best represents your total combined
      family income during the last calendar year?",
      :help_text => "Show response options on card to participant",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INCOME"
      a_1 "Less than $30,000"
      a_2 "$30,000-$49,999"
      a_3 "$50,000-$99,999"
      a_4 "$100,000 or more"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Mental health", :reference_identifier=>"Father_INT" do
    group "Mental health information" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_TIME_STAMP_7 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_7"
      a :datetime, :custom_class => "datetime"

      label "Now, I will read a list of the ways you might have felt or behaved. Please look at this card,
      and tell me how often you have felt this way during the past week.",
      :help_text => "Show response options on card to participant"

      q_BOTHERED "I was bothered by things that usually don’t bother me.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.BOTHERED"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_APPETITE_POOR "I did not feel like eating; my appetite was poor.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.APPETITE_POOR"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BLUES "I felt that I could not shake off the blues even with help from my family or friends.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.BLUES"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_GOOD_AS_OTHERS "I felt that I was just as good as other people.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.GOOD_AS_OTHERS"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_TRB_KEEP_MIND "I had trouble keeping my mind on what I was doing.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.TRB_KEEP_MIND"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_DEPRESSED "I felt depressed.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.DEPRESSED"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EVTHG_EFFORT "I felt that everything I did was an effort.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.EVTHG_EFFORT"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HOPEFUL_FUTURE "I felt hopeful about the future.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.HOPEFUL_FUTURE"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_LIFE_FAILURE "I thought my life had been a failure.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.LIFE_FAILURE"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_FELT_FEARFUL "I felt fearful.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.FELT_FEARFUL"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_SLEEP_RESTLESS "My sleep was restless.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.SLEEP_RESTLESS"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_HAPPY "I was happy.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.HAPPY"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_TALKED_LESS "I talked less than usual.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.TALKED_LESS"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_FELT_LONELY "I felt lonely.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.FELT_LONELY"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_PEOPLE_UNFRIENDLY "People were unfriendly.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.PEOPLE_UNFRIENDLY"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ENJOYED_LIFE "I enjoyed life.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.ENJOYED_LIFE"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CRYING_SPELLS "I had crying spells.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.CRYING_SPELLS"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_FELT_SAD "I felt sad.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.FELT_SAD"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_FEEL_PEOP_DISLIKE "I felt that people dislike me.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.FEEL_PEOP_DISLIKE"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_NOT_GET_GOING "I could not get \"going.\"",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.NOT_GET_GOING"
      a_1 "Rarely or none of the time (less than one day)"
      a_2 "Some or a little of the time (1-2 days)"
      a_3 "Occasionally or a moderate amount of time (3-4 days)"
      a_4 "Most or all of the time (5-7 days)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Household composition and demographics: Part 2", :reference_identifier=>"Father_INT" do
    group "Household composition and demographics: Part 2" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_TIME_STAMP_8 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_8"
      a :datetime, :custom_class => "datetime"

      label "These next questions are about your background and culture."

      q_BORN_US "Were you born in the United States?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.BORN_US"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_TIME_US "About how long have you lived in the United States?",
      :help_text => "If less than one year, enter \"00\".",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.TIME_US"
      a_years "Years", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_BORN_US, "==", :a_2

      q_M_BORN_US "Was your mother born in the United States?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.M_BORN_US"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_BORN_US "Was your father born in the United States?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_BORN_US"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Now I’m going to switch the subject and ask about health insurance."

      q_INS_EMPLOY "Do you currently have insurance through a current or former employer or union
      (of yourself or another family member)?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_PURCHASED "(Do you currently have): Insurance purchased directly from an
      insurance company (by yourself or another family member)?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INS_PURCHASED"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_MEDICAID "(Do you currently have:)
      Medicaid, Medical Assistance, or any kind of government-assistance plan for those with low incomes or a disability?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_TRICARE "(Do you currently have:) TRICARE, VA, or other military health care?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_IHS "(Do you currently have:) Indian Health Service?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_MEDICARE "(Do you currently have:) Medicare, for people 65 and older, or people with certain disabilities?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INS_MEDICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_INS_OTH "(Do you currently have:) Any other type of health insurance or health coverage plan?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Social resources", :reference_identifier=>"Father_INT" do
    group "Social resources" do
      dependency :rule => "A"
      condition_A :q_AGE_ELIG, "!=", :a_2

      q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"

      label "Social network:"

      label "I’d like to ask you about your contact with other people."

      q_NUM_PEOPLE_COMM "On a normal day, how many people do you communicate with? (including nodding,
      saying hi, talking, calling, writing, through the Internet, acquaintances or not, all added together).",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.NUM_PEOPLE_COMM"
      a_num "Number of people", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_FREQ_COMM "How often do you see, write or talk on the telephone with family or relatives who do not
      live with you? Would you say nearly every day, at least once a week, a few times a month, at least
      once a month, a few times a year, hardly ever or never?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.FREQ_COMM"
      a_1 "Nearly everyday (4 or more times a week)"
      a_2 "At least once a week (1 to 3 times)"
      a_3 "A few times a month (2 to 3 times)"
      a_4 "At least once a month"
      a_5 "A few times a year"
      a_6 "Hardly ever"
      a_7 "Never"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Social support:"

      label "Now, I’m going to ask about your feelings and thoughts."

      q_SOCIAL_SUPPORT "How often do you get the social and emotional support you need? Would you say
      always, usually, sometimes, rarely, or never?",
      :help_text => "If asked, read \"Please include support from any source.\"",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.SOCIAL_SUPPORT"
      a_1 "Always"
      a_2 "Usually"
      a_3 "Sometimes"
      a_4 "Rarely"
      a_5 "Never"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Paternal involvement", :reference_identifier=>"Father_INT" do
    group "Paternal involvement" do
      dependency :rule => "A or B"
      condition_A :q_AGE_ELIG, "!=", :a_2
      condition_B :F_INT_READY, "==", :a_2

      q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_10"
      a :datetime, :custom_class => "datetime"

      label "General involvement:"

      q_TIMING "Now I'd like to ask about your spouse or partner's current pregnancy. Did you feel
      that she became pregnant sooner than you wanted, later than you wanted or at about the right time?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.TIMING"
      a_1 "Too soon"
      a_2 "Right time"
      a_3 "Later"
      a_4 "Didn’t care"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Have you done any of the following?"

      q_DISCUSS_PREG "Discussed the pregnancy with spouse/partner?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.DISCUSS_PREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_SEEN_SONO "Seen a sonogram/ultrasound?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.SEEN_SONO"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_LISTEN_HEART "Listened to baby’s heartbeat?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.LISTEN_HEART"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_FELT_MOVE "Felt baby move?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.FELT_MOVE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ATTEND_LAMAZE "Attended childbirth or Lamaze classes?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.ATTEND_LAMAZE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_BOUGHT_BABY "Bought things for the baby?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.BOUGHT_BABY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "General commitment:"

      q_PLAN_ATTEND_BIRTH "Do you plan to be present at the birth?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.PLAN_ATTEND_BIRTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_CHILD_LNAME "Will the {baby/babies} have your last name?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.CHILD_LNAME"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      #     PROGRAMMER INSTRUCTION:
      #     •	If IN MOTHER’S PREGNANCY VISIT 1 INTERVIEW, MULTIPLE_GESTATION=1, -1 OR -2, DISPLAY “BABY,” ELSE DISPLAY “BABIES.”

      q_WANT_CHILD_LNAME "Do you want the {baby/babies} to have your last name?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.WANT_CHILD_LNAME"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # PROGRAMMER INSTRUCTION:
      # • If IN MOTHER’S PREGNANCY VISIT 1 INTERVIEW, MULTIPLE_GESTATION=1, -1 OR -2, DISPLAY “BABY,” ELSE DISPLAY “BABIES.”

      q_FAM_ATTEND_BIRTH "Will any of your family members be present for the birth?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.FAM_ATTEND_BIRTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_WANT_FAM_ATTEND "Do you want any of your family members to be present for the birth?",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.WANT_FAM_ATTEND"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Beliefs about involvement:"

      label "Here are some statements that men have made about their role as fathers. For each of the
      following statements, please look at this card  and tell me whether you strongly agree, agree, disagree,
      or strongly disagree with the statement.",
      :help_text => "Show response options on card to participant."

      q_F_TIME_ESSENTIAL "It is essential for the child's well being that fathers spend time playing with their children.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_TIME_ESSENTIAL"
      a_1 "Strongly agree"
      a_2 "Agree"
      a_3 "Disagree"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_AFFECT_DIFFICULT "It is difficult for men to express affectionate feelings toward babies.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.AFFECT_DIFFICULT"
      a_1 "Strongly agree"
      a_2 "Agree"
      a_3 "Disagree"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_INVOLVED_AS_M "A father should be as heavily involved as the mother in the care of the child.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_INVOLVED_AS_M"
      a_1 "Strongly agree"
      a_2 "Agree"
      a_3 "Disagree"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_EFFECTS_BABY "The way a father treats his baby has long-term effects on the child.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_EFFECTS_BABY"
      a_1 "Strongly agree"
      a_2 "Agree"
      a_3 "Disagree"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_PROVIDE_MATTER "The activities a father does with his children don't matter. What matters more is whether he provides for them.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_PROVIDE_MATTER"
      a_1 "Strongly agree"
      a_2 "Agree"
      a_3 "Disagree"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_SUPPORT_M "One of the most important things a father can do for his children is to give their
      mother encouragement and emotional support.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_SUPPORT_M"
      a_1 "Strongly agree"
      a_2 "Agree"
      a_3 "Disagree"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_F_REWARD "All things considered, fatherhood is a highly rewarding experience.",
      :pick => :one,
      :data_export_identifier=>"FATHER_PV1.F_REWARD"
      a_1 "Strongly agree"
      a_2 "Agree"
      a_3 "Disagree"
      a_4 "Strongly disagree"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end

    label "Thank you for participating in the National Children’s Study and for taking the time to complete this interview."

    q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"FATHER_PV1.TIME_STAMP_11"
    a :datetime, :custom_class => "datetime"

  end
end
