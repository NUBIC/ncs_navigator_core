survey "INS_QUE_24MMother_SAQ_EHPBHI_P2_V1.0" do
  section "24 Month questionaire", :reference_identifier=>"24MMother_SAQ" do
    label "Thank you for agreeing to participate in the National Children’s Study. This self-administered questionnaire 
    will take about 10 minutes to complete. There are questions about your relationships, experiences as a parent, 
    and questions about your child’s diet."
    
    label "Your answers are important to us. There are no right or wrong answers. You can skip over any question. 
    We will keep everything that you tell us confidential."
    
    q_ASQ_DATE_COMP "Date ASQ was completed.",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ_DATE_COMP"
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    a_neg_4 "Missing in Error"

    label "Child's information"
    
    q_C_FNAME "Child's first name:",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.C_FNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"

    q_C_MINITIAL "Child's middle initial:",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.C_MINITIAL"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_C_LNAME "Child's last name:",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.C_LNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"

    q_CHILD_DOB "Child's date of birth:",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.CHILD_DOB"
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    a_neg_4 "Missing in Error"

    q_CHILD_SEX "Is child boy or girl?",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.CHILD_SEX"
    a_1 "Male"
    a_2 "Female"
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"

    label "Person filling out questionnaire"
 
    q_RESPONDENT_FNAME "Respondent's first name",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.RESPONDENT_FNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_RESPONDENT_MINITAL "Respondent's middle initial",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.RESPONDENT_MINITAL"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_RESPONDENT_LNAME "Respondent's last name",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.RESPONDENT_LNAME"
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't Know"
    
    q_RESPONDENT_REL "Respondent's relationship to child",
    :pick => :one,
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.RESPONDENT_REL"
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
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.RESPONDENT_REL_OTH"
    a "Specify", :string
    dependency :rule => "A"
    condition_A :q_RESPONDENT_REL, "==", :a_neg_5
    
    q_ASQ24_ADDRESS_1 "Address 1 - street/PO Box", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_ADDRESS_1",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ24_ADDRESS_2 "Address 2", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_ADDRESS_2",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ24_UNIT "Unit", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_UNIT",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ24_CITY "City", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_CITY",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ24_STATE "State", :display_type=>:dropdown, 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_STATE"
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
    a_24 "KY"
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

    q_ASQ24_ZIP "ZIP Code", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_ZIP",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ24_ZIP4 "ZIP+4", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_ZIP4",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_ASQ24_COUNTRY "Country", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_COUNTRY",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_HOME_PHONE "Participant's home phone number",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.HOME_PHONE",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_OTHER_PHONE "Other phone",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.OTHER_PHONE",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_EMAIL "Best e-mail at which to reach participant",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.EMAIL",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_ASQ24_ASSISTNAME_COMMENT "Names of people assisting in questionnaire completion.",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ24_ASSISTNAME_COMMENT",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    label "Program Information"
    
    q_ASQ_CHILD_ID "Child ID Number",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.ASQ_CHILD_ID",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SC_ID "Program ID Number",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.SC_ID",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_SC_NAME "Program name:",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.SC_NAME",
    :pick=>:one
    a :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    label "Communication"
    
    q_COMM24_PICTURE_1 "Without your showing him, does your child point to the correct picture when you say, \"Show me the kitty,\" or ask, 
    \"Where is the dog?\". (She needs to identify only one picture correctly.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.COMM24_PICTURE_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM24_IMITATE_2 "Does your child imitate a two-word sentence? For example, when you say a two-word phrase, such as \"Mama eat,\" 
    \"Daddy play,\" \"Go home,\" or \"What's this?\" does your child say both words back to you? (Mark \"Yes\" even if her words 
    are difficult to understand.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.COMM24_IMITATE_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    
    
    q_COMM24_DIRECT_3 "Without your giving him clues by pointing or using gestures, can your child carry out at least three of these kinds of 
    directions? a)\"Put the toy on the table.\" b)\"Close the door.\" c)\"Bring me a towel.\" d)\"Find your coat\" e)\"Take my hand.\" 
    f) \"Get your book.\"",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.COMM24_IMITATE_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM24_NAME_4 "If you point to a picture of a ball (kitty, cup, hat, etc.) and ask your child, \"What is this?\" does your child correctly 
    name at least one picture?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.COMM24_NAME_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_COMM24_SAY_IDEA_5 "Does your child say two or three words that represent different ideas together, such as \"See dog,\" 
    \"Mommy come home,\" or \"Kitty gone\"? (Don't count word combinations that express one idea, such as \"bye-bye,\" \"all gone,\" 
    \"all right,\" and \"What's that?\") Please give an example of your child's word combinations",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.COMM24_SAY_IDEA_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_EXAMPLE24_COMMENT "Comment",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.EXAMPLE24_COMMENT"
    a :text
    
    q_COMM24_USEWORDS_6 "Does your child correctly use at least two words like \"me,\" \"I,\" \"mine,\" and \"you\"?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.COMM24_USEWORDS_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"    
    
    q_COMM24_TOTAL "Communication total", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.COMM24_TOTAL"
    a :integer
    
    label "Gross motor"
    
    q_GRMTR24_STAIRS_1 "Does your child walk down stairs if you hold onto one of her hands? She may also hold onto the railing or wall. 
    (You can look for this at a store, on a playground, or at home.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.GRMTR24_STAIRS_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR24_HOWKICK_2 "When you show your child how to kick a large ball, does he try to kick the ball by moving his leg forward 
    or by walking into it? (If your child already kicks a ball, mark \"yes\" for this item.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.GRMTR24_HOWKICK_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR24_STEPS_3 "Does your child walk either up or down at least two steps by herself? She may hold onto the railing or wall",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.GRMTR24_STEPS_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR24_RUN_4 "Does your child run fairly well, stopping herself without bumping into things or falling?",    
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.GRMTR24_RUN_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR24_JUMP_5 "Does your child jump with both feet leaving the floor at the same time?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.GRMTR24_JUMP_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_GRMTR24_CANKICK_6 "Without holding onto anything for support, does your child kick a ball by swinging his leg forward?",
    :help_text => "If the answer is marked as \"Yes\" or \"sometimes,\" mark Gross Motor Item 2 \"Yes.\"",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.GRMTR24_CANKICK_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know" 
    
    q_GRMTR24_TOTAL "Gross motor total", 
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.GRMTR24_TOTAL"
    a :integer
    
    label "Fine motor"  
    
    q_FNMTR24_SPOON_1 "Does your child get a spoon into his mouth right side up so that the food usually doesn't spill?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.FNMTR24_SPOON_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR24_TURN_2 "Does your child turn the pages of a book by herself? (She may turn more than one page at a time.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.FNMTR24_TURN_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR24_KNOBS_3 "Does your child use a turning motion with his hand while trying to turn doorknobs, wind up toys, twist tops, or screw lids 
    on and offjars?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.FNMTR24_KNOBS_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know" 
    
    q_FNMTR24_SWITCH_4 "Does your child flip switches off and on?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.FNMTR24_SWITCH_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR24_7STACK_5 "Does your child stack seven small blocks or toys on top of each other by herself? (You could also use spools of thread, 
    small boxes, or toys that are about 1 inch in size.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.FNMTR24_7STACK_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_FNMTR24_STRING_6 "Can your child string small items such as beads, macaroni, or pasta \"wagon wheels\" onto a string or shoelace?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.FNMTR24_STRING_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_FNMTR24_TOTAL "Fine motor total",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.FNMTR24_TOTAL"
    a :integer
    
    label "Problem solving"
    
    q_PSLV24_COPY_1 "After watching you draw a line from the top of the paper to the bottom with a crayon (or pencil or pen), does your child 
    copy you by drawing a single line on the paper in any direction? (Mark \"not yet\" if your child scribbles back and forth.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_COPY_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV24_DMPBTL_2 "After a crumb or Cheerio is dropped into a small, clear bottle, does your child turn the bottle over and dump it out? 
    (You may show him how.) (You can use a soda-pop bottle or a baby bottle.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_DMPBTL_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV24_PRETEND_3 "Does your child pretend objects are something else? For example, does your child hold a cup to her ear, pretending it is 
    a telephone? Does she put a box on her head, pretending it is a hat? Does she use a block or small toy to stir food?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_PRETEND_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV24_AWAY_4 "Does your child put things away where they belong? For example, does he know his toys belong on the toy shelf, his blanket 
    goes on his bed, and dishes go in the kitchen?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_AWAY_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV24_STDON_5 "If your child wants something she cannot reach, does she find a chair or box to stand on to reach it (for example, to get 
    a toy on a counter or to \"help\" you in the kitchen)?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_STDON_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV24_LINE4_6 "While your child watches, line up four objects like blocks or cars in a row. Does your child copy or imitate you and 
    line up four objects in a row? (You can also use spools of thread, small boxes, or other toys.)",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_LINE4_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV24_TOTAL "Problem solving total",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_TOTAL"
    a :integer
    
    label "Personal-social"        
  
    q_PSOC24_SPILL_1 "Does your child drink from a cup or glass, putting it down again with little spilling?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSOC24_SPILL_1",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC24_COPY_2 "Does your child copy the activities you do, such as wipe up a spill, sweep, shave, or comb hair?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSOC24_COPY_2",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_PSOC24_FORK_3 "Does child eat with a fork?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSOC24_FORK_3",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC24_HUGTOY_4 "When playing with a stuffed animal or a doll, does your child pretend to rock it, feed it, change its diapers, 
    put it to bed, and so forth?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSOC24_HUGTOY_4",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC24_PUSHTOY_5 "Does your child push a little wagon, stroller, or other toy on wheels, steering it around objects and backing out of 
    corners if he cannot turn?",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSOC24_PUSHTOY_5",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSOC24_CALLI_6 "Does your child call herself \"I\" or \"me\" more often than her own name? For example, \"I do it,\" more often than 
    \"Juanita do it.\"",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSOC24_CALLI_6",
    :pick=>:one    
    a_0 "Not Yet"
    a_5 "Sometimes"
    a_10 "Yes"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    
    q_PSLV24_TOTAL "Personal-social total",
    :data_export_identifier=>"TWENTY_FOUR_MTH_SAQ.PSLV24_TOTAL"
    a :integer
  end
end       