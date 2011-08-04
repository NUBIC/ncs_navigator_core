survey "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0" do
  section "INTERVIEW INTRODUCTION", :reference_identifier=>"prepregnancy_visit_1_v20" do

    q_hipv1_2_time_stamp_1 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_1"
    a :datetime

    label "Thank you for agreeing to participate in the National Children’s Study. 
    This interview will take about 30 minutes to complete. Your answers are important to us. 
    There are no right or wrong answers. During this interview, we will ask you questions about yourself, 
    your health and pregnancy, your household and where you live. You can skip over any question or 
    stop the interview at any time. We will keep everything that you tell us confidential..
    <br><br>First, we're like to make sure we have your correct name and birth date."

    q_prepopulated_name "Name:"
    a :string
    
#     TODO - the name should be pre-populated
    q_hipv1_2_name_confirm "Is that your name? ", 
    :data_export_identifier=>"PREG_VISIT_1_2.NAME_CONFIRM", :pick=>:one
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

#don't have the corresponding identifier
    label "What is your full name?
    <br><br><b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT REFUSES TO PROVIDE INFORMATION, RE-STATE CONFIDENTIALITY PROTECTIONS, 
    ASK FOR INITIALS OR SOME OTHER NAME SHE WOULD LIKE TO BE CALLED.<br><br>
    - CONFIRM SPELLING OF FIRST 
    NAME IF NOT PREVIOUSLY COLLECTED AND OF LAST NAME FOR ALL PARTICIPANTS."
    dependency :rule=>"A"
    condition_A :q_hipv1_2_name_confirm, "!=", :a_1    

    q_hipv1_2_r_fname "FIRST NAME", :display_type=>"string", :data_export_identifier=>"PREG_VISIT_1_2.R_FNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_name_confirm, "!=", :a_1

    q_hipv1_2_r_lname "LAST NAME", :display_type=>"string", :data_export_identifier=>"PREG_VISIT_1_2.R_LNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_name_confirm, "!=", :a_1

    q_prepopulated_date_of_birth "[PARTICIPANT'S DATE OF BIRTH AS MM/DD/YYYY]"
    a :date

    q_hipv1_2_dob_confirm "Is this your birth date?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.DOB_CONFIRM"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    label "<b>INTERVIEWER INSTRUCTIONS:</b>
    <br>IF PARTICIPANT REFUSES TO PROVIDE INFORMATION, RE-STATE CONFIDENTIALITY PROTECTIONS AND THAT DOB IS 
    REQUIRED TO DETERMINE ELIGIBILITY. 
    <br><br>ENTER A TWO DIGIT MONTH, TWO DIGIT DAY, AND A FOUR DIGIT YEAR
    <br><br>IF RESPONSE WAS DETERMINED TO BE INVALID, ASK QUESTION AGAIN AND PROBE FOR VALID RESPONSE"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_dob_confirm, "!=", :a_1

    q_hipv1_2_confirmed_dob "What is your date of birth?",
    :data_export_identifier=>"PREG_VISIT_1_2.PERSON_DOB"
    a :date
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_dob_confirm, "!=", :a_1    

    q_hipv1_2_calc_age_confirmed_dob "<b>INTERVIEWER INSTRUCTIONS:</b> CALCULATED AGE (AS OF 'TODAY')"
    a :integer

    q_hipv1_2_age_elig "Is PARTICIPANT age-eligible? ", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.AGE_ELIG"
    a_1 "PARTICIPANT IS AGE ELIGIBLE"
    a_2 "PARTICIPANT IS YOUNGER THAN AGE OF MAJORITY"
    a_3 "PARTICIPANT IS OVER 49"
    a_4 "AGE ELIGIBILITY IS UNKNOWN"
    
    label "PARTICIPANT IS NOT ELIGIBLE"
    dependency :rule => "A"
    condition_A :q_hipv1_2_age_elig, "==", :a_2 
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_1_2.END"
    dependency :rule=> "A" 
    condition_A :q_hipv1_2_age_elig, "==", :a_2
    
    label "<b>INTERVIEWER INSTRUCTIONS: </b>END THE QUESTIONARE"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_age_elig, "==", :a_2

    label "CASE FOR SUPERVISOR REVIEW AT SC TO CONFIRM AGE ELIGIBILITY POST-INTERVIEW"
    dependency :rule => "A or B"
    condition_A :q_hipv1_2_confirmed_dob, "==", :a_neg_1
    condition_B :q_hipv1_2_confirmed_dob, "==", :a_neg_2     
  end  
  section "CURRENT PREGNANCY INFORMATION", :reference_identifier=>"prepregnancy_visit_v20" do
    
    q_hipv1_2_time_stamp_2 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_2"
    a :datetime

    label "We’ll begin by asking some questions about you, your health, and your health history. First, I’ll ask about your current pregnancy."

    q_hipv1_2_pregnant "The first questions ask about how your pregnancy is progressing. Are you still pregnant?", :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_2.PREGNANT"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
   
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_1_2.END"
    dependency :rule=> "A or B" 
    condition_A :q_hipv1_2_pregnant, "==", :a_neg_1
    condition_B :q_hipv1_2_pregnant, "==", :a_neg_2
    
    label "<b>INTERVIEWER INSTRUCTIONS: </b>END THE QUESTIONARE"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_loss_info, "==", :a_2    
    
    q_hipv1_2_time_stamp_3 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_3"
    a :datetime

    label "I’m so sorry for your loss. I know this can be a difficult time.
    <br><br>INTERVIEWER INSTRUCTIONS:<br>
      USE SOCIAL CUES AND PROFESSIONAL JUDGMENT IN RESPONSE<br>
      PROGRAMMER/INTERVIEWER INSTRUCTION: <br>
      IF SC HAS PREGNANCY LOSS INFORMATION TO DISSEMINATE, OFFER TO PARTICIPANT"
    dependency :rule=> "A"
    condition_A :q_hipv1_2_pregnant, "==", :a_2
    
    q_hipv1_sc_loss_info "DOES THE STUDY CENTER (SC) HAVE PREGNANCY LOSS INFORMATION TO 
    DISSEMINATE TO PARTICIPANT?<br><br>IF SC HAS PREGNANCY LOSS INFORMATION TO DISSEMINATE, OFFER TO PARTICIPANT", :pick=>:one
    a_1 "YES"
    a_2 "NO"
    dependency :rule=> "A"
    condition_A :q_hipv1_2_pregnant, "==", :a_2    
      
    q_hipv1_2_loss_info "DID PARTICIPANT REQUEST ADDITIONAL INFORMATION ON COPING WITH PREGNANCY LOSS?", :pick => :one, 
    :data_export_identifier=>"PREG_VISIT_1_2.LOSS_INFO"
    a_1 "YES"
    a_2 "NO"
    dependency :rule=> "A"
    condition_A :q_hipv1_2_pregnant, "==", :a_2
    
    label "Again, I'd like to say how sorry I am for your loss.Please accept our best wishes for a quick recovery. Thank you for your time.<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    IF LOSS OF PREGNANCY, END INTERVIEW. DO NOT ADMINISTER SAQs.", :data_export_identifier=>"PREG_VISIT_1_2.END_INFO"
    dependency :rule=> "A"
    condition_A :q_hipv1_2_pregnant, "==", :a_2
    
    label "We'll send the information packet you requested as soon as possible."
    dependency :rule=>"A"
    condition_A :q_hipv1_2_loss_info, "==", :a_2
    
    label "<b>INTERVIEWER INSTRUCTIONS: </b>END THE QUESTIONARE"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_loss_info, "==", :a_2
    
    q_hipv1_2_enter_due_date "What is your current due date? (YYYYMMDD)", :pick => :one,
    :help_text => "INTERVIEWER INSTRUCTIONS: <br>
      IF RESPONSE WAS DETERMINED TO BE INVALID, ASK QUESTION AGAIN AND PROBE FOR VALID RESPONSE",
    :data_export_identifier=>"PREG_VISIT_1_2.DUE_DATE"
    a_1 :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=> "A"
    condition_A :q_hipv1_2_pregnant, "==", :a_1
    
    #TODO - have to be able to calculate the labels below - put the request in surveyor to address the issue
    q_hipv1_2_due_date_check "CALCULATION: NUMBER OF MONTHS BETWEEN REPORTED DUE DATE AND 'TODAY'
    <br><br>CAN NOT BE (1) ON OR BEFORE 'TODAY' OR (2) MORE THAN 9 MONTHS AFTER 'TODAY'
    <br><br>IF RESPONSE WAS DETERMINED TO BE INVALID, ASK QUESTION AGAIN AND PROBE FOR VALID RESPONSE", :pick => :one
    a_on_or_before_today "ON OR BEFORE 'TODAY'"
    a_more_than_9_months_after_today "MORE THAN 9 MONTHS AFTER 'TODAY'"
    a_valid "VALID DUE DATE"
    a_invalid "NO VALID DATE IS GIVEN "
    dependency :rule=> "A"
    condition_A :q_hipv1_2_pregnant, "==", :a_1
    
    label "YOU HAVE ENTERED A DATE THAT IS MORE THAN 9 MONTHS FROM TODAY. RE-ENTER DATE"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_due_date_check, "==", :a_more_than_9_months_after_today
    
    label "YOU HAVE ENTERED A DATE THAT OCCURRED MORE THAN A MONTH BEFORE TODAY. RE-ENTER DATE"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_due_date_check, "==", :a_on_or_before_today
    
    q_hipv1_2_know_date "How did you find out your due date?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.KNOW_DATE"
    a_1 "FIGURED IT OUT MYSELF"
    a_2 "HAD AN ULTRASOUND TO FIGURE IT OUT"
    a_3 "DOCTOR OR OTHER PROVIDER TOLD ME WITHOUT AN ULTRASOUND"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_due_date_check, "==", :a_valid
    
    q_hipv1_2_enter_date_period "DATE OF FIRST DAY OF LAST MENSTRUAL PERIOD (MM/DD/YYYY)<br><br>- CODE DAY AS '15' IF PARTICIPANT IS 
    UNSURE/UNABLE TO ESTIMATE DAY", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.DATE_PERIOD"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_due_date_check, "==", :a_invalid
        
    #these labels have to be calculated automatically
    q_hipv1_2_date_period_check "CALCULATION: NUMBER OF MONTHS BETWEEN REPORTED DATE OF FIRST DAY OF LAST MENSTRUAL PERIOD AND 
    'TODAY'<br><br>CAN NOT BE (1) AFTER 'TODAY' OR (2) NO MORE THAN 10 MONTHS BEFORE 'TODAY'<br><br>IF RESPONSE WAS DETERMINED 
    TO BE INVALID, ASK QUESTION AGAIN AND PROBE FOR VALID RESPONSE"
    a_after_today "IS AFTER 'TODAY'"
    a_more_than_10_months_before_today "IS MORE THAN 10 MONTHS BEFORE 'TODAY'"
    a_valid "VALID"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_date_period, "==", :a_1

    label "YOU HAVE ENTERED A DATE THAT IS MORE THAN 10 MONTHS BEFORE TODAY. CONFIRM DATE. IF DATE IS CORRECT, ENTER ‘DON’T KNOW’"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_date_period_check, "==", :a_more_than_10_months_before_today
    
    label "YOU HAVE ENTERED A DATE THAT HAS NOT OCCURRED YET. RE-ENTER DATE."
    dependency :rule=>"A"
    condition_A :q_hipv1_2_date_period_check, "==", :a_after_today
    
    q_hipv1_2_calculated_due_date "DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD (YYYYMMDD)", :help_text => "INTERVIEWER INSTRUCTIONS: <br>
      SET DUE_DATE (YYYYMMDD) = DATE_PERIOD + 280 DAYS",
    :data_export_identifier=>"PREG_VISIT_1_2.DUE_DATE"
    a :string
    
    q_hipv1_2_knew_date "DID PARTICIPANT GIVE DATE?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.KNEW_DATE"
    a_1 "PARTICIPANT GAVE COMPLETE DATE"
    a_2 "INTERVIEWER ENTERED 15 FOR DAY"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_date_period, "==", :a_1  
    
    q_hipv1_2_time_stamp_4 "CURRENT DATE & TIME", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_4"
    a :datetime
    
    q_hipv1_2_home_test "Did you use a home pregnancy test to help find out you were pregnant?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HOME_TEST"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_hipv1_2_multiple_gestation "Are you pregnant with a single baby (singleton), twins, or triplets or other multiple births?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.MULTIPLE_GESTATION"
    a_1 "SINGLETON"
    a_2 "TWINS"
    a_3 "TRIPLETS OR HIGHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
        
    q_hipv1_2_birth_plan "Where do you plan to deliver your (baby/babies)?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.BIRTH_PLAN"
    a_1 "In a hospital"
    a_2 "A birthing center"
    a_3 "At home"
    a_4 "Some other place"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    label "Name and address of the place where you are planning to deliver your (baby/babies)?"
    dependency :rule=>"A or B or C"
    condition_A :q_hipv1_2_birth_plan, "==", :a_1
    condition_B :q_hipv1_2_birth_plan, "==", :a_2
    condition_C :q_hipv1_2_birth_plan, "==", :a_4        

    q_hipv1_2_nash_hosp_name "NAME OF BIRTH HOSPITAL/BIRTHING CENTER", :data_export_identifier=>"PREG_VISIT_1_2.BIRTH_PLACE"
    a :string
    dependency :rule=>"A or B or C"
    condition_A :q_hipv1_2_birth_plan, "==", :a_1
    condition_B :q_hipv1_2_birth_plan, "==", :a_2
    condition_C :q_hipv1_2_birth_plan, "==", :a_4        

    q_hipv1_2_b_address_1 "ADDRESS 1 - STREET/PO BOX", :data_export_identifier=>"PREG_VISIT_1_2.B_ADDRESS_1"
    a :string
    dependency :rule=>"A or B or C"
    condition_A :q_hipv1_2_birth_plan, "==", :a_1
    condition_B :q_hipv1_2_birth_plan, "==", :a_2
    condition_C :q_hipv1_2_birth_plan, "==", :a_4        

    q_hipv1_2_b_address_2 "ADDRESS 2", :data_export_identifier=>"PREG_VISIT_1_2.B_ADDRESS_2"
    a :string
    dependency :rule=>"A or B or C"
    condition_A :q_hipv1_2_birth_plan, "==", :a_1
    condition_B :q_hipv1_2_birth_plan, "==", :a_2
    condition_C :q_hipv1_2_birth_plan, "==", :a_4        

    q_hipv1_2_b_city "CITY", :data_export_identifier=>"PREG_VISIT_1_2.B_CITY"
    a "Text", :string
    dependency :rule=>"A or B or C"
    condition_A :q_hipv1_2_birth_plan, "==", :a_1
    condition_B :q_hipv1_2_birth_plan, "==", :a_2
    condition_C :q_hipv1_2_birth_plan, "==", :a_4        

    q_hipv1_2_b_state "STATE", :display_type=>"dropdown", :data_export_identifier=>"PREG_VISIT_1_2.B_STATE"
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
    dependency :rule=>"A or B or C"
    condition_A :q_hipv1_2_birth_plan, "==", :a_1
    condition_B :q_hipv1_2_birth_plan, "==", :a_2
    condition_C :q_hipv1_2_birth_plan, "==", :a_4        

    q_hipv1_2_b_zipcode "ZIP CODE", :data_export_identifier=>"PREG_VISIT_1_2.B_ZIPCODE"
    a :string
    dependency :rule=>"A or B or C"
    condition_A :q_hipv1_2_birth_plan, "==", :a_1
    condition_B :q_hipv1_2_birth_plan, "==", :a_2
    condition_C :q_hipv1_2_birth_plan, "==", :a_4        

    q_hipv1_2_pn_vitamin "In the month before you became pregnant, did you regularly take multivitamins, prenatal vitamins, folate, or folic acid?", 
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.PN_VITAMIN"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_preg_vitamin "Since you’ve become pregnant, have you regularly taken multivitamins, prenatal vitamins, folate, or folic acid?", 
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.PREG_VITAMIN"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_date_visit "What was the date of your most recent doctor’s visit or checkup since you’ve become pregnant? (MM/DD/YYYY)", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.DATE_VISIT"
    a :string
    a_7 "HAVE NOT HAD A VISIT"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    # PROGRAMMER INSTRUCTIONS: 
    #     • IF VALID DATE FOR DATE_VISIT IS PROVIDED, DISPLAY “AT THIS VISIT OR AT”. OTHERWISE ”At”.
    label "At this visit or at any time during your pregnancy, did the doctor or other health care provider tell you that you have any 
    of the following conditions? <br><br>- RE-READ INTRODUCTORY STATEMENT AS NEEDED"

    q_hipv1_2_diabetes_1 "Diabetes? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_highbp_preg "High blood pressure? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HIGHBP_PREG"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_urine "Protein in your urine? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.URINE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_preeclamp "Preeclampsia or toxemia? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.PREECLAMP"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_early_labor "Early or premature labor? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.EARLY_LABOR"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_anemia "Anemia or low blood count? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.ANEMIA"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_nausea "Severe nausea or vomiting (hyperemesis)? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.NAUSEA"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_kidney "Bladder or kidney infection? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.KIDNEY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_rh_disease "Rh disease or isoimmunization? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.RH_DISEASE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_group_b "Infection with bacteria called Group B strep?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.GROUP_B"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_herpes "Infection with a Herpes virus? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HERPES"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_vaginosis "Infection of the vagina with bacteria (bacterial vaginosis?)", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.VAGINOSIS"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_oth_condition "Any other serious condition? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.OTH_CONDITION"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_condition_oth "Can you please specify the other serious conditions? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.CONDITION_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_oth_condition, "==", :a_1
  end
  section "MEDICAL HISTORY", :reference_identifier=>"prepregnancy_visit_v20" do
    q_hipv1_2_time_stamp_5 "CURRENT DATE & TIME", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_5"
    a :datetime
    
    label "This next question is about your health when you are <U>not</U> pregnant"

    q_hipv1_2_health "Would you say your health in general is. . . ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HEALTH"
    a_1 "Excellent"
    a_2 "Very good,"
    a_3 "Good,"
    a_4 "Fair, or"
    a_5 "Poor?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_height "How tall are you without shoes? ", :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_height_ft "PORTION OF HEIGHT IN WHOLE FEET (e.g., 5)", 
    :data_export_identifier=>"PREG_VISIT_1_2.HEIGHT_FT"
    a "FEET", :integer
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_height, "==", :a_1
    
    label "The value you provided is outside the suggested range.<br>
     Appropriate range is:<br> 
      4 to 7 feet. <br> 
      This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_height_ft, "<", {:integer_value => "4"}
    condition_B :q_hipv1_2_height_ft, ">", {:integer_value => "7"}

    q_hipv1_2_ht_inch "ADDITIONAL PORTION OF HEIGHT IN INCHES (e.g., 7)", 
    :data_export_identifier=>"PREG_VISIT_1_2.HT_INCH"
    a "INCHES", :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_height, "==", :a_1
    
    label "The value you provided is outside the suggested range.<br> 
      Appropriate ranges are:<br>
       0 to 11 inches when FEET value is specified.
       48 to 84 inches, when FEET value is blank.<br>
      This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B or C or D"
    condition_A :q_hipv1_2_ht_inch, "<", {:integer_value => "0"}
    condition_B :q_hipv1_2_ht_inch, ">", {:integer_value => "11"}
    condition_C :q_hipv1_2_ht_inch, ">", {:integer_value => "84"}
    condition_D :q_hipv1_2_ht_inch, "<", {:integer_value => "48"}

    q_hipv1_2_enter_weight "What was your weight just before you became pregnant? ", :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_weight "WEIGHT BEFORE BECOMING PREGNANT (pounds)", :data_export_identifier=>"PREG_VISIT_1_2.WEIGHT"
    a "POUNDS", :integer
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_weight, "==", :a_1
    
    label "The value you provided is outside the suggested range.<br>
     Appropriate range is:<br> 
      90 to 400 lbs. <br> 
      This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_weight, "<", {:integer_value => "90"}
    condition_B :q_hipv1_2_weight, ">", {:integer_value => "400"}      

    label "The next questions are about medical conditions or health problems you might have now or may have had in the past."

    q_hipv1_2_asthma "Have you ever been told by a doctor or other health care provider that you had asthma? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.ASTHMA"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_highbp_notpreg "Have you ever been told by a doctor or other health care provider that you had<br>
    Hypertension or high blood pressure when you’re <b>not pregnant</b>?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HIGHBP_NOTPREG"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_diabetes_notpreg "Have you ever been told by a doctor or other health care provider that you had<br>
    High blood sugar or Diabetes when you're <b>not pregnant</b>?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_NOTPREG"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_diabetes_2 "Have you taken any medicine or received other medical treatment for diabetes in the past 12 months? ", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_diabetes_notpreg, "==", :a_1

    q_hipv1_2_diabetes_3 "Have you ever taken insulin? ", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_diabetes_notpreg, "==", :a_1

    q_hipv1_2_thyroid_1 "Have you ever been told by a doctor or other health care provider that you had <br>
    Hypothyroidism, that is, an under active thyroid?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.THYROID_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_thyroid_2 "Have you taken any medicine or received other medical treatment for a thyroid problem in the past 12 months?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.THYROID_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_thyroid_1, "==", :a_1
    
    label "This next question is about where you go for routine health care."

    q_hipv1_2_hlth_care "What kind of place do you usually go to when you need routine or preventive care, such as a physical examination or check-up?", 
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.HLTH_CARE"
    a_1 "Clinic or health center"
    a_2 "Doctor's office or Health Maintenance Organization (HMO)"
    a_3 "Hospital emergency room"
    a_4 "Hospital outpatient department"
    a_5 "Some other place"
    a_6 "DOESN'T GO TO ONE PLACE MOST OFTEN"
    a_7 "DOESN'T GET PREVENTIVE CARE ANYWHERE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
  end  
  section "HEALTH INSURANCE", :reference_identifier=>"prepregnancy_visit_v20" do
    q_hipv1_2_time_stamp_6 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_6"
    a :datetime      

    label "Now I'm going to switch to another subject and ask about health insurance."

    q_hipv1_2_insure "Are you <U>currently</U> covered by any kind of health insurance or some other kind of health care plan? ", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.INSURE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    label "Now I'll read a list of different types of insurance. Please tell me which types you currently have. Do you currently have..."
    
    label "<b>INTERVIEWER INSTRUCTIONS:</b> <br>
      RE-READ INTRODUCTORY STATEMENT (Do you currently <b>have…</b>) AS NEEDED"

    q_hipv1_2_ins_employ "Insurance through an employer or union either through yourself or another family member? ", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.INS_EMPLOY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_insure, "==", :a_1

    q_hipv1_2_ins_medicaid "Medicaid or any government-assistance plan for those with low incomes or a disability?<br><br>
      <b>INTERVIEWER INSTRUCTIONS:</b>- PROVIDE EXAMPLES OF LOCAL MEDICAID PROGRAMS", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.INS_MEDICAID"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_insure, "==", :a_1      

    q_hipv1_2_ins_tricare "TRICARE, VA, or other military health care? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.INS_TRICARE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_insure, "==", :a_1      

    q_hipv1_2_ins_ihs "Indian Health Service? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.INS_IHS"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_insure, "==", :a_1      

    q_hipv1_2_ins_medicaire "Medicare, for people with certain disabilities? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.INS_MEDICARE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_insure, "==", :a_1
    
    q_hipv1_2_ins_oth "Any other type of health insurance or health coverage plan? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.INS_OTH"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_insure, "==", :a_1
  end
     
  section "HOUSING CHARACTERISTICS", :reference_identifier=>"prepregnancy_visit_v20" do
    q_hipv1_2_time_stamp_7 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_7"
    a :datetime

    label "Now I'd like to find out more about your home and the area in which you live."

#TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF OWN_HOME WAS ASKED DURING PREGNANCY SCREENER OR PRE-PREGANCY VISIT, THEN ASK RECENT_MOVE; ELSE SKIP TO OWN_HOME.

    q_hipv1_2_recent_move "Have you moved or changed your housing situation since we last spoke with you? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.RECENT_MOVE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_own_home "Is your home…", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.OWN_HOME"
    a_1 "Owned or being bought by you or someone in your household"
    a_2 "Rented by you or someone in your household, or"
    a_3 "Occupied without payment of rent?"
    a_neg_5 "SOME OTHER ARRANGEMENT"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_own_home_oth "Can you please specify your home arrangement? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.OWN_HOME_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_own_home, "==", :a_neg_5

    q_hipv1_2_time_stamp_8 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_8"
    a :datetime

#TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • THE REST OF THE QUESTIONS IN THIS SECTION ARE ONLY ASKED OF A SUBSET OF PARTICIPANTS, DEPENDING UPON WHETHER A PRE-PREGNANCY 
    # QUESTIONNAIRE WAS COMPLETED AND RESPONSES TO RECENT_MOVE ABOVE AND DURING THE PRE-PREGNANCY VISIT
    # • IF RECENT_MOVE DURING THIS EVENT IS “YES” GO TO AGE_HOME AND CONTINUE THROUGH REST OF SECTION
    # • IF RECENT_MOVE DURING THIS EVENT IS ‘NO,’ REFUSED,’ OR ‘DON’T KNOW’ AND
    #   o NO PRE-PREGNANCY INFORMATION IS AVAILABLE; GO TO AGE_HOME AND CONTINUE THROUGH REST OF SECTION
    #   o IF RECENT_MOVE WAS ASKED DURING PRE-PREGNANCY QUESTIONNAIRE AND WAS CODED AS “YES”; SKIP REST OF SECTION AND GO TO TIME_STAMP_9
    #   o IF RECENT_MOVE WAS ASKED DURING PRE-PREGNANCY QUESTIONNAIRE AND WAS NOT CODED AS “YES”; GO TO (AGE_HOME) AND CONTINUE THROUGH SECTION


    q_hipv1_2_age_home "Can you tell us, which of these categories do you think best describes when your home or building was built?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.AGE_HOME"
    a_1 "2001 TO PRESENT"
    a_2 "1981 TO 2000"
    a_3 "1961 to 1980"
    a_4 "1941 to 1960"
    a_5 "1940 OR BEFORE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_length_reside "How long have you lived in this home?  ", :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_length_reside "LENGTH RESIDE: NUMBER (e.g., 5)", 
    :data_export_identifier=>"PREG_VISIT_1_2.LENGTH_RESIDE"
    a "NUMBER", :integer
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_length_reside, "==", :a_1

    q_hipv1_2_length_reside_units "LENGTH RESIDE: UNITS (e.g., months)", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.LENGTH_RESIDE_UNIT"
    a_1 "WEEKS"
    a_2 "MONTHS"
    a_3 "YEARS"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_length_reside, "==", :a_1

    label "Now I'm going to ask you about how your home is heated and cooled."

    q_hipv1_2_main_heat "Which of these types of heat sources best describes the <U><b>main</b></U> heating fuel source for your home?  
    <br><br><b>INTERVIEWER INSTRUCTION: </b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.MAIN_HEAT"
    a_1 "ELECTRIC"
    a_2 "GAS - PROPANE OR LP"
    a_3 "OIL"
    a_4 "WOOD"
    a_5 "KEROSENE OR DIESEL"
    a_6 "COAL OR COKE"
    a_7 "SOLAR ENERGY"
    a_8 "HEAT PUMP"
    a_9 "NO HEATING SOURCE"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_main_heat_oth "OTHER MAIN HEATING FUEL SOURCE", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.MAIN_HEAT_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_main_heat, "==", :a_neg_5

    q_hipv1_2_heat2 "Are there any <U>other</U> types of heat you use regularly during the heating season 
    to heat your home?<br><br><b>INTERVIEWER INSTRUCTION: </b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.<br><br>
    <b>PROBE:</b> Do you have any space heaters, or any secondary method for heating your home?<br><br>
    SELECT ALL THAT APPLY.", :pick=>:any, 
    :data_export_identifier=>"PREG_VISIT_1_HEAT2_2.HEAT2"
    a_1 "ELECTRIC"
    a_2 "GAS - PROPANE OR LP"
    a_3 "OIL"
    a_4 "WOOD"
    a_5 "KEROSENE OR DIESEL"
    a_6 "COAL OR COKE"
    a_7 "SOLAR ENERGY"
    a_8 "HEAT PUMP"
    a_9 "NO OTHER HEATING SOURCE"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B or C or D or E or F or G or H"
    condition_A :q_hipv1_2_main_heat, "==", :a_1
    condition_B :q_hipv1_2_main_heat, "==", :a_2
    condition_C :q_hipv1_2_main_heat, "==", :a_3
    condition_D :q_hipv1_2_main_heat, "==", :a_4
    condition_E :q_hipv1_2_main_heat, "==", :a_5
    condition_F :q_hipv1_2_main_heat, "==", :a_6
    condition_G :q_hipv1_2_main_heat, "==", :a_7
    condition_H :q_hipv1_2_main_heat, "==", :a_8


    q_hipv1_2_enter_heat2_oth "OTHER SECONDARY HEATING FUEL SOURCE", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_HEAT2_2.HEAT2_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_hipv1_2_heat2, "==", :a_neg_5
    condition_B :q_hipv1_2_heat2, "!=", :a_neg_1
    condition_C :q_hipv1_2_heat2, "!=", :a_neg_2            

    q_hipv1_2_cooling "Does your home have any type of cooling or air conditioning besides fans? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.COOLING"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_cool "Not including fans, which of the following kinds of cooling systems do you <U>regularly use</U>?
    <br><br><b>INTERVIEWER INSTRUCTION: </b><br>PROBE FOR ANY OTHER RESPONSES<br><br>
     SELECT ALL THAT APPLY", :pick=>:any, 
     :data_export_identifier=>"PREG_VISIT_1_COOL_2.COOL"
    a_1 "Windows or wall air conditioners"
    a_2 "Central air conditioning"
    a_3 "Evaporative cooler (swamp cooler), or"
    a_4 "NO COOLING OR AIR CONDITIONING REGULARLY USED"
    a_neg_5 "Some other cooling system"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_cooling, "==", :a_1

    q_hipv1_2_enter_cool_oth "OTHER COOLING SYSTEM", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_COOL_2.COOL_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C and D"
    condition_A :q_hipv1_2_cool, "==", :a_neg_5
    condition_B :q_hipv1_2_cool, "!=", :a_4
    condition_C :q_hipv1_2_cool, "!=", :a_neg_1
    condition_D :q_hipv1_2_cool, "!=", :a_neg_2                  

    q_hipv1_2_time_stamp_9 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_9"
    a :datetime      

    label "Now I'd like to ask about the water in your home."

    q_hipv1_2_water_drink "What water source in your home do you use most of the time for <U>drinking</U>? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.WATER_DRINK"
    a_1 "Tap water,"
    a_2 "Filtered tap water,"
    a_3 "Bottled water, or"
    a_neg_5 "Some other source?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_water_drink_oth "OTHER SOURCE OF DRINKING", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.WATER_DRINK_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_water_drink, "==", :a_neg_5

    q_hipv1_2_water_cook "What water source in your home is used most of the time for <U>cooking</U>?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.WATER_COOK"
    a_1 "Tap water,"
    a_2 "Filtered tap water,"
    a_3 "Bottled water, or"
    a_neg_5 "Some other source?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_water_cook_oth "OTHER SOURCE OF COOKING WATER", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.WATER_COOK_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_water_cook, "==", :a_neg_5

    label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the 
    ceiling or walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof, or floods."

    q_hipv1_2_water "In the <b>past 12 months</b>, have you seen any water damage inside your home? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.WATER"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_mold "In the past 12 months, have you seen any mold or mildew on walls or other surfaces other 
    than the shower or bathtub, inside your home? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.MOLD"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_room_mold "In which rooms have you seen the mold or mildew?<br><br><b>INTERVIEWER INSTRUCTION:<br><br>
    PROBE:</b> Any other rooms? 
    <br><br>SELECT ALL THAT APPLY", :pick=>:any,
    :data_export_identifier=>"PREG_VISIT_1_ROOM_MOLD_2.ROOM_MOLD"
    a_1 "KITCHEN"
    a_2 "LIVING ROOM"
    a_3 "HALL/LANDING"
    a_4 "PARTICIPANT'S BEDROOM"
    a_5 "OTHER BEDROOM"
    a_6 "BATHROOM/TOILET"
    a_7 "BASEMENT"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_mold, "==", :a_1

    q_hipv1_2_enter_room_mold_oth "OTHER ROOMS WHERE MOLD OR MILDEW WAS SEEN", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_ROOM_MOLD_2.ROOM_MOLD_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv1_2_room_mold, "==", :a_neg_5
    condition_B :q_hipv1_2_room_mold, "!=", :a_neg_1
    condition_C :q_hipv1_2_room_mold, "!=", :a_neg_2            

    q_hipv1_2_time_stamp_10 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_10"
    a :datetime

    label "The next few questions ask about any recent additions or renovations to your home."

    q_hipv1_2_prenovate "Since you became pregnant, have any additions been built onto your home to make 
    it bigger or renovations or other construction been done in your home? Include only major projects. Do not count 
    smaller projects, such as painting, wallpapering, carpeting or re-finishing floors.", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.PRENOVATE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_prenovate_room "Which rooms were renovated? <br><br><b>INTERVIEWER INSTRUCTION:<br>PROBE:</b> Any others?<br><br>
    SELECT ALL THAT APPLY", :pick=>:any, 
    :data_export_identifier=>"PREG_VISIT_1_PRENOVATE_ROOM_2.PRENOVATE_ROOM"
    a_1 "KITCHEN"
    a_2 "LIVING ROOM"
    a_3 "HALL/LANDING"
    a_4 "PARTICIPANT'S BEDROOM"
    a_5 "OTHER BEDROOM"
    a_6 "BATHROOM/TOILET"
    a_7 "BASEMENT"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_prenovate, "==", :a_1

    q_hipv1_2_enter_prenovate_room_oth "OTHER ROOMS THAT WERE RENOVATED", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_PRENOVATE_ROOM_2.PRENOVATE_ROOM_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv1_2_prenovate_room, "==", :a_neg_5
    condition_B :q_hipv1_2_prenovate_room, "!=", :a_neg_1
    condition_C :q_hipv1_2_prenovate_room, "!=", :a_neg_2      

    q_hipv1_2_pdecorate "Since you became pregnant, were any smaller projects done in your home, 
    such as painting, wallpapering, refinishing floors, or installing new carpet?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.PDECORATE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_pdecorate_room "In which rooms were these smaller projects done? <br><br><b>INTERVIEWER INSTRUCTION:<br>PROBE:</b> Any others?<br><br>
    SELECT ALL THAT APPLY", :pick=>:any, 
    :data_export_identifier=>"PREG_VISIT_1_PDECORATE_ROOM_2.PDECORATE_ROOM"
    a_1 "KITCHEN"
    a_2 "LIVING ROOM"
    a_3 "HALL/LANDING"
    a_4 "PARTICIPANT'S BEDROOM"
    a_5 "OTHER BEDROOM"
    a_6 "BATHROOM/TOILET"
    a_7 "BASEMENT"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_pdecorate, "==", :a_1

    q_hipv1_2_enter_pdecorate_room_oth "OTHER ROOMS WHERE SMALLER PROJECTS WERE DONE", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_PDECORATE_ROOM_2.PDECORATE_ROOM_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv1_2_pdecorate_room, "==", :a_neg_5
    condition_B :q_hipv1_2_pdecorate_room, "!=", :a_neg_1
    condition_C :q_hipv1_2_pdecorate_room, "!=", :a_neg_2      
  end
  section "PETS", :reference_identifier=>"prepregnancy_visit_v20" do    
      q_hipv1_2_time_stamp_11 "INSERT DATE/TIME STAMP", 
      :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_11"
      a :datetime
      
      label "Now, I'd like to ask about any pets you may have in your home."

      q_hipv1_2_pets "Are there any pets that spend any time inside your home?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.PETS"
      a_1 "YES"
      a_2 "NO"
      a_neg_1 "REFUSED"
      a_neg_2 "DON'T KNOW"

      q_hipv1_2_pet_type "What kind of pets are these? <br><br><b>INTERVIEWER INSTRUCTION:</b><br> PROBE FOR ANY OTHER RESPONSES<br><br>
      SELECT ALL THAT APPLY", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_1_PET_TYPE_2.PET_TYPE"
      a_1 "DOG"
      a_2 "CAT"
      a_3 "SMALL MAMMAL (RABBIT, GERBIL, HAMSTER, GUINEA PIG, FERRET, MOUSE)"
      a_4 "BIRD"
      a_5 "FISH OR REPTILE (TURTLE, SNAKE, LIZARD)"
      a_neg_5 "OTHER"
      a_neg_1 "REFUSED"
      a_neg_2 "DON'T KNOW"
      dependency :rule=>"A"
      condition_A :q_hipv1_2_pets, "==", :a_1

      q_hipv1_2_pet_type_oth "OTHER TYPES OF PETS", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_PET_TYPE_2.PET_TYPE_OTH"
      a_1 "SPECIFY", :string
      a_neg_1 "REFUSED"
      a_neg_2 "DON'T KNOW"
      dependency :rule=>"A and B and C"
      condition_A :q_hipv1_2_pet_type, "==", :a_neg_5
      condition_B :q_hipv1_2_pet_type, "!=", :a_neg_1
      condition_C :q_hipv1_2_pet_type, "!=", :a_neg_2            
  end
  section "HOUSEHOLD COMPOSITION AND DEMOGRAPHICS", :reference_identifier=>"prepregnancy_visit_v20" do 
    q_hipv1_2_time_stamp_12 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_12"
    a :datetime

