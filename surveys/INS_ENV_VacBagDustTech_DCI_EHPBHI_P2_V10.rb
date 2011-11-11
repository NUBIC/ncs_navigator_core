survey "INS_ENV_VacBagDustTechCollect_DCI_EHPBHI_P2_V1.0" do
  section "Environmental Vacuum Bag Dust Sample Collection Instrument", :reference_identifier=>"VacBagDustTech_DCI" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"VACUUM_BAG.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    q_VACUUM_PARTICIPANT "At this visit, will the participant be asked to collect the vacuum sample?",
    :help_text => "Check site office visit specifications",
    :pick => :one,
    :data_export_identifier=>"VACUUM_BAG.VACUUM_PARTICIPANT"
    a_1 "Yes"
    a_2 "No"
    
    group "Additional questions" do
      dependency :rule=>"A"
      condition_A :q_VACUUM_PARTICIPANT, "==", :a_2
      
      label "Now we are going to ask you some questions that will help us collect the vacuum bag dust sample"
    
      q_VACUUM_IN_HOME "Do you have a vacuum cleaner in your home?",
      :pick => :one,
      :data_export_identifier=>"VACUUM_BAG.VACUUM_IN_HOME"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don't know"
    end
    
    q_VACUUM_TECH_OKAY "We would like to collect the dust from your vacuum cleaner. Is that okay?",
    :pick => :one,
    :data_export_identifier=>"VACUUM_BAG.VACUUM_TECH_OKAY"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_VACUUM_IN_HOME, "==", :a_1
    
    q_VACUUM_REFUSE "Record reason for refusal if given.",
    :pick => :one,
    :data_export_identifier=>"VACUUM_BAG.VACUUM_REFUSE"
    a_1 "None given"
    a_2 "No replacement vacuum bag"
    a_3 "Vacuum not in home"
    a_neg_5 "Other"
    dependency :rule=>"A or B"
    condition_A :q_VACUUM_IN_HOME, "==", :a_neg_1
    condition_B :q_VACUUM_TECH_OKAY, "==", :a_2
    
    # TODO
    # • ALLOW UP TO 250 CHARACTERS
    q_VACUUM_REFUSE_OTH "Other reason for refusal",
    :data_export_identifier=>"VACUUM_BAG.VACUUM_REFUSE_OTH"
    a "Specify", :string
    dependency :rule=>"A"
    condition_A :q_VACUUM_REFUSE, "==", :a_neg_5
    
    group "Vacuum information" do
      dependency :rule=>"A"
      condition_A :q_VACUUM_TECH_OKAY, "==", :a_1
    
      q_VACUUM_TYPE "Can you show us the vacuum that is used most often in your home?  This is the vacuum that we would like to collect dust from.",
      :help_text => "Record the type of vacuum that you will collect the dust from. remember: only collect dust from a handheld vacuum or a 
      shop vac if it is the only vacuum in the home. If participant brings out a shop vac or handheld vacuum ask if you can see participant’s 
      next most used vacuum before answering. Choose the one type of vacuum from which the dust sample is collected. see the vacuum bag dust 
      collection sop for photos of each type of vacuum.",
      :pick => :one,
      :data_export_identifier=>"VACUUM_BAG.VACUUM_TYPE"
      a_1 "Standard vacuum (with a disposable bag)"
      a_2 "Bag-less vacuum"
      a_3 "Handheld vacuum (with a disposable bag)"
      a_4 "Handheld vacuum (without a bag or with a reusable cloth bag)"
      a_5 "Central house collection system"
      a_6 "Robotic vacuum"
      a_7 "Hard surface vacuum (with a disposable bag)"
      a_8 "Hard surface vacuum (without a bag or with a reusable cloth bag)"
      a_9 "Shop vac"
      a_neg_5 "Other"
      
    
      # TODO
      # • ALLOW UP TO 250 CHARACTERS    
      q_VAC_TYPE_OTH "Other vacuum type",
      :data_export_identifier=>"VACUUM_BAG.VAC_TYPE_OTH"
      a "Specify", :string
      dependency :rule=>"A"
      condition_A :q_VACUUM_TYPE, "==", :a_neg_5
    
      q_VACUUM_MAKE_MODEL "Record the make and model of the vacuum you are going to collect the sample from.",
      :help_text => "Record the make or manufacturer name of the vacuum from which the dust sample will be collected. This might be eureka, 
      kenmore, hoover, dirt devil, etc. Record the model name and/or number of the vacuum from which the dust sample will be collected. 
      This might be mighty mite, magic blue, 431DX etc.",
      :data_export_identifier=>"VACUUM_BAG.VACUUM_MAKE_MODEL"
      a "Make and Model:", :string
    
      label "Approximately how has it been long since the vacuum bag was changed?" 
      dependency :rule=>"A or B or C or D"
      condition_A :q_VACUUM_TYPE, "==", :a_1
      condition_B :q_VACUUM_TYPE, "==", :a_3
      condition_C :q_VACUUM_TYPE, "==", :a_7
      condition_D :q_VACUUM_TYPE, "==", :a_neg_5
    
      label "Approximately how long has it been since you emptied the dust from the vacuum cleaner?"
      dependency :rule=>"A and B and C and D"
      condition_A :q_VACUUM_TYPE, "!=", :a_1
      condition_B :q_VACUUM_TYPE, "!=", :a_3
      condition_C :q_VACUUM_TYPE, "!=", :a_7
      condition_D :q_VACUUM_TYPE, "!=", :a_neg_5
    
      q_VACUUM_BAG_CHANGED "Length: number", 
      :data_export_identifier=>"VACUUM_BAG.VACUUM_BAG_CHANGED"
      a "Number", :integer

      q_VACUUM_BAG_CHANGED_FREQ "Length: units", :pick=>:one, 
      :data_export_identifier=>"VACUUM_BAG.VACUUM_BAG_CHANGED_FREQ"
      a_1 "Weeks"
      a_2 "Months"
      a_3 "Years"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"

      q_VAC_USED_OUTSIDE_1 "Since the vacuum bag was changed has your vacuum been used to clean a place other than your home such as...",
      :help_text => "Select all that apply",
      :pick => :any,
      :data_export_identifier=>"VACUUM_BAG_OUTSIDE.VAC_USED_OUTSIDE"
      a_1 "Your car"
      a_2 "Your garage"
      a_3 "Your porch"
      a_4 "Someone else’s home"
      a_5 "Somewhere outside your apartment, but within your apartment building"
      a_neg_5 "Other"
      dependency :rule=>"A or B or C or D"
      condition_A :q_VACUUM_TYPE, "==", :a_1
      condition_B :q_VACUUM_TYPE, "==", :a_3
      condition_C :q_VACUUM_TYPE, "==", :a_7
      condition_D :q_VACUUM_TYPE, "==", :a_neg_5
    
      q_VAC_USED_OUTSIDE_2 "Since the dust was emptied from your vacuum  has your vacuum been used to clean a place other than your 
      home such as...",
      :help_text => "Select all that apply",
      :pick => :any,
      :data_export_identifier=>"VACUUM_BAG_OUTSIDE.VAC_USED_OUTSIDE"
      a_1 "Your car"
      a_2 "Your garage"
      a_3 "Your porch"
      a_4 "Someone else’s home"
      a_5 "Somewhere outside your apartment, but within your apartment building"
      a_neg_5 "Other"
      dependency :rule=>"A and B and C and D"
      condition_A :q_VACUUM_TYPE, "!=", :a_1
      condition_B :q_VACUUM_TYPE, "!=", :a_3
      condition_C :q_VACUUM_TYPE, "!=", :a_7
      condition_D :q_VACUUM_TYPE, "!=", :a_neg_5

      # TODO
      # PROGRAMMER INSTRUCTION: 
      # • ALLOW UP TO 250 CHARACTERS
      q_VAC_USED_OUTSIDE_OTH "Other place",
      :data_export_identifier=>"VACUUM_BAG_OUTSIDE.VAC_USED_OUTSIDE_OTH"
      a "Specify: ", :string
      dependency :rule=>"A or B"
      condition_A :q_VAC_USED_OUTSIDE_1, "==", :a_neg_5
      condition_B :q_VAC_USED_OUTSIDE_2, "==", :a_neg_5
    
      q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"VACUUM_BAG.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime" 
    
      label "Vacuum bag dust sample collection instructions"
    
      label "- Put on a clean pair of powder-free disposable gloves."
    
      label "- Obtain the vacuum bag dust kit."
    
      label "- Collect the vacuum bag dust sample following the instructions in the vacuum bag collection sop." 
    
      q_VACUUM_COLLECTED "Were you able to collect the sample?", 
      :pick => :one,
      :data_export_identifier=>"VACUUM_BAG.VACUUM_COLLECTED"
      a_1 "Yes"
      a_2 "No"
    
      q_R_VACUUM_N_COLLECTED "Why were you unable to collect the sample?",
      :pick => :one,
      :data_export_identifier=>"VACUUM_BAG.R_VACUUM_N_COLLECTED"
      a_1 "Participant refused"
      a_2 "Ran out of time"
      a_3 "Supplies or kit missing"
      a_4 "Trouble removing bag/cup"
      a_neg_5 "Other"
      dependency :rule=>"A"
      condition_A :q_VACUUM_COLLECTED, "==", :a_2
    
      q_R_VACUUM_N_COLLECTED_OTH "Other reason",
      :data_export_identifier=>"VACUUM_BAG.R_VACUUM_N_COLLECTED_OTH"
      a "Specify: ", :string
      dependency :rule=>"A"
      condition_A :q_R_VACUUM_N_COLLECTED, "==", :a_neg_5
    
      q_VACUUM_MOST_USED "Was the sample collected from the most used vacuum?",
      :pick => :one,
      :data_export_identifier=>"VACUUM_BAG.VACUUM_MOST_USED"
      a_1 "Yes"
      a_2 "No"
    
      q_VACUUM_TEMP "Temperature when vacuum bag dust sample collected:",
      :data_export_identifier=>"VACUUM_BAG.VACUUM_TEMP"
      a "|°F", :integer
    
      label "The provided value is outside the suggested range (between 14 and 114°F). This value is admissible, but you may wish to verify."
      dependency :rule=>"A or B"
      condition_A :q_VACUUM_TEMP, "<", {:integer_value => "14"}
      condition_B :q_VACUUM_TEMP, ">", {:integer_value => "114"}
    
      q_VACUUM_RH "Relative humidity when vacuum bag dust sample collected:",
      :data_export_identifier=>"VACUUM_BAG.VACUUM_RH"
      a "|%", :integer
    
      label "The provided value is outside the suggested range (between 10 and 113%). This value is admissible, but you may wish to verify."
      dependency :rule=>"A or B"
      condition_A :q_VACUUM_RH, "<", {:integer_value => "10"}
      condition_B :q_VACUUM_RH, ">", {:integer_value => "113"}
    
      q_VACUUM_BAG "Did you include the vacuum bag with the sample?",
      :pick => :one,
      :data_export_identifier=>"VACUUM_BAG.VACUUM_BAG"
      a_1 "Yes, bag was included intact"
      a_2 "No, dust was removed from bag"
      a_3 "Yes, but bag was cut open"
      a_neg_5 "Other"
      dependency :rule=>"A or B or C or D"
      condition_A :q_VACUUM_TYPE, "==", :a_1
      condition_B :q_VACUUM_TYPE, "==", :a_3
      condition_C :q_VACUUM_TYPE, "==", :a_7
      condition_D :q_VACUUM_TYPE, "==", :a_10
    
      # TODO
      # PROGRAMMER INSTRUCTION: 
      # • ALLOW UP TO 250 CHARACTERS
      q_VACUUM_BAG_OTH "Other",
      :data_export_identifier=>"VACUUM_BAG.VACUUM_BAG_OTH"
      a "Specify: ", :string
      dependency :rule=>"A"
      condition_A :q_VACUUM_BAG, "==", :a_neg_5
    
      label "Vacume bag dust sample", 
      :data_export_identifier=>"VACUUM_BAG.SAMPLE_NUMBER"
    
      q_SAMPLE_ID "Sample ID:",
      :help_text => "Affix one vacuum bag dust sample ID label to the plastic bag. Enter the ID on the sample ID label, for example: 
      EC2345671 – DB01",
      :data_export_identifier=>"VACUUM_BAG.SAMPLE_ID"
      a "EC|-DB01", :integer
    
      q_VACUUM_PROBLEMS "Did you have any problems collecting the vacuum sample?",
      :pick => :one,
      :data_export_identifier=>"VACUUM_BAG.VACUUM_PROBLEMS"
      a_1 "No problems"
      a_2 "Trouble removing bag/cup"
      a_3 "Lots of dust fell on towel"
      a_4 "Trouble putting vacuum back together"
      a_neg_5 "Other"
    
      # TODO 
      # PROGRAMMER INSTRUCTION: 
      # • ALLOW UP TO 250 CHARACTERS
      q_VACUUM_PROBLEMS_OTH "Other problems",
      :help_text => "Record here if you had any difficulties collecting the sample, if there were any unsual sampling conditions, 
      if you have any improvements to the sample collection procedure, etc.",
      :data_export_identifier=>"VACUUM_BAG.VACUUM_PROBLEMS_OTH"
      a "Specify:", :string
      dependency :rule=>"A"
      condition_A :q_VACUUM_PROBLEMS, "==", :a_neg_5
    end
    
    q_TIME_STAMP_3 "Insert date/time stamp", :data_export_identifier=>"VACUUM_BAG.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
  end
end