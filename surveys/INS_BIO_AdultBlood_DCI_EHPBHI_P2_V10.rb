survey "INS_BIO_AdultBlood_DCI_EHPBHI_P2_V1.0" do
  section "BIOSPECIMEN BLOOD COLLECTION", :reference_identifier=>"AdultBlood_DCI" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"SPEC_BLOOD.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    q_BLOOD_INTRO "I will now collect a blood sample. I will need to ask you some questions before I collect your blood sample.",
    :help_text => "If the participant refuses this collection, select refused. otherwise select continue.",
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.BLOOD_INTRO"
    a_1 "Continue"
    a_neg_1 "Refused"
    
    q_HEMOPHILIA "Do you have hemophilia or any bleeding disorder?",
    :help_text => "Response determines eligibility of study participant for blood draw.",
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.HEMOPHILIA"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_BLOOD_INTRO, "==", :a_1
    
    label "Because you have hemophilia, we will not be able to draw your blood for this study. "
    dependency :rule=>"A"
    condition_A :q_HEMOPHILIA, "==", :a_1
    
    label "Because you do not know or declined to answer questions about your hemophilia we will not be able to draw your blood."
    dependency :rule=>"A or B"
    condition_A :q_HEMOPHILIA, "==", :a_neg_1
    condition_B :q_HEMOPHILIA, "==", :a_neg_2
    
    q_BLOOD_THINNER "Do you take any blood thinning medication, such as Coumadin or warfarin?",
    :help_text => "Response determines eligibility of study participant for blood draw.",
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.BLOOD_THINNER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_HEMOPHILIA, "==", :a_2 
    
    label "Because you are taking a blood thinning medication, we will not be able to draw your blood at this time."
    dependency :rule=>"A"
    condition_A :q_BLOOD_THINNER, "==", :a_1
    
    label "Because you do not know or declined to answer questions about your use of blood thinners we will not be able 
    to draw your blood."
    dependency :rule=>"A or B"
    condition_A :q_BLOOD_THINNER, "==", :a_neg_1
    condition_B :q_BLOOD_THINNER, "==", :a_neg_2    
    
    q_CHEMO "Have you had cancer chemotherapy within the past 4 weeks?",
    :help_text => "Response determines eligibility of study participant for blood draw.",
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.CHEMO"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_BLOOD_THINNER, "==", :a_2    
    
    label "Because you’ve had chemotherapy recently, we will not be able to draw your blood at this time."
    dependency :rule=>"A"
    condition_A :q_CHEMO, "==", :a_1
    
    label "Because you do not know or declined to answer questions about your chemotherapy status of blood thinners we 
    will not be able 
    to draw your blood."
    dependency :rule=>"A or B"
    condition_A :q_CHEMO, "==", :a_neg_1
    condition_B :q_CHEMO, "==", :a_neg_2
    
    q_BLOOD_DRAW "Have you had any problems with taking blood in the past?",
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.BLOOD_DRAW"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"    
    dependency :rule=>"A"
    condition_A :q_CHEMO, "==", :a_2
    
    q_BLOOD_DRAW_PROB "What problems did you have with taking blood in the past?",
    :help_text => "Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"SPEC_BLOOD_DRAW.BLOOD_DRAW_PROB"
    a_1 "Fainting"
    a_2 "Light-headedness"
    a_3 "Hematoma"
    a_4 "Bruising"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_BLOOD_DRAW, "==", :a_1
    
