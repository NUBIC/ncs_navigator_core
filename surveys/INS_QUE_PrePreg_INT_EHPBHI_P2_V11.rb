survey "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1" do
  section "INTERVIEW INTRODUCTION", :reference_identifier=>"pre_pregnancy_int_v11" do

    q_pre_preg_time_stamp_1 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_1"
    a :datetime

    label "Thank you for agreeing to participate in the National Children’s Study. This interview will take about 20 minutes 
    to complete. Your answers are important to us. There are no right or wrong answers, just those that help us understand your 
    situation. During this interview, we will ask about yourself, your health, where you live, and your feelings about being a 
    part of the National Children’s Study. You can skip over any questions or stop the interview at any time. We will keep everything 
    that you tell us confidential."

    label "First, we’d like to make sure we have your correct name and birth date."
    
    q_prepopulated_name "Name:"
    a :string
    
#     TODO - the name should be pre-populated
    q_pre_preg_name_confirm "Is that your name? ", 
    :data_export_identifier=>"PRE_PREG.NAME_CONFIRM", :pick=>:one
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

#don't have the corresponding identifier
    label "What is your full name?
    <br><i>
    - if participant refuses to provide information, re-state confidentiality protections, ask for initials 
      or some other name she would like to be called<br><br>
    - confirm spelling of first name if not previously collected and of last name for all participants.</i>"
    dependency :rule=>"A"
    condition_A :q_pre_preg_name_confirm, "!=", :a_1    

    q_pre_preg_r_fname "FIRST NAME", :display_type=>"string", :data_export_identifier=>"PRE_PREG.R_FNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_name_confirm, "!=", :a_1

    q_pre_preg_r_lname "LAST NAME", :display_type=>"string", :data_export_identifier=>"PRE_PREG.R_LNAME"
    a :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_name_confirm, "!=", :a_1

    q_prepopulated_date_of_birth "[PARTICIPANT'S DATE OF BIRTH AS MM/DD/YYYY]"
    a :date

    q_pre_preg_dob_confirm "Is this your birth date?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.DOB_CONFIRM"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    label "<i>- if participant refuses to provide information, re-state confidentiality protections and that dob is 
    required to determine eligibility. 
    <br><br>- enter a two digit month, two digit day, and a four digit year
    <br><br>- if response was determined to be invalid, ask question again and probe for valid response</i>"
    dependency :rule=>"A"
    condition_A :q_pre_preg_dob_confirm, "!=", :a_1

    q_pre_preg_confirmed_dob "What is your date of birth?",
    :data_export_identifier=>"PRE_PREG.PERSON_DOB"
    a :date
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_dob_confirm, "!=", :a_1    

    q_pre_preg_calc_age_confirmed_dob "<i>calculated age (as of 'today')</i>"
    a :integer

    q_pre_preg_age_elig "Is PARTICIPANT age-eligible? ", :pick=>:one, :data_export_identifier=>"PRE_PREG.AGE_ELIG"
    a_1 "PARTICIPANT IS AGE ELIGIBLE"
    a_2 "PARTICIPANT IS YOUNGER THAN AGE OF MAJORITY"
    a_3 "PARTICIPANT IS OVER 49"
    a_4 "AGE ELIGIBILITY IS UNKNOWN"
    
    label "PARTICIPANT IS NOT ELIGIBLE"
    dependency :rule => "A"
    condition_A :q_pre_preg_age_elig, "==", :a_2 
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.", :data_export_identifier=>"PRE_PREG.END"
    dependency :rule=> "A" 
    condition_A :q_pre_preg_age_elig, "==", :a_2
    
    label "<b>INTERVIEWER INSTRUCTIONS: </b>END THE QUESTIONARE"
    dependency :rule=>"A"
    condition_A :q_pre_preg_age_elig, "==", :a_2

    label "CASE FOR SUPERVISOR REVIEW AT SC TO CONFIRM AGE ELIGIBILITY POST-INTERVIEW"
    dependency :rule => "A or B"
    condition_A :q_pre_preg_confirmed_dob, "==", :a_neg_1
    condition_B :q_pre_preg_confirmed_dob, "==", :a_neg_2     
  end
  section "MEDICAL HISTORY", :reference_identifier=>"pre_pregnancy_int_v11" do
    q_pre_preg_time_stamp_2 "CURRENT DATE & TIME", :data_export_identifier=>"PRE_PREG.TIME_STAMP_2"
    a :datetime
    
    label "Next, I have some general questions about your health and health care."

    q_pre_preg_health "Would you say your health in general is...", 
    :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.HEALTH"
    a_1 "Excellent"
    a_2 "Very good,"
    a_3 "Good,"
    a_4 "Fair, or"
    a_5 "Poor?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_EVER_PREG "Have you ever been pregnant? Please include live births, miscarriages, stillbirths, ectopic pregnancies, 
    and pregnancy terminations.",
    :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.EVER_PREG"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    
    label "The next questions are about medical conditions or health problems you might have now or may have had in the past."

    q_pre_preg_asthma "Have you ever been told by a doctor or other health care provider that you had asthma? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.ASTHMA"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    
    q_pre_preg_highbp "Have you ever been told by a doctor or other health care provider that you had...<br>
    Hypertension or high blood pressure when you’re <b>not pregnant</b>?<br>
        <i>- re-read introductory statement as needed</i>", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.HIGHBP"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_EVER_PREG, "!=", :a_no

    q_pre_preg_highbp_alternative "Have you ever been told by a doctor or other health care provider that you had...<br>
    Hypertension or high blood pressure?<br>
        <i>- re-read introductory statement as needed</i>", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.HIGHBP"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_EVER_PREG, "==", :a_no

    q_pre_preg_diabetes_1 "Have you ever been told by a doctor or other health care provider that you had<br>
    High blood sugar or Diabetes when you're <b>not pregnant</b><br>
        <i>- re-read introductory statement as needed</i>?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.DIABETES_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_EVER_PREG, "!=", :a_no  
  
    q_pre_preg_diabetes_1_alternative "Have you ever been told by a doctor or other health care provider that you had<br>
    High blood sugar or Diabetes?<br>
        <i>- re-read introductory statement as needed</i>", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.DIABETES_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"    

    q_pre_preg_diabetes_2 "Have you taken any medicine or received other medical treatment for diabetes in the past 12 months? ", 
    :pick=>:one,
    :data_export_identifier=>"PRE_PREG.DIABETES_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_pre_preg_diabetes_notpreg, "==", :a_1
    condition_B :q_pre_preg_diabetes_notpreg_alternative, "==", :a_1

    q_pre_preg_diabetes_3 "Have you ever taken insulin? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.DIABETES_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_pre_preg_diabetes_notpreg, "==", :a_1
    condition_B :q_pre_preg_diabetes_notpreg_alternative, "==", :a_1

    q_pre_preg_thyroid_1 "(Have you ever been told by a doctor or other health care provider that you had) Hypothyroidism, 
    that is, an under active thyroid?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.THYROID_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_thyroid_2 "Have you taken any medicine or received other medical treatment for a thyroid problem in the past 12 months?", 
    :pick=>:one,
    :data_export_identifier=>"PRE_PREG.THYROID_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_thyroid_1, "==", :a_1
    
    q_pre_preg_vitamin "Do you currently take multivitamins, prenatal vitamins, folic acid, or folate?", 
    :pick=>:one,
    :data_export_identifier=>"PRE_PREG.VITAMIN"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"    
    
    label "This next question is about where you go for routine health care."

    q_pre_preg_hlth_care "What kind of place do you usually go to when you need routine or preventive care, such as a physical 
    examination or check-up?", 
    :pick=>:one,
    :data_export_identifier=>"PRE_PREG.HLTH_CARE"
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
  section "HEALTH INSURANCE", :reference_identifier=>"pre_pregnancy_int_v11" do
    q_pre_preg_time_stamp_3 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_3"
    a :datetime      
  
    label "Now I'm going to switch to another subject and ask about health insurance."
  
    q_pre_preg_insure "Are you <U>currently</U> covered by any kind of health insurance or some other kind of health care plan? ", 
    :pick=>:one,
    :data_export_identifier=>"PRE_PREG.INSURE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
  
    label "Now I'll read a list of different types of insurance. Please tell me which types you currently have. Do you <b>currently</b>
    have..."
    
    label "<i>re-read introductory statement (Do you <b>currently</b> have…) as needed</i>"
  
    q_pre_preg_ins_employ "Insurance through an employer or union either through yourself or another family member? ", :pick=>:one,
    :data_export_identifier=>"PRE_PREG.INS_EMPLOY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_insure, "==", :a_1
  
    q_pre_preg_ins_medicaid "Medicaid or any government-assistance plan for those with low incomes or a disability?", :pick=>:one,
    :data_export_identifier=>"PRE_PREG.INS_MEDICAID"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_insure, "==", :a_1      
  
    q_pre_preg_ins_tricare "TRICARE, VA, or other military health care? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.INS_TRICARE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_insure, "==", :a_1      
  
    q_pre_preg_ins_ihs "Indian Health Service? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.INS_IHS"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_insure, "==", :a_1      
  
    q_pre_preg_ins_medicaire "Medicare, for people with certain disabilities? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.INS_MEDICARE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_insure, "==", :a_1
    
    q_pre_preg_ins_oth "Any other type of health insurance or health coverage plan? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.INS_OTH"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_insure, "==", :a_1
  end
  section "HOUSING CHARACTERISTICS", :reference_identifier=>"pre_pregnancy_int_v11" do
    q_pre_preg_time_stamp_4 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_4"
    a :datetime

    label "Now I'd like to find out more about your home and the area in which you live."

#TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF OWN_HOME WAS ASKED DURING PREGNANCY SCREENER OR PRE-PREGANCY VISIT, THEN ASK RECENT_MOVE; ELSE SKIP TO OWN_HOME.

    q_pre_preg_recent_move "Have you moved or changed your housing situation since we last spoke with you? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.RECENT_MOVE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_own_home "Is your home...", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.OWN_HOME"
    a_1 "Owned or being bought by you or someone in your household"
    a_2 "Rented by you or someone in your household, or"
    a_3 "Occupied without payment of rent?"
    a_neg_5 "SOME OTHER ARRANGEMENT"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_own_home_oth "Can you please specify your home arrangement? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.OWN_HOME_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_own_home, "==", :a_neg_5

    q_pre_preg_age_home "Can you tell us, which of these categories do you think best describes when your home or building was built?<br><br>
    <i>show response options on card to participant</i>", :pick=>:one,
    :data_export_identifier=>"PRE_PREG.AGE_HOME"
    a_1 "2001 TO PRESENT"
    a_2 "1981 TO 2000"
    a_3 "1961 to 1980"
    a_4 "1941 to 1960"
    a_5 "1940 OR BEFORE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_enter_length_reside "How long have you lived in this home?  ", :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_length_reside "LENGTH RESIDE: NUMBER (e.g., 5)", 
    :data_export_identifier=>"PRE_PREG.LENGTH_RESIDE"
    a "NUMBER", :integer
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_length_reside, "==", :a_1

    q_pre_preg_length_reside_units "LENGTH RESIDE: UNITS (e.g., months)", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.LENGTH_RESIDE_UNIT"
    a_1 "WEEKS"
    a_2 "MONTHS"
    a_3 "YEARS"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_length_reside, "==", :a_1

    label "Now I'm going to ask you about how your home is heated and cooled."

    q_pre_preg_main_heat "Which of these types of heat sources best describes the main heating fuel source for your home?  
    <br><i>show response options on card to participant.</i>", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.MAIN_HEAT"
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

    q_pre_preg_enter_main_heat_oth "OTHER MAIN HEATING FUEL SOURCE", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.MAIN_HEAT_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_main_heat, "==", :a_neg_5

    q_pre_preg_heat2 "Are there any other types of heat you use regularly during the heating season 
    to heat your home?<br><i>
    - show response options on card to participant.<br>
    - probe for any other responses: Do you have any space heaters, or any secondary method for heating your home?<br>
    - select all that apply.</i>", :pick=>:any, 
    :data_export_identifier=>"PRE_PREG_HEAT2.HEAT2"
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
    condition_A :q_pre_preg_main_heat, "==", :a_1
    condition_B :q_pre_preg_main_heat, "==", :a_2
    condition_C :q_pre_preg_main_heat, "==", :a_3
    condition_D :q_pre_preg_main_heat, "==", :a_4
    condition_E :q_pre_preg_main_heat, "==", :a_5
    condition_F :q_pre_preg_main_heat, "==", :a_6
    condition_G :q_pre_preg_main_heat, "==", :a_7
    condition_H :q_pre_preg_main_heat, "==", :a_8

    q_pre_preg_enter_heat2_oth "OTHER SECONDARY HEATING FUEL SOURCE", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG_HEAT2.HEAT2_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_pre_preg_heat2, "==", :a_neg_5
    condition_B :q_pre_preg_heat2, "!=", :a_neg_1
    condition_C :q_pre_preg_heat2, "!=", :a_neg_2            

    q_pre_preg_cooling "Does your home have any type of cooling or air conditioning besides fans? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.COOLING"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_cool "Not including fans, which of the following kinds of cooling systems do you regularly use?
    <br><i>- probe for any other responses<br>
     - select all that apply</i>", :pick=>:any, 
     :data_export_identifier=>"PRE_PREG_COOL.COOL"
    a_1 "Windows or wall air conditioners"
    a_2 "Central air conditioning"
    a_3 "Evaporative cooler (swamp cooler), or"
    a_4 "NO COOLING OR AIR CONDITIONING REGULARLY USED"
    a_neg_5 "Some other cooling system"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_cooling, "==", :a_1

    q_pre_preg_enter_cool_oth "OTHER COOLING SYSTEM", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG_COOL.COOL_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C and D"
    condition_A :q_pre_preg_cool, "==", :a_neg_5
    condition_B :q_pre_preg_cool, "!=", :a_4
    condition_C :q_pre_preg_cool, "!=", :a_neg_1
    condition_D :q_pre_preg_cool, "!=", :a_neg_2                  

    q_pre_preg_time_stamp_5 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_5"
    a :datetime      

    label "Water damage is a common problem that occurs inside of many homes. Water damage includes water stains on the ceiling 
    or walls, rotting wood, and flaking sheetrock or plaster. This damage may be from broken pipes, a leaky roof, or floods."

    q_pre_preg_water "In the past 12 months, have you seen any water damage inside your home? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.WATER"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_mold "In the past 12 months, have you seen any mold or mildew on walls or other surfaces other 
    than the shower or bathtub, inside your home? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.MOLD"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_room_mold "In which rooms have you seen the mold or mildew?<br><i>
    - probe for any other responses: Any other rooms? <br>
    - select all that apply</i>", :pick=>:any,
    :data_export_identifier=>"PRE_PREG_ROOM_MOLD.ROOM_MOLD"
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
    condition_A :q_pre_preg_mold, "==", :a_1

    q_pre_preg_enter_room_mold_oth "OTHER ROOMS WHERE MOLD OR MILDEW WAS SEEN", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG_ROOM_MOLD.ROOM_MOLD_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_pre_preg_room_mold, "==", :a_neg_5
    condition_B :q_pre_preg_room_mold, "!=", :a_neg_1
    condition_C :q_pre_preg_room_mold, "!=", :a_neg_2            

    q_pre_preg_time_stamp_6 "INSERT DATE/TIME STAMP", 
    :data_export_identifier=>"PRE_PREG.TIME_STAMP_6"
    a :datetime

    label "The next few questions ask about any recent additions or renovations to your home."

    q_pre_preg_renovate "In the past 12 months, have any additions been built onto your home to make it bigger or renovations 
    or other construction been done in your home? Include only major projects. Do not count smaller projects such as painting, 
    wallpapering, carpeting or refinishing floors.", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.RENOVATE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_renovate_room "Which rooms were renovated? <br><i>
    - probe for any other responses: Any others?<br>
    - select all that apply</i>", :pick=>:any, 
    :data_export_identifier=>"PRE_PREG_PRENOVATE_ROOM.RENOVATE_ROOM"
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
    condition_A :q_pre_preg_prenovate, "==", :a_1

    q_pre_preg_enter_renovate_room_oth "OTHER ROOMS THAT WERE RENOVATED", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG_PRENOVATE_ROOM.RENOVATE_ROOM_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_pre_preg_prenovate_room, "==", :a_neg_5
    condition_B :q_pre_preg_prenovate_room, "!=", :a_neg_1
    condition_C :q_pre_preg_prenovate_room, "!=", :a_neg_2      

    q_pre_preg_decorate "In the past 12 months, were any smaller projects done in your home, such as painting, wallpapering, 
    refinishing floors, or installing new carpet?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.DECORATE"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_decorate_room "In which rooms were these smaller projects done? <br>
    <i>- probe for any other responses: Any others?<br>
    - select all that apply</i>", :pick=>:any, 
    :data_export_identifier=>"PRE_PREG_PDECORATE_ROOM.DECORATE_ROOM"
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
    condition_A :q_pre_preg_pdecorate, "==", :a_1

    q_pre_preg_enter_decorate_room_oth "OTHER ROOMS WHERE SMALLER PROJECTS WERE DONE", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG_PDECORATE_ROOM.DECORATE_ROOM_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_pre_preg_pdecorate_room, "==", :a_neg_5
    condition_B :q_pre_preg_pdecorate_room, "!=", :a_neg_1
    condition_C :q_pre_preg_pdecorate_room, "!=", :a_neg_2
    
    q_pre_preg_time_stamp_7 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_7"
    a :datetime      

    label "Now I'd like to ask about the water in your home."

    q_pre_preg_water_drink "What water source in your home do you use most of the time for drinking? ", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.WATER_DRINK"
    a_1 "Tap water,"
    a_2 "Filtered tap water,"
    a_3 "Bottled water, or"
    a_neg_5 "Some other source?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_enter_water_drink_oth "OTHER SOURCE OF DRINKING", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.WATER_DRINK_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_water_drink, "==", :a_neg_5

    q_pre_preg_water_cook "What water source in your home is used most of the time for cooking?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.WATER_COOK"
    a_1 "Tap water,"
    a_2 "Filtered tap water,"
    a_3 "Bottled water, or"
    a_neg_5 "Some other source?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_enter_water_cook_oth "OTHER SOURCE OF COOKING WATER", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.WATER_COOK_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_water_cook, "==", :a_neg_5          
  end
  section "HOUSEHOLD COMPOSITION AND DEMOGRAPHICS", :reference_identifier=>"pre_pregnancy_int_v11" do 
    q_pre_preg_time_stamp_8 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_8"
    a :datetime
  
    label "Now, I'd like to ask some questions about your schooling and employment."
  
    q_pre_preg_educ "What is the highest degree or level of school that you have completed?<br>
    <i>show response options on card to participant.</i>",
     :pick=>:one, 
     :data_export_identifier=>"PRE_PREG.EDUC"
    a_1 "LESS THAN A HIGH SCHOOL DIPLOMA OR GED"
    a_2 "HIGH SCHOOL DIPLOMA OR GED"
    a_3 "SOME COLLEGE BUT NO DEGREE"
    a_4 "ASSOCIATE DEGREE"
    a_5 "BACHELOR’S DEGREE (E.G., BA, BS)"
    a_6 "POST GRADUATE DEGREE (E.G., MASTERS OR DOCTORAL)"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
  
    q_pre_preg_working "Are you currently working at any full or part time jobs?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.WORKING"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
  
    q_pre_preg_enter_hours "Approximately how many hours each week are you working?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.HOURS"
    a_1 "NUMBER OF HOURS (double check if > 60)", :integer
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_working, "==", :a_1
  
    q_pre_preg_shift_work "Do you work shifts that starts after 2 pm?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.SHIFT_WORK"
    a_1 "YES"
    a_2 "NO"
    a_3 "SOMETIMES"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_working, "==", :a_1
  
    q_pre_preg_time_stamp_9 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_9"
    a :datetime
     
    label "The next questions may be similar to those asked the last time we contacted you, 
    but we are asking them again because sometimes the answers change."
  
    q_pre_preg_maristat "I’d like to ask about your marital status. Are you: <br>
    <i>- probe for current marital status</i>", :pick => :one, 
    :data_export_identifier=>"PRE_PREG.MARISTAT"
    a_1 "Married,"
    a_2 "Not married but living together with a partner"
    a_3 "Never been married,"
    a_4 "Divorced,"
    a_5 "Separated, or"
    a_6 "Widowed?"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"        
  
    q_pre_preg_sp_educ "What is the highest degree or level of school that your spouse or partner has completed?
    <i>- show response options on card to participant.</i>",
    :pick => :one, 
    :data_export_identifier=>"PRE_PREG.SP_EDUC"
    a_1 "LESS THAN A HIGH SCHOOL DIPLOMA OR GED"
    a_2 "HIGH SCHOOL DIPLOMA OR GED"
    a_3 "SOME COLLEGE BUT NO DEGREE"
    a_4 "ASSOCIATE DEGREE"
    a_5 "BACHELOR'S DEGREE (E.G., BA, BS)"
    a_6 "POST GRADUATE DEGREE (E.G., MASTERS OR DOCTORAL)"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_pre_preg_maristat, "==", :a_1
    condition_B :q_pre_preg_maristat, "==", :a_2
  
    q_pre_preg_sp_ethnicity "Does your spouse or partner consider himself [OR HERSELF, IF VOLUNTEERED] to be Hispanic, or Latino [LATINA]?",
    :pick=>"one", 
    :data_export_identifier=>"PRE_PREG.SP_ETHNICITY"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A or B"
    condition_A :q_pre_preg_maristat, "==", :a_1
    condition_B :q_pre_preg_maristat, "==", :a_2
  
    q_pre_preg_sp_race "What race does your spouse (or partner) consider himself [OR HERSELF, IF VOLUNTEERED] to be? 
    You may select one or more.
    <br><br>
    <i>probe: Anything else? <br>
    - show response options on card to participant.<br>
    - select all that apply. only use “some other race” if volunteered</i>", 
    :pick=>"any", 
    :data_export_identifier=>"PRE_PREG_SP_RACE.SP_RACE"
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
    condition_A :q_pre_preg_maristat, "==", :a_1
    condition_B :q_pre_preg_maristat, "==", :a_2
  
    q_pre_preg_sp_race_oth "OTHER RACE", 
    :pick=>:one, 
    :data_export_identifier=>"PRE_PREG_SP_RACE.SP_RACE_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_pre_preg_sp_race, "==", :a_neg_5
    condition_B :q_pre_preg_sp_race, "!=", :a_neg_1
    condition_C :q_pre_preg_sp_race, "!=", :a_neg_2                              
  end     
  section "FAMILY INCOME", :reference_identifier=>"pre_pregnancy_int_v11" do    
    q_pre_preg_time_stamp_10 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_10"
    a :datetime    
    
    label "Now I’m going to ask a few questions about your income.  Family income is important in analyzing the data we 
    collect and is often used in scientific studies to compare groups of people who are similar. Please remember that all the 
    information you provide is confidential."
    
    # TODO : [CURRENT YEAR – 1]
    label "Please think about your total combined family income during [CURRENT YEAR – 1] for all members of the family."

    q_pre_preg_enter_hh_members "How many household members are supported by your total combined family income?", 
    :pick=>:one
    a_1 "ENTER RESPONSE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_hh_members "NUMBER HOUSEHOLD MEMBERS SUPPORTED BY TOTAL COMBINED FAMILY INCOME", 
    :data_export_identifier=>"PRE_PREG.HH_MEMBERS"
    a_total "SPECIFY", :integer
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_hh_members, "==", :a_1

    label "The value you provided is outside the suggested range. (Range = 1 to 15) This value is admissible, but you may wish to verify."
    dependency :rule=>"A or B"
    condition_A :q_pre_preg_hh_members, "<", {:integer_value => "1"}
    condition_B :q_pre_preg_hh_members, ">", {:integer_value => "15"}

    q_pre_preg_enter_num_child "How many of those people are children? Please include anyone under 18 years or anyone 
    older than 18 years and in high school.", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A and B and C"
    condition_A :q_pre_preg_enter_hh_members, "==", :a_1
    condition_B :q_pre_preg_hh_members, ">", {:integer_value => "0"}
    condition_C :q_pre_preg_hh_members, "<", {:integer_value => "15"}    