# TODO
    # PROGRAMMER INSTRUCTION: 
    # • IF A PRE-PREGNANCY QUESTIONNAIRE WAS COMPLETED DISPLAY BRACKETEDTEXT: 
    # “The next questions may be similar to those asked the last time we spoke, but we are asking them again 
    # because sometimes the answers change.”

    label "{The next questions may be similar to those asked the last time we spoke, but we are asking them again because 
    sometimes the answers change.}Now, I'd like to ask some questions about your schooling and employment."

    q_hipv1_2_educ "What is the highest degree or level of school that you have completed?<br><br>
    <b>INTERVIEWER INSTRUCTION: </b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.",
     :pick=>:one, 
     :data_export_identifier=>"PREG_VISIT_1_2.EDUC"
    a_1 "LESS THAN A HIGH SCHOOL DIPLOMA OR GED"
    a_2 "HIGH SCHOOL DIPLOMA OR GED"
    a_3 "SOME COLLEGE BUT NO DEGREE"
    a_4 "ASSOCIATE DEGREE"
    a_5 "BACHELOR’S DEGREE (E.G., BA, BS)"
    a_6 "POST GRADUATE DEGREE (E.G., MASTERS OR DOCTORAL)"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_working "Are you <U>currently</U> working at any full or part time jobs?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.WORKING"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_enter_hours "Approximately how many hours each week are you working?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HOURS"
    a_1 "NUMBER OF HOURS (double check if > 60)", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_working, "==", :a_1

    q_hipv1_2_shift_work "Do you work shifts that starts after 2 pm?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.SHIFT_WORK"
    a_1 "YES"
    a_2 "NO"
    a_3 "SOMETIMES"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_working, "==", :a_1
    
    label "These next questions are about the language that will be spoken to your baby."
    
    q_hipv1_2_hh_nonenglish "Is there any language other than English regularly spoken in your home?", :pick =>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.HH_NONENGLISH"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_hipv1_2_hh_nonenglish_2 "What languages other than English are spoken in your home?<br><br> 
    <b>INTERVIEWER INSTRUCTION:</b><br> 
      PROBE AS NEEDED; \"Any others?\"<br><br>
    SELECT ALL THAT APPLY.", :pick =>:any, 
    :data_export_identifier=>"PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH_2"
    a_1 "SPANISH"
    a_2 "ARABIC"
    a_3 "CHINESE"
    a_4 "FRENCH"
    a_5 "FRENCH CREOLE"
    a_6 "GERMAN"
    a_7 "ITALIAN"
    a_8 "KOREAN"
    a_9 "POLISH"
    a_10 "RUSSIAN"
    a_11 "TAGALOG"
    a_12 "VIETNAMESE"
    a_13 "URDU"
    a_14 "PUNJABI"
    a_15 "BENGALI"
    a_16 "FARSI"
    a_17 "SIGN LANGUAGE"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule => "A"
    condition_A :q_hipv1_2_hh_nonenglish, "==", :a_1
    
    q_hipv1_2_hh_nonenglish_2_oth "OTHER LANGUAGES THAT ARE SPOKEN IN YOUR HOME", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH2_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv1_2_hh_nonenglish_2, "==", :a_neg_5
    condition_B :q_hipv1_2_hh_nonenglish_2, "!=", :a_neg_1
    condition_C :q_hipv1_2_hh_nonenglish_2, "!=", :a_neg_2
    
    
    q_hipv1_2_english "Is English also spoken in your home?", :pick => :one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HH_ENGLISH"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_hipv1_2_hh_primary_lang "What is the primary language spoken in your home?", :pick => :one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HH_PRIMARY_LANG"
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
    a_18 "SIGN LANGUAGE"
    a_19 "CANNOT CHOOSE"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule => "A"
    condition_A :q_hipv1_2_english, "==", :a_1    
    
    q_hipv1_2_hh_primary_lang_oth "OTHER PRIMARY LANGUAGES THAT ARE SPOKEN IN YOUR HOME", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HH_PRIMARY_LANG_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv1_2_hh_primary_lang, "==", :a_neg_5
    condition_B :q_hipv1_2_hh_primary_lang, "!=", :a_neg_1
    condition_C :q_hipv1_2_hh_primary_lang, "!=", :a_neg_2      
    
    label "The next questions may be similar to those asked the last time we contacted you, 
    but we are asking them again because sometimes the answers change."
    
    q_hipv1_2_maristat "I’d like to ask about your marital status. Are you: <br><br>
    <b>INTERVIEWER INSTRUCTION: </b><br>
      PROBE FOR CURRENT MARITAL STATUS", :pick => :one, 
    :data_export_identifier=>"PREG_VISIT_1_2.MARISTAT"
    a_1 "Married,"
    a_2 "Not married but living together with a partner"
    a_3 "Never been married,"
    a_4 "Divorced,"
    a_5 "Separated, or"
    a_6 "Widowed?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"        
    
    q_hipv1_2_sp_educ "What is the highest degree or level of school that your spouse or partner has completed?<br><br>
    <b>INTERVIEWER INSTRUCTION: </b>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.<br>",
    :pick => :one, 
    :data_export_identifier=>"PREG_VISIT_1_2.SP_EDUC"
    a_1 "LESS THAN A HIGH SCHOOL DIPLOMA OR GED"
    a_2 "HIGH SCHOOL DIPLOMA OR GED"
    a_3 "SOME COLLEGE BUT NO DEGREE"
    a_4 "ASSOCIATE DEGREE"
    a_5 "BACHELOR'S DEGREE (e.g., BA, BS)"
    a_6 "POST GRADUATE DEGREE (e.g., Masters or Doctoral)"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_maristat, "==", :a_1
    condition_B :q_hipv1_2_maristat, "==", :a_2
    
    q_hipv1_2_sp_ethnicity "Does your spouse or partner consider himself [OR HERSELF, IF VOLUNTEERED] to be Hispanic, or Latino [LATINA]?",
     :pick=>"one", 
     :data_export_identifier=>"PREG_VISIT_1_2.SP_ETHNICITY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_maristat, "==", :a_1
    condition_B :q_hipv1_2_maristat, "==", :a_2
    
    q_hipv1_2_sp_race "What race does your spouse (or partner) consider himself [OR HERSELF, IF VOLUNTEERED] to be? You may select one or more.
    <br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.
    <br><br>PROBE FOR ANY OTHER RESPONSES
    <br><br>ONLY USE “SOME OTHER RACE” IF VOLUNTEERED. DON’T ASK
    <br><br>SELECT ALL THAT APPLY.", :pick=>"any", 
    :data_export_identifier=>"PREG_VISIT_1_SP_RACE_2.SP_RACE"
    a_1 "WHITE,"
    a_2 "BLACK OR AFRICAN AMERICAN,"
    a_3 "AMERICAN INDIAN OR ALASKA NATIVE,"
    a_4 "ASIAN, OR"
    a_5 "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER?"
    a_6 "MULTI-RACIAL"
    a_neg_5 "SOME OTHER RACE?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_maristat, "==", :a_1
    condition_B :q_hipv1_2_maristat, "==", :a_2
    
    q_hipv1_2_sp_race_oth "OTHER RACE", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_SP_RACE_2.SP_RACE_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_hipv1_2_sp_race, "==", :a_neg_5
    condition_B :q_hipv1_2_sp_race, "!=", :a_neg_1
    condition_C :q_hipv1_2_sp_race, "!=", :a_neg_2                              
    
    q_hipv1_2_time_stamp_13 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_13"
    a :datetime      
  end
  
  section "COMMUTING", :reference_identifier=>"prepregnancy_visit_v20" do    
    label "Next, I'll be asking you about commuting and how travel from place to place."

    q_hipv1_2_commute "Think of the longest regular commute that you take, to work, school, or other places. By regular commute, 
    I mean someplace that you travel to at least 3 days a week. Since you became pregnant, how do you normally get to your destination? 
    <br><br><b>INTERVIEWER INSTRUCTION:</b><br>PROBE FOR ANY OTHER RESPONSES
    <br><br>SELECT ALL THAT APPLY", 
      :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_1_COMMUTE_2.COMMUTE"
    a_1 "CAR"
    a_2 "BUS"
    a_3 "TRAIN, SUBWAY, RAIL, OR LIGHT RAIL"
    a_4 "WALK, BIKE (NON-MOTORIZED)"
    a_5 "DOES NOT HAVE A REGULAR COMMUTE"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_commute_oth "OTHER FORMS OF COMMUTING", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_COMMUTE_2.COMMUTE_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B or C)"
    condition_A :q_hipv1_2_commute, "==", :a_neg_5
    condition_B :q_hipv1_2_commute, "!=", :a_neg_1
    condition_C :q_hipv1_2_commute, "!=", :a_neg_2

    q_hipv1_2_commute_time "About how many minutes is this commute, one way? Be sure to include any routine side trips you 
    make on the way, such as stops at day care or school. Include only the time spent driving or sitting inside the car.", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.COMMUTE_TIME"
    a_1 "NUMBER OF MINUTES (should not be > 60)", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_local_trav "<b>Since you became pregnant</b>, how do you normally get to other places, for example, shopping, doctor, 
    visiting friends, or church? 
    <br><br><b>INTERVIEWER INSTRUCTION:</b><br>PROBE FOR ANY OTHER RESPONSES
    <br><br>SELECT ALL THAT APPLY", :pick=>:any, :data_export_identifier=>"PREG_VISIT_1_LOCAL_TRAV_2.LOCAL_TRAV"
    a_1 "CAR"
    a_2 "BUS"
    a_3 "TRAIN, SUBWAY, RAIL, OR LIGHT RAIL"
    a_4 "WALK, BIKE (NON-MOTORIZED)"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_local_trav_oth "OTHER FORMS OF LOCAL TRAVEL", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_LOCAL_TRAV_2.LOCAL_TRAV_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv1_2_local_trav, "==", :a_neg_5
    condition_A :q_hipv1_2_local_trav, "!=", :a_neg_5
    condition_A :q_hipv1_2_local_trav, "!=", :a_neg_5      

    label "Next, I'd like to find out about how often you pump gasoline."

    q_hipv1_2_pump_gas "Since you became pregnant, about how often have you pumped or poured gasoline into a car, truck, motorcycle, other 
    motor vehicle, lawnmower, or other engine:", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.PUMP_GAS"
    a_1 "Every day,"
    a_2 "4-6 times per week,"
    a_3 "2-3 times per week,"
    a_4 "Once a week,"
    a_5 "One to three times a month,"
    a_6 "Less than once a month, or"
    a_7 "Never?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_time_stamp_14 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_14"
    a :datetime
  end  
  section "FAMILY INCOME", :reference_identifier=>"prepregnancy_visit_v20" do    
    label "Now I’m going to ask a few questions about your income. Family income is important in analyzing the data we 
    collect and is often used in scientific studies to compare groups of people who are similar. Please remember that all the 
    information you provide is confidential.<br>Please think about your total combined <u>family</u> income during {CURRENT YEAR – 1} 
    for all members of the family."

    q_hipv1_2_enter_hh_members "How many household members are supported by your total combined family income?", 
    :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_hh_members "NUMBER HOUSEHOLD MEMBERS SUPPORTED BY TOTAL COMBINED FAMILY INCOME", :data_export_identifier=>"PREG_VISIT_1_2.HH_MEMBERS"
    a "SPECIFY", :integer
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_hh_members, "==", :a_1
    
    label "The value you provided is outside the suggested range. (Range = 1 to 15) This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_hipv1_2_hh_members, "<", {:integer_value => "1"}
    condition_B :q_hipv1_2_hh_members, ">", {:integer_value => "15"}

    q_hipv1_2_enter_num_child "How many of those people are children? Please include anyone under 18 years or anyone 
    older than 18 years and in high school.", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_hipv1_2_enter_hh_members, "==", :a_1
    condition_B :q_hipv1_2_hh_members, ">", {:integer_value => "0"}
    condition_C :q_hipv1_2_hh_members, "<", {:integer_value => "15"}    