# TODO:
# PROGRAMMER INSTRUCTION:
# • LIMIT FREE TEXT TO 250 CHARACTERS
    q_BLOOD_DRAW_OTH "Other problems", 
    :help_text => "If there were any problems with a past blood draw that are not listed in the previous question, record the problem below",
    :pick=>:one, 
    :data_export_identifier=>"SPEC_BLOOD.BLOOD_DRAW_OTH"
    a_1 "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A and B and C"
    condition_A :q_BLOOD_DRAW_PROB, "==", :a_neg_5
    condition_B :q_BLOOD_DRAW_PROB, "!=", :a_neg_1
    condition_C :q_BLOOD_DRAW_PROB, "!=", :a_neg_2

    group "Additional questions" do
      dependency :rule=>"A"
      condition_A :q_CHEMO, "==", :a_2
      
      label "When was the last time you had anything to eat or drink other than water?"
    
      q_LAST_TIME_EAT "Last time ate or drank – TIME",
      :help_text => "Record the time as HH:MM, be sure to fill the space with a zero when necessary and to mark the box to choose 
      \"AM\" or \"PM\". For example, if the last time participant ate or drank was at 2:05PM record \"02:05\" and choose \"PM\". ",
      :data_export_identifier=>"SPEC_BLOOD.LAST_TIME_EAT"
      a "HH:MM", :string, :custom_class => "time"
    
      q_LAST_TIME_EAT_UNIT "Last time ate or drank – AM/PM",
      :data_export_identifier=>"SPEC_BLOOD.LAST_TIME_EAT_UNIT",
      :pick =>:one
      a_1 "AM"
      a_2 "PM"
    
      q_LAST_DATE_EAT "Last time ate or drank – DATE",
      :help_text => "Double check if year is < 2011.",
      :data_export_identifier=>"SPEC_BLOOD.LAST_DATE_EAT",
      :pick => :one
      a "Date", :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    
      q_COFFEE_TEA "Have you had coffee or tea with sweetener or milk in the last 8 hours?",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.COFFEE_TEA"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_ALCOHOL "Have you had alcohol such as beer, wine, or liquor in the last 8 hours?",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.ALCOHOL"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
        
      q_COUGH_COLD "Have you chewed gum, or used breath mints, lozenges, cough drops, or other cough or cold remedies in the last 8 hours?",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.COUGH_COLD"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_LAXATIVE "Have you used antacid, laxatives, or anti-diarrheal medication in the last 8 hours? ",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.LAXATIVE"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_VITAMIN "Have you taken a dietary supplement such as vitamins or minerals in the last 8 hours?",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.VITAMIN"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_DIABETES "Are you diabetic? This includes gestational diabetes?",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.DIABETES"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_INSULIN "Have you taken any insulin in the last 8 hours?",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.INSULIN"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
      dependency :rule=>"A"
      condition_A :q_DIABETES, "==", :a_1
    
      q_BLOOD_COMPLETE "Thank you for answering my questions. I am now going to prepare to draw your blood",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.BLOOD_INTRO"
      a_1 "Continue"
      a_neg_1 "Refused"
    end

    label "That’s fine.  Thank you"
    dependency :rule=>"A or B"
    condition_A :q_BLOOD_COMPLETE, "==", :a_neg_1
    condition_B :q_BLOOD_INTRO, "==", :a_neg_1
    
    group "Blood collection" do
      dependency :rule=>"A"
      condition_A :q_BLOOD_COMPLETE, "==", :a_1
      
      q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"SPEC_BLOOD.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime"

      label "Blood collection"
    
      label"- Confirm that blood tubes are labeled and not expired prior to collection of sample."
    
      label"- Be sure to employ universal precautions to prevent exposure to infectious diseases at all times when handling 
      biological specimens."
      # , :custom_class => 'instructions'
    
      label "- Wear ppe including a lab coat and gloves until samples are sealed in transport bag."
    
      label "- Be sure to explain each part of procedure being performed during blood collection."
    
      label "- Once in an area with adequate light and a flat, clean surface free of food, clutter and distractions, begin set up."
    
      label "- Ideally the prep area should be near a place where the participant can sit with her/his arm stretched out on a flat surface."
    
      label "- Drape a chux pad over surfaces where the participant will put her/his arm."
    
      label "- Stop drawing blood if bruising occurs. continue after three minutes only with verbal permission of participant."
    
      label "- Collection tubes should be drawn in the following order: tube_type."
    
      label "- Once collection is complete, remove the needle and apply gauze."
    
      label "Thank you for your blood sample. Please hold this gauze on your arm with mild pressure.",
      :help_text => "Check if clotting has occurred and apply band-aid over gauze. 
      If necessary, instruct participant to raise her arm above her head for two minutes without bending her elbow to prevent the formation of 
      a hematoma. "

      q_COLLECTION_STATUS "Blood tube collection overall status",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.COLLECTION_STATUS",
      :help_text => "Select \"Collected\" to indicate that all blood tubes are filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. this choice should not be selected 
      if there are any partially filled tubes. 
      select \"Partially collected\" to indicate that at least one, but not all of the blood tubes is filled to at least 3/4 of the 
      desired capacity. select \"Not collected\" to indicate that no blood tubes were collected."
      a_1 "Collected"
      a_2 "Partially collected"
      a_3 "Not collected"
    end

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • IF VISIT IS PARTICIPANT’S FIRST VISIT (PRE-PREGNANCY OR PREGNANCY 
    # VISIT 1), DISPLAY THE FOLLOWING BLOOD TUBES:
    # (TUBE_TYPE)=1  8.5mL SST  AA######-SS10 
    # (TUBE_TYPE)=2  10 mL Red top  AA######-RD10 
    # (TUBE_TYPE)=3  5mL PPT  AA######-PP10 
    # (TUBE_TYPE)=4  6mL Lavender   AA######-LV10
    # (TUBE_TYPE)=5  8.5mL P100 AA######-PN10
    # (TUBE_TYPE)=6  8.5mL ACD  AA######-AD10
    # 
    # • IF VISIT IS PARTICIPANT’S SECOND VISIT(PREGNANCY VISIT 1 OR PREGNANCY VISIT 2), DISPLAY THE FOLLOWING BLOOD TUBES:
    # (TUBE_TYPE)=7   6mL Royal Blue Trace Metal  AA######-RB10
    # (TUBE_TYPE)=1  8.5mL SST  AA######-SS10
    # (TUBE_TYPE)=2  10 mL Red top  AA######-RD10
    # (TUBE_TYPE)=3  5mL PPT  AA######-PP10
    # (TUBE_TYPE)=4  6mL Lavender   AA######-LV10
    # (TUBE_TYPE)=8  2.5mL Paxgene  AA######-PX10

    q_VISIT_NUMBER "Data collector: is this visit participant’s first visit (pre-pregnancy or pregnancy visit 1)?",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_COLLECTION_STATUS, "!=", :a_3

    group "First visit" do
      dependency :rule=>"A"
      condition_A :q_VISIT_NUMBER, "==", :a_1
      
      # a_1  "8.5mL SST  AA|-SS10"
      label_TUBE_TYPE_1_VISIT_1 "8.5mL SST"
    
      q_SPECIMEN_ID_TUBE_TYPE_1_VISIT_1 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].SPECIMEN_ID"
      a "AA|-SS10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_1_VISIT_1 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_1_VISIT_1 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1, "!=", :a_neg_2
    
      # a_2  "10 mL Red top  AA|-RD10"
      label_TUBE_TYPE_2_VISIT_1 "10 mL Red top"

      q_SPECIMEN_ID_TUBE_TYPE_2_VISIT_1 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].SPECIMEN_ID"
      a "AA|-RD10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_2_VISIT_1 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_1 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_2_VISIT_1 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_1, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_1, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_1, "!=", :a_neg_2    

      # a_3  "5mL PPT  AA|-PP10"
      label_TUBE_TYPE_3_VISIT_1 "5mL PPT"
    
      q_SPECIMEN_ID_TUBE_TYPE_3_VISIT_1 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].SPECIMEN_ID"
      a "AA|-PP10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_3_VISIT_1 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_1 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_3_VISIT_1 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_1, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_1, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_1, "!=", :a_neg_2

      # a_4  "6mL Lavender  AA|-LV10"
      label_TUBE_TYPE_4_VISIT_1 "6mL Lavender"
    
      q_SPECIMEN_ID_TUBE_TYPE_4_VISIT_1 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].SPECIMEN_ID"
      a "AA|-LV10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_4_VISIT_1 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_1 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_4_VISIT_1 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_1, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_1, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_1, "!=", :a_neg_2

      # 8.5mL P100  AA|-PN10
      label_TUBE_TYPE_5_VISIT_1 "8.5mL P100"
    
      q_SPECIMEN_ID_TUBE_TYPE_5_VISIT_1 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=5].SPECIMEN_ID"
      a "AA|-PN10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_5_VISIT_1 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=5].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_5_VISIT_1 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=5].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_5_VISIT_1 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=5].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_5_VISIT_1, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_5_VISIT_1, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_5_VISIT_1, "!=", :a_neg_2

      # 8.5mL ACD  AA|-AD10
      label_TUBE_TYPE_6_VISIT_1 "8.5mL ACD"
    
      q_SPECIMEN_ID_TUBE_TYPE_6_VISIT_1 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=6].SPECIMEN_ID"
      a "AA|-AD10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_6_VISIT_1 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=6].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_6_VISIT_1 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=6].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_6_VISIT_1 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=6].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_6_VISIT_1, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_6_VISIT_1, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_6_VISIT_1, "!=", :a_neg_2
    end
    group "Second visit" do
      dependency :rule=>"A"
      condition_A :q_VISIT_NUMBER, "==", :a_2
      
      # VISIT 2 TUBES
      # a_7  "6mL Royal Blue Trace Metal  AA|-RB10"
      label_TUBE_TYPE_7_VISIT_2 "6mL Royal Blue Trace Metal"
    
      q_SPECIMEN_ID_TUBE_TYPE_7_VISIT_2 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=7].SPECIMEN_ID"
      a "AA|-RB10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_7_VISIT_2 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=7].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_7_VISIT_2 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=7].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_7_VISIT_2 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=7].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_7_VISIT_2, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_7_VISIT_2, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_7_VISIT_2, "!=", :a_neg_2    
    
      # a_1  "8.5mL SST  AA|-SS10"
      label_TUBE_TYPE_1_VISIT_2 "8.5mL SST"
    
      q_SPECIMEN_ID_TUBE_TYPE_1_VISIT_2 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].SPECIMEN_ID"
      a "AA|-SS10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_1_VISIT_2 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_2 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_1_VISIT_2 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_2, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_2, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_2, "!=", :a_neg_2
    
      # a_2  "10 mL Red top  AA|-RD10"
      label_TUBE_TYPE_2_VISIT_2 "10 mL Red top"
    
      q_SPECIMEN_ID_TUBE_TYPE_2_VISIT_2 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].SPECIMEN_ID"
      a "AA|-RD10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_2_VISIT_2 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_2 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_2_VISIT_2 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_2, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_2, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_2, "!=", :a_neg_2    

      # a_3  "5mL PPT  AA|-PP10"
      label_TUBE_TYPE_3_VISIT_2 "5mL PPT"
    
      q_SPECIMEN_ID_TUBE_TYPE_3_VISIT_2 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].SPECIMEN_ID"
      a "AA|-PP10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_3_VISIT_2 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_2 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_3_VISIT_2 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_2, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_2, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_2, "!=", :a_neg_2

      # a_4  "6mL Lavender  AA|-LV10"
      label_TUBE_TYPE_4_VISIT_2 "6mL Lavender"
    
      q_SPECIMEN_ID_TUBE_TYPE_4_VISIT_2 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].SPECIMEN_ID"
      a "AA|-LV10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_4_VISIT_2 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_2 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_4_VISIT_2 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=4].TUBE_COMMENTS_OTH"
      a_1 "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_2, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_2, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_4_VISIT_2, "!=", :a_neg_2

      # a_8  "2.5mL Paxgene  AA|-PX10"
      label_TUBE_TYPE_8_VISIT_2 "2.5mL Paxgene"
    
      q_SPECIMEN_ID_TUBE_TYPE_8_VISIT_2 "Tube barcode", 
      :help_text => "Scan tube_type barcode. If the barcode scanner is not working, manually enter the information. Format # # # # # #",
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=8].SPECIMEN_ID"
      a "AA|-PX10", :string
    
      q_TUBE_STATUS_TUBE_TYPE_8_VISIT_2 "Blood tube collection status",
      :help_text => "Select \"Full draw\" to indicate that the blood tube was filled to at least 3/4 of the desired capacity. 
      desired capacity is defined as filled to the fill line indicated on the blood tube label. Select \"Short draw\" to indicate that the 
      blood tube was filled to less than 3/4 of the desired capacity. Select \"No draw\" to indicate that the blood tube was not collected.",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=8].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
    
      q_TUBE_COMMENTS_TUBE_TYPE_8_VISIT_2 "Blood tube collection comments",
      :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply", 
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=8].TUBE_COMMENTS"
      a_1 "Equipment failure"
      a_2 "Fainting"
      a_3 "Light-headedness"
      a_4 "Hematoma"
      a_5 "Bruising"
      a_6 "Vein collapsed during procedure"
      a_7 "No suitable vein"
      a_neg_5 "Other"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_TUBE_COMMENTS_OTH_TUBE_TYPE_8_VISIT_2 "Blood tube collection other comments", 
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=8].TUBE_COMMENTS_OTH"
      a "Specify", :string
      dependency :rule=>"A and B and C"
      condition_A :q_TUBE_COMMENTS_TUBE_TYPE_8_VISIT_2, "==", :a_neg_5
      condition_B :q_TUBE_COMMENTS_TUBE_TYPE_8_VISIT_2, "!=", :a_neg_1
      condition_C :q_TUBE_COMMENTS_TUBE_TYPE_8_VISIT_2, "!=", :a_neg_2
    end
    q_COLLECTION_LOCATION "Collection location",
    :help_text => "Record where blood collection occurred", 
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.COLLECTION_LOCATION"
    a_1 "Home"
    a_2 "Clinic"
    a_3 "Other location"
    dependency :rule=>"A"
    condition_A :q_COLLECTION_STATUS, "!=", :a_3
    
    q_OVERALL_COMMENTS "Blood collection overall comments",
    :help_text => "Enter reason blood was not collected", 
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.OVERALL_COMMENTS"
    a_1 "Safety exclusion"
    a_2 "Physical limitation"
    a_3 "Participant ill/emergency"
    a_4 "Quantity not sufficient"
    a_5 "Language issue, spanish"
    a_6 "Language issue, non spanish"
    a_7 "Cognitive disability"
    a_8 "No time"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_COLLECTION_STATUS, "==", :a_3
    
    q_OVERALL_COMMENTS_OTH "Blood collection other overall comments",
    :data_export_identifier=>"SPEC_BLOOD.OVERALL_COMMENTS_OTH"
    a "Specify", :string
    dependency :rule=>"A and B and C"
    condition_A :q_OVERALL_COMMENTS, "==", :a_neg_5
    condition_B :q_OVERALL_COMMENTS, "!=", :a_neg_1
    condition_C :q_OVERALL_COMMENTS, "!=", :a_neg_2
    
    label "Blood centrifugation"
    dependency :rule=>"A"
    condition_A :q_COLLECTION_STATUS, "!=", :a_3
    
    q_TIME_STAMP_3 "Insert date/time stamp", 
    :data_export_identifier=>"SPEC_BLOOD.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
    dependency :rule=>"A"
    condition_A :q_COLLECTION_STATUS, "!=", :a_3
    
    q_CENTRIFUGE_LOCATION "Will blood be centrifuged at collection location?", 
    :help_text => "Record whether blood will be centrifuged at collection location", 
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.CENTRIFUGE_LOCATION"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_COLLECTION_STATUS, "!=", :a_3
    
    group "Additional collection information" do
      dependency :rule=>"A"
      condition_A :q_CENTRIFUGE_LOCATION, "==", :a_1
            
      # TODO
      #     PROGRAMMER INSTRUCTION: 
      #     • EQUIPMENT ID FORMAT SHOULD BE: AAA # # # # # # # # #
      q_EQUIP_ID "Equipment id for centrifuge",
      :help_text => "Enter equipment id for centrifuge. Format should be AAA # # # # # # # # #.",
      :data_export_identifier=>"SPEC_BLOOD.EQUIP_ID"
      a "AAA", :string
    
      label "Time centrifugation began "
    
      q_CENTRIFUGE_TIME "Time centrifugation began – TIME",
      :help_text => "Record the time the blood tubes were placed in the centrifuge. Record the time as HH:MM. Be sure to fill the space 
      with a zero when necessary and to mark the box to choose \"AM\" or \"PM\". For example, if time of last urination was at 2:05PM 
      record \"02:05\" and choose \"PM\". Double check if hour is not between 01 and 12. Double check if minutes are not between 00 and 59. 
      Fill the space with 0 as necessary",
      :data_export_identifier=>"SPEC_BLOOD.CENTRIFUGE_TIME", :pick => :one
      a "HH:MM", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      q_CENTRIFUGE_TIME_UNIT "Time centrifugation began – AM/PM",
      :data_export_identifier=>"SPEC_BLOOD.CENTRIFUGE_TIME_UNIT", :pick => :one
      a_1 "AM"
      a_2 "PM"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_CENTRIFUGE_DATE "Time centrifugation began – DATE",
      :help_text => "Double check if year is < 2011.",
      :pick => :one,
      :data_export_identifier=>"SPEC_URINE.CENTRIFUGE_DATE"
      a "Date", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      label "Time centrifugation ended"

      q_CENTRIFUGE_END_TIME "Time centrifugation began – TIME",
      :help_text => "Record the time the blood tubes were placed in the centrifuge. Record the time as HH:MM. Be sure to fill the space 
      with a zero when necessary and to mark the box to choose \"AM\" or \"PM\". For example, if time of last urination was at 2:05PM 
      record \"02:05\" and choose \"PM\". Double check if hour is not between 01 and 12. Double check if minutes are not between 00 and 59. 
      Fill the space with 0 as necessary",
      :data_export_identifier=>"SPEC_BLOOD.CENTRIFUGE_END_TIME", :pick => :one
      a "HH:MM", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      q_CENTRIFUGE_END_TIME_UNIT "Time centrifugation began – AM/PM",
      :data_export_identifier=>"SPEC_BLOOD.CENTRIFUGE_END_TIME_UNIT", 
      :pick => :one
      a_1 "AM"
      a_2 "PM"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      q_CENTRIFUGE_END_DATE "Time centrifugation began – DATE",
      :help_text => "Double check if year is < 2011.",
      :pick => :one,
      :data_export_identifier=>"SPEC_URINE.CENTRIFUGE_END_DATE"
      a "Date", :string
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
  
      q_CENTRIFUGE_TEMP_MEASURE "Temperature of centrifuge",
      :help_text => "If able to measure temperature, then select \"Temperature\". If not able to measure temperature, then 
      select \"Not able to measure\".",
      :pick => :one,
      :data_export_identifier=>"SPEC_URINE.CENTRIFUGE_TEMP_MEASURE"
      a_1 "Temperature"
      a_2 "Not able to measure"

      q_CENTRIFUGE_TEMP "Temperature of centrifuge",
      :help_text => "Record the temperature reading on the digital thermometer attached to the centrifuge at the time that the blood tubes are 
      removed after centrifugation. Enter temperature in degrees celsius. Record the temperature to the first decimal point. 
      Double check if temperature is < 15C or > 28C ",
      :data_export_identifier=>"SPEC_URINE.CENTRIFUGE_TEMP"
      a "|°C", :string
      dependency :rule=>"A"
      condition_A :q_CENTRIFUGE_TEMP_MEASURE, "==", :a_1

      q_BLOOD_HEMOLYZE "Did blood hemolyze?",
      :help_text => "Record whether hemolysis occurred in one or more of the blood tubes",
      :pick => :one,
      :data_export_identifier=>"SPEC_URINE.BLOOD_HEMOLYZE"
      a_1 "Yes, all tubes hemolyzed"
      a_2 "Yes, at least one tube hemolyzed and at least one tube did not hemolyze"
      a_3 "No, none of the tubes hemolyzed"
    end
  
    group "Hemolyze information" do
      dependency :rule=>"A"
      condition_A :q_BLOOD_HEMOLYZE, "!=", :a_3    
      
      # TODO:
      # (TUBE_TYPE)=5, 8.5mL P100.... 4
      # ID is 4 for the tube_type=5?
      q_V1_TUBE_HEMOLYZE_VISIT_1 "Indicate which tube(s) hemolyzed",
      :help_text => "Select all that apply",
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_HEMOLYZE.V1_TUBE_HEMOLYZE"
      a_1 "8.5mL SST"
      a_2 "10 mL Red top"
      a_3 "5mL PPT"
      a_4 "8.5mL P100"
      dependency :rule=>"A"
      condition_A :q_VISIT_NUMBER, "==", :a_1

      q_V1_TUBE_HEMOLYZE_VISIT_2 "Indicate which tube(s) hemolyzed",
      :help_text => "Select all that apply",
      :pick => :any,
      :data_export_identifier=>"SPEC_BLOOD_HEMOLYZE.V1_TUBE_HEMOLYZE"
      a_1 "8.5mL SST"
      a_2 "10 mL Red top"
      a_3 "5mL PPT"
      dependency :rule=>"A"
      condition_A :q_VISIT_NUMBER, "==", :a_2

      q_CENTRIFUGE_COMMENT "Centrifuge other comments",
      :help_text => "Enter centrifuge comments:",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_HEMOLYZE.CENTRIFUGE_COMMENT"
      a_1 "No comments"
      a_2 "Comment"
    
      q_CENTRIFUGE_COMMENT_OTH "Any other centrifuge comments",
      :help_text => "Enter centrifuge comments:",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_HEMOLYZE.CENTRIFUGE_COMMENT_OTH"
      a "Comment", :string
      dependency :rule=>"A"
      condition_A :q_CENTRIFUGE_COMMENT, "==", :a_2
    end

    q_TIME_STAMP_4 "Insert date/time stamp", :data_export_identifier=>"SPEC_BLOOD.TIME_STAMP_4"
    a :datetime, :custom_class => "datetime"
    dependency :rule=>"A or B or C or D"
    condition_A :q_CENTRIFUGE_LOCATION, "==", :a_2
    condition_B :q_BLOOD_HEMOLYZE, "==", :a_3
    condition_C :q_CENTRIFUGE_COMMENT, "==", :a_1
    condition_D :q_CENTRIFUGE_COMMENT, "==", :a_2
    
    group "Transport information" do
      dependency :rule=>"A or B or C or D"
      condition_A :q_CENTRIFUGE_LOCATION, "==", :a_2
      condition_B :q_BLOOD_HEMOLYZE, "==", :a_3
      condition_C :q_CENTRIFUGE_COMMENT, "==", :a_1
      condition_D :q_CENTRIFUGE_COMMENT, "==", :a_2
    
      label "Preparation for blood tube transport"
    
      label"- Prepare the tubes for transport in either the refrigerated clamshell or in the ambient tube holder, depending on the 
      tube type and location of centrifugation."
    
      label"- Place a lower threshold (0°C) monitor inside the refrigerated clamshell and inside the ambient tube holder (if applicable)."
      # , :custom_class => 'instructions'
    
      label "- Activate an upper threshold (20°C) monitor and affix it to the outside of the refrigerated clamshell"
    
      label "- If able to measure temperature, then select \"temperature\". enter the temperature of the digital thermometer in the 
      transport cooler at the time the data collector puts the specimen in the cooler."
    
      label "- If not able to measure temperature, then select \"Not able to measure\"."
    
      label "- If there are not any tubes that require refrigerated transport temperatures, then select \"Not applicable\"."
    
      q_COLD_TEMP_MEASURE "Temperature of refrigerated chamber",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.COLD_TEMP_MEASURE"
      a_1 "Temperature"
      a_2 "Not able to measure"
      a_neg_7 "Not applicable"

      q_COLD_TEMP "Record temperature of refrigerated chamber",
      :help_text => "Record the temperature of the refrigerated chamber of the transport cooler. 
      Enter temperature in degrees celsius. Double check if temperature is ≥ 10C or if ≤ 0C",
      :data_export_identifier=>"SPEC_BLOOD.COLD_TEMP"
      a "|°C", :string
      dependency :rule=>"A"
      condition_A :q_COLD_TEMP_MEASURE, "==", :a_1

      q_COLD_THRESHOLD_LOW "Status of refrigerated chamber low threshold monitor",
      :help_text => "Record status of the low threshold monitor in the refrigerated chamber of the transport cooler. 
      If there are not any tubes that require refrigerated transport temperatures, then select \"No, not in chamber\". ",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.COLD_THRESHOLD_LOW"
      a_1 "Yes, in chamber"
      a_2 "No, not in chamber"
    
      q_COLD_THRESHOLD_HIGH "Status of refrigerated chamber high threshold monitor",
      :help_text => "Record status of the high threshold monitor in the refrigerated compartment of the cooler. 
      If there are not any tubes that require refrigerated transport temperatures, then select \"No, not in chamber\". ",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.COLD_THRESHOLD_HIGH"
      a_1 "Yes, in chamber"
      a_2 "No, not in chamber"
    
      q_AMBIENT_THRESHOLD_LOW "Status of ambient low threshold monitor",
      :help_text => "Record status of the low threshold monitor in the ambient compartment of the cooler.  
      If there are not any tubes that require ambient transport temperatures, then select  \"No, not in chamber\". ",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.AMBIENT_THRESHOLD_LOW"
      a_1 "Yes, in chamber"
      a_2 "No, not in chamber"
    
      q_BLOOD_DRAW_COM "Blood draw other comments",
      :help_text => "Enter blood collection comments",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD.BLOOD_DRAW_COM"
      a_1 "No comments"
      a_2 "Comment"

      q_BLOOD_DRAW_COMMENT "Blood draw comments",
      :help_text => "Enter any other blood collection comments",
      :data_export_identifier=>"SPEC_BLOOD.BLOOD_DRAW_COMMENT"
      a "Comment", :string
      dependency :rule=>"A"
      condition_A :q_BLOOD_DRAW_COM, "==", :a_2
    end
    q_TIME_STAMP_5 "Insert date/time stamp", :data_export_identifier=>"SPEC_BLOOD.TIME_STAMP_5"
    a :datetime, :custom_class => "datetime"
  end
end