# TODO == • DISPLAY  HARD EDIT IF RESPONSE > HH_MEMBERS 
    q_pre_preg_num_child "NUMBER OF CHILDREN 
    <br><i>Check the entry field for this question with the answer above. If response is higher, ask the question again</i>", 
    :data_export_identifier=>"PRE_PREG.NUM_CHILD"
    a "SPECIFY", :integer
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_num_child, "==", :a_1

    label "The value you provided is outside the suggested range. (Range = 0 to 10) This value is admissible, but you may wish to verify."
    dependency :rule=>"A"
    condition_A :q_pre_preg_num_child, ">", {:integer_value => "10"}

    q_pre_preg_income "Of these income groups, which category best represents your combined family income during the last calendar year?<br>
    <i>show response options on card to participant.</i>", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.INCOME"
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
  section "TRACING QUESTIONS", :reference_identifier=>"pre_pregnancy_int_v11" do  
    q_pre_preg_time_stamp_11 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_11"
    a :datetime

    label "The next set of questions asks about different ways we might be able to keep in touch with you. Please remember 
    that all the information you provide is confidential and will not be provided to anyone outside the National Children’s Study."

    q_pre_preg_have_email "Do you have an email address?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.HAVE_EMAIL"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_email_2 "May we use your personal email address to make future study appointments or send appointment reminders?", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.EMAIL_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_have_email, "==", :a_1      

    q_pre_preg_email_3 "May we use your personal email address for questionnaires (like this one) that you can answer over the Internet?", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.EMAIL_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_have_email, "==", :a_1

    q_pre_preg_enter_email "What is the best email address to reach you?", :pick=>:one, 
    :help_text=>"EXAMPLE OF VALID EMAIL ADDRESS SUCH AS MARYJANE@EMAIL.COM", 
    :data_export_identifier=>"PRE_PREG.EMAIL"
    a_1 "ENTER E-MAIL ADDRESS:", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_email, "==", :a_1      

    q_pre_preg_cell_phone_1 "Do you have a personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.CELL_PHONE_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"


    q_pre_preg_cell_phone_2 "May we use your personal cell phone to make future study appointments or for appointment reminders?", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.CELL_PHONE_2"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_cell_phone_1, "==", :a_1

    q_pre_preg_cell_phone_3 "Do you send and receive text messages on your personal cell phone?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.CELL_PHONE_3"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_cell_phone_1, "==", :a_1      

    q_pre_preg_cell_phone_4 "May we send text messages to make future study appointments or for appointment reminders?", :pick=>:one,
    :data_export_identifier=>"PRE_PREG.CELL_PHONE_4"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_cell_phone_3, "==", :a_1

    q_pre_preg_enter_cell_phone "What is your personal cell phone number (XXXXXXXXXX)?", :pick=>:one,
    :data_export_identifier=>"PRE_PREG.CELL_PHONE"
    a_1 "PHONE NUMBER", :string
    a_neg_7 "PARTICIPANT HAS NO CELL PHONE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_contact_1 "Sometimes if people move or change their telephone number, we have difficulty reaching them. Could I 
    have the name of a friend or relative not currently living with you who should know where you could be reached in case we 
      have trouble contacting you?", :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_1"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_contact_fname_1 "What is this person’s first name?<br>
    <i>
    - if participant does not want to provide name of contact ask for initials<br>
    - confirm spelling of first and last names</i>", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_FNAME_1"
    a_1 "FIRST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_contact_1, "==", :a_1

    q_pre_preg_contact_lname_1 "What is this person's last name?<br>
    <i>
    - if participant does not want to provide name of contact ask for initials<br>
    - confirm spelling of first and last names</i>", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_LNAME_1"
    a_1 "LAST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_contact_1, "==", :a_1      

    q_pre_preg_contact_relate_1 "What is his/her relationship to you?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.CONTACT_RELATE_1"
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
    condition_A :q_pre_preg_contact_1, "==", :a_1

    q_pre_preg_enter_contact_relate1_oth "OTHER RELATIONSHIP OF CONTACT", :pick=>:one,
    :data_export_identifier=>"PRE_PREG.CONTACT_RELATE1_OTH"      
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_contact_relate_1, "==", :a_neg_5

    q_pre_preg_enter_contact_addr_1 "What is his/her address?<br>
    <i>- prompt as needed to complete information</i>", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_c_addr1_1 "ADDRESS 1 - STREET/PO BOX", :data_export_identifier=>"PRE_PREG.C_ADDR1_1"  
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_1, "==", :a_1

    q_pre_preg_c_addr2_1 "ADDRESS 2", :data_export_identifier=>"PRE_PREG.C_ADDR2_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_1, "==", :a_1

    q_pre_preg_c_unit_1 "UNIT", :data_export_identifier=>"PRE_PREG.C_UNIT_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_1, "==", :a_1

    q_pre_preg_c_city_1 "CITY", :data_export_identifier=>"PRE_PREG.C_CITY_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_1, "==", :a_1

    q_pre_preg_c_state_1 "STATE", :display_type=>"dropdown", :data_export_identifier=>"PRE_PREG.C_STATE_1"
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
    condition_A :q_pre_preg_enter_contact_addr_1, "==", :a_1

    q_pre_preg_c_zipcode_1 "ZIP CODE", :data_export_identifier=>"PRE_PREG.C_ZIPCODE_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_1, "==", :a_1

    q_pre_preg_c_zip4_1 "ZIP+4", :data_export_identifier=>"PRE_PREG.C_ZIP4_1"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_1, "==", :a_1

    q_pre_preg_enter_contact_phone_1 "What is his/her telephone number (XXXXXXXXXX)?<br>
    <i>- if contact has no telephone ask for telephone number where he/she receives calls</i>", 
    :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.CONTACT_PHONE_1"
    a_1 "PHONE NUMBER", :string
    a_1 "CONTACT HAS NO TELEPHONE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"


