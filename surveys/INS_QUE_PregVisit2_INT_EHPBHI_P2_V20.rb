survey "INS_QUE_PregVisit2_INT_EHPBHI_P2_V2.0" do
  section "CAPI", :reference_identifier=>"prepregnancy_visit_2_v20" do

    q_TIME_STAMP_1 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_1"
    a :datetime
    
    label "Thank you for agreeing to participate in the National Children’s Study. This interview will take about 20 minutes 
    to complete. Your answers are important to us. There are no right or wrong answers. We will ask you questions about yourself, 
    your health and pregnancy, your feelings and attitudes, and where you live. You can skip over any question or stop the 
    interview at any time. We will keep everything that you tell us confidential. First, we’d like to make sure we have your 
    correct name and birth date."
    
    q_prepopulated_name "Name:"
    a :string

#     TODO - the name should be pre-populated
    q_hipv2_2_name_confirm "Is that your name? ", 
    :data_export_identifier=>"PREG_VISIT_2_2.NAME_CONFIRM", :pick=>:one
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
    condition_A :q_hipv2_2_name_confirm, "!=", :a_1        

    q_hipv2_2_r_fname "FIRST NAME", :display_type=>"string", :data_export_identifier=>"PREG_VISIT_2_2.R_FNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_name_confirm, "!=", :a_1

    q_hipv2_2_r_lname "LAST NAME", :display_type=>"string", :data_export_identifier=>"PREG_VISIT_2_2.R_LNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_name_confirm, "!=", :a_1

    # TODO:
    # PROGRAMMER INSTRUCTION:
    # • PRELOAD PARTICIPANT’S DOB IF COLLECTED PREVIOUSLY
    # • IF RESPONSE = YES, SET PERSON_DOB TO KNOWN VALUE

    q_prepopulated_date_of_birth "[PARTICIPANT'S DATE OF BIRTH AS MM/DD/YYYY]"
    a :date

    q_hipv2_2_dob_confirm "Is this your birth date?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.DOB_CONFIRM"
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
    condition_A :q_hipv2_2_dob_confirm, "!=", :a_1

    q_hipv2_2_confirmed_dob "What is your date of birth?",
    :data_export_identifier=>"PREG_VISIT_2_2.PERSON_DOB"
    a :date
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_dob_confirm, "!=", :a_1    

    q_hipv2_2_calc_age_confirmed_dob "<b>INTERVIEWER INSTRUCTIONS:</b> CALCULATED AGE (AS OF 'TODAY')"
    a :integer

    q_hipv2_2_age_elig "Is PARTICIPANT age-eligible? ", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.AGE_ELIG"
    a_1 "PARTICIPANT IS AGE ELIGIBLE"
    a_2 "PARTICIPANT IS YOUNGER THAN AGE OF MAJORITY"
    a_3 "PARTICIPANT IS OVER 49"
    a_4 "AGE ELIGIBILITY IS UNKNOWN"

    label "PARTICIPANT IS NOT ELIGIBLE. DO NOT OFFER SAQS."
    dependency :rule => "A"
    condition_A :q_hipv2_2_age_elig, "==", :a_2 

    label "Thank you for participating in the National Children’s Study and for taking the time to answer our questions. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_2_2.END"
    dependency :rule=> "A" 
    condition_A :q_hipv2_2_age_elig, "==", :a_2    

    label "CASE FOR SUPERVISOR REVIEW AT SC TO CONFIRM AGE ELIGIBILITY POST-INTERVIEW"
    dependency :rule => "A or B"
    condition_A :q_hipv2_2_confirmed_dob, "==", :a_neg_1
    condition_B :q_hipv2_2_confirmed_dob, "==", :a_neg_2     
  end
  section "CURRENT PREGNANCY INFORMATION", :reference_identifier=>"prepregnancy_visit_v20" do
    
    q_hipv2_2_time_stamp_2 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_2"
    a :datetime

    # PROGRAMMER INSTRUCTIONS: 
    # • IF PARTICIPANT HAS REPORTED BEING PREGNANT WITH MULTIPLES FILL IN “BABIES’ AS APPROPRIATE THROUGHOUT INSTRUMENT

    label "First, I’d like to update some information about your current pregnancy."

    q_hipv2_2_pregnant "The first questions ask about how your pregnancy is progressing. First, are you still pregnant?", 
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.PREGNANT"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
   
    label "DO NOT OFFER SAQS."
    dependency :rule=> "A or B" 
    condition_A :q_hipv2_2_pregnant, "==", :a_neg_1
    condition_B :q_hipv2_2_pregnant, "==", :a_neg_2  
   
    label "Thank you for participating in the National Children’s Study and for taking the time to answer our questions. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_2_2.END"
    dependency :rule=> "A or B" 
    condition_A :q_hipv2_2_pregnant, "==", :a_neg_1
    condition_B :q_hipv2_2_pregnant, "==", :a_neg_2
    
    q_hipv2_2_time_stamp_3 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_3"
    a :datetime

    label "I’m so sorry for your loss. I know this can be a difficult time.
    <br><br>INTERVIEWER INSTRUCTIONS:<br>
      - USE SOCIAL CUES AND PROFESSIONAL JUDGMENT IN RESPONSE<br>
      PROGRAMMER/INTERVIEWER INSTRUCTION: <br>
      - IF SC HAS PREGNANCY LOSS INFORMATION TO DISSEMINATE, OFFER TO PARTICIPANT"
    dependency :rule=> "A"
    condition_A :q_hipv2_2_pregnant, "==", :a_2
    
    q_hipv1_sc_loss_info "DOES THE STUDY CENTER (SC) HAVE PREGNANCY LOSS INFORMATION TO 
    DISSEMINATE TO PARTICIPANT?<br><br>IF SC HAS PREGNANCY LOSS INFORMATION TO DISSEMINATE, OFFER TO PARTICIPANT", :pick=>:one
    a_1 "YES"
    a_2 "NO"
    dependency :rule=> "A"
    condition_A :q_hipv2_2_pregnant, "==", :a_2    
      
    q_hipv2_2_loss_info "INTERVIEWER ANSWERED QUESTION: DID PARTICIPANT REQUEST ADDITIONAL INFORMATION ON 
    COPING WITH PREGNANCY LOSS?", :pick => :one, 
    :data_export_identifier=>"PREG_VISIT_2_2.LOSS_INFO"
    a_1 "YES"
    a_2 "NO"
    dependency :rule=> "A"
    condition_A :q_hipv2_2_pregnant, "==", :a_2
    
    label "Again, I’d like to say how sorry I am for your loss. We’ll send the information packet you requested as soon as possible.
    Please accept our condolences. Thank you for your time.<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    IF LOSS OF PREGNANCY, END INTERVIEW. DO NOT ADMINISTER SAQs.", :data_export_identifier=>"PREG_VISIT_2_2.END_INFO"
    dependency :rule=> "A and B"
    condition_A :q_hipv2_2_pregnant, "==", :a_2
    condition_B :q_hipv2_2_loss_info, "==", :a_1
    
    label "Again, I’d like to say how sorry I am for your loss. Please accept our condolences. Thank you for your time.<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    IF LOSS OF PREGNANCY, END INTERVIEW. DO NOT ADMINISTER SAQs.", :data_export_identifier=>"PREG_VISIT_2_2.END_INFO"
    dependency :rule=> "A and B"
    condition_A :q_hipv2_2_pregnant, "==", :a_2
    condition_B :q_hipv2_2_loss_info, "==", :a_2    
    
    label "We'll send the information packet you requested as soon as possible."
    dependency :rule=>"A"
    condition_A :q_hipv2_2_loss_info, "==", :a_2
    
    label "<b>INTERVIEWER INSTRUCTIONS: </b>END THE QUESTIONARE"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_loss_info, "==", :a_2
    
    q_hipv2_2_enter_due_date "What is your current due date? (YYYYMMDD)", :pick => :one,
    :help_text => "INTERVIEWER INSTRUCTIONS: <br>
      IF RESPONSE WAS DETERMINED TO BE INVALID, ASK QUESTION AGAIN AND PROBE FOR VALID RESPONSE",
    :data_export_identifier=>"PREG_VISIT_2_2.DUE_DATE"
    a_1 :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=> "A"
    condition_A :q_hipv2_2_pregnant, "==", :a_1
    
    #TODO - have to be able to calculate the labels below - put the request in surveyor to address the issue
    q_hipv2_2_due_date_check "CALCULATION: NUMBER OF MONTHS BETWEEN REPORTED DUE DATE AND 'TODAY'
    <br><br>CAN NOT BE (1) ON OR BEFORE 'TODAY' OR (2) MORE THAN 9 MONTHS FROM 'TODAY'
    <br><br>IF RESPONSE WAS DETERMINED TO BE INVALID, ASK QUESTION AGAIN AND PROBE FOR VALID RESPONSE", :pick => :one
    a_on_or_before_today "ON OR BEFORE 'TODAY'"
    a_more_than_9_months_after_today "MORE THAN 9 MONTHS AFTER 'TODAY'"
    a_valid "VALID DUE DATE"
    a_invalid "NO VALID DATE IS GIVEN "
    dependency :rule=> "A"
    condition_A :q_hipv2_2_pregnant, "==", :a_1
    
    label "YOU HAVE ENTERED A DATE THAT IS MORE THAN 9 MONTHS FROM TODAY. RE-ENTER DATE"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_due_date_check, "==", :a_more_than_9_months_after_today
    
    label "YOU HAVE ENTERED A DATE THAT OCCURRED MORE THAN A MONTH BEFORE TODAY. RE-ENTER DATE"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_due_date_check, "==", :a_on_or_before_today
    
    q_DATE_KNOWN "INTERVIEWER COMPLETED QUESTION: DID PARTICIPANT GIVE DATE?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.DATE_KNOWN"
    a_1 "PARTICIPANT GAVE COMPLETE DATE"
    a_2 "PARTICIPANT GAVE PARTIAL DATE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_BPLAN_CHANGE "Has the place where you plan to deliver your [baby/babies] changed since we last spoke with you?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.BPLAN_CHANGE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
 
    q_BIRTH_PLAN_OLD "So we make sure we have the correct information, where do you plan to deliver your {baby/babies}?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLAN"
    a_1 "In a hospital"
    a_2 "A birthing center"
    a_3 "At home, or"
    a_4 "Some other place?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_BPLAN_CHANGE, "==", :a_2
    
    q_hipv2_2_birth_plan "Where do you plan to deliver your {baby/babies}?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLAN"
    a_1 "In a hospital"
    a_2 "A birthing center"
    a_3 "At home, or"
    a_4 "Some other place?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_BPLAN_CHANGE, "!=", :a_2    
 

    q_name_and_addr_of_hospital "What is the name and address of the place where you are planning to deliver your 
    [baby/babies]?", :pick =>:one
    a_resp "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B or C"
    condition_A :q_hipv2_2_birth_plan, "==", :a_1
    condition_B :q_hipv2_2_birth_plan, "==", :a_2
    condition_C :q_hipv2_2_birth_plan, "==", :a_4        

    q_hipv2_2_birth_place "NAME OF BIRTH HOSPITAL/BIRTHING CENTER", 
    :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLACE"
    a :string
    dependency :rule=>"A"
    condition_A :q_name_and_addr_of_hospital, "==", :a_resp

    q_hipv2_2_b_address_1 "ADDRESS 1 - STREET/PO BOX", :data_export_identifier=>"PREG_VISIT_2_2.B_ADDRESS_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_name_and_addr_of_hospital, "==", :a_resp

    q_hipv2_2_b_address_2 "ADDRESS 2", :data_export_identifier=>"PREG_VISIT_2_2.B_ADDRESS_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_name_and_addr_of_hospital, "==", :a_resp

    q_hipv2_2_b_city "CITY", :data_export_identifier=>"PREG_VISIT_2_2.B_CITY"
    a "Text", :string
    dependency :rule=>"A"
    condition_A :q_name_and_addr_of_hospital, "==", :a_resp

    q_hipv2_2_b_state "STATE", :display_type=>"dropdown", :data_export_identifier=>"PREG_VISIT_2_2.B_STATE"
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
    condition_A :q_name_and_addr_of_hospital, "==", :a_resp

    q_hipv2_2_b_zipcode "ZIP CODE", :data_export_identifier=>"PREG_VISIT_2_2.B_ZIPCODE"
    a :string
    dependency :rule=>"A"
    condition_A :q_name_and_addr_of_hospital, "==", :a_resp

    q_USE_PR_LOG "Are you using the Pregnancy Health Care Log? This is the booklet that you or your health care 
    provider (doctor, midwife, nurse, etc.) uses to record information about your medical visits.",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.USE_PR_LOG"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    q_REASON_NO_PR_LOG "Is that because…",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.REASON_NO_PR_LOG"
    a_1 "You haven’t had a medical visit since our last interview,"
    a_2 "You’ve misplaced the log,"
    a_3 "You’ve forgotten to bring it to your medical visits"
    a_4 "The log was too much trouble to complete, or"
    a_5 "The log was too difficult to understand"
    a_neg_5 "OTHER:"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_2
    
    q_REASON_NO_PR_LOG_OTH "OTHER: SPECIFY",
    :data_export_identifier=>"PREG_VISIT_2_2.REASON_NO_PR_LOG_OTH"
    a :string
    dependency :rule=>"A"
    condition_A :REASON_NO_PR_LOG, "==", :a_neg_5    

    label "We’ll get another Pregnancy Health Care Log in the mail to you today."
    dependency :rule=>"A"
    condition_A :REASON_NO_PR_LOG, "==", :a_2

    label "This information is very important to the study. Please keep the log in a safe place and 
    bring the log with you to all of your medical visits. "
    dependency :rule=>"A"
    condition_A :REASON_NO_PR_LOG, "==", :a_3
    condition_A :REASON_NO_PR_LOG, "==", :a_4
    condition_A :REASON_NO_PR_LOG, "==", :a_neg_1
    condition_A :REASON_NO_PR_LOG, "==", :a_neg_2

    q_NUM_PROV_PR_LOG "How many health care providers have you seen since using this Pregnancy Health Care Log?",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.NUM_PROV_REC"
    a "NUMBER OF PROVIDERS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_1
    
    q_NUM_PROV_REC "Of those providers that you have seen, how many providers have you recorded their contact 
    information such as address or phone number?",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.NUM_PROV_REC"
    a "NUMBER OF CONTACTS", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_1    
    
    label "I am now going to ask some questions about visits to a doctor or other health care provider (doctor, midwife, 
    nurse, etc.). You may want to refer to the Pregnancy Health Care Log that you received as part of this study or to 
    any other personal record or calendar that you keep that would help you to remember the dates of these visits. If you 
    have this information available, please go and get it now."
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_1
    
    label "I am now going to ask some questions about visits to a doctor or other health care provider (doctor, midwife, 
    nurse, etc.). You may want to refer to 
    any other personal record or calendar that you keep that would help you to remember the dates of these visits. If you 
    have this information available, please go and get it now."    
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "!=", :a_1
    
    q_DATE_VISIT "What was the date of your most recent doctor’s visit or checkup since you’ve become pregnant?",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.DATE_VISIT"
    a "DATE", :date
    a_neg_7 "HAVE NOT HAD A VISIT"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"

    label "If you haven’t yet, please put a check mark in the box next to the visit you just told me about in your 
    Pregnancy Health Care Log"
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_1
    
    # PROGRAMMER INSTRUCTIONS: 
    #     • IF VALID DATE FOR DATE_VISIT IS PROVIDED, DISPLAY “At this visit or At”. OTHERWISE DISPLAY ‘”At”
    #     
    
    label "<b>INTERVIEWER INSTRUCTIONS:</b>
    - RE-READ INTRODUCTORY STATEMENT ({At this visit or at/{At} any time during your pregnancy, did the doctor 
    or other health care provider tell you that you have any of the following conditions?) AS NEEDED"
    
    q_valid_date "<b>INTERVIEWER INSTRUCTIONS: </b>Is the visit date valid?", :pick => :one
    a_1 "YES"
    a_2 "NO"
    
    label "At this visit or at any time during your pregnancy, did the doctor or other health care provider tell 
    you that you have any of the following conditions?"
    dependency :rule=> "A"
    condition_A :q_valid_date, "==", :a_1
    
    label "At any time during your pregnancy, did the doctor or other health care provider tell 
    you that you have any of the following conditions?"
    dependency :rule=> "A"
    condition_A :q_valid_date, "==", :a_2
    
    q_hipv2_2_diabetes_1 "Diabetes? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.DIABETES_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_highbp_preg "High blood pressure? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.HIGHBP_PREG"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_urine "Protein in your urine? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.URINE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_preeclamp "Preeclampsia or toxemia? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.PREECLAMP"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_early_labor "Early or premature labor? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.EARLY_LABOR"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_anemia "Anemia or low blood count? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.ANEMIA"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_nausea "Severe nausea or vomiting (hyperemesis)? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.NAUSEA"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_kidney "Bladder or kidney infection? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.KIDNEY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_rh_disease "Rh disease or isoimmunization? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.RH_DISEASE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_group_b "Infection with bacteria called Group B strep?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.GROUP_B"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_herpes "Infection with a Herpes virus? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.HERPES"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_vaginosis "Infection of the vagina with bacteria (bacterial vaginosis?)", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.VAGINOSIS"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_oth_condition "Any other serious condition? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.OTH_CONDITION"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_enter_condition_oth "Can you please specify the other serious conditions? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CONDITION_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_oth_condition, "==", :a_1 
    
    q_hipv2_2_time_stamp_4 "CURRENT DATE & TIME", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_4"
    a :datetime
    
    q_HOSPITAL "Since you’ve been pregnant, have you spent at least one night in the hospital?", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.HOSPITAL"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_ADMIN_DATE "What was the admission date of your most recent hospital stay?", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.ADMIN_DATE"
    a "DATE", :date
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    a_neg_7 "HAVE NOT BEEN HOSPITALIZED OVERNIGHT/NOT APPLICABLE"
    dependency :rule=>"A"
    condition_A :q_HOSPITAL, "==", :a_1    
     
    q_HOSP_NIGHTS "How many nights did you stay in the hospital during this hospital stay?<br>
    <b>INTERVIEWER INSTRUCTION: </b><br>
    - CONFIRM RESPONSE",
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.HOSP_NIGHTS"
    a "DATE", :date
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_HOSPITAL, "==", :a_1 
    
    q_DIAGNOSE "Did a doctor or other health care provider give you a diagnosis during this hospital stay?",
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.DIAGNOSE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_HOSPITAL, "==", :a_1
    
    q_DIAGNOSE_2 "What was the diagnosis?<b>INTERVIEWER INSTRUCTION:</b><br>
    - PROBE FOR MULTIPLE RESPONSES.<br><br>SELECT ALL THAT APPLY.",
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_DIAGNOSE_2_2.DIAGNOSE_2"
    a_1 "DEHYDRATION"
    a_2 "PRETERM LABOR"
    a_3 "HYPEREMESIS"
    a_4 "PREECLAMPSIA"
    a_5 "RUPTURE OF MEMBRANES"
    a_6 "KIDNEY DISORDER"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_DIAGNOSE, "==", :a_1    
 
    q_DIAGNOSIS_OTH "OTHER DIAGNOSIS", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_DIAGNOSE_2_2.DIAGNOSE_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_DIAGNOSE_2, "==", :a_neg_5
    condition_B :q_DIAGNOSE_2, "!=", :a_neg_1
    condition_C :q_DIAGNOSE_2, "!=", :a_neg_2
    
    label "If you haven’t yet, please put a check mark in the box next to the visit you just told me about in your 
    Pregnancy Health Care Log."
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_1
  end
  section "HOUSING CHARACTERISTICS", :reference_identifier=>"prepregnancy_visit_2_v20" do

    q_TIME_STAMP_5 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_5"
    a :datetime           
    
    label "Now I’d like to find out more about your home and the area in which you live."
    
    q_RECENT_MOVE "Have you moved or changed your housing situation since we last spoke with you?", 
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.RECENT_MOVE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_hipv2_2_own_home "Is your home…", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.OWN_HOME"
    a_1 "Owned or being bought by you or someone in your household"
    a_2 "Rented by you or someone in your household, or"
    a_3 "Occupied without payment of rent?"
    a_neg_5 "SOME OTHER ARRANGEMENT"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_own_home_oth "Can you please specify your other home arrangement? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.OWN_HOME_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv1_own_home, "==", :a_neg_5
    
    q_hipv2_2_age_home "Can you tell us, which of these categories do you think best describes when your home or building was built?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.AGE_HOME"
    a_1 "2001 TO PRESENT"
    a_2 "1981 TO 2000"
    a_3 "1961 to 1980"
    a_4 "1941 to 1960"
    a_5 "1940 OR BEFORE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_enter_length_reside "How long have you lived in this home?  ", :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_length_reside "LENGTH RESIDE: NUMBER (e.g., 5)", 
    :data_export_identifier=>"PREG_VISIT_2_2.LENGTH_RESIDE"
    a "NUMBER", :integer
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_length_reside, "==", :a_1

    q_hipv2_2_length_reside_units "LENGTH RESIDE: UNITS (e.g., months)", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.LENGTH_RESIDE_UNIT"
    a_1 "WEEKS"
    a_2 "MONTHS"
    a_3 "YEARS"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_length_reside, "==", :a_1

    label "Now I'm going to ask you about how your home is heated and cooled."

    q_hipv2_2_main_heat "Which of these types of heat sources best describes the <U>main</U> heating fuel source for your home?  
    <br><br><b>INTERVIEWER INSTRUCTION: </b><br>SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.MAIN_HEAT"
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

    q_hipv2_2_enter_main_heat_oth "OTHER MAIN HEATING FUEL SOURCE", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.MAIN_HEAT_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_main_heat, "==", :a_neg_5
   
    q_hipv2_2_heat2 "Are there any other types of heat you use regularly during the heating season 
    to heat your home?<br><br><b>INTERVIEWER INSTRUCTION: </b><br>- SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.<br><br>
    - PROBE: Do you have any space heaters, or any secondary method for heating your home?<br><br>
    SELECT ALL THAT APPLY.", :pick=>:any, 
    :data_export_identifier=>"PREG_VISIT_2_HEAT2_2.HEAT2"
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
    condition_A :q_hipv2_2_main_heat, "==", :a_1
    condition_B :q_hipv2_2_main_heat, "==", :a_2
    condition_C :q_hipv2_2_main_heat, "==", :a_3
    condition_D :q_hipv2_2_main_heat, "==", :a_4
    condition_E :q_hipv2_2_main_heat, "==", :a_5
    condition_F :q_hipv2_2_main_heat, "==", :a_6
    condition_G :q_hipv2_2_main_heat, "==", :a_7
    condition_H :q_hipv2_2_main_heat, "==", :a_8

    q_hipv2_2_enter_heat2_oth "OTHER SECONDARY HEATING FUEL SOURCE", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_HEAT2_2.HEAT2_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_hipv2_2_heat2, "==", :a_neg_5
    condition_B :q_hipv2_2_heat2, "!=", :a_neg_1
    condition_C :q_hipv2_2_heat2, "!=", :a_neg_2            

    q_hipv2_2_cooling "Does your home have any type of cooling or air conditioning besides fans? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.COOLING"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_cool "Not including fans, which of the following kinds of cooling systems do you regularly use?
    <br><br>SELECT ALL THAT APPLY", :pick=>:any, 
     :data_export_identifier=>"PREG_VISIT_2_COOL_2.COOL"
    a_1 "Windows or wall air conditioners,"
    a_2 "Central air conditioning,"
    a_3 "Evaporative cooler (swamp cooler), or"
    a_4 "NO COOLING OR AIR CONDITIONING REGULARLY USED"
    a_neg_5 "Some other cooling system"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_cooling, "==", :a_1

    q_hipv2_2_enter_cool_oth "OTHER COOLING SYSTEM", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_COOL_2.COOL_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C and D"
    condition_A :q_hipv2_2_cool, "==", :a_neg_5
    condition_B :q_hipv2_2_cool, "!=", :a_4
    condition_C :q_hipv2_2_cool, "!=", :a_neg_1
    condition_D :q_hipv2_2_cool, "!=", :a_neg_2                  
    
    q_hipv2_2_time_stamp_6 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_6"
    a :datetime      

    label "Now I'd like to ask about the water in your home."

    q_hipv2_2_water_drink "What water source in your home do you use most of the time for drinking? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.WATER_DRINK"
    a_1 "Tap water,"
    a_2 "Filtered tap water,"
    a_3 "Bottled water, or"
    a_neg_5 "Some other source?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_enter_water_drink_oth "OTHER SOURCE OF DRINKING", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.WATER_DRINK_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_water_drink, "==", :a_neg_5

    q_hipv2_2_water_cook "What water source in your home is used most of the time for cooking?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.WATER_COOK"
    a_1 "Tap water,"
    a_2 "Filtered tap water,"
    a_3 "Bottled water, or"
    a_neg_5 "Some other source?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_enter_water_cook_oth "OTHER SOURCE OF COOKING WATER", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.WATER_COOK_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_water_cook, "==", :a_neg_5
    
    q_hipv2_2_time_stamp_7 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_7"
    a :datetime    

    label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the 
    ceiling or walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof, or floods."

    q_hipv2_2_water "<u>Since we last spoke with you</u>, have you seen any water damage inside your home? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.WATER"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_mold "<u>Since we last spoke with you</u>, have you seen any mold or mildew on walls or other surfaces other 
    than the shower or bathtub, inside your home? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.MOLD"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_room_mold "In which rooms have you seen the mold or mildew?<br><br><b>INTERVIEWER INSTRUCTION:</b><br>
    - PROBE: Any other rooms? 
    <br><br>SELECT ALL THAT APPLY", :pick=>:any,
    :data_export_identifier=>"PREG_VISIT_2_ROOM_MOLD_2.ROOM_MOLD"
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
    condition_A :q_hipv2_2_mold, "==", :a_1

    q_hipv2_2_enter_room_mold_oth "OTHER ROOMS WHERE MOLD OR MILDEW WAS SEEN", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_ROOM_MOLD_2.ROOM_MOLD_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv2_2_room_mold, "==", :a_neg_5
    condition_B :q_hipv2_2_room_mold, "!=", :a_neg_1
    condition_C :q_hipv2_2_room_mold, "!=", :a_neg_2            

    q_hipv2_2_time_stamp_8 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_8"
    a :datetime


    label "The next few questions ask about any recent additions or renovations to your home."

    q_hipv2_2_prenovate2 "<u>Since we last spoke with you</u>, have any additions been built onto your home to make 
    it bigger or renovations or other construction been done in your home? Include only major projects. Do not count 
    smaller projects, such as painting, wallpapering, carpeting or re-finishing floors.", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.PRENOVATE2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_prenovate2_room "Which rooms were renovated? <br><br><b>INTERVIEWER INSTRUCTION:</b><br>- PROBE: Any others?<br><br>
    SELECT ALL THAT APPLY", :pick=>:any, 
    :data_export_identifier=>"PREG_VISIT_2_PRENOVATE_ROOM_2.PRENOVATE2_ROOM"
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
    condition_A :q_hipv2_2_prenovate2, "==", :a_1

    q_hipv2_2_enter_prenovate2_room_oth "OTHER ROOMS THAT WERE RENOVATED", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_PRENOVATE_ROOM_2.PRENOVATE2_ROOM_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_hipv2_2_prenovate2_room, "==", :a_neg_5
    condition_B :q_hipv2_2_prenovate2_room, "!=", :a_neg_1
    condition_C :q_hipv2_2_prenovate2_room, "!=", :a_neg_2
    
    q_hipv2_2_pdecorate2 "<u>Since we last spoke with you</u>, were any smaller projects done in your home, 
    such as painting, wallpapering, refinishing floors, or installing new carpet?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.PDECORATE2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_hipv2_2_pdecorate2_room "In which rooms were these smaller projects done? <br><br><b>INTERVIEWER INSTRUCTION:</b>
    <br> -PROBE:Any others?<br><br>
    SELECT ALL THAT APPLY", :pick=>:any, 
    :data_export_identifier=>"PREG_VISIT_2_PDECORATE2_ROOM_2.PDECORATE2_ROOM"
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
    condition_A :q_hipv2_2_pdecorate2, "==", :a_1
    
    q_hipv2_2_enter_pdecorate2_room_oth "OTHER ROOMS WHERE SMALLER PROJECTS WERE DONE", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_PDECORATE2_ROOM_2.PDECORATE2_ROOM_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and (B and C)"
    condition_A :q_hipv2_2_pdecorate2_room, "==", :a_neg_5
    condition_B :q_hipv2_2_pdecorate2_room, "!=", :a_neg_1
    condition_C :q_hipv2_2_pdecorate2_room, "!=", :a_neg_2
  end
  section "EMPLOYMENT", :reference_identifier=>"prepregnancy_visit_2_v20" do

    q_TIME_STAMP_9 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_9"
    a :datetime
    
    label "Now, I’d like to ask some questions about your current employment status."
    
    label "The next questions may be similar to those asked the last time we spoke, but we are asking them again 
    because sometimes the answers change. "
    
    q_hipv2_2_working "Are you currently working at any full or part time jobs?", 
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.WORKING"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW" 
    
    q_hipv2_2_hours "Approximately how many hours each week are you working?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.HOURS"
    a_1 "NUMBER OF HOURS (double check if > 60)", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_working, "==", :a_1

    q_hipv2_2_shift_work "Do you work shifts that starts after 2 pm?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.SHIFT_WORK"
    a_1 "YES"
    a_2 "NO"
    a_3 "SOMETIMES"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_working, "==", :a_1
  end  
  section "SOCIAL SUPPORT", :reference_identifier=>"prepregnancy_visit_2_v20" do

    q_TIME_STAMP_10 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_10"
    a :datetime
    
    label "The following questions ask about your feelings and thoughts <u>during the last month</u>. For the following questions, 
    please refer to the card and choose the answer that best describes your life now.<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>
    - SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT"
    
    q_LISTEN "Is there someone available to you whom you can count on to listen to you when you need to talk? Would you say...",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.LISTEN"
    a_1 "NONE OF THE TIME"
    a_2 "A LITTLE OF THE TIME"
    a_3 "SOME OF THE TIME"
    a_4 "MOST OF THE TIME"
    a_5 "ALL OF THE TIME"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_ADVICE "Is there someone available to give you good advice about a problem?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.ADVICE"
    a_1 "NONE OF THE TIME"
    a_2 "A LITTLE OF THE TIME"
    a_3 "SOME OF THE TIME"
    a_4 "MOST OF THE TIME"
    a_5 "ALL OF THE TIME"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_AFFECTION "Is there someone available to you who shows you love and affection?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.AFFECTION"
    a_1 "NONE OF THE TIME"
    a_2 "A LITTLE OF THE TIME"
    a_3 "SOME OF THE TIME"
    a_4 "MOST OF THE TIME"
    a_5 "ALL OF THE TIME"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_DAILY_HELP "Is there someone available to help you with daily chores?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.DAILY_HELP"
    a_1 "NONE OF THE TIME"
    a_2 "A LITTLE OF THE TIME"
    a_3 "SOME OF THE TIME"
    a_4 "MOST OF THE TIME"
    a_5 "ALL OF THE TIME"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_EMOT_SUPPORT "Can you count on anyone to provide you with emotional support 
    (talking over problems or helping you make a difficult decision)?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.EMOT_SUPPORT"
    a_1 "NONE OF THE TIME"
    a_2 "A LITTLE OF THE TIME"
    a_3 "SOME OF THE TIME"
    a_4 "MOST OF THE TIME"
    a_5 "ALL OF THE TIME"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_AMT_SUPPORT "Do you have as much contact as you would like with someone you feel close to, someone in 
    whom you can trust and confide?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_2.AMT_SUPPORT"
    a_1 "NONE OF THE TIME"
    a_2 "A LITTLE OF THE TIME"
    a_3 "SOME OF THE TIME"
    a_4 "MOST OF THE TIME"
    a_5 "ALL OF THE TIME"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"    
  end
  section "HEALTH INSURANCE", :reference_identifier=>"prepregnancy_visit_2_v20" do

    q_TIME_STAMP_11 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_11"
    a :datetime   
    
    label "Now I’m going to switch the subject and ask about health insurance.  The next questions are similar to those asked 
    the last time we contacted you, but we are asking them again because sometimes the answers change."
    
    q_hipv2_2_insure "Are you <U>currently</U> covered by any kind of health insurance or some other kind of health care plan? ", 
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.INSURE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    label "Now I'll read a list of different types of insurance. Please tell me which types you currently have. 
    Do you <u>currently</u> have. . ."
    
    label "<b>INTERVIEWER INSTRUCTIONS:</b> <br>
      RE-READ INTRODUCTORY STATEMENT (Do you <u>currently</u> have…) AS NEEDED"

    q_hipv2_2_ins_employ "Insurance through an employer or union either through yourself or another family member? ", 
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.INS_EMPLOY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_insure, "==", :a_1

    q_hipv2_2_ins_medicaid "Medicaid or any government-assistance plan for those with low incomes or a disability?<br><br>
      <b>INTERVIEWER INSTRUCTIONS:</b><br>- PROVIDE EXAMPLES OF LOCAL MEDICAID PROGRAMS", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.INS_MEDICAID"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_insure, "==", :a_1      

    q_hipv2_2_ins_tricare "TRICARE, VA, or other military health care? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.INS_TRICARE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_insure, "==", :a_1      

    q_hipv2_2_ins_ihs "Indian Health Service? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.INS_IHS"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_insure, "==", :a_1      

    q_hipv2_2_ins_medicaire "Medicare, for people with certain disabilities? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.INS_MEDICARE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_insure, "==", :a_1
    
    q_hipv2_2_ins_oth "Any other type of health insurance or health coverage plan? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.INS_OTH"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_insure, "==", :a_1    
  end
  
  section "TRACING QUESTIONS", :reference_identifier=>"prepregnancy_visit_v20" do  
    q_hipv2_2_time_stamp_12 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_12"
    a :datetime

    label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember 
    that all the information you provide is confidential and will not be provided to anyone outside the National Children’s Study."

# TODO
    # PROGRAMMER INSTRUCTIONS: 
    # • ASK COMM_EMAIL ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED; 
    # • ELSE SKIP TO HAVE_EMAIL

    q_hipv2_2_comm_email "When we last spoke, we asked questions about communicating with you through your personal email. 
    Have your preferences regarding contacting you via personal email changed since then?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.COMM_EMAIL"
    a_1 "YES"
    a_2 "NO"
    a_3 "DON'T REMEMBER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_have_email "So that I make sure that I have your latest information, do you have an email address?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.HAVE_EMAIL"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule => "A or B or C"
    condition_A :q_hipv2_2_comm_email, "==", :a_3
    condition_B :q_hipv2_2_comm_email, "==", :a_neg_1
    condition_C :q_hipv2_2_comm_email, "==", :a_neg_2  
    
    q_hipv2_2_have_email_alternative "Do you have an email address?", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.HAVE_EMAIL"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule => "A"
    condition_A :q_hipv2_2_comm_email, "==", :a_1

    q_hipv2_2_email_2 "May we use your personal email address to make future study appointments or send appointment reminders?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.EMAIL_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv2_2_have_email, "==", :a_1
    condition_B :q_hipv2_2_have_email_alternative, "==", :a_1      

    q_hipv2_2_email_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.EMAIL_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv2_2_have_email, "==", :a_1
    condition_B :q_hipv2_2_have_email_alternative, "==", :a_1

    q_hipv2_2_enter_email "What is the best email address to reach you?", :pick=>:one, 
    :help_text=>"EXAMPLE OF VALID EMAIL ADDRESS SUCH AS MARYJANE@EMAIL.COM", 
    :data_export_identifier=>"PREG_VISIT_2_2.EMAIL"
    a_1 "ENTER E-MAIL ADDRESS:", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv2_2_have_email, "==", :a_1
    condition_B :q_hipv2_2_have_email_alternative, "==", :a_1   
    
    q_hipv2_2_comm_cell "<u>At our last contact we asked questions about</u> communicating with you through your personal cell phone. 
    Have your preferences regarding contacting you via cell phone changed since then? ", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.COMM_CELL"
    a_1 "YES"
    a_2 "NO"
    a_3 "DON'T REMEMBER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_cell_phone_1 "So that I make sure that I have your latest information, do you have a personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule => "A or B or C"
    condition_A :q_hipv2_2_comm_cell, "==", :a_3
    condition_B :q_hipv2_2_comm_cell, "==", :a_neg_1
    condition_C :q_hipv2_2_comm_cell, "==", :a_neg_2  
    
    q_hipv2_2_cell_phone_1_alternative "Do you have a personal cell phone?", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule => "A"
    condition_A :q_hipv2_2_comm_email, "==", :a_1

    q_hipv2_2_cell_phone_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_cell_phone_1, "==", :a_1
   
    q_hipv2_2_cell_phone_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_cell_phone_1, "==", :a_1      

    q_hipv2_2_cell_phone_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_4"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_cell_phone_3, "==", :a_1

    q_hipv2_2_enter_cell_phone "What is your personal cell phone number (XXXXXXXXXX)?", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE"
    a_1 "PHONE NUMBER", :string
    a_neg_7 "PARTICIPANT HAS NO CELL PHONE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_hipv2_2_time_stamp_13 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_13"
    a :datetime
    
    q_hipv2_2_comm_contact "Sometimes if people move or change their telephone number, we have difficulty reaching them. At our 
    last visit, we asked for contact information for two friends or relatives not living with you who would know where you could be 
    reached in case we have trouble contacting you. Has that information changed since our last visit?", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.COMM_CONTACT"
    a_1 "YES"
    a_2 "NO"
    a_3 "DON'T REMEMBER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_text_contact_1 "Could I have the name of a friend or relative not currently living with you who should know where you could 
    be reached in case we have trouble contacting you?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_comm_contact, "==", :a_1   
    
    q_hipv2_2_text_alternative_contact_1 "So that I can make sure I have your latest information, could I have the name of a friend 
    or relative not currently living with you who should know where you could be reached in case we have trouble 
    contacting you?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B"
    condition_A :q_hipv2_2_comm_contact, "!=", :a_1
    condition_B :q_hipv2_2_comm_contact, "!=", :a_2 

    q_hipv2_2_contact_fname_1 "What is the person's first name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_FNAME_1"
    a_1 "FIRST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv2_2_text_contact_1, "==", :a_1
    condition_B :q_hipv2_2_text_alternative_contact_1, "==", :a_1
    
    q_hipv2_2_contact_lname_1 "What is the person's last name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_LNAME_1"
    a_1 "LAST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv2_2_text_contact_1, "==", :a_1
    condition_B :q_hipv2_2_text_alternative_contact_1, "==", :a_1
    
    q_hipv2_2_contact_relate_1 "What is his/her relationship to you?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE_1"
    a_1 "MOTHER/FATHER"
    a_2 "BROTHER/SISTER"
    a_3 "AUNT/UNCLE"
    a_4 "GRANDPARENT"
    a_5 "NEIGHBOR"
    a_6 "FRIEND"
    a_neg_5 "OTHER"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv2_2_text_contact_1, "==", :a_1
    condition_B :q_hipv2_2_text_alternative_contact_1, "==", :a_1
    
    q_hipv2_2_enter_contact_relate1_oth "OTHER RELATIONSHIP OF CONTACT", :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE1_OTH"      
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_contact_relate_1, "==", :a_neg_5
    
    q_hipv2_2_enter_contact_addr_1 "What is his/her address?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>- PROMPT AS NEEDED TO COMPLETE INFORMATION", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_hipv2_2_text_contact_1, "==", :a_1
    condition_B :q_hipv2_2_text_alternative_contact_1, "==", :a_1    

    q_hipv2_2_c_addr1_1 "ADDRESS 1 - STREET/PO BOX", :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR1_1"  
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_1, "==", :a_1

    q_hipv2_2_c_addr2_1 "ADDRESS 2", :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR2_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_1, "==", :a_1

    q_hipv2_2_c_unit_1 "UNIT", :data_export_identifier=>"PREG_VISIT_2_2.C_UNIT_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_1, "==", :a_1

    q_hipv2_2_c_city_1 "CITY", :data_export_identifier=>"PREG_VISIT_2_2.C_CITY_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_1, "==", :a_1

    q_hipv2_2_c_state_1 "STATE", :display_type=>"dropdown", :data_export_identifier=>"PREG_VISIT_2_2.C_STATE_1"
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
    condition_A :q_hipv2_2_enter_contact_addr_1, "==", :a_1

    q_hipv2_2_c_zipcode_1 "ZIP CODE", :data_export_identifier=>"PREG_VISIT_2_2.C_ZIPCODE_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_1, "==", :a_1

    q_hipv2_2_c_zip4_1 "ZIP+4", :data_export_identifier=>"PREG_VISIT_2_2.C_ZIP4_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_1, "==", :a_1
    
    
    q_hipv2_2_enter_contact_phone_1 "What is his/her telephone number (XXXXXXXXXX)?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>- IF CONTACT HAS NO TELEPHONE ASK FOR TELEPHONE NUMBER WHERE HE/SHE RECEIVES CALLS", 
    :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_PHONE_1"
    a_1 "PHONE NUMBER", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "CONTACT HAS NO TELEPHONE"

    label "Now I’d like to collect information on a second contact who does not currently live with you. What is this person’s name?"

    q_hipv2_2_enter_contact_2 "What is the person's name?<br><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "NO SECOND CONTACT PROVIDED"

    q_hipv2_2_contact_fname_2 "What is the person's first name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_FNAME_2"
    a_1 "FIRST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_2, "==", :a_1

    q_hipv2_2_contact_lname_2 "What is the person's last name?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>
    - IF PARTICIPANT DOES NOT WANT TO PROVIDE NAME OF CONTACT ASK FOR INITIALS<br>- CONFIRM SPELLING OF FIRST AND LAST NAMES", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_LNAME_2"
    a_1 "LAST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_2, "==", :a_1      

    q_hipv2_2_contact_relate_2 "What is his/her relationship to you?", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE_2"
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
    condition_A :q_hipv2_2_enter_contact_2, "==", :a_1

    q_hipv2_2_enter_contact_relate2_oth "OTHER RELATIONSHIP OF SECOND CONTACT", :pick=>:one, 
    :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE_2_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_hipv2_2_contact_relate_2, "==", :a_neg_5
    
    q_hipv2_2_enter_contact_addr_2 "What is his/her address?<br><br>
    <b>INTERVIEWER INSTRUCTIONS:</b><br>- PROMPT AS NEEDED TO COMPLETE INFORMATION", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_hipv2_2_c_addr1_2 "ADDRESS 1 - STREET/PO BOX", 
    :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR1_2"  
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_2, "==", :a_1

    q_hipv2_2_c_addr2_2 "ADDRESS 2", 
    :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR2_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_2, "==", :a_1

    q_hipv2_2_c_unit_2 "UNIT", :data_export_identifier=>"PREG_VISIT_2_2.C_UNIT_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_2, "==", :a_1

    q_hipv2_2_c_city_2 "CITY", :data_export_identifier=>"PREG_VISIT_2_2.C_CITY_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_2, "==", :a_1

    q_hipv1_c_state_2 "STATE", :display_type=>"dropdown", 
    :data_export_identifier=>"PREG_VISIT_2_2.C_STATE_2"
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
    condition_A :q_hipv2_2_enter_contact_addr_2, "==", :a_1

    q_hipv2_2_c_zipcode_2 "ZIP CODE", :data_export_identifier=>"PREG_VISIT_2_2.C_ZIPCODE_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_2, "==", :a_1

    q_hipv2_2_c_zip4_2 "ZIP+4", :data_export_identifier=>"PREG_VISIT_2_2.C_ZIP4_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_hipv2_2_enter_contact_addr_2, "==", :a_1
    
    q_hipv2_2_enter_contact_phone_2 "What is his/her telephone number (XXXXXXXXXX)?<br><br>
    <b>INTERVIEWER INSTRUCTION:</b><br>- IF CONTACT HAS NO TELEPHONE ASK FOR TELEPHONE NUMBER WHERE HE/SHE RECEIVES CALLS", 
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_PHONE_2"
    a_1 "PHONE NUMBER", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "CONTACT HAS NO TELEPHONE"
    
    label "Thank you for participating in the National Children’s Study and for taking the time to answer our questions. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_2_2.END"
    
    q_hipv1_time_stamp_14 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_14"
    a :datetime        
  end
  
end