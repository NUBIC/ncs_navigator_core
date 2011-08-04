survey "INS_QUE_PregVisit1_SAQ_EHPBHI_P2_V2.0" do
  section "SELF-ADMINISTERED QUESTIONAIRE", :reference_identifier=>"PREG_VISIT_1_SAQ_2" do
    label "<b>NOTE:</b> THE SAQS MAY BE COMPLETED IN EITHER A PAPI OR CASI MODE"
    
    q_is_papi_mode "IS SAQ COMPLETED IN A PAPI MODE?", :pick => :one
    a_1 "YES"
    a_2 "NO"
    
    q_participant_id "<b>FIELD INTERVIEWER INSTRUCTION:</b> ENTER THE PARTICIPANT ID"
    a :string
    dependency :rule => "A"
    condition_A :q_is_papi_mode, "==", :a_1

    q_time_stamp_1 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.TIME_STAMP_1"
    a :datetime
    
    label "Thank you for agreeing to participate in this study. This self-administered questionnaire will take about 
    10 minutes to complete. There are questions about your pregnancy and your lifestyle. We will also ask you about 
    your satisfaction with our visit with you today.<br>Your answers are important to us. There are no right or wrong 
    answers. You can always refuse to answer any question or group of questions, and your answers will be kept confidential."
  end
  section "PREGNANCY INTENTIONS AND HISTORY", :reference_identifier=>"PREG_VISIT_1_SAQ_2" do  
    q_PLANNED "Regarding this pregnancy, were you trying to become pregnant?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.PLANNED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
     
    q_MONTH_TRY "For about how many months were you trying to become pregnant? <br>
    <b>INTERVIEWER INSTRUCTION: </b><br>
    -If 1 month or less, enter 1",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.MONTH_TRY"
    a_months "Months", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule => "A"
    condition_A :q_PLANNED, "==", :a_1        
    
    label "The provided value is outside the suggested range. (Range < 24) This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_hh_members, "<", {:integer_value => "1"}
    condition_B :q_hipv1_2_hh_members, ">", {:integer_value => "24"}
    
    q_WANTED "When you became pregnant, did you yourself actually want to have a baby at sometime?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.WANTED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_TIMING "Would you say you became pregnant too soon, at about the right time, or later than you wanted?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.TIMING"
    a_1 "Too Soon"
    a_2 "Right Time"
    a_3 "Later"
    a_4 "Didn’t Care"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule => "A"
    condition_A :q_WANTED, "==", :a_1
    
    q_FATHER_NAME "Part of the National Children’s Study includes a planned study visit with the baby’s father. 
    What is the first and last name of your baby’s father?", 
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.FATHER_NAME"
    a_F_F_NAME_and_F_L_NAME "FIRST and LAST NAME:", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_FATHER_SAME_HH "Is the father of your baby/[FIRST NAME OF FATHER] living in the same household as you?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.FATHER_SAME_HH"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_FATHER_KNOW_PREG "Is the father/[FIRST NAME OF FATHER] aware of your pregnancy?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.FATHER_SAME_HH"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_CONTACT_F_NOW "May we have your permission to contact the father/[FIRST NAME OF FATHER] and invite him to participate 
    in the Study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CONTACT_F_NOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule => "A"
    condition_A :q_FATHER_KNOW_PREG, "!=", :a_2
    
    q_CONTACT_F_LATER "Once you have shared the information about your pregnancy with the father/[FIRST NAME OF FATHER], 
    may we have your permission to contact him and invite him to participate in the Study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CONTACT_F_LATER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule => "A"
    condition_A :q_FATHER_KNOW_PREG, "==", :a_2
    
    label_SHARE_PREG_F "The next time we follow up with you, we will ask if you have shared the information about your pregnancy 
    with the father/[FIRST NAME OF FATHER] so that we know if it is the right time to contact him."
    dependency :rule => "A"
    condition_A :q_CONTACT_F_LATER, "==", :a_1
    
    q_F_ADDR "What is the father’s/[FIRST NAME OF FATHER’s] home address?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>- PROMPT AS NECESSARY TO COMPLETE INFORMATION", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"