# *** CONTACT_2 doesn't exist
    label "Now I’d like to collect information on a second contact who does not currently live with you. What is this person’s name?"

    q_pre_preg_enter_contact_2 "What is the person's name?<br>
    <i>
    - if participant does not want to provide name of contact ask for initials<br>
    - confirm spelling of first and last names </i>", :pick=>:one
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    a_neg_7 "NO SECOND CONTACT PROVIDED"

    q_pre_preg_contact_fname_2 "What is the person's first name?<br><br>
    <i>
    - if participant does not want to provide name of contact ask for initials<br>
    - confirm spelling of first and last names </i>", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_FNAME_2"
    a_1 "FIRST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_2, "==", :a_1

    q_pre_preg_contact_lname_2 "What is the person's last name?<br><br>
    <i>
    - if participant does not want to provide name of contact ask for initials<br>
    - confirm spelling of first and last names </i>", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_LNAME_2"
    a_1 "LAST NAME", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_2, "==", :a_1      

    q_pre_preg_contact_relate_2 "What is his/her relationship to you?", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.CONTACT_RELATE_2"
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
    condition_A :q_pre_preg_enter_contact_2, "==", :a_1

    q_pre_preg_enter_contact_relate2_oth "OTHER RELATIONSHIP OF SECOND CONTACT", :pick=>:one, 
    :data_export_identifier=>"PRE_PREG.CONTACT_RELATE_2_OTH"
    a_1 "SPECIFY", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"
    dependency :rule=>"A"
    condition_A :q_pre_preg_contact_relate_2, "==", :a_neg_5


    q_pre_preg_enter_contact_addr_2 "What is his/her address?<br>
    <i>- prompt as needed to complete information</i>", :pick=>:one
    a_1 "ENTER RESPONSE", :string
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_c_addr1_2 "ADDRESS 1 - STREET/PO BOX", 
    :data_export_identifier=>"PRE_PREG.C_ADDR1_2"  
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_2, "==", :a_1

    q_pre_preg_c_addr2_2 "ADDRESS 2", 
    :data_export_identifier=>"PRE_PREG.C_ADDR2_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_2, "==", :a_1

    q_pre_preg_c_unit_2 "UNIT", :data_export_identifier=>"PRE_PREG.C_UNIT_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_2, "==", :a_1

    q_pre_preg_c_city_2 "CITY", :data_export_identifier=>"PRE_PREG.C_CITY_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_2, "==", :a_1

    q_pre_preg_c_state_2 "STATE", :display_type=>"dropdown", 
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
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_2, "==", :a_1

    q_pre_preg_c_zipcode_2 "ZIP CODE", :data_export_identifier=>"PRE_PREG.C_ZIPCODE_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_2, "==", :a_1

    q_pre_preg_c_zip4_2 "ZIP+4", :data_export_identifier=>"PRE_PREG.C_ZIP4_2"
    a :string
    dependency :rule=>"A"
    condition_A :q_pre_preg_enter_contact_addr_2, "==", :a_1

    q_pre_preg_enter_contact_phone_2 "What is his/her telephone number (XXXXXXXXXX)?<br>
    <i>- if contact has no telephone ask for telephone number where he/she receives calls</i>", 
    :pick=>:one, :data_export_identifier=>"PRE_PREG.CONTACT_PHONE_2"
    a "PHONE NUMBER", :string
    a_1 "CONTACT HAS NO TELEPHONE"
    a_neg_1 "REFUSED"
    a_neg_2 "DON'T KNOW"

    q_pre_preg_time_stamp_12 "INSERT DATE/TIME STAMP", :data_export_identifier=>"PRE_PREG.TIME_STAMP_12"
    a :datetime
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey. 
    This concludes the interview portion of our visit.<br>
    <i>explain saqs and return process</i>", :data_export_identifier=>"PRE_PREG.END"
  end
end