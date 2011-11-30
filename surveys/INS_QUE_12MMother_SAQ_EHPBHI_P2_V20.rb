survey "INS_QUE_12MMother_SAQ_EHPBHI_P2_V2.0" do
  section "Self-administered questionaire", :reference_identifier=>"12MMother_SAQ_2" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_SAQ_2.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    label "Thank you for agreeing to participate in the National Children’s Study. This self-administered questionnaire will take
    about 10 minutes to complete. There are questions about your relationships, experiences as a parent, and questions about your
    child’s diet."

    label "Your answers are important to us. There are no right or wrong answers. You can skip over any question.
    We will keep everything that you tell us confidential. "

# TODO:
# PROGRAMMER INSTRUCTION:
#
# • IF MARISTAT IN PERSON TABLE ≠ 1 OR 2, GO TO RSC010.

    label "The first set of items are about your relationship with your spouse or partner. Please indicate the extent to which you
    agree or disagree with each statement"

    q_SP_LISTEN "My spouse/partner listens to me when I need someone to talk to.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.SP_LISTEN"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Neither agree nor disagree"
    a_4 "Somewhat agree"
    a_5 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_SP_FEEL "I can state my feelings without him getting defensive.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.SP_FEEL"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Neither agree nor disagree"
    a_4 "Somewhat agree"
    a_5 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_SP_DISTANT "I often feel distant from my spouse/partner.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.SP_DISTANT"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Neither agree nor disagree"
    a_4 "Somewhat agree"
    a_5 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_SP_UNDERSTAND "My spouse/partner can really understand my hurts and joys.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.SP_UNDERSTAND"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Neither agree nor disagree"
    a_4 "Somewhat agree"
    a_5 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_SP_NEGLECT "I feel neglected at times by my spouse/partner.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.SP_NEGLECT"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Neither agree nor disagree"
    a_4 "Somewhat agree"
    a_5 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_SP_LONELY "I sometimes feel lonely when we’re together.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.SP_LONELY"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Neither agree nor disagree"
    a_4 "Somewhat agree"
    a_5 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    label "The next series of questions contain statements about children. Many statements describe normal feelings
    and behaviors, but some describe things that can be problems. Some statements may seem too young or too old for
    your child. Please indicate the response that best describes your child in the LAST MONTH."

    q_BEHAVE_1 "Shows pleasure when he/she succeeds (for example, claps for self)",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_1"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_2 "Gets hurt so often that you can’t take your eyes off him/her",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_2"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_3 "Seems nervous, tense or fearful",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_3"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_4 "Is restless and can’t sit still",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_4"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_5 "Follows rules",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_5"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_6 "Wakes up at night and needs help to fall asleep again",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_6"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_7 "Cries or tantrums until he/she is exhausted",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_7"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_8 "Is afraid of certain places, animals or things",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_8"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_9 "Has less fun than other children",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_9"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_10 "Looks for you (or other parent) when upset",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_10"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_11 "Cries or hangs onto you when you try to leave",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_11"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_12 "Worries a lot or is very serious",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_12"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_13 "Looks right at you when you say his/her name",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_13"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_14 "Does not react when hurt",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_14"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_15 "Is affectionate with loved ones",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_15"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_16 "Won’t touch some objects because of how they feel",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_16"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_17 "Has trouble falling asleep or staying asleep",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_17"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_18 "Runs away in public places",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_18"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_19 "Plays well with other children, not including brother/sister",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_19"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_20 "Can pay attention for a long time (not including TV)",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_20"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_21 "Has trouble adjusting to change",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_21"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_22 "Tries to help when someone is hurt. For example, gives a toy",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_22"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_23 "Often gets very upset",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_23"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_24 "Gags or chokes food",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_24"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_25 "Imitates playful sounds when you ask him/her to",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_25"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_26 "Refuses to eat",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_26"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_27 "Hits, shoves, kicks or bites children other than brother/sister",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_27"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_28 "Is destructive. Breaks or ruins things on purpose.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_28"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_29 "Points to show you something far away",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_29"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_30 "Hits, bites or kicks you or other parent",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_30"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_31 "Hugs or feeds dolls or stuffed animals",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_31"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_32 "Seems very unhappy, sad, depressed or withdrawn",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_32"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_33 "Purposely tries to hurt you or other parent",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_33"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVE_34 "When upset, gets very still, freezes or doesn’t move",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVE_34"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    label "The following items are about feelings and behaviors that young children may do. Some of the questions may be a bit
    hard to understand, especially if you have not seen them in a child. Please do your best to answer them anyway. How do
    the following descriptions describe your child? "

    q_BEHAVIORS_1 "Puts things in a special order, over and over",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_1"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVIORS_2 "Repeats the same action or phrase, over and over",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_2"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVIORS_3 "Repeats a particular movement, over and over (like rocking, spinning, etc.)",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_3"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVIORS_4 "\"Spaces out.\" Is totally unaware of what’s happening around him/her",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_4"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVIORS_5 "Does not make eye contact",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_5"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVIORS_6 "Avoids physical contact",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_6"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVIORS_7 "Eats or drinks things that are not edible, like paper or paint",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_7"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BEHAVIORS_8 "Hurts him/herself on purpose. For example, bangs his or her head.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BEHAVIORS_8"
    a_1 "Not true/Rarely"
    a_2 "Somewhat true/Sometimes"
    a_3 "Very true/Often"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_SAQ_2.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"

    label "The next questions will ask about the milk, formula, and food your child has eaten. In the past 7 Days,
    how often was your baby fed each item listed below? "

    label "Include feedings by everyone who feeds the baby and include snacks and night-time feedings. If your baby
    was fed the item once a Day or more, write the Number of feedings per Day. If your baby was fed the item less than
    once a Day, write the Number of feedings per Week. If your baby was not fed the item at all during the past 7 Days, write 0",
    :help_text => "Re-read introductory statement (In the past 7 Days, how often was your baby fed each item listed below?) as needed"

    q_BREAST_MILK "Breast milk (include breast fed and expressed or pumped breast milk)?",
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BREAST_MILK"
    a_Number "Number", :integer

    q_BREAST_UNIT "Breast milk unit?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BREAST_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_FORMULA "Formula?",
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.FORMULA"
    a_Number "Number", :integer

    q_FORMULA_UNIT "Formula unit?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.FORMULA_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_COW_MILK "Cow’s milk?",
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.COW_MILK"
    a_Number "Number", :integer

    q_COW_MILK_UNIT "Cow’s milk unit?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.COW_MILK_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_MILK_OTHER "Other milk (soy milk, rice milk, goat milk)?",
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.MILK_OTHER"
    a_Number "Number", :integer

    q_MILK_OTHER_UNIT "Other milk (soy milk, rice milk, goat milk) unit?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.MILK_OTHER_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BREAST_MILK_FED "Please tell me which best describes what your baby has been fed. My baby...",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BREAST_MILK_FED"
    a_1 "... is not drinking breast milk now, but was fed breast milk in the past"
    a_2 "... is drinking breast milk now"
    a_3 "... was never fed breast milk"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_BREAST_STOP "How old was your baby when you completely stopped breastfeeding and pumping or expressing breast milk?",
    :help_text => "If baby was less than one month, enter age in weeks; if older than one month, enter age in months.",
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BREAST_STOP"
    a "Number", :integer
    dependency :rule=>"A and B"
    condition_A :q_BREAST_MILK_FED, "!=", :a_2
    condition_B :q_BREAST_MILK_FED, "!=", :a_3

    q_BREAST_STOP_UNIT "Unit",
    :help_text => "If baby was less than one month, enter age in weeks; if older than one month, enter age in months.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.BREAST_STOP_UNIT"
    a_1 "Weeks"
    a_2 "Months"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A and B"
    condition_A :q_BREAST_MILK_FED, "!=", :a_2
    condition_B :q_BREAST_MILK_FED, "!=", :a_3

    q_PUMPED "Have you ever fed your baby pumped or expressed breast milk?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.PUMPED"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_BREAST_MILK_FED, "==", :a_2

    q_PUMPED_2 "In the past 7 days, about how often was your baby fed pumped or expressed breast milk? Include feedings by
    everyone who feeds the baby and include snacks and nighttime feedings.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.PUMPED_2"
    a_1 "1 time per week"
    a_2 "2 to 4 times per week"
    a_3 "Nearly every day"
    a_4 "1 time per day"
    a_5 "2 to 3 times per day"
    a_6 "4 to 6 times per day"
    a_7 "More than 6 times per day"
    a_neg_7 "Not applicable/I have not fed my baby breast milk in the past 7 days"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_PUMPED, "==", :a_1

    q_FORMULA_FED "How old was your baby when (he/she) was first fed formula on a daily basis?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.FORMULA_FED"
    a_1 "Less than 1 month old"
    a_2 "1 to 2 months old"
    a_3 "3 to 4 months old"
    a_4 "5 to 6 months old"
    a_5 "More than 6 months old"
    a_neg_7 "Not applicable (never fed formula to baby)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_FORMULA_LAST7 "Has your baby had formula in the last seven days?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.FORMULA_LAST7"
    a_1 "Yes"
    a_2 "No"
    a_neg_7 "Not applicable (Never fed formula to baby)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_FORMULA_FED, "!=", :a_neg_7

    q_FORMULA_BRAND "What kind of infant formula was your baby fed in the past 7 days?",
    :help_text => "Infant formulas are listed alphabetically. Probe for any other formula the baby was fed in the
    past 7 days. Select all that apply",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_SAQ_FORMULA_BRAND_2.FORMULA_BRAND"
    a_1 "Baby’s Only Organic Dairy"
    a_2 "Baby’s Only Organic Soy"
    a_3 "Baby’s Only Organic Lactose Free"
    a_4 "Bright Beginnings milk-based"
    a_5 "Bright Beginnings Gentle milk-based"
    a_6 "Bright Beginnings Organic"
    a_7 "Bright Beginnings milk-based 2"
    a_8 "Bright Beginnings NeoCare"
    a_9 "Earth’s Best Organic Infant Formula with DHA & ARA"
    a_10 "Earth’s Best Organic Soy Infant Formula with DHA & ARA"
    a_11 "EleCare®"
    a_12 "Enfamil® Premium with Triple Health Guard"
    a_13 "Enfamil® Premium Next Step"
    a_14 "Enfamil® ProSobee®"
    a_15 "Enfamil® RestFull"
    a_16 "Enfamil AR®"
    a_17 "Enfamil® Gentlease®"
    a_18 "Enfamil® Gentlease® Next Step"
    a_19 "Enfamil® Enfacare"
    a_20 "Enfamil® Premature"
    a_21 "Enfamil® Premium Vanilla or Chocolate"
    a_22 "Enfamil® Soy Next Step"
    a_23 "Gerber® Good Start® Gentle Plus"
    a_24 "Gerber® Good Start® Gentle Plus 2"
    a_25 "Gerber® Good Start® Protect Plus"
    a_26 "Gerber® Good Start® Protect Plus 2"
    a_27 "Gerber® Good Start® Soy Plus"
    a_28 "Gerber® Good Start® Soy Plus 2"
    a_29 "Nutramigen® with Enflora LGG"
    a_30 "Nutramigen® AA"
    a_31 "Pregestimil®"
    a_32 "Similac® Advance® EarlyShield"
    a_33 "Similac Isomil® Advance®"
    a_34 "Similac Isomil® DF"
    a_35 "Similac® Organic"
    a_36 "Similac® Go & Grow"
    a_37 "Similac® Go & Grow EarlyShield"
    a_38 "Similac® Sensitive"
    a_39 "Similac® Sensitive R.S."
    a_40 "Similac® Alimentum®"
    a_41 "Similac® Neosure®"
    a_42 "Store brand Milk based (like Member’s Mark, Kirkland, Target up & up)"
    a_43 "Store brand Gentle or partially broken down whey protein formula (like Member’s Mark or Target up & up))"
    a_44 "Store brand Soy based (like Target up & up)"
    a_45 "Store brand Next step (like Target up & up)"
    a_46 "Store brand Lacto sensitive (like Target up & up)"
    a_47 "Store brand Prebiotic (like Target up & up)"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A and B and C"
    condition_A :q_FORMULA_LAST7, "!=", :a_2
    condition_B :q_FORMULA_LAST7, "!=", :a_neg_7
    condition_C :q_FORMULA_FED, "!=", :a_neg_7

    q_FORMULA_BRAND_OTH "Other Formula Brand",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_FORMULA_BRAND_2.FORMULA_BRAND_OTH"
    a "Specify:", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A and B and C"
    condition_A :q_FORMULA_BRAND, "==", :a_neg_5
    condition_B :q_FORMULA_BRAND, "!=", :a_neg_1
    condition_B :q_FORMULA_BRAND, "!=", :a_neg_2

    q_FORMULA_TYPE "Was the formula ready-to-feed, liquid concentrate, powder from a can that makes a single
    serving, or powder from single serving packets?",
    :help_text => "Select all that apply",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_SAQ_FORMULA_BRAND_2.FORMULA_TYPE"
    a_1 "Ready-to-feed"
    a_2 "Liquid concentrate"
    a_3 "Powder from a can that makes more than one bottle"
    a_4 "Powder from single serving packets"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A or B"
    condition_A :q_FORMULA_LAST7, "!=", :a_2
    condition_B :q_FORMULA_LAST7, "!=", :a_neg_7

    q_WATER_1 "During the past 7 days, what types of water have you and others who care for your baby used for
    mixing your baby’s formula?",
    :help_text => "Select all that apply",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_SAQ_WATER_2.WATER_1"
    a_1 "Tap water from the cold faucet"
    a_2 "Warm tap water from the hot faucet"
    a_3 "Bottled water"
    a_neg_5 "Other type of water used"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A and B and C and (D or E or F))"
    condition_A :q_FORMULA_TYPE, "!=", :a_neg_1
    condition_B :q_FORMULA_TYPE, "!=", :a_neg_2
    condition_C :q_FORMULA_TYPE, "==", :a_1
    condition_D :q_FORMULA_TYPE, "==", :a_2
    condition_E :q_FORMULA_TYPE, "==", :a_3
    condition_F :q_FORMULA_TYPE, "==", :a_4

    q_WATER_1_OTH "Specify other type of water user",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_WATER_2.WATER_1_OTH"
    a_specify "Specify: ", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A and B and C"
    condition_A :q_WATER_1, "==", :a_neg_5
    condition_B :q_WATER_1, "!=", :a_neg_1
    condition_C :q_WATER_1, "!=", :a_neg_2

    q_WATER_2 "Was the water used to mix the formula boiled?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.WATER_2"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A and B and C and (D or E or F))"
    condition_A :q_FORMULA_TYPE, "!=", :a_neg_1
    condition_B :q_FORMULA_TYPE, "!=", :a_neg_2
    condition_C :q_FORMULA_TYPE, "==", :a_1
    condition_D :q_FORMULA_TYPE, "==", :a_2
    condition_E :q_FORMULA_TYPE, "==", :a_3
    condition_F :q_FORMULA_TYPE, "==", :a_4

    q_OUNCES "In the past 7 days, on the average, how many ounces of formula did your baby drink at each feeding?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.OUNCES"
    a_Ounces "Ounces", :integer
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A or B"
    condition_A :q_FORMULA_LAST7, "!=", :a_2
    condition_B :q_FORMULA_LAST7, "!=", :a_neg_7

    label_BOTTLE_TYPE "In the past 7 days, about how often did your baby drink from each of the following types of bottles and cups?",
    :help_text => "Re-read introductory statement (In the past 7 days, about how often did your baby drink from each of the
    following types of bottles and cups?:) as needed"

    q_B_TYPE_1 "Plastic baby bottle with disposable bottle liner.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.B_TYPE_1"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_B_TYPE_2 "Plastic baby bottle without disposable liner.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.B_TYPE_2"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_B_TYPE_3 "Other plastic bottle (for example, a water bottle).",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.B_TYPE_3"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_B_TYPE_4 "Other plastic bottle (for example, a water bottle).",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.B_TYPE_4"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_B_TYPE_5 "Plastic \"no spill\" cup",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.B_TYPE_5"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