# FATHER_SAME_HH = 2 AND CONTACT_F_NOW 
    q_F_ADDR1_2 "ADDRESS 1 - STREET/PO BOX", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.F_ADDR1_2"  
    a :string
    dependency :rule=>"A and B and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_2
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    condition_C :q_F_ADDR, "==", :a_1
    

    q_F_ADDR_2_2 "ADDRESS 2", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.F_ADDR_2_2"
    a :string
    dependency :rule=>"A and B and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_2
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    condition_C :q_F_ADDR, "==", :a_1

    q_F_UNIT_2 "UNIT", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.F_UNIT_2"
    a :string
    dependency :rule=>"A and B and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_2
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    condition_C :q_F_ADDR, "==", :a_1

    q_F_CITY_2 "CITY", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.F_CITY_2"
    a :string
    dependency :rule=>"A and B and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_2
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    condition_C :q_F_ADDR, "==", :a_1

    q_F_STATE_2 "STATE", :display_type=>"dropdown", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.F_STATE_2"
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
    dependency :rule=>"A and B and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_2
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    condition_C :q_F_ADDR, "==", :a_1

    q_F_ZIPCODE_2 "ZIP CODE", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.F_ZIPCODE_2"
    a :string
    dependency :rule=>"A and B and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_2
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    condition_C :q_F_ADDR, "==", :a_1

    q_F_ZIP4_2 "ZIP+4", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.F_ZIP4_2"
    a :string
    dependency :rule=>"A and B and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_2
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    condition_C :q_F_ADDR, "==", :a_1

    q_F_PHONE "What is the father’s/[FIRST NAME OF FATHER’s] telephone number (XXXXXXXXXX)?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>- IF FATHER HAS NO TELEPHONE ASK FOR TELEPHONE NUMBER WHERE HE/SHE RECEIVES CALLS", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_PHONE_1"
    a_1 "PHONE NUMBER", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "FATHER HAS NO TELEPHONE"
    dependency :rule=>"A and B"
    condition_A :q_FATHER_SAME_HH, "==", :a_1
    condition_B :q_CONTACT_F_NOW, "==", :a_1
    
    q_F_AGE "What is the father’s/[FIRST NAME OF FATHER’s] age?",
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.F_AGE"
    a_f_age "AGE IN YEARS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"(A or B) and C"
    condition_A :q_FATHER_SAME_HH, "==", :a_1
    condition_B :q_FATHER_SAME_HH, "==", :a_2    
    condition_C :q_CONTACT_F_NOW, "==", :a_1
    
    q_time_stamp_2 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.TIME_STAMP_2"
    a :datetime
    
    label "These next questions are about any previous pregnancies you may have had."
    
    q_PAST_PREG "Before this pregnancy, have you ever been pregnant? Please include live births, miscarriages, 
    stillbirths, ectopic pregnancies, abortions and pregnancy terminations.",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.PAST_PREG"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_NUM_PREG "Including this pregnancy, how many times total have you been pregnant?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.NUM_PREG"
    a_number "NUMBER", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    a_neg_7 "NEVER BEEN PREGNANT/NOT APPLICABLE"
    dependency :rule=>"A"
    condition_A :q_PAST_PREG, "==", :a_1
    
    label "The provided value is outside the suggested range. (Range < 5) This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_NUM_PREG, "<", {:integer_value => "1"}
    condition_B :q_NUM_PREG, ">", {:integer_value => "5"}

    q_AGE_FIRST "How old were you when you became pregnant for the first time?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.AGE_FIRST"
    a_number "AGE IN YEARS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_PAST_PREG, "==", :a_1
    
    label "The provided value is outside the suggested range. (Range > 13) This value is admissible, but you may wish to verify."
    dependency :rule=>"A"
    condition_A :q_NUM_PREG, "<", {:integer_value => "13"}
    
    q_PREMATURE "Did any of your previous pregnancies end in the birth of a child more than 3 weeks early, 
    before his or her due date? <br><br>
    <b>INTERVIEWER INSTRUCTIONS: </b>
    - INCLUDE ALL INFANTS WHO WERE ALIVE AT THE TIME OF BIRTH. DO NOT INCLUDE MISCARRIAGES, STILLBIRTHS OR ABORTIONS.",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.PREMATURE"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_PAST_PREG, "==", :a_1    
    
    q_MISCARRY "Did any of your previous pregnancies end in a miscarriage or stillbirth?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.MISCARRY"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_PAST_PREG, "==", :a_1        
  end
  section "TOBACCO AND ALCOHOL USE", :reference_identifier=>"PREG_VISIT_1_SAQ_2" do
    q_time_stamp_3 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.TIME_STAMP_3"
    a :datetime
    
    label "The next questions are about your use of cigarettes and alcohol just before your current pregnancy."
    
    q_CIG_PAST "In the 3 months before you knew you were pregnant, did you smoke any cigarettes?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CIG_PAST"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_CIG_PAST_FREQ "Did you smoke cigarettes:",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CIG_PAST_FREQ"
    a_1 "Every day"
    a_2 "5 or 6 days a week"
    a_3 "2-4 days a week"
    a_4 "Once a week"
    a_5 "1-3 days a month"
    a_6 "Less than once a month"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_CIG_PAST, "==", :a_1    
    
    q_CIG_PAST_NUM "On days that you smoked, how many cigarettes did you smoke per day? If you smoked 1 cigarette 
    or less each day, please enter \"1.\"",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CIG_PAST_NUM"
    a_number "NUMBER PER DAY", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_CIG_PAST, "==", :a_1
    
    label "The provided value is outside the suggested range. (Range < 60) This value is admissible, but you may wish to verify."
    dependency :rule=>"A"
    condition_A :q_CIG_PAST_NUM, ">", {:integer_value => "60"}
   
