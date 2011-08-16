survey "INS_BIO_AdultUrine_DCI_EHPBHI_P2_V1.0" do
  section "BIOSPECIMEN URINE COLLECTION", :reference_identifier=>"AdultUrine_DCI" do
    q_time_stamp_1 "Insert date/time stamp", :data_export_identifier=>"SPEC_URINE.TIME_STAMP_1"
    a :datetime
    
    q_URINE_INTRO "You will now collect a urine sample. I will need to ask you some questions before you collect your urine sample.",
    :pick => :one,
    :data_export_identifier=>"SPEC_URINE.URINE_INTRO"
    a_1 "CONTINUE"
    a_neg_1 "REFUSED"
    
# TODO - tried to accomodate with aditional text next to the question:    
# PROGRAMMER INSTRUCTIONS:
# • HARD EDIT: INCLUDE HARD EDIT IF HOUR OR MINUTES ARE NOT 2 DIGITS (FILL THE SPACE WITH 0 AS NECESSARY)
# • HARD EDIT: INCLUDE HARD EDIT IF HOUR IS NOT BETWEEN 01 AND 12
# • HARD EDIT: INCLUDE HARD EDIT IF MINUTES ARE NOT BETWEEN 00 AND 59
# • FORMAT DATE AS YYYYMMDD
# • HARD EDIT: INCLUDE HARD EDIT IF MONTH IS NOT BETWEEN 01 AND 12.
# • HARD EDIT: INCLUDE HARD EDIT IF DAY IS NOT BETWEEN 01 AND 31.
# • HARD EDIT: INCLUDE HARD EDIT IF YEAR IS < 2011.
    
    label "When did you last urinate? "
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    q_LT_URINE_1 "Last urination – DATE",
    :help_text => "Double check if year is < 2011.",
    :data_export_identifier=>"SPEC_URINE.LT_URINE_1"
    a "DATE", :date
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1    
    
    q_LT_URINE_2 "Last urination – TIME",
    :help_text => "Record the time as HH:MM. Be sure to fill the space with a zero when necessary and 
    to mark the box to choose \"AM\" or \"PM\". For example, if time of last urination was at 2:05PM record \"02:05\" and choose \"PM\". 
    Double check if hour is not between 01 and 12. Double check if minutes are not between 00 and 59. 
    Fill the space with 0 as necessary",
    :data_export_identifier=>"SPEC_URINE.LT_URINE_2", :pick => :one
    a "HH:MM", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1    

    # label "The value you provided is outside the suggested range. (Range = 1 to 15) This value is admissible, but you may wish to verify."
    # dependency :rule=>"A or B"
    # condition_A :q_hipv1_2_hh_members, "<", {:integer_value => "1"}
    # condition_B :q_hipv1_2_hh_members, ">", {:integer_value => "15"}
    
    q_LT_URINE_3 "Last urination – AM/PM",
    :data_export_identifier=>"SPEC_URINE.LT_URINE_3", :pick => :one
    a_1 "AM"
    a_2 "PM"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1    
    
    label "When was the last time you had anything to eat or drink other than water?"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1   
   
    q_LT_EAT_DRINK_1 "Last time ate or drank – DATE",
    :help_text => "Double check if year is < 2011.",
    :data_export_identifier=>"SPEC_URINE.LT_EAT_DRINK_1"
    a "DATE (double check if year is < 2011)", :date
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1    
    
    q_LT_EAT_DRINK_2 "Last time ate or drank – TIME",
    :help_text => "Record the time as HH:MM. Be sure to fill the space with a zero when necessary and to mark the box to 
    choose \"AM\" OR \"PM\". 
    For example, if the last time participant ate or drank was at 2:05 PM record \"02:05\" and choose \"PM\". Double check if 
    hour is not between 01 and 12. Double check if minutes are not between 00 and 59. 
    Fill the space with 0 as necessary",
    :data_export_identifier=>"SPEC_URINE.LT_EAT_DRINK_2", :pick => :one
    a "HH:MM", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1    
    
    q_LT_EAT_DRINK_3 "Last time ate or drank – AM/PM",
    :data_export_identifier=>"SPEC_URINE.LT_EAT_DRINK_3", :pick => :one
    a_1 "AM"
    a_2 "PM"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1    
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    q_ATE_MEAT "How much of what you ate was beef, pork, tuna, or salmon?",
    :pick => :one,
    :data_export_identifier=>"SPEC_URINE.ATE_MEAT"
    a_1 "NONE"
    a_2 "Less than one quarter of the meal"
    a_3 "One quarter to one half of the meal"
    a_4 "Less than three quarters of the meal"
    a_5 "Three quarters to all of the meal"
    a_6 "All of the meal"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    q_CREATINE_SUPP "Do you take creatine supplements?", 
    :help_text => "If the participant asks, explain that creatine supplements are often taken by athletes wishing to gain muscle mass.",
    :pick => :one,
    :data_export_identifier => "SPEC_URINE.CREATINE_SUPP"
    a_1 "YES"
    a_2 "NO"
    a_neg_1 "REFUSED"
    a_neg_2 "DON’T KNOW"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    label "Data collector instructions:",
    :help_text => "- Read urine collection instructions to the participant."
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    label "Data collector instructions:",
    :help_text => "- Prepare the work area while the participant is collecting specimen."
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1

    label "Data collector instructions:",
    :help_text => "- Put on lab coat and gloves."
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    q_SPECIMEN_STATUS "Urine collection status",
    :help_text => "Thank the participant for their sample (or for trying if no sample was collected).", 
    :pick => :one,
    :data_export_identifier => "SPEC_URINE.SPECIMEN_STATUS"
    a_1 "Collected"
    a_2 "Not collected"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1    
    
    label "Data collector instructions:",
    :help_text => "- If the participant has a physical limitation that prevents him/her from providing a urine specimen choose 
    \"Physical limitation\"."
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    label "Data collector instructions:",
    :help_text => "- If participant becomes ill during the visit and is unable to provide a urine specimen or has an emergency that 
    requires termination of the visit before a urine specimen is collected choose \"Participant ill/emergency\"."
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    label "Data collector instructions:",
    :help_text => "- If the collection equipment was not available and urine sample was not collected choose 
    \"Collection equipment not available.\""
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
        
    label "Data collector instructions:",
    :help_text => "- If the urine sample quantity was not sufficient for analysis choose \"Quantity not sufficient.\""
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    label "Data collector instructions:",
    :help_text => "- If there was a language issue due to the participant’s primary language being spanish choose \"Language issue, spanish\""
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
        
    label "Data collector instructions:",
    :help_text => "- If there was a language issue due to the participant’s primary language being a language other than spanish choose 
    \"Language issue, non spanish.\""
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    label "Data collector instructions:",
    :help_text => "- If the participant has a cognitive disability that prevents him/her from understanding the instructions and providing 
    a urine specimen choose \"Cognitive disability.\""
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    label "Data collector instructions:",
    :help_text => "- If there was not a sufficent amount of time for the urine specimen collection choose \"No time.\""
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
    q_SPECIMEN_COMMENTS "Urine collection technical comments",
    :pick => :one,
    :data_export_identifier => "SPEC_URINE.SPECIMEN_COMMENTS"
    a_1 "Physical limitation"
    a_2 "Participant ill/ emergency"
    a_3 "Collection equipment not available"
    a_4 "Quantity not sufficient"
    a_5 "Language issue, spanish"
    a_6 "Language issue, non spanish"
    a_7 "Cognitive disability"
    a_8 "No time"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A "
    condition_A :q_URINE_INTRO, "==", :a_1
    