# TODO == • DISPLAY  HARD EDIT IF RESPONSE > HH_MEMBERS 
    q_hipv1_2_num_child "NUMBER OF CHILDREN 
    <br><br> <b>INTERVIEWER INSTRUCTION: </b>
    Check the entry field for this question with the answer above. If response is higher, ask the question again", 
    :data_export_identifier=>"PREG_VISIT_1_2.NUM_CHILD"
    a "SPECIFY", :integer
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_num_child, "==", :a_1

    label "The value you provided is outside the suggested range. (Range = 0 to 10) This value is admissible, but you may wish to verify."
    dependency :rule=>"A"
    condition_A :q_hipv1_2_num_child, ">", {:integer_value => "10"}

    q_hipv1_2_income "Of these income groups, which category best represents your combined family income during the last calendar year?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.INCOME"
    a_1 "LESS THAN $4,999"
    a_2 "$5,000-$9,999"
    a_3 "$10,000-$19,999"
    a_4 "$20,000-$29,999"
    a_5 "$30,000-$39,999"
    a_6 "$40,000-$49,999"
    a_7 "$50,000-$74,999"
    a_8 "$75,000-$99,999"
    a_9 "$100,000-$199,999"
    a_10 "$200,000 OR MORE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
  end
  section "TRACING QUESTIONS", :reference_identifier=>"prepregnancy_visit_v20" do  
    label "PRESS THE 'NOW' BUTTON TO ENTER THE CURRENT DATE & TIME"

    q_hipv1_2_time_stamp_15 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_15"
    a :datetime

    label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember 
    that all the information you provide is confidential and will not be provided to anyone outside the National Children’s Study."

# TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • ASK COMM_EMAIL ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED; 
    # • ELSE SKIP TO HAVE_EMAIL

    q_hipv1_2_comm_email "When we last spoke, we asked questions about communicating with you through your personal email. 
    Has your email address or your preferences regarding use of your personal email changed since then?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.COMM_EMAIL"
    a_1 "YES"
    a_2 "NO"
    a_3 "DON'T REMEMBER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_have_email "Do you have an email address?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.HAVE_EMAIL"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_hipv1_2_email_2 "May we use your personal email address to make future study appointments or send appointment reminders?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.EMAIL_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_have_email, "==", :a_1      
    
    q_hipv1_2_email_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.EMAIL_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_have_email, "==", :a_1

    q_hipv1_2_enter_email "What is the best email address to reach you?", :pick=>:one, 
    :help_text=>"EXAMPLE OF VALID EMAIL ADDRESS SUCH AS MARYJANE@EMAIL.COM", 
    :data_export_identifier=>"PREG_VISIT_1_2.EMAIL"
    a_1 "ENTER E-MAIL ADDRESS:", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_enter_email, "==", :a_1      

#       TODO
# PROGRAMMER INSTRUCTIONS: 
# • ASK COMM_CELL ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED
# • ELSE SKIP TO CELL_PHONE_1

    label "ASK (COMM_CELL) ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED; ELSE SKIP TO (CELL_PHONE_1)"

    q_hipv1_2_comm_cell "When we last spoke, we asked questions about communicating with you through your personal cell 
    phone number. Has your cell phone number or your preferences regarding use of your personal cell phone number 
    changed since then?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.COMM_CELL"
    a_1 "YES"
    a_2 "NO"
    a_3 "DON'T REMEMBER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_cell_phone_1 "Do you have a personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    

    q_hipv1_2_cell_phone_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_cell_phone_1, "==", :a_1

    q_hipv1_2_cell_phone_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_cell_phone_1, "==", :a_1      

    q_hipv1_2_cell_phone_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_4"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_cell_phone_3, "==", :a_1

    q_hipv1_2_enter_cell_phone "What is your personal cell phone number (XXXXXXXXXX)?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE"
    a_1 "PHONE NUMBER", :string
    a_neg_7 "PARTICIPANT HAS NO CELL PHONE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_time_stamp_16 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_16"
    a :datetime

    label "ASK (COMM_CONTACT) ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED; ELSE SKIP TO (CONTACT_1)"

    q_hipv1_2_comm_contact "Sometimes if people move or change their telephone number, we have difficulty reaching them. At our last visit, 
    we asked for contact information for two friends or relatives not living with you who would know where you could be reached in case we 
    have trouble contacting you. Has that information changed since our last visit?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.COMM_CONTACT"
    a_1 "YES"
    a_2 "NO"
    a_3 "DON'T REMEMBER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_contact_1 "Could I have the name of a friend or relative not currently living with you who should know where you could be reached 
    in case we have trouble contacting you?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_contact_fname_1 "What is the person's first name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_FNAME_1"
    a_1 "FIRST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_contact_1, "==", :a_1

    q_hipv1_2_contact_lname_1 "What is the person's last name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_LNAME_1"
    a_1 "LAST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_contact_1, "==", :a_1      

    q_hipv1_2_contact_relate_1 "What is his/her relationship to you?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE_1"
    a_1 "MOTHER/FATHER"
    a_2 "BROTHER/SISTER"
    a_3 "AUNT/UNCLE"
    a_4 "GRANDPARENT"
    a_5 "NEIGHBOR"
    a_6 "FRIEND"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_contact_1, "==", :a_1

    q_hipv1_2_enter_contact_relate1_oth "OTHER RELATIONSHIP OF CONTACT", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE1_OTH"      
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_contact_relate_1, "==", :a_neg_5

    q_hipv1_2_enter_contact_addr_1 "What is his/her address?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>- PROMPT AS NEEDED TO COMPLETE INFORMATION", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_c_addr1_1 "ADDRESS 1 - STREET/PO BOX", :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR1_1"  
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_1, "==", :a_1

    q_hipv1_2_c_addr2_1 "ADDRESS 2", :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR2_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_1, "==", :a_1

    q_hipv1_2_c_unit_1 "UNIT", :data_export_identifier=>"PREG_VISIT_1_2.C_UNIT_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_1, "==", :a_1

    q_hipv1_2_c_city_1 "CITY", :data_export_identifier=>"PREG_VISIT_1_2.C_CITY_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_1, "==", :a_1

    q_hipv1_2_c_state_1 "STATE", :display_type=>"dropdown", :data_export_identifier=>"PREG_VISIT_1_2.C_STATE_1"
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
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_1, "==", :a_1

    q_hipv1_2_c_zipcode_1 "ZIP CODE", :data_export_identifier=>"PREG_VISIT_1_2.C_ZIPCODE_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_1, "==", :a_1

    q_hipv1_2_c_zip4_1 "ZIP+4", :data_export_identifier=>"PREG_VISIT_1_2.C_ZIP4_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_1, "==", :a_1

    q_hipv1_2_enter_contact_phone_1 "What is his/her telephone number (XXXXXXXXXX)?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>- IF CONTACT HAS NO TELEPHONE ASK FOR TELEPHONE NUMBER WHERE HE/SHE RECEIVES CALLS", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_PHONE_1"
    a_1 "PHONE NUMBER", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "CONTACT HAS NO TELEPHONE"

