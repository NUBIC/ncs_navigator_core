survey "INS_BIO_CordBlood_DCI_EHPBHI_P2_V1.0" do
  section "Biospecimen Cord Blood Instrument (EH, PB, HI)", :reference_identifier=>"LIPregNotPreg_INT" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"SPEC_CORD_BLOOD.TIME_STAMP_1"
    a :datetime
    
    q_PERSON_DOB "Mother’s date of birth (YYYYMMDD)",
    :help_text => "Record the mother’s date of birth. 
    The two digit month, the two digit day, and the four digit year should be recorded. 
    Please verify if month is not between 1 and 12, if day is not between 1 and 31 and if year < 1960.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.PERSON_DOB"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_CHILD_DOB "Child’s date of birth (YYYYMMDD)",
    :help_text => "Record the child’s date of birth. 
    The two digit month, the two digit day, and the four digit year should be recorded. 
    Please verify if month is not between 1 and 12, if day is not between 1 and 31 and if year < 2011.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CHILD_DOB"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label_CB003 "Time of child’s birth: hour\time of child’s birth : minute\time of child’s birth, AM/PM",
    :help_text => "Record the time of the child’s birth. Be sure to fill the space with a zero when necessary and 
    to mark the box to choose \"AM\" or \"PM\". For example, if the child was born at 2:05 PM record \"02:05\" and 
    choose \"PM\"."
    
    q_CORD_BIRTH_HR "Time of child’s birth: hour",
    :help_text=> "Verify if value is not 2 digits (fill the space with 0 as necessary). The value must be between 01 and 12.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_BIRTH_HR"
    a "Hour: HH", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_CORD_BIRTH_MIN "Time of child’s birth: minute",
    :help_text=> "Verify if value is not 2 digits (fill the space with 0 as necessary). The value must be between 00 and 59.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_BIRTH_MIN"
    a "Minutes: MM", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"  

    q_CORD_BIRTH_UNIT "Time of child’s birth: AM/PM",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_BIRTH_UNIT"
    a_1 "AM"
    a_2 "PM"    
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_CHILD_SEX "Child’s gender",
    :help_text=> "Select the child’s gender.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_3 "Both"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_CORD_COLLECTION "Cord blood collection status: Was the cord blood collected for the NCS?",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_COLLECTION"
    a_1 "Yes"
    a_2 "No"
    
    q_CORD_NOTCOL_COMMENT "Cord blood not collected reason",
    :help_text => "Please choose the one reason that best describes why the blood was not collected. 
    choose \"Parent chose to bank\" to indicate parents have chosen to participate in a private cord blood banking program. 
    Choose \"Other banking program\" to indicate that parents have chosen to participate in a public cord blood 
    banking program.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_NOTCOL_COMMENT"
    a_1 "Parents chose to bank"
    a_2 "Need for clinical purposes"
    a_3 "Other banking program"
    a_4 "Parent/guardian refusal"
    a_5 "Quantity not sufficient"
    a_6 "Defective collection equipment"
    a_7 "No time"
    a_8 "Precipitous delivery"
    a_9 "Study staff not present at delivery"
    a_10 "NCS not notified of birth in time"
    a_11 "Participant not identified prior to birth"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_2
    
    q_CORD_NOTCOL_OTH "Cord blood not collected",
    :help_text => "If the cord blood was not collected for a reason not listed in the previous question, type 
    in the reason below",
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_NOTCOL_OTHT"
    a "Specify", :string
    dependency :rule=>"A"
    condition_A :q_CORD_NOTCOL_COMMENT, "==", :a_neg_5
    
    q_CORD_COLLECT_DATE "Date cord blood collected (YYYYMMDD)",
    :help_text => "Record the date the cord blood was collected. 
    The two digit month, the two digit day, and the four digit year should be recorded. 
    Please verify if month is not between 1 and 12, if day is not between 1 and 31 and if year < 2011.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_COLLECT_DATE"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label_BD008 "Time of cord blood collection: hour\time of cord blood collection : minute\time of cord blood collection, AM/PM",
    :help_text => "Record the time of the cord blood collection be sure to fill the space with a zero when necessary 
    and to choose \"AM\" or \"PM\". For example, if the child was born at 2:05 PM record \"02:05\" and choose \"PM\". "
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1
    
    q_CORD_COLLECT_HR "Time of cord blood collection: hour",
    :help_text=> "Verify if value is not 2 digits (fill the space with 0 as necessary). The value must be between 01 and 12.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_COLLECT_HR"
    a "Hour: HH", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1    
    
    q_CORD_COLLECT_MIN "Time of cord blood collection: minute",
    :help_text=> "Verify if value is not 2 digits (fill the space with 0 as necessary). The value must be between 00 and 59.",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_COLLECT_MIN"
    a "Minutes: MM", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1

    q_CORD_COLLECT_UNIT "Time of cord blood collection: AM/PM",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_COLLECT_UNIT"
    a_1 "AM"
    a_2 "PM"    
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1
    
    q_CORD_WHERE_COLLECT "Where was the sample collected?",
    :help_text => "If the cord blood was collected prior to delivery of the placenta, choose \"In utero\". 
    If the cord blood was collected after delivery of the placenta, choose \"Ex utero\".",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_WHERE_COLLECT"
    a_1 "In utero"
    a_2 "Ex utero"       
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1
    
    q_CORD_DELIVERY "What type of delivery was performed?",
    :help_text => "If the delivery was a vaginal delivery choose \"Vaginal.\". 
    If the deivery was cesarean (c-section) choose \"Cesarean.\"",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_DELIVERY"
    a_1 "Vaginal"
    a_2 "Cesarean"       
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1
    
    q_CORD_CONTAINER "In what type of container was the cord blood collected?",
    :pick => :one,
    :data_export_identifier=>"SPEC_CORD_BLOOD.CORD_CONTAINER"
    a_1 "Cord blood bag with edta"
    a_2 "Cord blood bag with heparin"
    a_3 "Vacutainer tubes collected"           
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LOOP THROUGH SPECIMEN_ID TO CAPTURE NEEDED SPECIMEN IDs FOR CORD BLOOD COLLECTION.  NOT ALL 
    # SPECIMEN_IDs WILL BE NEEDED:
    # • IF CORD_CONTAINER=3:
    #   o DISPLAY DATA COLLECTOR INSTRUCTION:
    #     • RECORD THE SPECIMEN_ID PRINTED ON THE LABEL OF THE TUBE(S) COLLECTED. ONE LAVENDAR EDTA AND/OR ONE RED TOP TUBE WILL BE ACCEPTED. 
    #   o DISPLAY BOTH OF THE FOLLOWING, SINCE EITHER TUBE OR BOTH CAN BE COLLECTED.
    #     • FOR SPECIMEN_TYPE= 9, DISPLAY:
    #       “EDTA TUBE” AND  FORMAT FOR SPECIMEN_ID: 
    #         |___|___|___|___|___|___|___|___|___|-CL|___|___| (SPECIMEN_ID) 
    #     • FOR SPECIMEN_TYPE= 10, DISPLAY:
    #       “RED TOP TUBE” AND FORMAT FOR SPECIMEN_ID 
    #         |___|___|___|___|___|___|___|___|___|-CS|___|___| (SPECIMEN_ID)
    #   o HARD EDIT: INCLUDE HARD EDIT IF FORMAT IS NOT AA # # # # # # #-CL## (FOR SPECIMEN_TYPE= 9, EDTA TUBE) AND/OR AA # # # # # # #-CS## (FOR SPECIMEN_TYPE= 10, RED TOP TUBE).
    #   o RECORD SPECIMEN_TYPE FOR EACH SPECIMEN_ID ENTERED.
    # • IF CORD_CONTAINER= 1 OR 2, SPECIMEN_TYPE=11.
    #   o DISPLAY:
    #     DATA COLLECTOR INSTRUCTIONS: 
    #     • RECORD THE SPECIMEN ID PRINTED ON THE LABEL THAT IS AFFIXED TO THE BIOHAZARD BAG THAT CONTAINS THE CORD BLOOD BAG.
    #     • DISPLAY “BIOHAZARD BAG THAT CONTAINS THE CORD BLOOD BAG” AND FORMAT FOR SPECIMEN_ID:
    #       |___|___|___|___|___|___|___|___|___|-CB|___|___|
    #     • CANNOT BE NULL.
    #     • HARD EDIT: INCLUDE HARD EDIT IF FORMAT IS NOT AA # # # # # # #-CB## (FORMAT MUST BE AA # # # # # # #-CB##).

    # Nataliya's comment - does it have to be in some range (ex 1-20)?
    q_CORD_CONTAINER "What is the cord container",
    :pick => :any
    a_1 "1"
    a_2 "2"
    a_3 "3"
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1
    
    # Nataliya's comment - does it have to be in some range (ex 1-20)?
    q_SPECIMEN_TYPE "What is the specimen type?",
    :pick => :any
    a_9 "9"
    a_10 "10"
    a_11 "11"
    dependency :rule=>"A"
    condition_A :q_CORD_COLLECTION, "==", :a_1
    
    q_SPECIMEN_ID_EDTA_TUBE "EDTA tube",
    :help_text => "Verify the format AA # # # # # # #-CL##",
    :display_type => :inline,
    :data_export_identifier=>"SPEC_CORD_BLOOD_SPECIMEN"
    a_first_part "$AA|-CL", :string
    a_second_part :string
    dependency :rule=>"A and B"
    condition_A :q_CORD_CONTAINER, "==", :a_3
    condition_B :q_SPECIMEN_TYPE, "==", :a_9
    
    q_SPECIMEN_ID_RED_TOP_TUBE "Red top tube",
    :help_text => "Verify the format AA # # # # # # #-CS##",
    :display_type => :inline,
    :data_export_identifier=>"SPEC_CORD_BLOOD_SPECIMEN" 
    a "$AA|-CS", :string
    a_second_part :string
    dependency :rule=>"A and B"
    condition_A :q_CORD_CONTAINER, "==", :a_3
    condition_B :q_SPECIMEN_TYPE, "==", :a_10
    
    q_SPECIMEN_ID_BIOHAZART_BAG "Biohazard bag that contains the cord blood bag",
    :help_text => "Verify the format AA # # # # # # #-CB##",    
    :display_type => :inline,
    :data_export_identifier=>"SPEC_CORD_BLOOD_SPECIMEN"
    a "$AA|-CB", :string
    a_second_part :string    
    dependency :rule=>"(A or B) and C"
    condition_A :q_CORD_CONTAINER, "==", :a_1
    condition_B :q_CORD_CONTAINER, "==", :a_2
    condition_C :q_SPECIMEN_TYPE, "==", :a_11
    
    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"SPEC_CORD_BLOOD.TIME_STAMP_2"
    a :datetime
  end
end
    