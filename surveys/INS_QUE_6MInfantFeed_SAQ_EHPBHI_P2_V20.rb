survey "INS_QUE_6MInfantFeed_SAQ_EHPBHI_P2_V2.0" do
  section "Interview introduction", :reference_identifier=>"6MInfantFeed_SAQ" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_SAQ_2.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    label "Thank you for agreeing to participate in the National Children’s Study. This self-administered 
    questionnaire will take about 10 minutes to complete. There are questions about your child’s diet. 
    Your answers are important to us. There are no right or wrong answers. You can skip over any question. 
    We will keep everything that you tell us confidential."
  end
  section "Child feeding questionnaire", :reference_identifier=>"6MInfantFeed_SAQ" do
    label "First, we will ask about the milk, formula, and food your child has eaten."
    
    q_BREAST_FEED "Did you ever breast feed your baby?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_FEED"
    a_1 "Yes"
    a_2 "No"
    
    group "Breast feeding information" do 
      dependency :rule=>"A"
      condition_A :q_BREAST_FEED, "==", :a_1
            
      q_BREAST_FEED_NOW "Are you currently breast feeding your baby?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_FEED_NOW"
      a_1 "Yes"
      a_2 "No"

      q_PUMPED "Did you ever feed your baby pumped or expressed breast milk?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.PUMPED"
      a_1 "Yes"
      a_2 "No"
      
      q_PUMPED_NOW "Are you currently feeding your baby pumped or expressed breast milk?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.PUMPED_NOW"
      a_1 "Yes"
      a_2 "No"
      dependency :rule=>"A"
      condition_A :q_PUMPED, "==", :a_1      
    end
    
    group "Breast feeding additional information" do
      dependency :rule=>"A and B"
      condition_A :q_BREAST_FEED_NOW, "==", :a_2
      condition_B :q_PUMPED, "==", :a_2      
      
      label "How old was your baby when you completely stopped feeding your baby breast milk?"
    
      q_BREAST_STOP "Number",
      :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_STOP"
      a_num :integer
    
      q_BREAST_STOP_UNIT "Unit",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_STOP_UNIT"
      a_1 "Weeks"
      a_2 "Months"
      a_neg_7 "Never fed breast milk"
    end
    
    q_FED_7DAYS "The next questions will ask about the milk, formula, and food your child has eaten. 
    In the past 7 days, how often was your baby fed each item listed below? Include feedings by everyone 
    who feeds the baby and include snacks and night-time feedings. If your baby was fed the item once a 
    day or more, write the number of feedings per day in the spaces above \"NUMBER\" and then circle \"1\" 
    for \"DAY\" below. If your baby was fed the item less than once a day, write the number of feedings per 
    week in the spaces above \"NUMBER\" and then circle \"2\" for \"WEEK\" below. If your baby was not 
    fed the item at all during the past 7 days, write \"00\" in the spaces above NUMBER.",
    :help_text => "Re-read introductory statement (In the past 7 days, how often was your baby fed each item 
    listed below?) as needed."
    
    label "Breast milk (include breast fed and expressed or pumped breast milk)?"
    
    q_BREAST_MILK "Amount",
    :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_MILK"
    a_num "Number", :integer
    
    q_BREAST_UNIT "Unit",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    label "Formula?"
    
    q_FORMULA_OFTEN "Amount",
    :data_export_identifier=>"SIX_MTH_SAQ_2.FORMULA_OFTEN"
    a_num "Number", :integer
    
    q_FORMULA_OFTEN_UNIT "Unit",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.FORMULA_OFTEN_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    label "Cow’s milk?"
    
    q_COW_MILK "Amount",
    :data_export_identifier=>"SIX_MTH_SAQ_2.COW_MILK"
    a_num "Number", :integer
    
    q_COW_MILK_UNIT "Unit",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.COW_MILK_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    label "Other milk (soy milk, rice milk, goat milk)?"
    
    q_MILK_OTHER "Amount",
    :data_export_identifier=>"SIX_MTH_SAQ_2.MILK_OTHER"
    a_num "Number", :integer
    
    q_MILK_OTHER_UNIT "Unit",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.MILK_OTHER_UNIT"
    a_1 "Day"
    a_2 "Week"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_PUMPED_2 "In the past 7 days, about how often was your baby fed pumped or expressed breast milk? Include feedings 
    by everyone who feeds the baby and include snacks and night-time feedings.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.PUMPED_2"
    a_neg_7 "Never"
    a_2 "1 time per week"
    a_3 "2 to 4 times per week"
    a_4 "Nearly every day"
    a_5 "1 to 3 times per day"
    a_6 "More than 4 times per day"
    dependency :rule=>"A or B"
    condition_A :q_PUMPED, "!=", :a_2
    condition_B :q_PUMPED_NOW, "!=", :a_2
    
    group "Breast milk information" do
      dependency :rule=>"A"
      condition_A :q_PUMPED_2, "!=", :a_neg_7      
    
      q_BREAST_MILK_STORED "In the past 7 days, about how long was your breast milk usually stored in the refrigerator before 
      it was fed to your baby? (Include cooler with cold source such as freezer packs).",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_MILK_STORED"
      a_1 "1 day or less"
      a_2 "2-3 days"
      a_3 "4-5 days"
      a_4 "More than 6 days"
      a_neg_7 "Did not store breast milk in refrigerator"

      q_BREAST_MILK_TEMP "In the past 7 days, about how long was your breast milk usually kept at room temperature and then fed to your baby?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.BREAST_MILK_TEMP"
      a_1 "Less than 2 hours"
      a_2 "2-4 hours"
      a_3 "5-8 hours"
      a_4 "More than 8 hours"
      a_neg_7 "Did not keep breast milk at roomtemperature"
    end

    q_FORMULA "How old was your baby when {he/she} was first fed formula on a daily basis?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.FORMULA"
    a_1 "Less than one week"
    a_2 "7 to 13 days"
    a_3 "14 to 31 days"
    a_4 "More than 31 days"
    a_neg_7 "Never fed formula"
    
    group "Formula information" do
      dependency :rule=>"A"
      condition_A :q_FORMULA, "!=", :a_neg_7
          
      q_FORMULA_IRON "Was the formula fed to your baby within the past 7 days with iron or a low iron formula?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.FORMULA_IRON"
      a_1 "With iron"
      a_2 "Low iron"

      q_FORMULA_TYPE "Was the formula fed to your baby within the past 7 days ready-to-feed, liquid concentrate, 
      powder from a can that makes more than one bottle, or powder from single serving packets?",
      :pick => :any,
      :data_export_identifier=>"SIX_MTH_SAQ_FORMULA_TYPE_2.FORMULA_TYPE"
      a_1 "Ready-to-feed"
      a_2 "Liquid concentrate"
      a_3 "Powder from a can that makes more than one bottle"
      a_4 "Powder from single serving packets"
    end
    
    q_FORMULA_LABEL "When the formula was mixed, was it made according to the directions on the formula label?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.FORMULA_LABEL"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"(A and (B or C or D)) or E"
    condition_A :q_FORMULA_TYPE, "==", :a_1
    condition_B :q_FORMULA_TYPE, "==", :a_2
    condition_C :q_FORMULA_TYPE, "==", :a_3
    condition_D :q_FORMULA_TYPE, "==", :a_4
    condition_E :q_FORMULA_TYPE, "!=", :a_1
    
    group "Formula mixing information" do
      dependency :rule=>"A"
      condition_A :q_FORMULA_LABEL, "==", :a_2
          
      label "When the formula was mixed, how much formula and how much water were used?"

      q_FORMULA_AMT "Formula - amount",
      :data_export_identifier=>"SIX_MTH_SAQ_2.FORMULA_AMT"
      a_amt :integer
    
      q_FORMULA_UNIT "Formula - unit",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.FORMULA_UNIT"
      a_1 "Tablespoon"
      a_2 "Teaspoon"
      a_3 "Ounce"
      a_4 "Cup"
      a_5 "Packet"
      a_6 "Formula Can"
    
      q_WATER_AMT "Water - amount",
      :data_export_identifier=>"SIX_MTH_SAQ_2.WATER_AMT"
      a_amt :integer
    
      q_WATER_UNIT "Water - unit",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.WATER_UNIT"
      a_1 "Tablespoon"
      a_2 "Teaspoon"
      a_3 "Ounce"
    end
    
    q_WATER_1 "During the past 7 days, what types of water have you and others who care 
    for your baby used for mixing your baby’s formula?",
    :help_text => "Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"SIX_MTH_SAQ_WATER_2.WATER_1"
    a_1 "Tap water from the cold faucet"
    a_2 "Warm tap water from the hot faucet"
    a_3 "Bottled water"
    a_4 "No water used"
    dependency :rule=>"A"
    condition_A :q_FORMULA_LABEL, "==", :a_1
    
    q_WATER_2 "In the past 7 days, was the water used to mix the formula ALWAYS boiled?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.WATER_2"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_WATER_1, "!=", :a_4
    
    group "Additional information about formula" do
      dependency :rule=>"A"
      condition_A :q_FORMULA, "!=", :a_neg_7
          
      q_OUNCES "In the past 7 days, on the average, how many ounces of formula did your baby drink at each feeding?",
      :data_export_identifier=>"SIX_MTH_SAQ_2.OUNCES"
      a_ounces "Ounces", :string

      label_CLEAN_HANDS "Now think about how you cleaned your hands when you were preparing formula. 
      During the past 7 days, did you never, sometimes, most of the time, or always:",
      :help_text => "Re-read introductory statement (Now think about how you cleaned your hands when you 
      were preparing formula. During the past 7 days, did you never, sometimes, most of the time, or always:) as needed."
    
      q_CLEAN_HANDS_1 "Rinse hands with water only.",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.CLEAN_HANDS_1"
      a_1 "Never"
      a_2 "Sometimes"
      a_3 "Most of the Time"
      a_4 "Always"
    
      q_CLEAN_HANDS_2 "Wipe hands only.",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.CLEAN_HANDS_2"
      a_1 "Never"
      a_2 "Sometimes"
      a_3 "Most of the Time"
      a_4 "Always"
    
      q_CLEAN_HANDS_3 "Wash hands with soap.",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.CLEAN_HANDS_3"
      a_1 "Never"
      a_2 "Sometimes"
      a_3 "Most of the Time"
      a_4 "Always"
    
      q_CLEAN_HANDS_4 "Use a hand sanitizer (such as gel or wipes).",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.CLEAN_HANDS_4"
      a_1 "Never"
      a_2 "Sometimes"
      a_3 "Most of the Time"
      a_4 "Always"
    
      q_CLEAN_HANDS_5 "Prepare formula without cleaning your hands.",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.CLEAN_HANDS_5"
      a_1 "Never"
      a_2 "Sometimes"
      a_3 "Most of the Time"
      a_4 "Always"
    end
    
    label_B_TYPE "In the past 7 days, about how often did your baby drink from each of the following types of bottles and cups?",
    :help_text => "Re-read introductory statement (In the past 7 days, about how often did your baby 
    drink from each of the following types of bottles and cups?:) as needed."
    
    q_B_TYPE_1 "Plastic baby bottle with disposable bottle liner.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.B_TYPE_1"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    
    q_B_TYPE_2 "Plastic baby bottle without disposable liner",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.B_TYPE_2"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    
    q_B_TYPE_3 "Other plastic bottle (for example, a water bottle).",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.B_TYPE_3"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    
    q_B_TYPE_4 "Glass baby bottle.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.B_TYPE_4"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    
    q_B_TYPE_5 "Plastic \"no spill\" cup.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.B_TYPE_5"
    a_1 "Never"
    a_2 "Sometimes"
    a_3 "Most of the Time"
    a_4 "Always"
    
    q_PACIFIER "Has your baby used a pacifier in the past 7 days?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.PACIFIER"
    a_1 "Yes"
    a_2 "No"
    
    q_COWS_MILK_1 "Has your baby ever been fed cow’s milk that was not sold especially for babies? 
    (This includes whole, lowfat, nonfat, or chocolate milk.)",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.COWS_MILK_1"
    a_1 "Yes"
    a_2 "No"

    group "Cow milk information" do
      dependency :rule=>"A"
      condition_A :q_COWS_MILK_1, "==", :a_1
      
      label "How old was your baby when he/she was first fed cow’s milk that was not sold especially for babies?"
    
      q_COWS_MILK_2 "Amount",
      :data_export_identifier=>"SIX_MTH_SAQ_2.COWS_MILK_2"
      a_number :integer
    
      q_COWS_MILK_2_UNIT "Unit",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.COWS_MILK_2_UNIT"
      a_1 "Days"
      a_2 "Weeks"
    end
    
    q_JUICE "Have you ever fed your baby fruit juice that was not sold especially for babies?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.JUICE"
    a_1 "Yes"
    a_2 "No"
    
    group "Juice information" do
      dependency :rule=>"A"
      condition_A :q_JUICE, "==", :a_1

      label "How old was your baby when he/she was first fed fruit juice that was not sold especially for babies?"

      q_JUICE_AGE "Amount",
      :data_export_identifier=>"SIX_MTH_SAQ_2.JUICE_AGE"
      a_number :integer
    
      q_JUICE_AGE_UNIT "Unit",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.JUICE_AGE_UNIT"
      a_1 "Days"
      a_2 "Weeks"
    
      q_JUICE_CALCIUM "About how often was the fruit juice fortified with calcium?",
      :pick => :one,
      :data_export_identifier=>"SIX_MTH_SAQ_2.JUICE_CALCIUM"
      a_1 "Always"
      a_2 "Sometimes"
      a_3 "Rarely"
      a_4 "Never"
      a_neg_2 "Don’t know"
    end
    
    label_C_FOOD "Now think about fruits, vegetables, and meats that may have been fed to your baby 
    in the past 7 days. How often was each of the foods your baby ate commercial baby food? (Commercial 
    baby food is food sold for babies. Foods that are NOT commercial baby food are table foods your whole 
    family eats, foods you made especially for your baby, fresh fruit, and fruit juices that are not sold 
    especially for babies.)",
    :help_text => "Re-read introductory statement (Now think about fruits, vegetables, and meats that may 
    have been fed to your baby in the past 7 days. How often was each of the foods your baby ate commercial 
    baby food? (Commercial baby food is food sold for babies. Foods that are NOT commercial baby food are 
    table foods your whole family eats, foods you made especially for your baby, fresh fruit, and fruit juices 
    that are not sold especially for babies:) as needed."
    
    q_C_FOOD1 "Fruit and vegetable juice.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.C_FOOD1"
    a_1 "Always"
    a_2 "Usually"
    a_3 "Sometimes"
    a_4 "Never"
    a_5 "Not Fed to My Baby"
    
    q_C_FOOD2 "Fruit",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.C_FOOD2"
    a_1 "Always"
    a_2 "Usually"
    a_3 "Sometimes"
    a_4 "Never"
    a_5 "Not Fed to My Baby"
    
    q_C_FOOD3 "Vegetable.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.C_FOOD3"
    a_1 "Always"
    a_2 "Usually"
    a_3 "Sometimes"
    a_4 "Never"
    a_5 "Not Fed to My Baby"
    
    q_C_FOOD4 "Meat, chicken and turkey",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.C_FOOD4"
    a_1 "Always"
    a_2 "Usually"
    a_3 "Sometimes"
    a_4 "Never"
    a_5 "Not Fed to My Baby"
    
    q_C_FOOD5 "Combination dinner (for example, Spaghetti Dinner, Pasta and Vegetable Dinner, or a Turkey and Rice Dinner).",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.C_FOOD5"
    a_1 "Always"
    a_2 "Usually"
    a_3 "Sometimes"
    a_4 "Never"
    a_5 "Not Fed to My Baby"
    
    q_ORGANIC "During the past 7 days, were the baby foods your baby ate always, sometimes, rarely, or never organic baby foods?",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.ORGANIC"
    a_1 "Always"
    a_2 "Usually"
    a_3 "Sometimes"
    a_4 "Never"
    a_5 "Not Fed to My Baby"
    
    q_SUPPLEMENT "Which of the following supplements was your child given at least three days a week during the past 2 weeks?",
    :help_text => "Select all that apply",
    :pick => :any,
    :data_export_identifier=>"SIX_MTH_SAQ_SUPP_2.SUPPLEMENT"
    a_1 "Fluoride"
    a_2 "Iron"
    a_3 "Vitamin D"
    a_neg_5 "Other vitamins or supplements"
    a_5 "None"
    
    q_SUPPLEMENT_OTH "Other",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_SUPP_2.SUPPLEMENT_OTH"
    a "Specify", :string
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_SUPPLEMENT, "==", :a_neg_5
    
    q_SUPP_FORM "Were the supplements you gave your baby in the form of drops or pills?",
    :help_text => "Mark crushed pills mixed with liquid as \"Pills\".",
    :pick => :any,
    :data_export_identifier=>"SIX_MTH_SAQ_2.SUPP_FORM"
    a_1 "Drops"
    a_2 "Pills"
    
    q_HERBAL "Was your baby given any herbal or botanical preparations or any kind of tea or home 
    remedy in the past 7 days? Do not count preparations put on the baby’s skin or anything the 
    baby may have gotten from breast milk after you took an herbal or botanical preparation.",
    :pick => :one,
    :data_export_identifier=>"SIX_MTH_SAQ_2.HERBAL"
    a_1 "Yes"
    a_2 "No"
    
    q_HERBAL_OTH "Please write in the name of all of the kinds of herbal or botanical preparations, 
    teas or home remedies your baby was given in the past 7 days.",
    :data_export_identifier=>"SIX_MTH_SAQ_2.HERBAL_OTH"
    a :text
    dependency :rule=>"A"
    condition_A :q_HERBAL, "==", :a_1
    
    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"SIX_MTH_SAQ_2.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
    
    label "Thank you for participating in the National Children’s Study and for taking the time to complete this survey.", 
    :help_text => "If SAQ is completed as a PAPI, SCs must provide instructions and a business reply envelope for participant to return."
  end
end