# *** CONTACT_2 doesn't exist
    label "Now I’d like to collect information on a second contact who does not currently live with you. What is this person’s name?",
    :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_2"

    q_hipv1_2_enter_contact_2 "What is the person's name?<br><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", :pick=>:one
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "NO SECOND CONTACT PROVIDED"

    q_hipv1_2_contact_fname_2 "What is the person's first name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_FNAME_2"
    a_1 "FIRST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_2, "==", :a_1

    q_hipv1_2_contact_lname_2 "What is the person's last name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_LNAME_2"
    a_1 "LAST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_2, "==", :a_1      

    q_hipv1_2_contact_relate_2 "What is his/her relationship to you?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE_2"
    a_1 "MOTHER/FATHER"
    a_2 "BROTHER/SISTER"
    a_3 "AUNT/UNCLE"
    a_4 "GRANDPARENT"
    a_5 "NEIGHBOR"
    a_6 "FRIEND"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_2, "==", :a_1

    q_hipv1_2_enter_contact_relate2_oth "OTHER RELATIONSHIP OF SECOND CONTACT", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE_2_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_2_contact_relate_2, "==", :a_neg_5
    
    
    q_hipv1_2_enter_contact_addr_2 "What is his/her address?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>- PROMPT AS NEEDED TO COMPLETE INFORMATION", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv1_2_c_addr1_2 "ADDRESS 1 - STREET/PO BOX", 
    :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR1_2"  
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_2_c_addr2_2 "ADDRESS 2", 
    :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR2_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_2_c_unit_2 "UNIT", :data_export_identifier=>"PREG_VISIT_1_2.C_UNIT_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_2_c_city_2 "CITY", :data_export_identifier=>"PREG_VISIT_1_2.C_CITY_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_c_state_2 "STATE", :display_type=>"dropdown", 
    :data_export_identifier=>"PREG_VISIT_1_2.C_STATE_2"
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
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_2_c_zipcode_2 "ZIP CODE", :data_export_identifier=>"PREG_VISIT_1_2.C_ZIPCODE_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_2_c_zip4_2 "ZIP+4", :data_export_identifier=>"PREG_VISIT_1_2.C_ZIP4_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv1_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_2_enter_contact_phone_2 "What is his/her telephone number (XXXXXXXXXX)?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>- IF CONTACT HAS NO TELEPHONE ASK FOR TELEPHONE NUMBER WHERE HE/SHE RECEIVES CALLS", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_PHONE_2"
    a_1 "PHONE NUMBER", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "CONTACT HAS NO TELEPHONE"
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_1_2.END"
    
    q_hipv1_time_stamp_17 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_17"
    a :datetime
  end
  section "PREGNANCY CARE LOG INTRODUCTION" do
    label "<b>INTERVIEWER INSTRUCTION: </b><br>EXPLAIN PREGNANCY HEALTH CARE LOG<br><br>
    In order to help you keep track of your doctor visits or other health care provider visits during your pregnancy, we are giving 
    you a Pregnancy Health Care Log. At each Study visit or telephone interview, we will ask you about any health care visits you had 
    since the last Study visit or telephone interview. This log will help you remember that information. The Pregnancy Health Care Log 
    has a Health Care Provider Log section for writing down information about your health care providers; address and phone numbers, and 
    there is also a Health Care Visits and Overnight Hospital Stays section for keeping track of information about your health care visits 
    and any diagnoses, procedures, or treatments.<br>
    It will be very helpful if you use the log to write down information any time that you receive health care, so that you will be able 
    to remember it accurately during your NCS Study visits or telephone interviews."
  end
end  