# NOTE : TYPO in the MDES2 for the variable name - record 5666
    q_PACIFIER "Has your baby used a pacifier in the past 7 days?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.PACIFER"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_COWS_MILK_1 "Has your baby ever been fed cow’s milk that was not sold especially for babies? (This
    includes whole, low-fat, nonfat, or chocolate milk.)",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.COWS_MILK_1"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_COWS_MILK_2 "How old was your baby when he/she was first fed cow’s milk that was not sold especially for babies?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.COWS_MILK_2"
    a_age_in_months "Age in months", :integer
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_COWS_MILK_1, "==", :a_1

    q_CEREAL "How old was your baby when he/she was first fed cereal, including baby cereal on a daily basis?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.CEREAL"
    a_1 "Less than 1 month old"
    a_2 "1 to 2 months old"
    a_3 "3 to 4 months old"
    a_4 "5 to 6 months old"
    a_5 "More than 6 months old"
    a_neg_7 "Not applicable (never fed cereal)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_PUREED "How old was your baby when he/she was first fed pureed baby food on a daily basis? Please include
    commercial (store bought) and homemade baby food.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.PUREED"
    a_1 "Less than 1 month old"
    a_2 "1 to 2 months old"
    a_3 "3 to 4 months old"
    a_4 "5 to 6 months old"
    a_5 "More than 6 months old"
    a_neg_7 "Not applicable (never fed cereal)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_TABLE_FOOD "How old was your baby when he/she was first fed table food such as eggs, cheese, or potatoes on a daily basis?",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.TABLE_FOOD"
    a_1 "Less than 1 month old"
    a_2 "1 to 2 months old"
    a_3 "3 to 4 months old"
    a_4 "5 to 6 months old"
    a_5 "More than 6 months old"
    a_neg_7 "Not applicable (never fed cereal)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_SUPPLEMENT "Which of the following supplements was your child given at least 3 days a week during the past 2 weeks?",
    :help_text => "Select all that apply",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT"
    a_1 "Fluoride"
    a_2 "Iron"
    a_3 "Vitamin D"
    a_neg_5 "Other vitamins or supplements:"
    a_neg_7 "Not applicable (child not given supplements)"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_SUPPLEMENT_OTH "Other supplements",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_SAQ_SUPPLEMENT_2.SUPPLEMENT_OTH"
    a_specify "Specify: ", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A and B and C and D"
    condition_A :q_SUPPLEMENT, "==", :a_neg_5
    condition_B :q_SUPPLEMENT, "!=", :a_neg_7
    condition_C :q_SUPPLEMENT, "!=", :a_neg_1
    condition_D :q_SUPPLEMENT, "!=", :a_neg_2

    q_HERBAL "Was your baby given any herbal or botanical preparations or any kind of tea or home remedy in the past 7 days?
    Do not count preparations put on the baby’s skin or anything the baby may have gotten from breast milk after you took
    an herbal or botanical preparation.",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_SAQ_2.HERBAL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"TWELVE_MTH_SAQ_2.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"

    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey.",
    :help_text => "If saq is completed as a papi, scs must provide instructions and a business reply envelope for respondent to return"
  end
end