# TODO: 
# PROGRAMMER INSTRUCTIONS: 
# • DISPLAY SOFT EDIT IF RESPONSE > 60
# • IF RESPONSE IS IN PACKS, CALCULATE 20 CIGARETTES PER PACK
    q_CIG_NOW "Currently, do you smoke cigarettes?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CIG_NOW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_CIG_NOW_FREQ "Do you smoke cigarettes:",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CIG_NOW_FREQ"
    a_1 "Every day"
    a_2 "5 or 6 days a week"
    a_3 "2-4 days a week"
    a_4 "Once a week"
    a_5 "1-3 days a month"
    a_6 "Less than once a month"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_CIG_NOW, "==", :a_1
    
    q_CIG_NOW_NUM "On days that you smoke, how many cigarettes do you smoke per day? If you smoke 1 cigarette or 
    less each day, please enter \"1.\"",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.CIG_NOW_NUM"
    a_number "NUMBER PER DAY", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_CIG_NOW, "==", :a_1
     
# TODO: 
# PROGRAMMER INSTRUCTIONS: 
# • DISPLAY SOFT EDIT IF RESPONSE > 60
# • IF RESPONSE IS IN PACKS, CALCULATE 20 CIGARETTES PER PACK     
    label "The provided value is outside the suggested range. (Range < 60) This value is admissible, but you may wish to verify."
    dependency :rule=>"A"
    condition_A :q_CIG_NOW_NUM, ">", {:integer_value => "60"}     
     
    q_DRINK_PAST "<u>In the 3 months before you knew you were pregnant</u>, how often did you drink alcoholic beverages including wine, 
    beer, drinks containing hard liquor, wine coolers, hard lemonade, or hard cider?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.DRINK_PAST"
    a_1 "5 or more times a week"
    a_2 "2-4 times a week"
    a_3 "Once a week"
    a_4 "1-3 times a month"
    a_5 "Less than once a month"
    a_6 "Never"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_DRINK_PAST_NUM "<u>In the 3 months before you knew you were pregnant</u>, on days that you drank alcoholic beverages, 
    how many did you have per day? If you had one drink or less, please enter \"1.\"",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.DRINK_PAST_NUM"     
    a_number "NUMBER OF DRINKS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A or B or C"
    condition_A :q_DRINK_PAST, "!=", :a_6
    condition_A :q_DRINK_PAST, "!=", :a_neg_1
    condition_A :q_DRINK_PAST, "!=", :a_neg_2
    
    q_DRINK_PAST_5 "<u>In the 3 months before you knew you were pregnant</u>, how often did you have 5 or more drinks within 
    a couple of hours?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.DRINK_PAST_NUM"     
    a_1 "Never"
    a_2 "About once a month"
    a_3 "About once a week"
    a_4 "About once a day"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A or B or C"
    condition_A :q_DRINK_PAST, "!=", :a_6
    condition_A :q_DRINK_PAST, "!=", :a_neg_1
    condition_A :q_DRINK_PAST, "!=", :a_neg_2
    
    q_DRINK_NOW "How often do you currently drink alcoholic beverages?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.DRINK_NOW"
    a_1 "5 or more times a week"
    a_2 "2-4 times a week"
    a_3 "Once a week"
    a_4 "1-3 times a month"
    a_5 "Less than once a month"
    a_6 "Never"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_DRINK_NOW_NUM "<u>In the 3 months before you knew you were pregnant</u>, on days that you drank alcoholic beverages, 
    how many did you have per day? If you had one drink or less, please enter \"1.\"",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.DRINK_NOW_NUM"
    a_number "NUMBER OF DRINKS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A or B or C"
    condition_A :q_DRINK_NOW, "!=", :a_6
    condition_A :q_DRINK_NOW, "!=", :a_neg_1
    condition_A :q_DRINK_NOW, "!=", :a_neg_2
    
    q_DRINK_NOW_5 "Currently, how often do you have 5 or more drinks within a couple of hours:",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.DRINK_NOW_5"     
    a_1 "Never"
    a_2 "About once a month"
    a_3 "About once a week"
    a_4 "About once a day"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A or B or C"
    condition_A :q_DRINK_NOW, "!=", :a_6
    condition_A :q_DRINK_NOW, "!=", :a_neg_1
    condition_A :q_DRINK_NOW, "!=", :a_neg_2
    
    label "<b>INTERVIEWER INSTRUCTION:</b><br>
    FOLLOW LOCAL MANDATORY REPORTING REQUIREMENTS."
  end
  section "EVALUATION QUESTIONS", :reference_identifier=>"PREG_VISIT_1_SAQ_2" do
    q_time_stamp_4 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.TIME_STAMP_4"
    a :datetime
    
    label "We would now like to take a few minutes to ask some questions about your experience in the study. 
    There are no right or wrong answers. You can always refuse to answer any question or group of questions, and your 
    answers will be kept confidential."
    
    label "How important was each of the following in your decision to take part in the National Children’s Study?"
    
    q_LEARN "(How important was…) Learning more about my health or the health of my child?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.LEARN"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_HELP "(How important was…) Feeling as if I can help children now and in the future?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.HELP"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_INCENT "(How important was…) Receiving money or gifts for taking part in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.INCENT"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_RESEARCH "(How important was…) Helping doctors and researchers learn more about children and their health?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.RESEARCH"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_ENVIR "(How important was…) Helping researchers learn how the environment may affect children’s health?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.ENVIR"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_COMMUNITY "(How important was…) Feeling part of my community?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.COMMUNITY"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_KNOW_OTHERS "(How important was…) Knowing other women in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.KNOW_OTHERS"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_FAMILY "(How important was…) Having family members or friends support my choice to take part in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.FAMILY"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_DOCTOR "(How important was…) Having my doctor or health care provider support my choice to take part in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.DOCTOR"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_STAFF "(How important was…) Feeling comfortable with the study staff who come to my home?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.STAFF"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    label "How negative or positive do each of the following people feel about you taking part in the National Children’s Study?"
    
    q_OPIN_SPOUSE "Your spouse or partner",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.OPIN_SPOUSE"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"
    
    q_OPIN_FAMILY "Other family members",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.OPIN_FAMILY"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"
     
    q_OPIN_FRIEND "Your friends",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.OPIN_FRIEND"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"
    
    q_OPIN_DR "Your doctor or health care provider",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.OPIN_DR"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"    

    q_EXPERIENCE "In general, has your experience with the National Children’s Study been…",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.EXPERIENCE"
    a_1 "Mostly negative"
    a_2 "Somewhat negative"
    a_3 "Neither negative nor positive"
    a_4 "Somewhat positive"
    a_5 "Mostly positive"

    q_IMPROVE "In your opinion, how much do you think the National Children’s Study will help improve the health 
    of children now and in the future?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.IMPROVE"
    a_1 "Not at all"
    a_2 "A little"
    a_3 "Some"
    a_4 "A lot"

    q_INT_LENGTH "Did you think the interview was",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.INT_LENGTH"
    a_1 "Too short"
    a_2 "Too long, or"
    a_3 "Just about right?"
    
    q_INT_STRESS "Do you think the interview was",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.INT_STRESS"
    a_1 "Not at all stressful"
    a_2 "A little stressful"
    a_3 "Somewhat stressful, or"
    a_4 "Very stressful?"
    
    q_INT_REPEAT "If you were asked, would you participate in an interview like this again?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_SAQ_2.INT_REPEAT"
    a_1 "Yes"
    a_2 "No"
    
    label_END_EVAL "Thank you for participating in the National Children’s Study and for taking the time to complete this survey."

    label_instructions "<b>INSTRUCTIONS: </b><br>IF SAQ IS COMPLETED AS A PAPI, SCs MUST PROVIDE INSTRUCTIONS AND A BUSINESS 
    REPLY ENVELOPE FOR PARTICIPANT TO RETURN"
    dependency :rule => "A"
    condition_A :q_is_papi_mode, "==", :a_1
    
    q_time_stamp_5 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_SAQ_2.TIME_STAMP_5"
    a :datetime
  end 
end