# TODO:
# PROGRAMMER INSTRUCTION:
# • LIMIT FREE TEXT TO 250 CHARACTERS
    q_SPECIMEN_COMMENT_OTH "Urine collection technical comment other specify", 
    :help_text => "If there are any other urine collection technical comments not listed in the previous question, enter the reason below.",
    :data_export_identifier=>"SPEC_URINE.SPECIMEN_COMMENT_OTH"      
    a_1 "SPECIFY", :string
    dependency :rule=>"A"
    condition_A :q_q_SPECIMEN_COMMENTS, "==", :a_neg_5

 # TODO:
 # PROGRAMMER INSTRUCTIONS:
 # •  CANNOT BE NULL
 # •  HARD EDIT: INCLUDE HARD EDIT IF FORMAT IS NOT AA # # # # # # #-UR## (FORMAT MUST BE AA # # # # # # #-UR##)
 # •  ADD SPECIMEN_TYPE=12, URINE COLLECTION
 #  
 
   q_SPECIMEN_ID "Specimen ID",
   :help_text => "-Record urine collection cup specimen id when participant returns with the sample.
   - Immediately place collection cup in dry ice chamber of the transport cooler per transport instructions.
   - Format must be AA # # # # # # #-UR## 
   - Specimen_type=12, urine collection",
   :data_export_identifier=>"SPEC_URINE.SPECIMEN_ID"      
   a :string
   dependency :rule=>"A "
   condition_A :q_URINE_INTRO, "==", :a_1

   q_COLLECTION_LOCATION "Collection location",
   :help_text => "Record where urine collection occurred",
   :data_export_identifier=>"SPEC_URINE.COLLECTION_LOCATION",
   :pick => :one
   a_1 "Home"
   a_2 "Clinic"
   a_3 "Other location"
   dependency :rule=>"A "
   condition_A :q_URINE_INTRO, "==", :a_1
    
# TODO:
# PROGRAMMER INSTRUCTIONS:
# • IF STUDY CENTER IS PARTICIPATING IN LOI3-ENV-01-D AND SPECIMEN_STATUS = 1, GO TO UR_COOL_DIFFICULT. 
   q_UR_COLL_DIFFICULT "Was the urine collection difficult for you?",
   :pick => :one,
   :data_export_identifier=>"SPEC_URINE.UR_COLL_DIFFICULT"
   a_1 "Yes"
   a_2 "No"
   a_neg_1 "Refused"
   a_neg_2 "Don’t know"
   dependency :rule=>"A and B"
   condition_A :q_URINE_INTRO, "==", :a_1
   condition_B :q_SPECIMEN_STATUS, "==", :a_1
    
   q_UR_COLL_EASIER_COMMENT "Is there anything that would make the urine sample collection easier for you?",
   :pick => :one,
   :data_export_identifier=>"SPEC_URINE.UR_COLL_DIFFICULT"
   a "Comment", :string
   a_neg_1 "Refused"
   a_neg_2 "Don’t know"
   dependency :rule=>"A and B"
   condition_A :q_URINE_INTRO, "==", :a_1
   condition_B :q_SPECIMEN_STATUS, "==", :a_1
   
   q_time_stamp_2 "Insert date/time stamp", :data_export_identifier=>"SPEC_URINE.TIME_STAMP_2"
   a :datetime
   dependency :rule=>"A "
   condition_A :q_URINE_INTRO, "==", :a_1   
  end
end