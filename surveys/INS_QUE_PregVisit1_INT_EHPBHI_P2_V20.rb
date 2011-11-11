survey "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0" do
  section "Interview introduction", :reference_identifier=>"prepregnancy_visit_1_v20" do

    q_time_stamp_1 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Thank you for agreeing to participate in the National Children’s Study. 
    This interview will take about 30 minutes to complete. Your answers are important to us. 
    There are no right or wrong answers. During this interview, we will ask you questions about yourself, 
    your health and pregnancy, your household and where you live. You can skip over any question or 
    stop the interview at any time. We will keep everything that you tell us confidential..
    First, we're like to make sure we have your correct name and birth date."

    q_prepopulated_name "Name:"
    a :string
    
#     TODO - the name should be pre-populated
    q_name_confirm "Is that your name? ", 
    :data_export_identifier=>"PREG_VISIT_1_2.NAME_CONFIRM", :pick=>:one
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
      ask for initials or some other name she would like to be called. confirm spelling of first 
      name if not previously collected and of last name for all participants."

      q_r_fname "First name", :display_type=>"string", :data_export_identifier=>"PREG_VISIT_1_2.R_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_name_confirm, "!=", :a_1

      q_r_lname "Last name", :display_type=>"string", :data_export_identifier=>"PREG_VISIT_1_2.R_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    q_prepopulated_date_of_birth "[Participant's date of birth as MM/DD/YYYY]"
    a :string

    q_dob_confirm "Is this your birth date?", 
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and that dob is 
    required to determine eligibility. If response was determined to be invalid, ask question again and probe for valid response",
    :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.DOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_confirmed_dob "What is your date of birth?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_1_2.PERSON_DOB"
    a_date :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_dob_confirm, "!=", :a_1    

    q_age_elig "Is participant age-eligible? ", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.AGE_ELIG"
    a_1 "Participant is age eligible"
    a_2 "Participant is younger than age of majority"
    a_3 "Participant is over 49"
    a_4 "Age eligibility is unknown"
    
    group "Not eligible" do
      dependency :rule=>"A"
      condition_A :q_age_elig, "==", :a_2
      
      label "Participant is not eligible"
    
      label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
      This concludes the interview portion of our visit.", 
      :help_text => "Interviewer instructions: end the questionare",
      :data_export_identifier=>"PREG_VISIT_1_2.END"
    end
    
    label "Case for supervisor review at SC to confirm age eligibility post-interview"
    dependency :rule => "A or B"
    condition_A :q_confirmed_dob, "==", :a_neg_1
    condition_B :q_confirmed_dob, "==", :a_neg_2
  end  
  section "Current pregnancy information", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Current pregnancy information" do
      dependency :rule=>"A"
      condition_A :q_age_elig, "!=", :a_2
      
      q_time_stamp_2 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime"

      label "We’ll begin by asking some questions about you, your health, and your health history. First, I’ll ask about your current pregnancy."
    
      q_pregnant "The first questions ask about how your pregnancy is progressing. Are you still pregnant?", :pick => :one,
      :data_export_identifier=>"PREG_VISIT_1_2.PREGNANT"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_1_2.END"
    dependency :rule=> "A or B" 
    condition_A :q_pregnant, "==", :a_neg_1
    condition_B :q_pregnant, "==", :a_neg_2
   
    group "Loss information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_2
      
      label "I’m so sorry for your loss. I know this can be a difficult time.",
      :help_text => "Use social cues and professional judgment in response. If SC has pregnancy loss information to disseminate, 
      offer to participant"
    
      q_loss_info "Did participant request additional information on coping with pregnancy loss?", :pick => :one, 
      :data_export_identifier=>"PREG_VISIT_1_2.LOSS_INFO"
      a_1 "Yes"
      a_2 "No"
    
      label "Interviewer instructions: end the questionare"
    
      label "Again, I'd like to say how sorry I am for your loss.Please accept our best wishes for a quick recovery. Thank you for your time.",
      :help_text => "If loss of pregnancy, end interview. Do not administer SAQs.", :data_export_identifier=>"PREG_VISIT_1_2.END_INFO"
    
      label "We'll send the information packet you requested as soon as possible."
    
      label "Interviewer instructions: end the questionare"
    end
    
    group "Pregnancy information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_time_stamp_3 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_3"
      a :datetime, :custom_class => "datetime"      

      q_due_date "What is your current due date?", :pick => :one,
      :help_text => "If response was determined to be invalid, ask question again and probe for valid response. Answer can not be (1) on or before 'TODAY' 
      or (2) more than 9 months after 'TODAY'. If response was determined to be invalid, ask question again and probe for valid response",
      :data_export_identifier=>"PREG_VISIT_1_2.DUE_DATE"
      a_date :string, :custom_class => "date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      # TODO
      # PROGRAMMER INSTRUCTIONS:
      # • CHECK REPORTED DUE DATE AGAINST CURRENT DATE; DISPLAY APPROPRIATE MESSAGE:
      # o IF DATE IS MORE THAN 9 MONTHS AFTER CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT IS MORE THAN 9 MONTHS FROM TODAY. RE-ENTER DATE.” 
      # o IF DATE IS MORE THAN 1 MONTH BEFORE CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT OCCURRED MORE THAN A MONTH BEFORE TODAY. RE-ENTER DATE.” 
      # o IF VALID DUE DATE WAS PROVIDED, SET DUE_DATE = YYYYMMDD AS REPORTED; GO TO KNOW_DATE
      # o IF NO VALID DATE IS GIVEN → GO TO CP004 DATE_PERIOD 
    
      q_know_date "How did you find out your due date?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.KNOW_DATE"
      a_1 "Figured it out myself"
      a_2 "Had an ultrasound to figure it out"
      a_3 "Doctor or other provider told me without an ultrasound"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_due_date, "==", :a_date
    
      q_date_period "Date of first day of last menstrual period", 
      :help_text => "Code day as '15' if participant is unsure/unable to estimate day. Answer can not be (1) after 'TODAY' or (2) no more than 10 months 
      before 'TODAY'. If response was determined to be invalid, ask question again and probe for valid response", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.DATE_PERIOD"
      a_date :string, :custom_class => "date"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
        
      # TODO
      # PROGRAMMER INSTRUCTIONS:
      # • CHECK REPORTED MENSTRUAL DATE AGAINST CURRENT DATE; DISPLAY APPROPRIATE MESSAGE:
      # o IF DATE IS MORE THAN 10 MONTHS BEFORE CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT IS MORE THAN 10 MONTHS BEFORE TODAY. CONFIRM DATE. IF DATE IS CORRECT, ENTER ‘DON’T KNOW’.” 
      # o IF DATE IS AFTER CURRENT DATE, DISPLAY INTERVIEWER INSTRUCTION: “YOU HAVE ENTERED A DATE THAT HAS NOT OCCURRED YET. RE-ENTER DATE.” 
      # o IF VALID DATE WAS PROVIDED, CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET DUE_DATE (YYYYMMDD) = DATE_PERIOD + 280 DAYS; GO TO KNEW_DATE. 
    
      q_knew_date "Did participant give date?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.KNEW_DATE"
      a_1 "Participant gave complete date"
      a_2 "Interviewer entered 15 for day"
      dependency :rule=>"A"
      condition_A :q_date_period, "==", :a_date
    
      q_time_stamp_4 "Current date & time", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_4"
      a :datetime, :custom_class => "datetime"
        
      q_home_test "Did you use a home pregnancy test to help find out you were pregnant?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HOME_TEST"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_multiple_gestation "Are you pregnant with a single baby (singleton), twins, or triplets or other multiple births?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.MULTIPLE_GESTATION"
      a_1 "Singleton"
      a_2 "Twins"
      a_3 "Triplets or higher"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      # TODO
      # PROGRAMMER INSTRUCTION: 
      # • IF MULTIPLE_GESTATION =2 OR 3, DISPLAY “BABIES” AS APPROPRIATE THROUGHOUT INSTRUMENT. OTHERWISE, DISPLAY “BABY.”
    
      q_birth_plan "Where do you plan to deliver your (baby/babies)?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.BIRTH_PLAN"
      a_1 "In a hospital"
      a_2 "A birthing center"
      a_3 "At home"
      a_4 "Some other place"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Birth hospital information" do
      dependency :rule=>"A or B or C"
      condition_A :q_birth_plan, "==", :a_1
      condition_B :q_birth_plan, "==", :a_2
      condition_C :q_birth_plan, "==", :a_4        
      
      label "Name and address of the place where you are planning to deliver your (baby/babies)?"

      q_nash_hosp_name "Name of birth hospital/birthing center", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.BIRTH_PLACE"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_address_1 "Address 1 - STREET/PO BOX", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.B_ADDRESS_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_address_2 "Address 2", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.B_ADDRESS_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_city "City", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.B_CITY"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    

      q_b_state "State", :display_type=>"dropdown", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.B_STATE"
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

      q_b_zipcode "ZIP code", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.B_ZIPCODE"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
    end
    
    group "Additional pregnancy information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
        
      q_pn_vitamin "In the month before you became pregnant, did you regularly take multivitamins, prenatal vitamins, folate, or folic acid?", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.PN_VITAMIN"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_preg_vitamin "Since you’ve become pregnant, have you regularly taken multivitamins, prenatal vitamins, folate, or folic acid?", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.PREG_VITAMIN"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_date_visit "What was the date of your most recent doctor’s visit or checkup since you’ve become pregnant?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.DATE_VISIT"
      a :string, :custom_class => "date"
      a_7 "Have not had a visit"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # PROGRAMMER INSTRUCTIONS: 
      #     • IF VALID DATE FOR DATE_VISIT IS PROVIDED, DISPLAY “AT THIS VISIT OR AT”. OTHERWISE ”At”.
      label "At this visit or at any time during your pregnancy, did the doctor or other health care provider tell you that you have any 
      of the following conditions?",
      :help_text => "If valid date for date_visit is provided, display \"At this visit or at\". 
      Otherwise \"At\". Re-read introductory statement as needed"

      q_diabetes_1 "Diabetes? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_highbp_preg "High blood pressure? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HIGHBP_PREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_urine "Protein in your urine? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.URINE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_preeclamp "Preeclampsia or toxemia? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.PREECLAMP"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_early_labor "Early or premature labor? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.EARLY_LABOR"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_anemia "Anemia or low blood count? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.ANEMIA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_nausea "Severe nausea or vomiting (hyperemesis)? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.NAUSEA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_kidney "Bladder or kidney infection? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.KIDNEY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_rh_disease "Rh disease or isoimmunization? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.RH_DISEASE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_group_b "Infection with bacteria called Group B strep?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.GROUP_B"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_herpes "Infection with a Herpes virus? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HERPES"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_vaginosis "Infection of the vagina with bacteria (bacterial vaginosis?)", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.VAGINOSIS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_oth_condition "Any other serious condition? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.OTH_CONDITION"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_condition_oth "Can you please specify the other serious conditions? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CONDITION_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_oth_condition, "==", :a_1
    end
  end
  section "Medical history", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Medical history" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_time_stamp_5 "Current date & time", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_5"
      a :datetime, :custom_class => "datetime"
    
      label "This next question is about your health when you are not pregnant"
  
      q_health "Would you say your health in general is...", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HEALTH"
      a_1 "Excellent"
      a_2 "Very good,"
      a_3 "Good,"
      a_4 "Fair, or"
      a_5 "Poor?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      label "How tall are you without shoes? " 

      q_height_ft "Feet (e.g., 5)",
      :help_text => "Verify if provided value is outside of the suggested range (4 to 7 feet). This value is admissible, but you may wish to verify",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.HEIGHT_FT"
      a :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      
    
      q_ht_inch "Inches (e.g., 7)",
      :help_text => "Verify if provided value is outside of the suggested range (0 to 11 inches when \"feet\" value is specified and 
      48 to 84 inches, when \"feet\" value is blank. This value is admissible, but you may wish to verify.",
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.HT_INCH"
      a :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      
    
      label "What was your weight just before you became pregnant? " 
  
      q_weight "Weight before becoming pregnant (pounds)",
      :help_text => "Verify if provided value is outside of the suggested range (90 to 400 lbs). This value is admissible, but you may wish to verify.",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.WEIGHT"
      a :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      
    
      label "The next questions are about medical conditions or health problems you might have now or may have had in the past."
  
      q_asthma "Have you ever been told by a doctor or other health care provider that you had asthma? ", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.ASTHMA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_highbp_notpreg "Have you ever been told by a doctor or other health care provider that you had
      Hypertension or high blood pressure when you’re not pregnant?", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HIGHBP_NOTPREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_diabetes_notpreg "Have you ever been told by a doctor or other health care provider that you had
      High blood sugar or Diabetes when you're not pregnant?", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_NOTPREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_diabetes_2 "Have you taken any medicine or received other medical treatment for diabetes in the past 12 months? ", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_diabetes_notpreg, "==", :a_1
  
      q_diabetes_3 "Have you ever taken insulin? ", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.DIABETES_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_diabetes_notpreg, "==", :a_1
  
      q_thyroid_1 "Have you ever been told by a doctor or other health care provider that you had 
      Hypothyroidism, that is, an under active thyroid?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.THYROID_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_thyroid_2 "Have you taken any medicine or received other medical treatment for a thyroid problem in the past 12 months?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.THYROID_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_thyroid_1, "==", :a_1
    
      label "This next question is about where you go for routine health care."
  
      q_hlth_care "What kind of place do you usually go to when you need routine or preventive care, such as a physical examination or check-up?", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.HLTH_CARE"
      a_1 "Clinic or health center"
      a_2 "Doctor's office or Health Maintenance Organization (HMO)"
      a_3 "Hospital emergency room"
      a_4 "Hospital outpatient department"
      a_5 "Some other place"
      a_6 "Doesn't go to one place most often"
      a_7 "Doesn't get preventive care anywhere"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end  
  section "Health insurance", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Health insurance" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
    
      q_time_stamp_6 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_6"
      a :datetime, :custom_class => "datetime"      

      label "Now I'm going to switch to another subject and ask about health insurance."

      q_insure "Are you currently covered by any kind of health insurance or some other kind of health care plan? ", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.INSURE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Additional information on health insurance" do
      dependency :rule=> "A"
      condition_A :q_insure, "==", :a_1

      label "Now I'll read a list of different types of insurance. Please tell me which types you currently have. Do you currently have...",
      :help_text => "Re-read introductory statement (Do you currently have...) as needed"
    
      q_ins_employ "Insurance through an employer or union either through yourself or another family member? ", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_medicaid "Medicaid or any government-assistance plan for those with low incomes or a disability?",
      :help_text => "Provide examples of local medicaid programs", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_tricare "TRICARE, VA, or other military health care? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_ihs "Indian Health Service? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_ins_medicaire "Medicare, for people with certain disabilities? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.INS_MEDICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_ins_oth "Any other type of health insurance or health coverage plan? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
     
  section "Housing characteristics", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Housing characteristics" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      q_time_stamp_7 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_7"
      a :datetime, :custom_class => "datetime"

      label "Now I'd like to find out more about your home and the area in which you live."

      #TODO
      # PROGRAMMER INSTRUCTIONS:
      # • IF OWN_HOME WAS ASKED DURING PREGNANCY SCREENER OR PRE-PREGANCY VISIT, THEN ASK RECENT_MOVE; ELSE SKIP TO OWN_HOME.

      q_recent_move "Have you moved or changed your housing situation since we last spoke with you? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.RECENT_MOVE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_own_home "Is your home...", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.OWN_HOME"
      a_1 "Owned or being bought by you or someone in your household"
      a_2 "Rented by you or someone in your household, or"
      a_3 "Occupied without payment of rent?"
      a_neg_5 "Some other arrangement"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=> "A"
      condition_A :q_recent_move, "==", :a_1

      q_own_home_oth "Can you please specify your home arrangement?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.OWN_HOME_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_own_home , "==", :a_neg_5

      q_time_stamp_8 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_8"
      a :datetime, :custom_class => "datetime"
      dependency :rule=> "A"
      condition_A :q_recent_move, "==", :a_1

      #TODO
      # PROGRAMMER INSTRUCTIONS: 
      # • THE REST OF THE QUESTIONS IN THIS SECTION ARE ONLY ASKED OF A SUBSET OF PARTICIPANTS, DEPENDING UPON WHETHER A PRE-PREGNANCY 
      # QUESTIONNAIRE WAS COMPLETED AND RESPONSES TO RECENT_MOVE ABOVE AND DURING THE PRE-PREGNANCY VISIT
      # • IF RECENT_MOVE DURING THIS EVENT IS “YES” GO TO AGE_HOME AND CONTINUE THROUGH REST OF SECTION
      # • IF RECENT_MOVE DURING THIS EVENT IS ‘NO,’ REFUSED,’ OR ‘DON’T KNOW’ AND
      #   o NO PRE-PREGNANCY INFORMATION IS AVAILABLE; GO TO AGE_HOME AND CONTINUE THROUGH REST OF SECTION
      #   o IF RECENT_MOVE WAS ASKED DURING PRE-PREGNANCY QUESTIONNAIRE AND WAS CODED AS “YES”; SKIP REST OF SECTION AND GO TO TIME_STAMP_9
      #   o IF RECENT_MOVE WAS ASKED DURING PRE-PREGNANCY QUESTIONNAIRE AND WAS NOT CODED AS “YES”; GO TO (AGE_HOME) AND CONTINUE THROUGH SECTION


      q_age_home "Can you tell us, which of these categories do you think best describes when your home or building was built?",
      :help_text => "Show response options on card to participant", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.AGE_HOME"
      a_1 "2001 to present"
      a_2 "1981 to 2000"
      a_3 "1961 to 1980"
      a_4 "1941 to 1960"
      a_5 "1940 or before"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "How long have you lived in this home?"

      q_length_reside "Length reside: number (e.g., 5)", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.LENGTH_RESIDE"
      a "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_length_reside_units "Length reside: units (e.g., months)", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.LENGTH_RESIDE_UNIT"
      a_1 "Weeks"
      a_2 "Months"
      a_3 "Years"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Now I'm going to ask you about how your home is heated and cooled."

      q_main_heat "Which of these types of heat sources best describes the main heating fuel source for your home?",
      :help_text => "Show response options on card to participant.", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.MAIN_HEAT"
      a_1 "Electric"
      a_2 "Gas - propane or LP"
      a_3 "Oil"
      a_4 "Wood"
      a_5 "Kerosene or diesel"
      a_6 "Coal or coke"
      a_7 "Solar energy"
      a_8 "Heat pump"
      a_neg_7 "No heating source"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_main_heat_oth "Other main heating fuel source", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.MAIN_HEAT_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_main_heat, "==", :a_neg_5

      q_heat2 "Are there any other types of heat you use regularly during the heating season 
      to heat your home? ",
      :help_text => "Show response options on card to participant. Probe: Do you have any space heaters, or any secondary 
      method for heating your home? Select all that apply.", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_1_HEAT2_2.HEAT2"
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
      condition_A :q_main_heat, "!=", :a_neg_7
      condition_B :q_main_heat, "!=", :a_neg_5
      condition_C :q_main_heat, "!=", :a_neg_1
      condition_D :q_main_heat, "!=", :a_neg_2

      q_enter_heat2_oth "Other secondary heating fuel source", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_HEAT2_2.HEAT2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_heat2, "==", :a_neg_5
      condition_B :q_heat2, "!=", :a_neg_1
      condition_C :q_heat2, "!=", :a_neg_2            

      q_cooling "Does your home have any type of cooling or air conditioning besides fans? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.COOLING"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cool "Not including fans, which of the following kinds of cooling systems do you regularly use?",
      :help_text => "Probe for any other responses. Select all that apply", :pick=>:any, 
       :data_export_identifier=>"PREG_VISIT_1_COOL_2.COOL"
      a_1 "Windows or wall air conditioners"
      a_2 "Central air conditioning"
      a_3 "Evaporative cooler (swamp cooler), or"
      a_4 "No cooling or air conditioning regularly used"
      a_neg_5 "Some other cooling system"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_cooling, "==", :a_1

      q_enter_cool_oth "Other cooling system", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_COOL_2.COOL_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C and D"
      condition_A :q_cool, "==", :a_neg_5
      condition_B :q_cool, "!=", :a_4
      condition_C :q_cool, "!=", :a_neg_1
      condition_D :q_cool, "!=", :a_neg_2                  

      q_time_stamp_9 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"      

      label "Now I'd like to ask about the water in your home."

      q_water_drink "What water source in your home do you use most of the time for drinking? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.WATER_DRINK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_water_drink_oth "Other source of drinking", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.WATER_DRINK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_water_drink, "==", :a_neg_5

      q_water_cook "What water source in your home is used most of the time for <U>cooking</U>?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.WATER_COOK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_water_cook_oth "Other source of cooking water", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.WATER_COOK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_water_cook, "==", :a_neg_5

      label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the 
      ceiling or walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof, or floods."

      q_water "In the past 12 months, have you seen any water damage inside your home? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.WATER"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_mold "In the past 12 months, have you seen any mold or mildew on walls or other surfaces other 
      than the shower or bathtub, inside your home? ", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.MOLD"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_room_mold "In which rooms have you seen the mold or mildew?",
      :help_text => "Probe: Any other rooms? Select all that apply", :pick=>:any,
      :data_export_identifier=>"PREG_VISIT_1_ROOM_MOLD_2.ROOM_MOLD"
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
      :data_export_identifier=>"PREG_VISIT_1_ROOM_MOLD_2.ROOM_MOLD_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_room_mold, "==", :a_neg_5
      condition_B :q_room_mold, "!=", :a_neg_1
      condition_C :q_room_mold, "!=", :a_neg_2            

      q_time_stamp_10 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_10"
      a :datetime, :custom_class => "datetime"

      label "The next few questions ask about any recent additions or renovations to your home."

      q_prenovate "Since you became pregnant, have any additions been built onto your home to make 
      it bigger or renovations or other construction been done in your home? Include only major projects. Do not count 
      smaller projects, such as painting, wallpapering, carpeting or re-finishing floors.", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.PRENOVATE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_prenovate_room "Which rooms were renovated?",
      :help_text => "Probe: Any others? Select all that apply", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_1_PRENOVATE_ROOM_2.PRENOVATE_ROOM"
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
      condition_A :q_prenovate, "==", :a_1

      q_enter_prenovate_room_oth "Other rooms that were renovated", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_PRENOVATE_ROOM_2.PRENOVATE_ROOM_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_prenovate_room, "==", :a_neg_5
      condition_B :q_prenovate_room, "!=", :a_neg_1
      condition_C :q_prenovate_room, "!=", :a_neg_2      

      q_pdecorate "Since you became pregnant, were any smaller projects done in your home, 
      such as painting, wallpapering, refinishing floors, or installing new carpet?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.PDECORATE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_pdecorate_room "In which rooms were these smaller projects done?",
      :help_text => "Probe: Any others? Select all that apply", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_1_PDECORATE_ROOM_2.PDECORATE_ROOM"
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
      condition_A :q_pdecorate, "==", :a_1

      q_enter_pdecorate_room_oth "Other rooms where smaller projects were done", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_PDECORATE_ROOM_2.PDECORATE_ROOM_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_pdecorate_room, "==", :a_neg_5
      condition_B :q_pdecorate_room, "!=", :a_neg_1
      condition_C :q_pdecorate_room, "!=", :a_neg_2 
    end     
  end
  section "Pets", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Pets" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1

      q_time_stamp_11 "Insert date/time stamp", 
      :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_11"
      a :datetime, :custom_class => "datetime"
      
      label "Now, I'd like to ask about any pets you may have in your home."

      q_pets "Are there any pets that spend any time inside your home?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.PETS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_pet_type "What kind of pets are these?",
      :help_text => "Probe for any other responses. Select all that apply", :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_1_PET_TYPE_2.PET_TYPE"
      a_1 "Dog"
      a_2 "Cat"
      a_3 "Small mammal (rabbit, gerbil, hamster, guinea pig, ferret, mouse)"
      a_4 "Bird"
      a_5 "Fish or reptile (turtle, snake, lizard)"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_pets, "==", :a_1

      q_pet_type_oth "Other types of pets", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_PET_TYPE_2.PET_TYPE_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_pet_type, "==", :a_neg_5
      condition_B :q_pet_type, "!=", :a_neg_1
      condition_C :q_pet_type, "!=", :a_neg_2            
    end
  end
  section "Household composition and demographics", :reference_identifier=>"prepregnancy_visit_v20" do 
    group "Household composition and demographics" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1

      q_time_stamp_12 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_12"
      a :datetime, :custom_class => "datetime"

      # TODO
      # PROGRAMMER INSTRUCTION: 
      # • IF A PRE-PREGNANCY QUESTIONNAIRE WAS COMPLETED DISPLAY BRACKETEDTEXT: 
      # “The next questions may be similar to those asked the last time we spoke, but we are asking them again 
      # because sometimes the answers change.”

      label "{The next questions may be similar to those asked the last time we spoke, but we are asking them again because 
      sometimes the answers change.}Now, I'd like to ask some questions about your schooling and employment."

      q_educ "What is the highest degree or level of school that you have completed?",
      :help_text => "Show response options on card to participant.",
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.EDUC"
      a_1 "Less than a high school diploma or GED"
      a_2 "High school diploma or GED"
      a_3 "Some college but no degree"
      a_4 "Associate degree"
      a_5 "Bachelor’s degree (e.g., BA, BS)"
      a_6 "Post graduate degree (e.g., masters or doctoral)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_working "Are you currently working at any full or part time jobs?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.WORKING"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Working information" do
      dependency :rule=>"A"
      condition_A :q_working, "==", :a_1
      
      q_enter_hours "Approximately how many hours each week are you working?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HOURS"
      a_1 "Number of hours (double check if > 60)", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_shift_work "Do you work shifts that starts after 2 pm?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.SHIFT_WORK"
      a_1 "Yes"
      a_2 "No"
      a_3 "Sometimes"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    group "Additional information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1

      label "These next questions are about the language that will be spoken to your baby."
    
      q_hh_nonenglish "Is there any language other than English regularly spoken in your home?", :pick =>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.HH_NONENGLISH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_hh_nonenglish_2 "What languages other than English are spoken in your home?",
      :help_text => "Probe as needed: \"any others?\" Select all that apply.", :pick =>:any, 
      :data_export_identifier=>"PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH_2"
      a_1 "Spanish"
      a_2 "Arabic"
      a_3 "Chinese"
      a_4 "French"
      a_5 "French creole"
      a_6 "German"
      a_7 "Italian"
      a_8 "Korean"
      a_9 "Polish"
      a_10 "Russian"
      a_11 "Tagalog"
      a_12 "Vietnamese"
      a_13 "Urdu"
      a_14 "Punjabi"
      a_15 "Bengali"
      a_16 "Farsi"
      a_17 "Sign language"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_hh_nonenglish, "==", :a_1
    
      q_hh_nonenglish_2_oth "Other languages that are spoken in your home", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_hh_nonenglish_2, "==", :a_neg_5
      condition_B :q_hh_nonenglish_2, "!=", :a_neg_1
      condition_C :q_hh_nonenglish_2, "!=", :a_neg_2
    
      q_hh_english "Is English also spoken in your home?", :pick => :one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HH_ENGLISH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_hh_primary_lang "What is the primary language spoken in your home?", :pick => :one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HH_PRIMARY_LANG"
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
      a_18 "Sign language"
      a_19 "Cannot choose"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_hh_nonenglish, "==", :a_1  
    
      q_hh_primary_lang_oth "Other primary languages that are spoken in your home", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HH_PRIMARY_LANG_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_hh_primary_lang, "==", :a_neg_5
      condition_B :q_hh_primary_lang, "!=", :a_neg_1
      condition_C :q_hh_primary_lang, "!=", :a_neg_2      
    
      label "The next questions may be similar to those asked the last time we contacted you, 
      but we are asking them again because sometimes the answers change."
    
      q_maristat "I’d like to ask about your marital status. Are you:", 
      :help_text => "Probe for current marital status", :pick => :one, 
      :data_export_identifier=>"PREG_VISIT_1_2.MARISTAT"
      a_1 "Married,"
      a_2 "Not married but living together with a partner"
      a_3 "Never been married,"
      a_4 "Divorced,"
      a_5 "Separated, or"
      a_6 "Widowed?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Marital information" do
      dependency :rule=>"A or B"
      condition_A :q_maristat, "==", :a_1
      condition_B :q_maristat, "==", :a_2
            
      q_sp_educ "What is the highest degree or level of school that your spouse or partner has completed?",
      :help_text => "Show response options on card to participant.",
      :pick => :one, 
      :data_export_identifier=>"PREG_VISIT_1_2.SP_EDUC"
      a_1 "Less than a high school diploma or GED"
      a_2 "High school diploma or GED"
      a_3 "Some college but no degree"
      a_4 "Associate degree"
      a_5 "Bachelor's degree (e.g., BA, BS)"
      a_6 "Post graduate degree (e.g., Masters or Doctoral)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_sp_ethnicity "Does your spouse or partner consider himself [or herself, if volunteered] to be Hispanic, or Latino [latina]?",
       :pick=>"one", 
       :data_export_identifier=>"PREG_VISIT_1_2.SP_ETHNICITY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_sp_race "What race does your spouse (or partner) consider himself [or herself, if volunteered] to be? You may select one or more.",
      :help_text => "Show response options on card to participant. Probe for any other responses. Only use \"Some other race\" 
      if volunteered. Don’t ask. Select all that apply.", :pick=>"any", 
      :data_export_identifier=>"PREG_VISIT_1_SP_RACE_2.SP_RACE"
      a_1 "White,"
      a_2 "Black or african american,"
      a_3 "American indian or alaska native,"
      a_4 "Asian, or"
      a_5 "Native hawaiian or other pacific islander?"
      a_6 "Multi-racial"
      a_neg_5 "Some other race?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_sp_race_oth "Other race", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_SP_RACE_2.SP_RACE_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_sp_race, "==", :a_neg_5
      condition_B :q_sp_race, "!=", :a_neg_1
      condition_C :q_sp_race, "!=", :a_neg_2                              
    end
    
    q_time_stamp_13 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_13"
    a :datetime, :custom_class => "datetime"
    dependency :rule=> "A"
    condition_A :q_pregnant, "==", :a_1      
  end
  
  section "Commuting", :reference_identifier=>"prepregnancy_visit_v20" do
    group "Commuting Information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
        
      label "Next, I'll be asking you about commuting and how travel from place to place."

      q_commute "Think of the longest regular commute that you take, to work, school, or other places. By regular commute, 
      I mean someplace that you travel to at least 3 days a week. Since you became pregnant, how do you normally get to your destination?",
      :help_text => "Probe for any other responses. Select all that apply", 
      :pick=>:any, 
      :data_export_identifier=>"PREG_VISIT_1_COMMUTE_2.COMMUTE"
      a_1 "Car"
      a_2 "Bus"
      a_3 "Train, subway, rail, or light rail"
      a_4 "Walk, bike (non-motorized)"
      a_5 "Does not have a regular commute"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_commute_oth "Other forms of commuting", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_COMMUTE_2.COMMUTE_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_commute, "==", :a_neg_5
      condition_B :q_commute, "!=", :a_neg_1
      condition_C :q_commute, "!=", :a_neg_2

      q_commute_time "About how many minutes is this commute, one way? Be sure to include any routine side trips you 
      make on the way, such as stops at day care or school. Include only the time spent driving or sitting inside the car.", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.COMMUTE_TIME"
      a_1 "Number of minutes (should not be > 60)", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B"
      condition_A :q_commute, "!=", :a_neg_1
      condition_B :q_commute, "!=", :a_neg_2      

      q_local_trav "Since you became pregnant, how do you normally get to other places, for example, shopping, doctor, 
      visiting friends, or church?",
      :help_text => "Probe for any other responses. Select all that apply", 
      :pick=>:any, :data_export_identifier=>"PREG_VISIT_1_LOCAL_TRAV_2.LOCAL_TRAV"
      a_1 "Car"
      a_2 "Bus"
      a_3 "Train, subway, rail, or light rail"
      a_4 "Walk, bike (non-motorized)"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_local_trav_oth "Other forms of local travel", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_LOCAL_TRAV_2.LOCAL_TRAV_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_local_trav, "==", :a_neg_5
      condition_B :q_local_trav, "!=", :a_neg_1
      condition_C :q_local_trav, "!=", :a_neg_2      

      label "Next, I'd like to find out about how often you pump gasoline."

      q_pump_gas "Since you became pregnant, about how often have you pumped or poured gasoline into a car, truck, motorcycle, other 
      motor vehicle, lawnmower, or other engine:", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.PUMP_GAS"
      a_1 "Every day,"
      a_2 "4-6 times per week,"
      a_3 "2-3 times per week,"
      a_4 "Once a week,"
      a_5 "One to three times a month,"
      a_6 "Less than once a month, or"
      a_7 "Never?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_time_stamp_14 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_14"
      a :datetime, :custom_class => "datetime"
    end
  end  
  section "Family income", :reference_identifier=>"prepregnancy_visit_v20" do    
    group "Family income" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
            
      label "Now I’m going to ask a few questions about your income. Family income is important in analyzing the data we 
      collect and is often used in scientific studies to compare groups of people who are similar. Please remember that all the 
      information you provide is confidential.Please think about your total combined family income during {CURRENT YEAR – 1} 
      for all members of the family."
      
      # TODO
      # PROGRAMMER INSTRUCTION:
      # • PRELOAD CURRENT YEAR MINUS 1.   

      q_hh_members "Number household members supported by total combined family income", 
      :help_text => "Response must be > 0 and < 15",
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_1_2.HH_MEMBERS"  
      a_number "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

  # TODO == • DISPLAY  HARD EDIT IF RESPONSE > HH_MEMBERS 
      q_num_child "How many of those people are children? Please include anyone under 18 years or anyone 
      older than 18 years and in high school.",
      :help_text => "Verify if responce > than the answer above, or if responce is > 10", 
      :pick => :one,
      :data_export_identifier=>"PREG_VISIT_1_2.NUM_CHILD"
      a_1 "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      dependency :rule=>"A"
      condition_A :q_hh_members, "==", :a_number

      q_income "Of these income groups, which category best represents your combined family income during the last calendar year?",
      :help_text => "Show response options on card to participant.", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.INCOME"
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
    end
  end
  section "Tracing questions", :reference_identifier=>"prepregnancy_visit_v20" do 
    group "Tracing questions" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
          
      q_time_stamp_15 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_15"
      a :datetime, :custom_class => "datetime"

      label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember 
      that all the information you provide is confidential and will not be provided to anyone outside the National Children’s Study."
      

  # TODO
      # PROGRAMMER INSTRUCTIONS: 
      # • ASK COMM_EMAIL ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED; 
      # • ELSE SKIP TO HAVE_EMAIL

      q_comm_email "When we last spoke, we asked questions about communicating with you through your personal email. 
      Has your email address or your preferences regarding use of your personal email changed since then?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.COMM_EMAIL"
      a_1 "Yes"
      a_2 "No"
      a_3 "Don't remember"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_have_email "Do you have an email address?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.HAVE_EMAIL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule => "A"
      condition_A :q_comm_email, "!=", :a_2
    end
    group "Email information" do
      dependency :rule=>"A"
      condition_A :q_have_email, "==", :a_1
      
      q_email_2 "May we use your personal email address to make future study appointments or send appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.EMAIL_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_email_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.EMAIL_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_email "What is the best email address to reach you?", :pick=>:one, 
      :help_text=>"Example of valid email address such as maryjane@email.com", 
      :data_export_identifier=>"PREG_VISIT_1_2.EMAIL"
      a_1 "Enter e-mail address:", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Phone information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
      
      #TODO
      # PROGRAMMER INSTRUCTIONS: 
      # • ASK COMM_CELL ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED
      # • ELSE SKIP TO CELL_PHONE_1

      label "Ask (comm_cell) only if a pre-pregnancy interview was completed; else skip to (cell_phone_1)"

      q_comm_cell "When we last spoke, we asked questions about communicating with you through your personal cell 
      phone number. Has your cell phone number or your preferences regarding use of your personal cell phone number 
      changed since then?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.COMM_CELL"
      a_1 "Yes"
      a_2 "No"
      a_3 "Don't remember"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cell_phone_1 "Do you have a personal cell phone?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=> "A"
      condition_A :q_comm_cell, "!=", :a_2   
    end
    group "Cell phone information" do
      dependency :rule=>"A"
      condition_A :q_cell_phone_1, "==", :a_1   

      q_cell_phone_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cell_phone_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cell_phone_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE_4"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_cell_phone "What is your personal cell phone number (XXXXXXXXXX)?", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.CELL_PHONE"
      a_1 "Phone number", :string
      a_neg_7 "Participant has no cell phone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Additional information" do
      dependency :rule=> "A"
      condition_A :q_pregnant, "==", :a_1
          
      q_hipv1_time_stamp_16 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_16"
      a :datetime, :custom_class => "datetime"

      #       TODO
      # PROGRAMMER INSTRUCTIONS: 
      # • ASK comm_contact ONLY IF A PRE-PREGNANCY INTERVIEW WAS COMPLETED
      # • ELSE SKIP TO contact_1
      label "Ask (comm_contact) only if a pre-pregnancy interview was completed; else skip to (contact_1)"

      q_comm_contact "Sometimes if people move or change their telephone number, we have difficulty reaching them. At our last visit, 
      we asked for contact information for two friends or relatives not living with you who would know where you could be reached in case we 
      have trouble contacting you. Has that information changed since our last visit?", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.COMM_CONTACT"
      a_1 "Yes"
      a_2 "No"
      a_3 "Don't remember"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      
      q_contact_1 "Could I have the name of a friend or relative not currently living with you who should know where you could be reached 
      in case we have trouble contacting you?", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know" 
      dependency :rule=>"A"
      condition_A :q_comm_contact, "!=", :a_2
    end
    group "Contact information" do
      dependency :rule=>"A"
      condition_A :q_contact_1, "==", :a_1     

      q_contact_fname_1 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_FNAME_1"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_lname_1 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_LNAME_1"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"  

      q_contact_relate_1 "What is his/her relationship to you?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE_1"
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
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE1_OTH"      
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_contact_relate_1, "==", :a_neg_5

      q_enter_contact_addr_1 "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_c_addr1_1 "Address 1 - street/PO Box", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR1_1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_addr2_1 "Address 2", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR2_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_unit_1 "Unit", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_UNIT_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_city_1 "City", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_CITY_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_state_1 "State", :display_type=>"dropdown", 
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.C_STATE_1"
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

      q_c_zipcode_1 "ZIP Code", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_ZIPCODE_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_zip4_1 "ZIP+4", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_ZIP4_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_enter_contact_phone_1 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_PHONE_1"
      a_1 "Phone number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      a_neg_7 "Contact has no telephone"
    
      label "Now I’d like to collect information on a second contact who does not currently live with you. What is this person’s name?",
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_2"

      q_enter_contact_2 "What is the person's name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names"

      q_contact_fname_2 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_FNAME_2"
      a_first_name "First name", :string
      a_neg_7 "No second contact provided"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_lname_2 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials- confirm spelling of first and last names", 
      :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_LNAME_2"
      a_last_name "Last name", :string
      a_neg_7 "No second contact provided"    
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_relate_2 "What is his/her relationship to you?", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE_2"
      a_1 "Mother/father"
      a_2 "Brother/sister"
      a_3 "Aunt/uncle"
      a_4 "Grandparent"
      a_5 "Neighbor"
      a_6 "Friend"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B"
      condition_A :q_contact_fname_2, "==", :a_first_name
      condition_B :q_contact_lname_2, "==", :a_last_name

      q_enter_contact_relate2_oth "Other relationship of second contact", :pick=>:one, 
      :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_RELATE_2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_contact_relate_2, "==", :a_neg_5
    end
    group "Second contact information" do
      dependency :rule=>"A and B"
      condition_A :q_contact_fname_2, "==", :a_first_name
      condition_B :q_contact_lname_2, "==", :a_last_name      
    
      q_enter_contact_addr_2 "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_c_addr1_2 "Address 1 - street/PO Box",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR1_2"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_addr2_2 "Address 2",
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_ADDR2_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_unit_2 "Unit",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.C_UNIT_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_city_2 "City",
      :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_1_2.C_CITY_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_hipv1_c_state_2 "State", :display_type=>"dropdown",
      :pick=>:one,
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
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_zipcode_2 "ZIP Code", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_ZIPCODE_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_zip4_2 "ZIP+4", 
      :pick=>:one,      
      :data_export_identifier=>"PREG_VISIT_1_2.C_ZIP4_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_enter_contact_phone_2 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_2.CONTACT_PHONE_2"
      a_1 "Phone number", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      a_neg_7 "Contact has no telephone"
    end
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PREG_VISIT_1_2.END"
    
    q_hipv1_time_stamp_17 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_1_2.TIME_STAMP_17"
    a :datetime, :custom_class => "datetime"
  end
  section "Pregnancy care log introduction" do
    label "In order to help you keep track of your doctor visits or other health care provider visits during your pregnancy, we are giving 
    you a Pregnancy Health Care Log. At each Study visit or telephone interview, we will ask you about any health care visits you had 
    since the last Study visit or telephone interview. This log will help you remember that information. The Pregnancy Health Care Log 
    has a Health Care Provider Log section for writing down information about your health care providers; address and phone numbers, and 
    there is also a Health Care Visits and Overnight Hospital Stays section for keeping track of information about your health care visits 
    and any diagnoses, procedures, or treatments.
    It will be very helpful if you use the log to write down information any time that you receive health care, so that you will be able 
    to remember it accurately during your NCS Study visits or telephone interviews.",
    :help_text=>"Explain pregnancy health care log"
  end
end  