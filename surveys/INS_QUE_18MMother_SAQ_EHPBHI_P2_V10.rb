survey "INS_QUE_18MMother_SAQ_EHPBHI_P2_V1.0" do
  section "18 Month questionaire", :reference_identifier=>"18MMother_SAQ" do
    label "Thank you for agreeing to participate in the National Children’s Study. This self-administered questionnaire 
    will take about 10 minutes to complete. There are questions about your relationships, experiences as a parent, 
    and questions about your child’s diet."
    
    label "Your answers are important to us. There are no right or wrong answers. You can skip over any question. 
    We will keep everything that you tell us confidential."
    
    q_ASQ_DATE_COMP "Date ASQ was completed.", 
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ_DATE_COMP"
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    a_neg_4 "Missing in Error"

    label "Child's information"

    q_C_FNAME "Child's first name:",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.C_FNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"

    q_C_MINITIAL "Child's middle initial:",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.C_MINITAL"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_C_LNAME "Child's last name:",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.C_LNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_CHILD_DOB "Child's date of birth:",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.CHILD_DOB"
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    a_neg_4 "Missing in Error"
    
    q_WEEKS_PREMATURE "If child was born 3 or more weeks prematurely, # of weeks premature",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.WEEKS_PREMATURE"
    a :integer
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_CHILD_SEX "Is child boy or girl?",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"

    label "Person filling out questionnaire"
 
    q_RESPONDENT_FNAME "Respondent's first name",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.RESPONDENT_FNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_RESPONDENT_MINITAL "Respondent's middle initial",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.RESPONDENT_MINITAL"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_RESPONDENT_LNAME "Respondent's last name",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.RESPONDENT_LNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_RESPONDENT_REL "Respondent's relationship to child",
    :pick => :one,
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.RESPONDENT_REL"
    a_1 "Parent"
    a_2 "Guardian"
    a_3 "Teacher"
    a_4 "Child Care Provider"
    a_5 "Grandparent or other relative"
    a_6 "Foster Parent"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_RESPONDENT_REL_OTH "Description of relationship of respondent to child.",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.RESPONDENT_REL_OTH"
    a "Specify", :string
    dependency :rule => "A"
    condition_A :q_RESPONDENT_REL, "==", :a_neg_5
    
    q_ASQ18_ADDRESS_1 "Address 1 - street/PO Box", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_ADDRESS_1",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ18_ADDRESS_2 "Address 2", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_ADDRESS_2",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ18_UNIT "Unit", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_UNIT",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ18_CITY "City", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_CITY",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ18_STATE "State", :display_type=>:dropdown, 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_STATE"
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

    q_ASQ18_ZIP "ZIP Code", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_ZIP",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ18_ZIP4 "ZIP+4", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_ZIP4",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ18_COUNTRY "Country", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_COUNTRY",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_HOME_PHONE "Participant's home phone number",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.HOME_PHONE",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_OTHER_PHONE "Other phone",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.OTHER_PHONE",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_EMAIL "Best e-mail at which to reach participant",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.EMAIL",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ASQ18_ASSISTNAME_COMMENT "Names of people assisting in questionnaire completion.",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_ASSISTNAME_COMMENT",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "Program Information"
    
    q_ASQ_CHILD_ID "Child ID Number",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ_CHILD_ID",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SC_ID "Program ID Number",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.SC_ID",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SC_NAME "Program name:",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.SC_NAME",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ASQ18_AGE_MONTHS "Age at administration in months",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_AGE_MONTHS",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"  
    
    q_ASQ18_AGE_DAYS "Age at administration in days",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_AGE_DAYS",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ASQ18_ADJ_AGE_MONTHS "If premature, adjusted age in months",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_ADJ_AGE_MONTHS",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ASQ18_ADJ_AGE_DAYS "If premature, adjusted age in months",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.ASQ18_ADJ_AGE_DAYS",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "Communication"
    
    q_COMM18_POINTS_1 "When your child wants something, does she tell by pointing to it?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.COMM18_POINTS_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM18_FIND_2 "When you ask your child to, does he go into another room to find familiar toy or object? (You might 
    ask, \"Where is your ball?\" or say, \"Bring me your coat,\" or \"Go get blanket.\")",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.COMM18_FIND_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM18_EIGHT_3 "Does your child say eight or more words in addition to \"Mama\" and \"Dada\"?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.COMM18_EIGHT_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM18_IMITATE_4 "Does your child imitate a two-word sentence? For example, when you say a two-word phrase, such as \"Mama eat,\" 
    \"Daddy play,\" \"Go home,\" or \"What's this?\" does your child say both words back to you? (Mark \"Yes\" even if her words 
    are difficult to understand.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.COMM18_IMITATE_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM18_PICTURE_5 "Without your showing him, does your child point to the correct picture when you say, \"Show me the kitty,\" or ask, 
    \"Where is the dog?\". (He needs to identify only one picture correctly.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.COMM18_PICTURE_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM18_SAY_IDEA_6 "Does your child say two or three words that represent different ideas together, such as \"See dog,\" 
    \"Mommy come home,\" or \"Kitty gone\"? (Don't count word combinations that express one idea, such as \"bye-bye,\" \"all gone,\" 
    \"all right,\" and \"What's that?\") Please give an example of your child's word combinations",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.COMM18_SAY_IDEA_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_EXAMPLE18_COMMENT "Comment",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.EXAMPLE18_COMMENT"
    a :text
    
    q_COMM18_TOTAL "Communication total", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.COMM18_TOTAL"
    a :integer
    
    label "Gross motor"
    
    q_GRMTR18_BNDSTD_1 "Does your child bend over or squat to pick up an object from the floor and then stand up again without any support?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.GRMTR18_BNDSTD_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR18_WALK_2 "Does your child move around by walking, rather than by crawling on her hands and knees?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.GRMTR18_WALK_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR18_NOFALL_3 "Does your child walk well and seldom fall?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.GRMTR18_NOFALL_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR18_CLIMB_4 "Does your child climb on an object such as a chair to reach something he wants (for example, to get a toy on a counter 
    or to \"help\" you in the kitchen)?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.GRMTR18_CLIMB_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR18_STAIRS_5 "Does your child walk down stairs if you hold onto one of her hands? She may also hold onto the railing or wall. 
    (You can look for this at a store, on a playground, or at home.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.GRMTR18_STAIRS_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR18_HOWKICK_6 "When you show your child how to kick a large ball, does he try to kick the ball by moving his leg forward 
    or by walking into it? (If your child already kicks a ball, mark \"yes\" for this item.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.GRMTR18_HOWKICK_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR18_TOTAL "Gross motor total", 
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.GRMTR18_TOTAL"
    a :integer
    
    label "Fine motor"
    
    q_FNMTR18_THROW_1 "Does your child throw a small ball with a forwarded arm motion?",
    :help_text => "If he simply drops the ball, mark \"not yet\" for this item.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.FNMTR18_THROW_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR18_STACK_2 "Does your child stack a small block or toy on top of another one? (You could also use spools of 
    thread, small boxes, or toys that are about 1 inch in size)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.FNMTR18_STACK_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR18_MARK_3 "Does your child make a mark on the paper with the tip of a crayon (or pencil or pen) when trying to draw?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.FNMTR18_MARK_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR18_THREESTK_4 "Does child stack three small blocks or toys on top of each other by himself?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.FNMTR18_THREESTK_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR18_TURN_5 "Does your child turn the pages of a book by himself? (he may turn more than one page at a time.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.FNMTR18_TURN_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR18_SPOON_6 "Does your child get a spoon into her mouth right side up so that the food usually doesn't spill?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.FNMTR18_SPOON_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  
    q_FNMTR18_TOTAL "Fine motor total",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.FNMTR18_TOTAL"
    a :integer
    
    label "Problem solving"
    
    q_PSLV18_DROP_1 "Does your child drop several small toys, one after another, into a container like a bowl or box? (You may show him how 
    to do it.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSLV18_DROP_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV18_RCHTOOL_2 "After you have shown your child how, does she try to get a small toy that is slightly out of reach by using a spoon, 
    stick, or similar tool?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSLV18_RCHTOOL_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV18_DMPBTL_3 "After a crumb or Cheerio is dropped into a small, clear bottle, does your child turn the bottle over and dump it out? 
    (You may show him how.) (You can use a soda-pop bottle or a baby bottle.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSLV18_DMPBTL_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV18_SCRIBBLE_4 "Without your showing her how, does child scribble back and forth when you give her a crayon (or pencil or pen)?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSLV18_SCRIBBLE_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV18_COPY_5 "After watching you draw a line from the top of the paper to the bottom with a crayon (or pencil or pen), does your child 
    copy you by drawing a single line on the paper in any direction? (Mark \"not yet\" if your child scribbles back and forth.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSLV18_COPY_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV18_BTLDMP_6 "After a crumb or Cheerio is dropped into a small, clear bottle, does your child turn the bottle upside down to dump out 
    the crumb or Cheerio? (Do not show him how.)",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSLV18_BTLDMP_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV18_TOTAL "Problem solving total",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSLV18_TOTAL"
    a :integer
    
    label "Personal-social"
    
    q_PSOC18_MIRROR_1 "While looking at herself in the mirror, does your child offer a toy to her own image?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSOC18_MIRROR_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC18_HUGTOY_2 "Does your child play with a doll or stuffed animal by hugging it?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSOC18_HUGTOY_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC18_ATTN_3 "Does your child get your attention or try to show you something by pulling on your hand or clothes?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSOC18_ATTN_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC18_HELP_4 "Does your child come to you when he needs help, such as with winding up a toy or unscrewing a lid from a jar?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSOC18_HELP_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC18_SPILL_5 "Does your child drink from a cup or glass, putting it down again with little spilling?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSOC18_SPILL_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC18_COPY_6 "Does your child copy the activities you do, such as wipe up a spill, sweep, shave, or comb hair?",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSOC18_COPY_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV18_TOTAL "Personal-social total",
    :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_SAQ.PSOC18_TOTAL"
    a :integer        
  end
end