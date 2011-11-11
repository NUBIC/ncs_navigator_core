survey "INS_QUE_PregVisit2_INT_EHPBHI_P2_V2.0" do
  section "CAPI", :reference_identifier=>"prepregnancy_visit_2_v20" do

    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    label "Thank you for agreeing to participate in the National Children’s Study. This interview will take about 20 minutes 
    to complete. Your answers are important to us. There are no right or wrong answers. We will ask you questions about yourself, 
    your health and pregnancy, your feelings and attitudes, and where you live. You can skip over any question or stop the 
    interview at any time. We will keep everything that you tell us confidential. First, we’d like to make sure we have your 
    correct name and birth date."
    
    q_prepopulated_name "Name:"
    a :string

#     TODO - the name should be pre-populated
    q_name_confirm "Is that your name? ", 
    :data_export_identifier=>"PREG_VISIT_2_2.NAME_CONFIRM", :pick=>:one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    #don't have the corresponding identifier
    group "Participant information" do
      dependency :rule=>"A"
      condition_A :q_name_confirm, "!=", :a_1

      label "What is your full name?",
      :help_text => "If participant refuses to provide information, re-state confidentiality protections, 
      ask for initials or some other name she would like to be called. Confirm spelling of first 
      name if not previously collected and of last name for all participants."

      q_r_fname "First name", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.R_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_r_lname "Last name", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.R_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    # TODO:
    # PROGRAMMER INSTRUCTION:
    # • PRELOAD PARTICIPANT’S DOB IF COLLECTED PREVIOUSLY
    # • IF RESPONSE = YES, SET PERSON_DOB TO KNOWN VALUE

    q_prepopulated_date_of_birth "[Participant's date of birth as MM/DD/YYYY]"
    a :string

    q_dob_confirm "Is this your birth date?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.DOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_confirmed_dob "What is your date of birth?",
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and that dob is 
    required to determine eligibility. If response was determined to be invalid, ask question again and probe for valid response.",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.PERSON_DOB"
    a_date :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_dob_confirm, "!=", :a_1    

    q_age_elig "Is participant age-eligible? ", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.AGE_ELIG"
    a_1 "Participant is age eligible"
    a_2 "Participant is younger than age of majority"
    a_3 "Participant is over 49"
    a_4 "Age eligibility is unknown"

    group "Not eligible" do
      dependency :rule=>"A"
      condition_A :q_age_elig, "==", :a_2
      
      label "Participant is not eligible"
    
      label "Thank you for participating in the National Children’s Study and for taking the time to answer our questions. 
       This concludes the interview portion of our visit.", 
       :data_export_identifier=>"PREG_VISIT_2_2.END"
    end

    label "Case for supervisor review at SC to confirm age eligibility post-interview"
    dependency :rule => "A or B"
    condition_A :q_dob_confirm, "==", :a_neg_1
    condition_B :q_dob_confirm, "==", :a_neg_2
  end
  section "Current pregnancy information", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Current pregnancy information" do
      dependency :rule=>"A"
      condition_A :q_age_elig, "!=", :a_2
          
      q_time_stamp_2 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime"

      # PROGRAMMER INSTRUCTIONS: 
      # • IF PARTICIPANT HAS REPORTED BEING PREGNANT WITH MULTIPLES FILL IN “BABIES’ AS APPROPRIATE THROUGHOUT INSTRUMENT

      label "First, I’d like to update some information about your current pregnancy."

      q_pregnant "The first questions ask about how your pregnancy is progressing. First, are you still pregnant?", 
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.PREGNANT"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      
      label "Thank you for participating in the National Children’s Study and for taking the time to answer our questions. 
      This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_2_2.END"
      dependency :rule=> "A or B" 
      condition_A :q_pregnant, "==", :a_neg_1
      condition_B :q_pregnant, "==", :a_neg_2
    end
    group "Loss information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_2

      q_time_stamp_3 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_3"
      a :datetime, :custom_class => "datetime"

      label "I’m so sorry for your loss. I know this can be a difficult time.",
      :help_text => "Use social cues and professional judgment in response. 
      If sc has pregnancy loss information to disseminate, offer to participant"
    
      q_loss_info "Interviewer answered question: did participant request additional information on 
      coping with pregnancy loss?", :pick => :one, 
      :data_export_identifier=>"PREG_VISIT_2_2.LOSS_INFO"
      a_1 "Yes"
      a_2 "No"
    
      label "Again, I’d like to say how sorry I am for your loss. We’ll send the information packet you requested as soon as possible.
      Please accept our condolences. Thank you for your time.",
      :help_text => "If loss of pregnancy, end interview. Do not administer SAQs.", :data_export_identifier=>"PREG_VISIT_2_2.END_INFO"
      dependency :rule=> "A"
      condition_A :q_loss_info, "==", :a_1
    
      label "Again, I’d like to say how sorry I am for your loss. Please accept our condolences. Thank you for your time.",
      :help_text => "If loss of pregnancy, end interview. Do not administer SAQs.", 
      :data_export_identifier=>"PREG_VISIT_2_2.END_INFO"
      dependency :rule=> "A"
      condition_A :q_loss_info, "==", :a_2    
    
      label "We'll send the information packet you requested as soon as possible."
      dependency :rule=>"A"
      condition_A :q_loss_info, "==", :a_2
    end
    group "Pregnancy information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
          
      q_due_date "What is your current due date?", :pick => :one,
      :help_text => "If response was determined to be invalid, ask question again and probe for valid response. Answer can not be (1) on or before 'TODAY' 
      or (2) more than 9 months after 'TODAY'. If response was determined to be invalid, ask question again and probe for valid response",
      :data_export_identifier=>"PREG_VISIT_2_2.DUE_DATE"
      a_date :string, :custom_class => "date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # PROGRAMMER INSTRUCTIONS:
      # • CHECK REPORTED DUE DATE AGAINST CURRENT DATE; DISPLAY APPROPRIATE MESSAGE:
      # o IF DATE IS MORE THAN 9 MONTHS AFTER CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT IS MORE THAN 9 MONTHS FROM TODAY. RE-ENTER DATE.”
      # o IF DATE IS MORE THAN 1 MONTH BEFORE CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT OCCURRED MORE THAN A MONTH BEFORE TODAY. RE-ENTER DATE.”
      # o IF VALID DUE DATE WAS PROVIDED, SET DUE_DATE = YYYYMMDD AS REPORTED; GO TO DATE_KNOWN
    
      q_DATE_KNOWN "Interviewer completed question: did participant give date?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.DATE_KNOWN"
      a_1 "Participant gave complete date"
      a_2 "Participant gave partial date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      
      q_BPLAN_CHANGE "Has the place where you plan to deliver your [baby/babies] changed since we last spoke with you?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.BPLAN_CHANGE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
 
      q_BIRTH_PLAN_OLD "So we make sure we have the correct information, where do you plan to deliver your {baby/babies}?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLAN"
      a_1 "In a hospital"
      a_2 "A birthing center"
      a_3 "At home, or"
      a_4 "Some other place?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_BPLAN_CHANGE, "==", :a_2
    
      q_birth_plan "Where do you plan to deliver your {baby/babies}?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLAN"
      a_1 "In a hospital"
      a_2 "A birthing center"
      a_3 "At home, or"
      a_4 "Some other place?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_BPLAN_CHANGE, "!=", :a_2    
    end
    group "Birth place address" do
      dependency :rule=>"A or B or C"
      condition_A :q_birth_plan, "==", :a_1
      condition_B :q_birth_plan, "==", :a_2
      condition_C :q_birth_plan, "==", :a_4        

      label "What is the name and address of the place where you are planning to deliver your [baby/babies]?"

      q_birth_place "NAME OF BIRTH HOSPITAL/BIRTHING CENTER",
      :pick =>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLACE"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_address_1 "Address 1 - street/PO Box", 
      :pick =>:one,        
      :data_export_identifier=>"PREG_VISIT_2_2.B_ADDRESS_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_address_2 "Address 2", 
      :pick =>:one,        
      :data_export_identifier=>"PREG_VISIT_2_2.B_ADDRESS_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_city "City", 
      :pick =>:one,        
      :data_export_identifier=>"PREG_VISIT_2_2.B_CITY"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_state "State", :display_type=>"dropdown", 
      :pick =>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.B_STATE"
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

      q_b_zipcode "ZIP Code", 
      :pick =>:one,        
      :data_export_identifier=>"PREG_VISIT_2_2.B_ZIPCODE"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
    end

    q_USE_PR_LOG "Are you using the Pregnancy Health Care Log? This is the booklet that you or your health care 
    provider (doctor, midwife, nurse, etc.) uses to record information about your medical visits.",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.USE_PR_LOG"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=> "A"
    condition_A :q_pregnant, "==", :a_1
    
    q_REASON_NO_PR_LOG "Is that because...",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.REASON_NO_PR_LOG"
    a_1 "You haven't had a medical visit since our last interview,"
    a_2 "You've misplaced the log,"
    a_3 "You've forgotten to bring it to your medical visits"
    a_4 "The log was too much trouble to complete, or"
    a_5 "The log was too difficult to understand"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_2
    
    q_REASON_NO_PR_LOG_OTH "Other: specify",
    :data_export_identifier=>"PREG_VISIT_2_2.REASON_NO_PR_LOG_OTH"
    a :string
    dependency :rule=>"A"
    condition_A :REASON_NO_PR_LOG, "==", :a_neg_5    

    label "We’ll get another Pregnancy Health Care Log in the mail to you today."
    dependency :rule=>"A"
    condition_A :REASON_NO_PR_LOG, "==", :a_2

    label "This information is very important to the study. Please keep the log in a safe place and 
    bring the log with you to all of your medical visits. "
    dependency :rule=>"A or B or C or D"
    condition_A :REASON_NO_PR_LOG, "==", :a_3
    condition_B :REASON_NO_PR_LOG, "==", :a_4
    condition_C :REASON_NO_PR_LOG, "==", :a_neg_1
    condition_D :REASON_NO_PR_LOG, "==", :a_neg_2

    group "Pregnancy log information" do
      dependency :rule=>"A"
      condition_A :q_USE_PR_LOG, "==", :a_1
            
      q_NUM_PROV_PR_LOG "How many health care providers have you seen since using this Pregnancy Health Care Log?",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.NUM_PROV_REC"
      a "Number of providers", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_NUM_PROV_REC "Of those providers that you have seen, how many providers have you recorded their contact 
      information such as address or phone number?",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.NUM_PROV_REC"
      a "Number of contacts", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      label "I am now going to ask some questions about visits to a doctor or other health care provider (doctor, midwife, 
      nurse, etc.). You may want to refer to the Pregnancy Health Care Log that you received as part of this study or to 
      any other personal record or calendar that you keep that would help you to remember the dates of these visits. If you 
      have this information available, please go and get it now."
    end
    
    label "I am now going to ask some questions about visits to a doctor or other health care provider (doctor, midwife, 
    nurse, etc.). You may want to refer to 
    any other personal record or calendar that you keep that would help you to remember the dates of these visits. If you 
    have this information available, please go and get it now."    
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "!=", :a_1
    
    q_DATE_VISIT "What was the date of your most recent doctor’s visit or checkup since you’ve become pregnant?",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_2_2.DATE_VISIT"
    a_date "Date", :string
    a_neg_7 "Have not had a visit"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=> "A"
    condition_A :q_pregnant, "==", :a_1    

    label "If you haven’t yet, please put a check mark in the box next to the visit you just told me about in your 
    Pregnancy Health Care Log"
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_1
    
    # PROGRAMMER INSTRUCTIONS: 
    #     • IF VALID DATE FOR DATE_VISIT IS PROVIDED, DISPLAY “At this visit or At”. OTHERWISE DISPLAY ‘”At”
    #     
    label "At this visit or at any time during your pregnancy, did the doctor or other health care provider tell 
    you that you have any of the following conditions?",
    :help_text => "Re-read introductory statement ({At this visit or at}/{At} any time during your pregnancy, did the doctor 
    or other health care provider tell you that you have any of the following conditions?) as needed"
    dependency :rule=> "A"
    condition_A :q_DATE_VISIT, "==", :a_date
    
    label "At any time during your pregnancy, did the doctor or other health care provider tell 
    you that you have any of the following conditions?",
    :help_text => "Re-read introductory statement ({At this visit or at}/{At} any time during your pregnancy, did the doctor 
    or other health care provider tell you that you have any of the following conditions?) as needed"
    dependency :rule=> "A"
    condition_A :q_DATE_VISIT, "!=", :a_date
    
    group "Additional information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1 

      q_diabetes_1 "Diabetes? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.DIABETES_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_highbp_preg "High blood pressure? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.HIGHBP_PREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_urine "Protein in your urine? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.URINE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_preeclamp "Preeclampsia or toxemia? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.PREECLAMP"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_early_labor "Early or premature labor? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.EARLY_LABOR"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_anemia "Anemia or low blood count? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.ANEMIA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_nausea "Severe nausea or vomiting (hyperemesis)? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.NAUSEA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_kidney "Bladder or kidney infection? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.KIDNEY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_rh_disease "Rh disease or isoimmunization? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.RH_DISEASE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_group_b "Infection with bacteria called Group B strep?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.GROUP_B"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_herpes "Infection with a Herpes virus? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.HERPES"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_vaginosis "Infection of the vagina with bacteria (bacterial vaginosis?)", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.VAGINOSIS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_oth_condition "Any other serious condition? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.OTH_CONDITION"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_condition_oth "Can you please specify the other serious conditions? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CONDITION_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_oth_condition, "==", :a_1 
    
      q_time_stamp_4 "Current date & time", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_4"
      a :datetime, :custom_class => "datetime"
    
      q_HOSPITAL "Since you’ve been pregnant, have you spent at least one night in the hospital?", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.HOSPITAL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Hospital information" do
      dependency :rule=>"A"
      condition_A :q_HOSPITAL, "==", :a_1    
      
      q_ADMIN_DATE "What was the admission date of your most recent hospital stay?",
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.ADMIN_DATE"
      a "Date", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      a_neg_7 "Have not been hospitalized overnight/not applicable"
     
      q_HOSP_NIGHTS "How many nights did you stay in the hospital during this hospital stay?",
      :help_text => "Confirm response",
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.HOSP_NIGHTS"
      a "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_DIAGNOSE "Did a doctor or other health care provider give you a diagnosis during this hospital stay?",
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.DIAGNOSE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_DIAGNOSE_2 "What was the diagnosis?",
      :help_text => "Probe for multiple responses. Select all that apply.",
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_DIAGNOSE_2_2.DIAGNOSE_2"
      a_1 "Dehydration"
      a_2 "Preterm labor"
      a_3 "Hyperemesis"
      a_4 "Preeclampsia"
      a_5 "Rupture of membranes"
      a_6 "Kidney disorder"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_DIAGNOSE, "==", :a_1    
 
      q_DIAGNOSIS_OTH "Other diagnosis", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_DIAGNOSE_2_2.DIAGNOSE_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_DIAGNOSE_2, "==", :a_neg_5
      condition_B :q_DIAGNOSE_2, "!=", :a_neg_1
      condition_C :q_DIAGNOSE_2, "!=", :a_neg_2
    end
    
    label "If you haven’t yet, please put a check mark in the box next to the visit you just told me about in your 
    Pregnancy Health Care Log."
    dependency :rule=>"A"
    condition_A :q_USE_PR_LOG, "==", :a_1
  end
  section "Housing characteristics", :reference_identifier=>"prepregnancy_visit_2_v20" do
    group "Housing characteristics" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_5"
      a :datetime, :custom_class => "datetime"           
    
      label "Now I’d like to find out more about your home and the area in which you live."
    
      q_RECENT_MOVE "Have you moved or changed your housing situation since we last spoke with you?", 
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.RECENT_MOVE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_own_home "Is your home…", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.OWN_HOME"
      a_1 "Owned or being bought by you or someone in your household"
      a_2 "Rented by you or someone in your household, or"
      a_3 "Occupied without payment of rent?"
      a_neg_5 "Some other arrangement"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=> "A or B"
      condition_A :q_RECENT_MOVE, "==", :a_1    
      condition_B :q_RECENT_MOVE, "==", :a_neg_2
      
      q_own_home_oth "Can you please specify your other home arrangement? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.OWN_HOME_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_own_home, "==", :a_neg_5
    
      q_age_home "Can you tell us, which of these categories do you think best describes when your home or building was built?",
      :help_text => "Show response options on card to participant", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.AGE_HOME"
      a_1 "2001 to present"
      a_2 "1981 to 2000"
      a_3 "1961 to 1980"
      a_4 "1941 to 1960"
      a_5 "1940 or before"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "How long have you lived in this home?"

      q_length_reside "Length reside: number (e.g., 5)", 
      :data_export_identifier=>"PREG_VISIT_2_2.LENGTH_RESIDE"
      a "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_length_reside_units "Length reside: units (e.g., months)", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.LENGTH_RESIDE_UNIT"
      a_1 "Weeks"
      a_2 "Months"
      a_3 "Years"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Now I'm going to ask you about how your home is heated and cooled."

      q_main_heat "Which of these types of heat sources best describes the main heating fuel source for your home?",
      :help_text => "Show response options on card to participant.", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.MAIN_HEAT"
      a_1 "Electric"
      a_2 "Gas - propane or LP"
      a_3 "Oil"
      a_4 "Wood"
      a_5 "Kerosene or diesel"
      a_6 "Coal or coke"
      a_7 "Solar energy"
      a_8 "Heat pump"
      a_9 "No heating source"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_main_heat_oth "Other main heating fuel source", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.MAIN_HEAT_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_main_heat, "==", :a_neg_5
   
      q_heat2 "Are there any other types of heat you use regularly during the heating season 
      to heat your home?",
      :help_text => "Show response options on card to participant. 
      Probe: Do you have any space heaters, or any secondary method for heating your home? 
      Select all that apply.", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_2_HEAT2_2.HEAT2"
      a_1 "Electric"
      a_2 "Gas - propane or LP"
      a_3 "Oil"
      a_4 "Wood"
      a_5 "Kerosene or diesel"
      a_6 "Coal or coke"
      a_7 "Solar energy"
      a_8 "Heat pump"
      a_9 "No other heating source"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C and D"
      condition_A :q_main_heat, "!=", :a_9
      condition_B :q_main_heat, "!=", :a_neg_5
      condition_C :q_main_heat, "!=", :a_neg_1
      condition_D :q_main_heat, "!=", :a_neg_2
      
      q_enter_heat2_oth "Other secondary heating fuel source", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_HEAT2_2.HEAT2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_heat2, "==", :a_neg_5
      condition_B :q_heat2, "!=", :a_neg_1
      condition_C :q_heat2, "!=", :a_neg_2            

      q_cooling "Does your home have any type of cooling or air conditioning besides fans? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.COOLING"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cool "Not including fans, which of the following kinds of cooling systems do you regularly use?",
      :help_text => "Select all that apply", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_2_COOL_2.COOL"
      a_1 "Windows or wall air conditioners,"
      a_2 "Central air conditioning,"
      a_3 "Evaporative cooler (swamp cooler), or"
      a_4 "No cooling or air conditioning regularly used"
      a_neg_5 "Some other cooling system"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_cooling, "==", :a_1

      q_enter_cool_oth "Other cooling system", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_COOL_2.COOL_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C and D"
      condition_A :q_cool, "==", :a_neg_5
      condition_B :q_cool, "!=", :a_4
      condition_C :q_cool, "!=", :a_neg_1
      condition_D :q_cool, "!=", :a_neg_2                  
    
      q_time_stamp_6 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_6"
      a :datetime, :custom_class => "datetime"      

      label "Now I'd like to ask about the water in your home."

      q_water_drink "What water source in your home do you use most of the time for drinking? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.WATER_DRINK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_water_drink_oth "Other source of drinking", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.WATER_DRINK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_water_drink, "==", :a_neg_5

      q_water_cook "What water source in your home is used most of the time for cooking?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.WATER_COOK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_water_cook_oth "Other source of cooking water", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.WATER_COOK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_water_cook, "==", :a_neg_5
    
      q_time_stamp_7 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_7"
      a :datetime, :custom_class => "datetime"    

      label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the 
      ceiling or walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof, or floods."

      q_water "Since we last spoke with you, have you seen any water damage inside your home? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.WATER"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_mold "Since we last spoke with you, have you seen any mold or mildew on walls or other surfaces other 
      than the shower or bathtub, inside your home? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.MOLD"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_room_mold "In which rooms have you seen the mold or mildew?",
      :help_text => "Probe: Any other rooms? Select all that apply", :pick=>:any,
      :data_export_identifier=>"PREG_VISIT_2_ROOM_MOLD_2.ROOM_MOLD"
      a_1 "Kitchen"
      a_2 "Living room"
      a_3 "Hall/landing"
      a_4 "Participant's bedroom"
      a_5 "Other bedroom"
      a_6 "Bathroom/toilet"
      a_7 "Basement"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_mold, "==", :a_1

      q_enter_room_mold_oth "Other rooms where mold or mildew was seen", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_ROOM_MOLD_2.ROOM_MOLD_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_room_mold, "==", :a_neg_5
      condition_B :q_room_mold, "!=", :a_neg_1
      condition_C :q_room_mold, "!=", :a_neg_2            

      q_time_stamp_8 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_8"
      a :datetime, :custom_class => "datetime"


    label "The next few questions ask about any recent additions or renovations to your home."

      q_prenovate2 "Since we last spoke with you, have any additions been built onto your home to make 
      it bigger or renovations or other construction been done in your home? Include only major projects. Do not count 
      smaller projects, such as painting, wallpapering, carpeting or re-finishing floors.", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.PRENOVATE2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_prenovate2_room "Which rooms were renovated?",
      :help_text => "Probe: Any others? Select all that apply", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_2_PRENOVATE_ROOM_2.PRENOVATE2_ROOM"
      a_1 "Kitchen"
      a_2 "Living room"
      a_3 "Hall/landing"
      a_4 "Participant's bedroom"
      a_5 "Other bedroom"
      a_6 "Bathroom/toilet"
      a_7 "Basement"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_prenovate2, "==", :a_1

      q_enter_prenovate2_room_oth "Other rooms that were renovated", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_PRENOVATE_ROOM_2.PRENOVATE2_ROOM_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_prenovate2_room, "==", :a_neg_5
      condition_B :q_prenovate2_room, "!=", :a_neg_1
      condition_C :q_prenovate2_room, "!=", :a_neg_2
    
      q_pdecorate2 "Since we last spoke with you, were any smaller projects done in your home, 
      such as painting, wallpapering, refinishing floors, or installing new carpet?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.PDECORATE2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_pdecorate2_room "In which rooms were these smaller projects done?",
      :help_text => "Probe: Any others? Select all that apply", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_2_PDECORATE2_ROOM_2.PDECORATE2_ROOM"
      a_1 "Kitchen"
      a_2 "Living room"
      a_3 "Hall/landing"
      a_4 "Participant's bedroom"
      a_5 "Other bedroom"
      a_6 "Bathroom/toilet"
      a_7 "Basement"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_pdecorate2, "==", :a_1
    
      q_enter_pdecorate2_room_oth "Other rooms where smaller projects were done", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_PDECORATE2_ROOM_2.PDECORATE2_ROOM_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and (B and C)"
      condition_A :q_pdecorate2_room, "==", :a_neg_5
      condition_B :q_pdecorate2_room, "!=", :a_neg_1
      condition_C :q_pdecorate2_room, "!=", :a_neg_2
    end
  end
  section "Employment", :reference_identifier=>"prepregnancy_visit_2_v20" do
    group "Employment" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_TIME_STAMP_9 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"
    
      label "Now, I’d like to ask some questions about your current employment status."
    
      label "The next questions may be similar to those asked the last time we spoke, but we are asking them again 
      because sometimes the answers change. "
    
      q_working "Are you currently working at any full or part time jobs?", 
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.WORKING"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know" 
    end
    group "Work information" do
      dependency :rule=>"A"
      condition_A :q_working, "==", :a_1
      
      q_hours "Approximately how many hours each week are you working?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.HOURS"
      a_1 "Number of hours (double check if > 60)", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_shift_work "Do you work shifts that starts after 2 pm?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.SHIFT_WORK"
      a_1 "Yes"
      a_2 "No"
      a_3 "Sometimes"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end  
  section "Social support", :reference_identifier=>"prepregnancy_visit_2_v20" do
    group "Social support" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_TIME_STAMP_10 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_10"
      a :datetime, :custom_class => "datetime"
    
      label "The following questions ask about your feelings and thoughts during the last month. For the following questions, 
      please refer to the card and choose the answer that best describes your life now.",
      :help_text => "Show response options on card to participant"
    
      q_LISTEN "Is there someone available to you whom you can count on to listen to you when you need to talk? Would you say...",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.LISTEN"
      a_1 "None of the time"
      a_2 "A little of the time"
      a_3 "Some of the time"
      a_4 "Most of the time"
      a_5 "All of the time"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_ADVICE "Is there someone available to give you good advice about a problem?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.ADVICE"
      a_1 "None of the time"
      a_2 "A little of the time"
      a_3 "Some of the time"
      a_4 "Most of the time"
      a_5 "All of the time"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_AFFECTION "Is there someone available to you who shows you love and affection?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.AFFECTION"
      a_1 "None of the time"
      a_2 "A little of the time"
      a_3 "Some of the time"
      a_4 "Most of the time"
      a_5 "All of the time"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_DAILY_HELP "Is there someone available to help you with daily chores?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.DAILY_HELP"
      a_1 "None of the time"
      a_2 "A little of the time"
      a_3 "Some of the time"
      a_4 "Most of the time"
      a_5 "All of the time"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_EMOT_SUPPORT "Can you count on anyone to provide you with emotional support 
      (talking over problems or helping you make a difficult decision)?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.EMOT_SUPPORT"
      a_1 "None of the time"
      a_2 "A little of the time"
      a_3 "Some of the time"
      a_4 "Most of the time"
      a_5 "All of the time"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_AMT_SUPPORT "Do you have as much contact as you would like with someone you feel close to, someone in 
      whom you can trust and confide?",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_2_2.AMT_SUPPORT"
      a_1 "None of the time"
      a_2 "A little of the time"
      a_3 "Some of the time"
      a_4 "Most of the time"
      a_5 "All of the time"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Health insurance", :reference_identifier=>"prepregnancy_visit_2_v20" do
    group "Health insurance" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_TIME_STAMP_11 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_11"
      a :datetime, :custom_class => "datetime"   
    
      label "Now I’m going to switch the subject and ask about health insurance.  The next questions are similar to those asked 
      the last time we contacted you, but we are asking them again because sometimes the answers change."
    
      q_insure "Are you currently covered by any kind of health insurance or some other kind of health care plan? ", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.INSURE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Additional information" do
      dependency :rule=>"A"
      condition_A :q_insure, "==", :a_1
            
      label "Now I'll read a list of different types of insurance. Please tell me which types you currently have. 
      Do you currently have...",
      :help_text=> "Re-read introductory statement (Do you <u>currently</u> have...) as needed"

      q_ins_employ "Insurance through an employer or union either through yourself or another family member? ", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_medicaid "Medicaid or any government-assistance plan for those with low incomes or a disability?",
      :help_text => "Provide examples of local medicaid programs", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_tricare "TRICARE, VA, or other military health care? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_ihs "Indian Health Service? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_medicaire "Medicare, for people with certain disabilities? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.INS_MEDICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_ins_oth "Any other type of health insurance or health coverage plan? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Tracing questions", :reference_identifier=>"prepregnancy_visit_v20" do 
    group "Tracing questions" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
       
      q_time_stamp_12 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_12"
      a :datetime, :custom_class => "datetime"

      label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember 
      that all the information you provide is confidential and will not be provided to anyone outside the National Children’s Study."

      # TODO
      # PROGRAMMER INSTRUCTIONS: 
      # • ASK COMM_EMAIL ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED; 
      # • ELSE SKIP TO HAVE_EMAIL

      q_comm_email "When we last spoke, we asked questions about communicating with you through your personal email. 
      Have your preferences regarding contacting you via personal email changed since then?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.COMM_EMAIL"
      a_1 "Yes"
      a_2 "No"
      a_3 "Don't remember"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_have_email "So that I make sure that I have your latest information, do you have an email address?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.HAVE_EMAIL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A or B or C"
      condition_A :q_comm_email, "==", :a_3
      condition_B :q_comm_email, "==", :a_neg_1
      condition_C :q_comm_email, "==", :a_neg_2  
    
      q_have_email_alternative "Do you have an email address?", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.HAVE_EMAIL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_comm_email, "==", :a_1
    end 
    group "Email information" do
      dependency :rule=>"A or B"
      condition_A :q_have_email, "==", :a_1
      condition_B :q_have_email_alternative, "==", :a_1   
      
      q_email_2 "May we use your personal email address to make future study appointments or send appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.EMAIL_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_email_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.EMAIL_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_email "What is the best email address to reach you?", :pick=>:one, 
      :help_text=>"Example of valid email address such as maryjane@email.com", 
      :data_export_identifier=>"PREG_VISIT_2_2.EMAIL"
      a_1 "Enter e-mail address:", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Phone information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_comm_cell "At our last contact we asked questions about communicating with you through your personal cell phone. 
      Have your preferences regarding contacting you via cell phone changed since then? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.COMM_CELL"
      a_1 "Yes"
      a_2 "No"
      a_3 "Don't remember"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cell_phone_1 "So that I make sure that I have your latest information, do you have a personal cell phone?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A or B or C"
      condition_A :q_comm_cell, "==", :a_3
      condition_B :q_comm_cell, "==", :a_neg_1
      condition_C :q_comm_cell, "==", :a_neg_2  
    
      q_cell_phone_1_alt "Do you have a personal cell phone?", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_comm_cell, "==", :a_1
    end
    group "Cell phone information" do
      dependency :rule=>"A or B"
      condition_A :q_cell_phone_1, "==", :a_1
      condition_B :q_cell_phone_1_alt, "==", :a_1
      
      q_cell_phone_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
   
      q_cell_phone_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cell_phone_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE_4"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_cell_phone_3, "==", :a_1

      q_enter_cell_phone "What is your personal cell phone number (XXXXXXXXXX)?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.CELL_PHONE"
      a_1 "Phone number", :string
      a_neg_7 "Participant has no cell phone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Additional information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
          
      q_time_stamp_13 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_13"
      a :datetime, :custom_class => "datetime"
    
      q_comm_contact "Sometimes if people move or change their telephone number, we have difficulty reaching them. At our 
      last visit, we asked for contact information for two friends or relatives not living with you who would know where you could be 
      reached in case we have trouble contacting you. Has that information changed since our last visit?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.COMM_CONTACT"
      a_1 "Yes"
      a_2 "No"
      a_3 "Don't remember"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_1 "Could I have the name of a friend or relative not currently living with you who should know where you could 
      be reached in case we have trouble contacting you?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_comm_contact, "==", :a_1   

      q_contact_1_alt "So that I can make sure I have your latest information, could I have the name of a friend 
      or relative not currently living with you who should know where you could be reached in case we have trouble 
      contacting you?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B"
      condition_A :q_comm_contact, "!=", :a_1
      condition_B :q_comm_contact, "!=", :a_2
    end
    group "Contact information" do
      dependency :rule=>"A or B"
      condition_A :q_contact_1, "==", :a_1
      condition_B :q_contact_1_alt, "==", :a_1

      q_contact_fname_1 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of the first name", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_FNAME_1"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_lname_1 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of the last name", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_LNAME_1"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_contact_relate_1 "What is his/her relationship to you?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE_1"
      a_1 "Mother/father"
      a_2 "Brother/sister"
      a_3 "Aunt/uncle"
      a_4 "Grandparent"
      a_5 "Neighbor"
      a_6 "Friend"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_enter_contact_relate1_oth "Other relationship of contact", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE1_OTH"      
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_contact_relate_1, "==", :a_neg_5
    
      label "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_c_addr1_1 "Address 1 - street/PO Box", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR1_1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
      dependency :rule=>"A"
      condition_A :q_enter_contact_addr_1, "==", :a_1

      q_c_addr2_1 "Address 2", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR2_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
      dependency :rule=>"A"
      condition_A :q_enter_contact_addr_1, "==", :a_1

      q_c_unit_1 "Unit", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.C_UNIT_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
      dependency :rule=>"A"
      condition_A :q_enter_contact_addr_1, "==", :a_1

      q_c_city_1 "City", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.C_CITY_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
      dependency :rule=>"A"
      condition_A :q_enter_contact_addr_1, "==", :a_1

      q_c_state_1 "State", :display_type=>"dropdown", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.C_STATE_1"
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
      dependency :rule=>"A"
      condition_A :q_enter_contact_addr_1, "==", :a_1

      q_c_zipcode_1 "ZIP Code", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.C_ZIPCODE_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
      dependency :rule=>"A"
      condition_A :q_enter_contact_addr_1, "==", :a_1

      q_c_zip4_1 "ZIP+4", 
      :pick=>:one,    
      :data_export_identifier=>"PREG_VISIT_2_2.C_ZIP4_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
      dependency :rule=>"A"
      condition_A :q_enter_contact_addr_1, "==", :a_1
    
      q_enter_contact_phone_1 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_PHONE_1"
      a_1 "Phone number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      a_neg_7 "Contact has no telephone"

      label "Now I’d like to collect information on a second contact who does not currently live with you. What is this person’s name?"

      q_contact_fname_2 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of the first name", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_FNAME_2"
      a_first_name "First name", :string
      a_1 "No second contact provided"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO
      # the code for "No second contact provided" is different from PregVisit1_INT - something to pay attention to
      q_contact_lname_2 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of the last name",
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_LNAME_2"
      a_last_name "Last name", :string
      a_1 "No second contact provided"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Second contact information" do
      dependency :rule=>"A and B"
      condition_A :q_contact_fname_2, "==", :a_first_name
      condition_B :q_contact_lname_2, "==", :a_last_name
      
      q_contact_relate_2 "What is his/her relationship to you?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE_2"
      a_1 "Mother/father"
      a_2 "Brother/sister"
      a_3 "Aunt/uncle"
      a_4 "Grandparent"
      a_5 "Neighbor"
      a_6 "Friend"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_contact_relate2_oth "Other relationship of second contact", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_RELATE_2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_contact_relate_2, "==", :a_neg_5
    
      label "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_c_addr1_2 "Address 1 - street/PO box",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR1_2"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_addr2_2 "Address 2", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_2_2.C_ADDR2_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_unit_2 "Unit", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_2_2.C_UNIT_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_city_2 "City", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_2_2.C_CITY_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_hipv1_c_state_2 "State", :display_type=>"dropdown",
      :pick=>:one,       
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
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_zipcode_2 "ZIP Code", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_2_2.C_ZIPCODE_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_zip4_2 "ZIP+4", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_2_2.C_ZIP4_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      
    
      q_enter_contact_phone_2 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.CONTACT_PHONE_2"
      a_1 "Phone number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      a_neg_7 "Contact has no telephone"
    end
    label "Thank you for participating in the National Children’s Study and for taking the time to answer our questions. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_2_2.END"
    
    q_hipv1_time_stamp_14 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_2.TIME_STAMP_14"
    a :datetime, :custom_class => "datetime"        
  end
  
end