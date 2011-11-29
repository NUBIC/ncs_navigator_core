survey "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1" do
  section "Interview introduction", :reference_identifier=>"pre_pregnancy_int_v11" do

    q_time_stamp_1 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Thank you for agreeing to participate in the National Children’s Study. This interview will take about 20 minutes 
    to complete. Your answers are important to us. There are no right or wrong answers, just those that help us understand your 
    situation. During this interview, we will ask about yourself, your health, where you live, and your feelings about being a 
    part of the National Children’s Study. You can skip over any questions or stop the interview at any time. We will keep everything 
    that you tell us confidential."

    label "First, we’d like to make sure we have your correct name and birth date."
    
    q_prepopulated_name "Name:"
    a :string
    
#     TODO - the name should be pre-populated
    q_name_confirm "Is that your name? ", 
    :data_export_identifier=>"PRE_PREG.NAME_CONFIRM", :pick=>:one
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

#don't have the corresponding identifier
    group "Participant information" do
      dependency :rule=>"A"
      condition_A :q_name_confirm, "!=", :a_1
      
      label "What is your full name?",
      :help_text => "If participant refuses to provide information, re-state confidentiality protections, ask for initials 
        or some other name she would like to be called. Confirm spelling of first name if not previously collected and of last name 
        for all participants."

      q_r_fname "First name", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.R_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_r_lname "Last name",
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.R_LNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    q_prepopulated_date_of_birth "Participant's date of birth"
    a :string

    q_dob_confirm "Is this your birth date?", 
    :help_text => "If participant refuses to provide information, re-state confidentiality protections and that dob is 
    required to determine eligibility. Enter a two digit month, two digit day, and a four digit year. 
    If response was determined to be invalid, ask question again and probe for valid response",
    :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.DOB_CONFIRM"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_confirmed_dob "What is your date of birth?",
    :data_export_identifier=>"PRE_PREG.PERSON_DOB"
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_dob_confirm, "!=", :a_1    

    q_age_elig "Is participant age-eligible? ", 
    :help_text => "Select eligibility based on the calculated age above",
    :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.AGE_ELIG"
    a_1 "Participant is age eligible"
    a_2 "Participant is younger than age of majority"
    a_3 "Participant is over 49"
    a_4 "Age eligibility is unknown"
    
    label "Participant is not eligible"
    dependency :rule => "A"
    condition_A :q_age_elig, "==", :a_2 
    
    label "Case for supervisor review at SC to confirm age eligibility post-interview"
    dependency :rule => "A or B"
    condition_A :q_confirmed_dob, "==", :a_neg_1
    condition_B :q_confirmed_dob, "==", :a_neg_2     
  end
  section "Medical history", :reference_identifier=>"pre_pregnancy_int_v11" do
    group "Current pregnancy information" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3
      
      q_time_stamp_2 "Current date & time", :data_export_identifier=>"PRE_PREG.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime"
    
      label "Next, I have some general questions about your health and health care."

      q_health "Would you say your health in general is...", 
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.HEALTH"
      a_1 "Excellent"
      a_2 "Very good,"
      a_3 "Good,"
      a_4 "Fair, or"
      a_5 "Poor?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_EVER_PREG "Have you ever been pregnant? Please include live births, miscarriages, stillbirths, ectopic pregnancies, 
      and pregnancy terminations.",
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.EVER_PREG"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      label "The next questions are about medical conditions or health problems you might have now or may have had in the past."

      q_asthma "Have you ever been told by a doctor or other health care provider that you had asthma? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.ASTHMA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_highbp "Have you ever been told by a doctor or other health care provider that you had - 
      Hypertension or high blood pressure when you’re not pregnant?",
      :help_text => "Re-read introductory statement as needed", 
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.HIGHBP"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_EVER_PREG, "!=", :a_2

      q_highbp_alt "Have you ever been told by a doctor or other health care provider that you had - 
      Hypertension or high blood pressure?",
      :help_text => "Re-read introductory statement as needed", 
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.HIGHBP"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_EVER_PREG, "==", :a_2

      q_diabetes_1 "Have you ever been told by a doctor or other health care provider that you had - 
      High blood sugar or Diabetes when you're not pregnant?",
      :help_text => "Re-read introductory statement as needed", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.DIABETES_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_EVER_PREG, "!=", :a_2  
  
      q_diabetes_1_alt "Have you ever been told by a doctor or other health care provider that you had - 
      High blood sugar or Diabetes?",
      :help_text => "Re-read introductory statement as needed", 
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.DIABETES_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_EVER_PREG, "==", :a_2          

      q_diabetes_2 "Have you taken any medicine or received other medical treatment for diabetes in the past 12 months? ", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.DIABETES_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A or B"
      condition_A :q_diabetes_notpreg, "==", :a_1
      condition_B :q_diabetes_notpreg_alt, "==", :a_1

      q_diabetes_3 "Have you ever taken insulin? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.DIABETES_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A or B"
      condition_A :q_diabetes_notpreg, "==", :a_1
      condition_B :q_diabetes_notpreg_alt, "==", :a_1

      q_thyroid_1 "Have you ever been told by a doctor or other health care provider that you had - Hypothyroidism, 
      that is, an under active thyroid?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.THYROID_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_thyroid_2 "Have you taken any medicine or received other medical treatment for a thyroid problem in the past 12 months?", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.THYROID_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_thyroid_1, "==", :a_1
    
      q_vitamin "Do you currently take multivitamins, prenatal vitamins, folic acid, or folate?", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.VITAMIN"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"    
    
      label "This next question is about where you go for routine health care."

      q_hlth_care "What kind of place do you usually go to when you need routine or preventive care, such as a physical 
      examination or check-up?", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.HLTH_CARE"
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
  section "Health insurance", :reference_identifier=>"pre_pregnancy_int_v11" do
    group "Health insurance information" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3
          
      q_time_stamp_3 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_3"
      a :datetime, :custom_class => "datetime"      
  
      label "Now I'm going to switch to another subject and ask about health insurance."
  
      q_insure "Are you currently covered by any kind of health insurance or some other kind of health care plan? ", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.INSURE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Health insurance" do
      dependency :rule=>"A"
      condition_A :q_insure, "==", :a_1
           
      label "Now I'll read a list of different types of insurance. Please tell me which types you currently have. Do you currently have...", 
      :help_text => "Re-read introductory statement (Do you currently have...) as needed"
    
      q_ins_employ "Insurance through an employer or union either through yourself or another family member? ", :pick=>:one,
      :data_export_identifier=>"PRE_PREG.INS_EMPLOY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_ins_medicaid "Medicaid or any government-assistance plan for those with low incomes or a disability?", :pick=>:one,
      :data_export_identifier=>"PRE_PREG.INS_MEDICAID"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_ins_tricare "TRICARE, VA, or other military health care? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.INS_TRICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_ins_ihs "Indian Health Service? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.INS_IHS"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_ins_medicaire "Medicare, for people with certain disabilities? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.INS_MEDICARE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_ins_oth "Any other type of health insurance or health coverage plan? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.INS_OTH"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
  end
  section "Housing characteristics", :reference_identifier=>"pre_pregnancy_int_v11" do
    group "Housing characteristics information" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3
      
      q_time_stamp_4 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_4"
      a :datetime, :custom_class => "datetime"

      label "Now I'd like to find out more about your home and the area in which you live."

      #TODO
      # PROGRAMMER INSTRUCTIONS:
      # • IF OWN_HOME WAS ASKED DURING PREGNANCY SCREENER OR PRE-PREGANCY VISIT, THEN ASK RECENT_MOVE; ELSE SKIP TO OWN_HOME.

      q_recent_move "Have you moved or changed your housing situation since we last spoke with you? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.RECENT_MOVE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_own_home "Is your home...", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.OWN_HOME"
      a_1 "Owned or being bought by you or someone in your household"
      a_2 "Rented by you or someone in your household, or"
      a_3 "Occupied without payment of rent?"
      a_neg_5 "Some other arrangement"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=> "A"
      condition_A :q_recent_move, "==", :a_1
      
      q_own_home_oth "Can you please specify your home arrangement? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.OWN_HOME_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_own_home, "==", :a_neg_5

      q_age_home "Can you tell us, which of these categories do you think best describes when your home or building was built?",
      :help_text => "Show response options on card to participant", :pick=>:one,
      :data_export_identifier=>"PRE_PREG.AGE_HOME"
      a_1 "2001 to present"
      a_2 "1981 to 2000"
      a_3 "1961 to 1980"
      a_4 "1941 to 1960"
      a_5 "1940 or before"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "How long have you lived in this home?"

      q_length_reside "Length reside: number (e.g., 5)", 
      :pick => :one,
      :data_export_identifier=>"PRE_PREG.LENGTH_RESIDE"
      a "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_length_reside_units "Length reside: units (e.g., months)", 
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.LENGTH_RESIDE_UNIT"
      a_1 "Weeks"
      a_2 "Months"
      a_3 "Years"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Now I'm going to ask you about how your home is heated and cooled."

      q_main_heat "Which of these types of heat sources best describes the main heating fuel source for your home?",
      :help_text => "Show response options on card to participant.",
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.MAIN_HEAT"
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
      :data_export_identifier=>"PRE_PREG.MAIN_HEAT_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_main_heat, "==", :a_neg_5

      q_heat2 "Are there any other types of heat you use regularly during the heating season 
      to heat your home?",
      :help_text => "Show response options on card to participant. 
      Probe for any other responses: Do you have any space heaters, or any secondary method for heating your home? 
      Select all that apply.", :pick=>:any, 
      :data_export_identifier=>"PRE_PREG_HEAT2.HEAT2"
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

      q_enter_heat2_oth "Other secondary heating fuel source", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG_HEAT2.HEAT2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_heat2, "==", :a_neg_5
      condition_B :q_heat2, "!=", :a_neg_1
      condition_C :q_heat2, "!=", :a_neg_2

      q_cooling "Does your home have any type of cooling or air conditioning besides fans? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.COOLING"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cool "Not including fans, which of the following kinds of cooling systems do you regularly use?",
      :help_text => "Probe for any other responses. Select all that apply", 
       :pick=>:any, 
       :data_export_identifier=>"PRE_PREG_COOL.COOL"
      a_1 "Windows or wall air conditioners"
      a_2 "Central air conditioning"
      a_3 "Evaporative cooler (swamp cooler), or"
      a_4 "No cooling or air conditioning regularly used"
      a_neg_5 "Some other cooling system"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_cooling, "==", :a_1

      q_enter_cool_oth "Other cooling system", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG_COOL.COOL_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C and D"
      condition_A :q_cool, "==", :a_neg_5
      condition_B :q_cool, "!=", :a_4
      condition_C :q_cool, "!=", :a_neg_1
      condition_D :q_cool, "!=", :a_neg_2                  

      q_time_stamp_5 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_5"
      a :datetime, :custom_class => "datetime"      

      label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the ceiling 
      or walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof, or floods."

      q_water "In the past 12 months, have you seen any water damage inside your home? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.WATER"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_mold "In the past 12 months, have you seen any mold or mildew on walls or other surfaces other 
      than the shower or bathtub, inside your home? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.MOLD"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_room_mold "In which rooms have you seen the mold or mildew?",
      :help_text => "Probe for any other responses: Any other rooms? Select all that apply", 
      :pick=>:any,
      :data_export_identifier=>"PRE_PREG_ROOM_MOLD.ROOM_MOLD"
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
      :data_export_identifier=>"PRE_PREG_ROOM_MOLD.ROOM_MOLD_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_room_mold, "==", :a_neg_5
      condition_B :q_room_mold, "!=", :a_neg_1
      condition_C :q_room_mold, "!=", :a_neg_2            

      q_time_stamp_6 "Insert date/time stamp", 
      :data_export_identifier=>"PRE_PREG.TIME_STAMP_6"
      a :datetime, :custom_class => "datetime"

      label "The next few questions ask about any recent additions or renovations to your home."

      q_renovate "In the past 12 months, have any additions been built onto your home to make it bigger or renovations 
      or other construction been done in your home? Include only major projects. Do not count smaller projects such as painting, 
      wallpapering, carpeting or refinishing floors.", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.RENOVATE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_renovate_room "Which rooms were renovated?",
      :help_text => "Probe for any other responses: Any others? Select all that apply", 
      :pick=>:any, 
      :data_export_identifier=>"PRE_PREG_PRENOVATE_ROOM.RENOVATE_ROOM"
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
      condition_A :q_renovate, "==", :a_1

      q_enter_renovate_room_oth "Other rooms that were renovated", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG_PRENOVATE_ROOM.RENOVATE_ROOM_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_renovate_room, "==", :a_neg_5
      condition_B :q_renovate_room, "!=", :a_neg_1
      condition_C :q_renovate_room, "!=", :a_neg_2      

      q_decorate "In the past 12 months, were any smaller projects done in your home, such as painting, wallpapering, 
      refinishing floors, or installing new carpet?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.DECORATE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_decorate_room "In which rooms were these smaller projects done?",
      :help_text => "Probe for any other responses: Any others? Select all that apply", 
      :pick=>:any, 
      :data_export_identifier=>"PRE_PREG_PDECORATE_ROOM.DECORATE_ROOM"
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
      condition_A :q_decorate, "==", :a_1

      q_enter_decorate_room_oth "Other rooms where smaller projects were done", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG_PDECORATE_ROOM.DECORATE_ROOM_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_decorate_room, "==", :a_neg_5
      condition_B :q_decorate_room, "!=", :a_neg_1
      condition_C :q_decorate_room, "!=", :a_neg_2
    
      q_time_stamp_7 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_7"
      a :datetime, :custom_class => "datetime"      

      label "Now I'd like to ask about the water in your home."

      q_water_drink "What water source in your home do you use most of the time for drinking? ", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.WATER_DRINK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_water_drink_oth "Other source of drinking", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.WATER_DRINK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_water_drink, "==", :a_neg_5

      q_water_cook "What water source in your home is used most of the time for cooking?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.WATER_COOK"
      a_1 "Tap water,"
      a_2 "Filtered tap water,"
      a_3 "Bottled water, or"
      a_neg_5 "Some other source?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_water_cook_oth "Other source of cooking water", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.WATER_COOK_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_water_cook, "==", :a_neg_5   
    end       
  end
  section "Household composition and demographics", :reference_identifier=>"pre_pregnancy_int_v11" do
    group "Household composition and demographics" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3
       
      q_time_stamp_8 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_8"
      a :datetime, :custom_class => "datetime"
  
      label "Now, I'd like to ask some questions about your schooling and employment."
  
      q_educ "What is the highest degree or level of school that you have completed?",
      :help_text => "Show response options on card to participant.",
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.EDUC"
      a_1 "Less than a high school diploma or GED"
      a_2 "High school diploma or GED"
      a_3 "Some college but no degree"
      a_4 "Associate degree"
      a_5 "Bachelor’s degree (e.g., BA, BS)"
      a_6 "Post graduate degree (e.g., Masters or doctoral)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_working "Are you currently working at any full or part time jobs?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.WORKING"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Work information" do
      dependency :rule=>"A"
      condition_A :q_working, "==", :a_1
            
      q_enter_hours "Approximately how many hours each week are you working?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.HOURS"
      a_1 "Number of hours (double check if > 60)", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_shift_work "Do you work shifts that starts after 2 pm?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.SHIFT_WORK"
      a_1 "Yes"
      a_2 "No"
      a_3 "Sometimes"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Additional questions" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3   

      q_time_stamp_9 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_9"
      a :datetime, :custom_class => "datetime"
     
      label "The next questions may be similar to those asked the last time we contacted you, 
      but we are asking them again because sometimes the answers change."
  
      q_maristat "I’d like to ask about your marital status. Are you:",
      :help_text => "Probe for current marital status", :pick => :one, 
      :data_export_identifier=>"PRE_PREG.MARISTAT"
      a_1 "Married,"
      a_2 "Not married but living together with a partner"
      a_3 "Never been married,"
      a_4 "Divorced,"
      a_5 "Separated, or"
      a_6 "Widowed?"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Spouse information" do
      dependency :rule=>"A or B"
      condition_A :q_maristat, "==", :a_1
      condition_B :q_maristat, "==", :a_2
            
      q_sp_educ "What is the highest degree or level of school that your spouse or partner has completed?",
      :help_text => "Show response options on card to participant.",
      :pick => :one, 
      :data_export_identifier=>"PRE_PREG.SP_EDUC"
      a_1 "Less than a high school diploma or GED"
      a_2 "High school diploma or GED"
      a_3 "Some college but no degree"
      a_4 "Associate degree"
      a_5 "Bachelor's degree (e.g., BA, BS)"
      a_6 "Post graduate degree (e.g., MASTERS OR DOCTORAL)"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_sp_ethnicity "Does your spouse or partner consider himself [or herself, if volunteered] to be Hispanic, or Latino [Latina]?",
      :pick=>"one", 
      :data_export_identifier=>"PRE_PREG.SP_ETHNICITY"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
  
      q_sp_race "What race does your spouse (or partner) consider himself [or herself, if volunteered] to be? 
      You may select one or more.",
      :help_text => "Probe: Anything else? Show response options on card to participant. 
      Select all that apply. only use \"some other race\" if volunteered", 
      :pick=>"any", 
      :data_export_identifier=>"PRE_PREG_SP_RACE.SP_RACE"
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
      :data_export_identifier=>"PRE_PREG_SP_RACE.SP_RACE_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A and B and C"
      condition_A :q_sp_race, "==", :a_neg_5
      condition_B :q_sp_race, "!=", :a_neg_1
      condition_C :q_sp_race, "!=", :a_neg_2                              
    end
  end     
  section "Family income", :reference_identifier=>"pre_pregnancy_int_v11" do 
    group "Family income information" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3
      
      q_time_stamp_10 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_10"
      a :datetime, :custom_class => "datetime"    
    
      label "Now I’m going to ask a few questions about your income.  Family income is important in analyzing the data we 
      collect and is often used in scientific studies to compare groups of people who are similar. Please remember that all the 
      information you provide is confidential."
    
      # TODO : [CURRENT YEAR – 1]
      label "Please think about your total combined family income during [CURRENT YEAR – 1] for all members of the family."

      q_hh_members "How many household members are supported by your total combined family income?",
      :help_text => "Response must be > 0 and < 15", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.HH_MEMBERS"
      a_number "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      # TODO == • DISPLAY  HARD EDIT IF RESPONSE > HH_MEMBERS 
      q_num_child "How many of those people are children? Please include anyone under 18 years or anyone 
      older than 18 years and in high school.", 
      :help_text => "Verify if responce > than the answer above, or if responce is > 10",
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.NUM_CHILD"
      a_1 "Number", :integer
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_hh_members, "==", :a_number 

      q_income "Of these income groups, which category best represents your combined family income during the last calendar year?",
      :help_text => "Show response options on card to participant.", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.INCOME"
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
  section "Tracing questions", :reference_identifier=>"pre_pregnancy_int_v11" do
    group "Tracing questions" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3
      
      q_time_stamp_11 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_11"
      a :datetime, :custom_class => "datetime"

      label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember 
      that all the information you provide is confidential and will not be provided to anyone outside the National Children’s Study."
      
      q_have_email "Do you have an email address?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.HAVE_EMAIL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Email information" do
      dependency :rule=>"A"
      condition_A :q_have_email, "==", :a_1      

      q_email_2 "May we use your personal email address to make future study appointments or send appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.EMAIL_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_email_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.EMAIL_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_email "What is the best email address to reach you?", :pick=>:one, 
      :help_text=>"Example of valid email address such as maryjane@email.com", 
      :data_export_identifier=>"PRE_PREG.EMAIL"
      a_1 "Enter e-mail address:", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Phone information" do
      dependency :rule=>"A and B"
      condition_A :q_age_elig, "!=", :a_2
      condition_B :q_age_elig, "!=", :a_3
            
      q_cell_phone_1 "Do you have a personal cell phone?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.CELL_PHONE_1"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Cell phone information" do
      dependency :rule=>"A"
      condition_A :q_cell_phone_1, "==", :a_1
      
      q_cell_phone_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.CELL_PHONE_2"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cell_phone_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.CELL_PHONE_3"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_cell_phone_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
      :data_export_identifier=>"PRE_PREG.CELL_PHONE_4"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_cell_phone_3, "==", :a_1

      q_enter_cell_phone "What is your personal cell phone number (XXXXXXXXXX)?", :pick=>:one,
      :data_export_identifier=>"PRE_PREG.CELL_PHONE"
      a_1 "Phone number", :string
      a_neg_7 "Participant has no cell phone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    q_contact_1 "Sometimes if people move or change their telephone number, we have difficulty reaching them. Could I 
    have the name of a friend or relative not currently living with you who should know where you could be reached in case we 
    have trouble contacting you?", :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A and B"
    condition_A :q_age_elig, "!=", :a_2
    condition_B :q_age_elig, "!=", :a_3

    group "Contact information" do
      dependency :rule=>"A"
      condition_A :q_contact_1, "==", :a_1
      
      q_contact_fname_1 "What is this person’s first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. 
      Confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_FNAME_1"
      a_1 "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_lname_1 "What is this person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_LNAME_1"
      a_1 "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_relate_1 "What is his/her relationship to you?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.CONTACT_RELATE_1"
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
      :data_export_identifier=>"PRE_PREG.CONTACT_RELATE1_OTH"      
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_contact_relate_1, "==", :a_neg_5

      label "What is his/her address?",
      :help_text => "Prompt as needed to complete information"

      q_c_addr1_1 "Address 1 - street/PO Box", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.C_ADDR1_1"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_addr2_1 "Address 2", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.C_ADDR_2_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_unit_1 "Unit", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.C_UNIT_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_city_1 "City", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.C_CITY_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_state_1 "State", :display_type=>:dropdown, :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.C_STATE_1"
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
      :data_export_identifier=>"PRE_PREG.C_ZIPCODE_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      
      q_c_zip4_1 "ZIP+4", 
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.C_ZIP4_1"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      
      q_enter_contact_phone_1 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.CONTACT_PHONE_1"
      a_1 "Phone number", :string
      a_1 "Contact has no telephone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      label "Now I’d like to collect information on a second contact who does not currently live with you. What is this person’s name?"
      
      q_contact_fname_2 "What is the person's first name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_FNAME_2"
      a_first_name "First name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_contact_lname_2 "What is the person's last name?",
      :help_text => "If participant does not want to provide name of contact ask for initials. Confirm spelling of first and last names.", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_LNAME_2"
      a_last_name "Last name", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    group "Second contact information" do
      dependency :rule=>"A and B"
      condition_A :q_contact_fname_2, "==", :a_first_name
      condition_B :q_contact_lname_2, "==", :a_last_name
    
      q_contact_relate_2 "What is his/her relationship to you?", :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.CONTACT_RELATE_2"
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
      :data_export_identifier=>"PRE_PREG.CONTACT_RELATE2_OTH"
      a_1 "Specify", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
      dependency :rule=>"A"
      condition_A :q_contact_relate_2, "==", :a_neg_5

      q_enter_contact_addr_2 "What is his/her address?",
      :help_text => "Prompt as needed to complete information", 
      :pick=>:one
      a_1 "Enter response", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_addr1_2 "Address 1 - street/PO Box",
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.C_ADDR1_2"  
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_addr2_2 "Address 2", 
      :data_export_identifier=>"PRE_PREG.C_ADDR_2_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_unit_2 "Unit", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.C_UNIT_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_city_2 "City", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.C_CITY_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"      

      q_c_state_2 "State", :display_type=>:dropdown,
      :pick=>:one, 
      :data_export_identifier=>"PRE_PREG.C_STATE_2"
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
      :data_export_identifier=>"PRE_PREG.C_ZIPCODE_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_c_zip4_2 "ZIP+4", 
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.C_ZIP4_2"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

      q_enter_contact_phone_2 "What is his/her telephone number (XXXXXXXXXX)?",
      :help_text => "If contact has no telephone ask for telephone number where he/she receives calls", 
      :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_PHONE_2"
      a "Phone number", :string
      a_1 "Contact has no telephone"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    q_time_stamp_12 "Insert date/time stamp", :data_export_identifier=>"PRE_PREG.TIME_STAMP_12"
    a :datetime, :custom_class => "datetime"
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.",
    :help_text => "Explain saqs and return process"
  end
end