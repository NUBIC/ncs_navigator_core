survey "INS_ENV_TapWaterPharmTechCollect_DCI_EHPBHI_P2_V1.0" do
  section "Technician-collect Tap Water Pharmaceuticals (TWF) Sample Collection Instrument", :reference_identifier=>"TapWaterPharmTech_DCI" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"TAP_WATER_TWF.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    q_TWF_SUBSAMPLES "What TWF samples should be collected at this visit?",
    :help_text => "Check site office visit specifications. Select all that apply. Note: you may only have the following combinations - 
    \"Participant TWF\" or \"Technician TWF\" or \"Technician TWF\" and \"Technician TWF blank\" or 
    \"Technician TWF\" and \"Technician TWF duplicate\" ",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWF_SUBSAMPLES.TWF_SUBSAMPLES"
    a_1 "Participant TWF"
    a_2 "Technician TWF"
    a_3 "Technician TWF blank"
    a_4 "Technician TWF duplicate"
    
    label "You may only select \"Technician TWF blank\" or \"Technician TWF duplicate\". Re_enter selection"
    dependency :rule=>"A and B"
    condition_A :q_TWF_SUBSAMPLES, "==", :a_3
    condition_B :q_TWF_SUBSAMPLES, "==", :a_4
    
    label "The invalid input is detected for the question above. Please verify the input. Note: you may only have the following combinations - 
    \"Participant TWF\" or \"Technician TWF\" or \"Technician TWF\" and \"Technician TWF blank\" or 
    \"Technician TWF\" and \"Technician TWF duplicate\""
    dependency :rule=>"A and (B or C or D)"
    condition_A :q_TWF_SUBSAMPLES, "==", :a_1
    condition_B :q_TWF_SUBSAMPLES, "==", :a_2
    condition_C :q_TWF_SUBSAMPLES, "==", :a_3
    condition_D :q_TWF_SUBSAMPLES, "==", :a_4
    
    q_TWF_OKAY "We would like to collect a tap water sample. Is that okay with you?",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWF.TWF_OKAY"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_TWF_SUBSAMPLES, "==", :a_2
    
    group "Tap water sample information" do
      dependency :rule=>"A"
      condition_A :q_TWF_OKAY, "==", :a_1
      
      q_TWF_LOCATION "Can you show us a faucet where we can collect the sample? We would prefer to sample from a kitchen faucet",
      :help_text => "Consider any room equipped for preparing meals as a kitchen. 
      If there are two faucets in the kitchen or two kitchens, ask the participant which one is used the most for preparing meals and 
      collect the sample there if available. 
      Collect the sample from the cold water faucet if there are separate hot and cold faucets. 
      Select the collection location.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWF.TWF_LOCATION"
      a_1 "Kitchen"
      a_2 "Bathroom sink/tub"
      a_neg_5 "Other"

      # TODO
      # PROGRAMMER INSTRUCTIONS:
      # • LIMIT FREE TEXT TO 250 CHARACTERS.

      q_TWF_LOCATION_OTH "Specify other location",
      :data_export_identifier=>"TAP_WATER_TWF.TWF_LOCATION_OTH"
      a "Specify", :string
      dependency :rule=>"A"
      condition_A :q_TWF_LOCATION, "==", :a_neg_5
    
      q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"TAP_WATER_TWF.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime"
    
      label "Tap water pharmaceuticals (TWF) sample collection instructions"

      label "- Put on a clean pair of powder-free disposable gloves."
    
      label "- Obtain the TWF sample collection kit."
    
      label "- Collect the sample following the instructions in the TWF sample collection sop. The TWF sample is comprised of three, 
      1-liter glass amber bottles. "
    
      label "- Fill each of the three bottles one at a time"
    
      q_TWF_COLLECT "Did you collect the TWF sample?",
      :help_text => "Select yes if either one bottle was filled partially or completely.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWF.TWF_COLLECT"
      a_1 "Yes"
      a_2 "No"
    end
    group "TWF Sample information" do
      dependency :rule=>"A"
      condition_A :q_TWF_COLLECT, "==", :a_1
            
      label "TWF Sample"
      # **** TWF_SAMPLE ****    
    
      # TODO
      # • DISPLAY A HARD EDIT ERROR IF SAMPLE_ID FOR ANY TWO OR MORE SAMPLES ARE THE SAME 
      q_SAMPLE_ID_TWF_SAMPLE_TWF_COLLECT "Sample ID:",
      :help_text => "Affix one TWF label to the bottle. Enter the id on the sample id label for example: EC2224444 – WQ01",
      :data_export_identifier=>"TAP_WATER_TWF_SAMPLE[sample_number=2].SAMPLE_ID"
      a "EC| - WQ01", :integer
      dependency :rule=>"A"
      condition_A :q_TWF_COLLECT, "==", :a_1
    
      q_BOTTLE1_FILLED "Was bottle 1 completely filled?",
      :help_text => "Enter filled status of the TWF sample bottle 1. 
        Select \"Completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"Partially filled\" to indicate that the bottle was filled lower than the shoulder.
        Select \"Not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWF.BOTTLE1_FILLED"      
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    
      q_BOTTLE2_FILLED "Was the TWF blank bottle 2 completely filled?",
      :help_text => "Enter filled status of the TWF sample bottle 2. 
        Select \"Completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"Partially filled\" to indicate that the bottle was filled lower than the shoulder.
        Select \"Not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWF.BOTTLE2_FILLED"      
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    
      q_BOTTLE3_FILLED "Was the TWF blank bottle 3 completely filled?",
      :help_text => "Enter filled status of the TWF sample bottle 3. 
        Select \"Completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"Partially filled\" to indicate that the bottle was filled lower than the shoulder.
        Select \"Not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWF.BOTTLE3_FILLED"      
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    end
    
    q_REAS_BOTTLE_N_FILLED "Why was the sample only partially collected?",
    :help_text => "Enter reasons that a bottle was not filled or was only partially filled. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWF_REASON_FILLED.REAS_BOTTLE_N_FILLED" 
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A or B or C"
    condition_A :q_BOTTLE1_FILLED, "!=", :a_1
    condition_B :q_BOTTLE2_FILLED, "!=", :a_1
    condition_C :q_BOTTLE3_FILLED, "!=", :a_1
    
    
    # TODO 
    #     PROGRAMMER INSTRUCTIONS:
    #     • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_SUPPLIES_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWF.SUPPLIES_MISSING" 
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_B :q_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_C :q_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5    
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REAS_BOTTLE_N_FILLED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are reasons a TWF bottle was not filled that were not listed above, enter them below",
    :data_export_identifier=>"TAP_WATER_TWF.REAS_BOTTLE_N_FILLED_OTH" 
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_REAS_BOTTLE_N_FILLED, "==", :a_neg_5    
    
    q_TWF_FILTERED "Is the water filtered? For example is there a drinking water filter visible on the faucet where you are 
    going to collect the sample?",
    :help_text => "Select \"Yes\" if you see a filter on the tap, but you cannot bypass it. Select \"No\" if there is a filter on the tap, 
    but you turned it off or by-passed it prior to collecting the sample, or if you do not see a filter on the tap. Select \"Don’t know\" if 
    you see something that looks like a filter that you cannot bypass, and you are not sure if it is a water filter.",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWF.TWF_FILTERED"
    a_1 "Yes"
    a_2 "No"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A and B and C) or ((D and E and F) or (D and F) or (E and F))"
    condition_A :q_BOTTLE1_FILLED, "==", :a_1
    condition_B :q_BOTTLE2_FILLED, "==", :a_1
    condition_C :q_BOTTLE3_FILLED, "==", :a_1    
    condition_D :q_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_E :q_REAS_BOTTLE_N_FILLED, "==", :a_2        
    condition_F :q_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5            

    q_REASON_TWF_N_COLLECTED "Why was the TWF sample not collected?",
    :help_text => "Select all that apply.",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWF_N_COLLECTED.REASON_TWF_N_COLLECTED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_TWF_COLLECT, "==", :a_2

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_TWF_NONE_SUPPL_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWF.TWF_NONE_SUPPL_MISSING" 
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REASON_TWF_N_COLLECTED, "==", :a_1
    condition_B :q_REASON_TWF_N_COLLECTED, "==", :a_2
    condition_C :q_REASON_TWF_N_COLLECTED, "!=", :a_neg_5

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REASON_TWF_N_COLLECTED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are any reasons the TWF sample was not collected not that were not listed under above, enter them below",
    :data_export_identifier=>"TAP_WATER_TWF.REASON_TWF_N_COLLECTED_OTH" 
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_REASON_TWF_N_COLLECTED, "==", :a_neg_5
    # **** TWF_SAMPLE END****

    # ****TWF_BLANK****
    q_TWF_BLANK_COLLECT "Did you collect a TWF blank sample?",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWF.TWF_BLANK_COLLECT"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"(D and E and F) or (A and C) or (B and C) or (A and B and C) "
    condition_A :q_REASON_TWF_N_COLLECTED, "==", :a_1
    condition_B :q_REASON_TWF_N_COLLECTED, "==", :a_2
    condition_C :q_REASON_TWF_N_COLLECTED, "!=", :a_neg_5
    condition_D :q_TWF_SUBSAMPLES, "==", :a_2
    condition_E :q_TWF_SUBSAMPLES, "==", :a_3
    condition_F :q_TWF_COLLECT, "==", :a_1

    group "TWF Blank" do
      dependency :rule=>"A"
      condition_A :q_TWF_BLANK_COLLECT, "==", :a_1
    
      label "TWF Blank"

      # TODO
      # • DISPLAY A HARD EDIT ERROR IF SAMPLE_ID FOR ANY TWO OR MORE SAMPLES ARE THE SAME 
      q_SAMPLE_ID_TWF_BLANK_TWF_BLANK_COLLECT "Sample ID:",
      :help_text => "Affix one TWF label to the bottle. Enter the id on the sample id label for example: EC2224444 – WQ01",
      :data_export_identifier=>"TAP_WATER_TWF_SAMPLE[sample_number=3].SAMPLE_ID"
      a "EC| - WQ01", :integer
      dependency :rule=>"A"
      condition_A :q_TWF_BLANK_COLLECT, "==", :a_1
    
      q_BL_BOTTLE1_FILLED "Was the TWF blank bottle 1 completely filled?",
      :help_text => "Enter status of the TWF blank bottle 1. 
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,      
      :data_export_identifier=>"TAP_WATER_TWF.BL_BOTTLE1_FILLED"      
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    
      q_BL_BOTTLE2_FILLED "Was the TWF blank bottle 2 completely filled?",
      :help_text => "Enter status of the TWF blank bottle 2. 
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,      
      :data_export_identifier=>"TAP_WATER_TWF.BL_BOTTLE2_FILLED"  
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    
      q_BL_BOTTLE3_FILLED "Was the TWF blank bottle 3 completely filled?",
      :help_text => "Enter status of the TWF blank bottle 3. 
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,      
      :data_export_identifier=>"TAP_WATER_TWF.BL_BOTTLE3_FILLED"  
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    end
    
    q_BL_REAS_BOTTLE_N_FILLED "Why was the sample only partially collected?",
    :help_text => "Enter reasons that a bottle was not filled or was only partially filled. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWF_REASON_FILLED2.BL_REAS_BOTTLE_N_FILLED" 
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A or B or C"
    condition_A :q_BL_BOTTLE1_FILLED, "!=", :a_1
    condition_B :q_BL_BOTTLE2_FILLED, "!=", :a_1
    condition_C :q_BL_BOTTLE3_FILLED, "!=", :a_1    
    
    # TODO 
    #     PROGRAMMER INSTRUCTIONS:
    #     •	LIMIT FREE TEXT TO 250 CHARACTERS.
    q_BL_SUPPLIES_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWF.BL_SUPPLIES_MISSING" 
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_BL_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_B :q_BL_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_C :q_BL_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5

    q_BL_REAS_BOTTLE_N_FILLED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are reasons a TWF blank bottle was not filled that were not listed under bl_reas_bottle_n_filled, enter them below",
    :data_export_identifier=>"TAP_WATER_TWF.BL_REAS_BOTTLE_N_FILLED_OTH" 
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_BL_REAS_BOTTLE_N_FILLED, "==", :a_neg_5
    
    q_REAS_TWF_BL_N_COLLECTED "Why was the blank sample not collected?",
    :help_text => "Select the reason the blank sample was not collected. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWF_BLANK_COLLECTED.REAS_TWF_BL_N_COLLECTED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_3 "None required"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_TWF_BLANK_COLLECT, "==", :a_2
    
    q_TWF_BL_NONE_SUPPL_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWF.TWF_BL_NONE_SUPPL_MISSING" 
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REAS_TWF_BL_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWF_BL_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWF_BL_N_COLLECTED, "!=", :a_neg_5

    # TODO 
    #     PROGRAMMER INSTRUCTION:
    #     •	LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REAS_TWF_BL_N_COLLECTED_OTH "Other reason the TWF blank sample was not collected",
    :help_text => "If there are any reasons the TWF blank was not collected that were not listed above, enter them below.",
    :data_export_identifier=>"TAP_WATER_TWF.REAS_TWF_BL_N_COLLECTED_OTH"
    a "Specify:", :string
    dependency :rule=>"A"
    dependency :rule=>"C or (A and C) or (A and B and C) or (B and C) "
    condition_A :q_REAS_TWF_BL_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWF_BL_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWF_BL_N_COLLECTED, "==", :a_neg_5
    # ****TWF_BLANK END****
    
    # ****TWF_DP ****
    q_TWF_DP_COLLECT "Did you collect a TWF duplicate sample?",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWF.TWF_DP_COLLECT"
    a_1 "Yes"
    a_2 "No"    
    dependency :rule=>"A and B and C"
    condition_A :q_TWF_SUBSAMPLES, "==", :a_2
    condition_B :q_TWF_SUBSAMPLES, "==", :a_4
    condition_C :q_TWF_COLLECT, "==", :a_1    
    
    group "TWF Duplicate" do
      dependency :rule=>"A"
      condition_A :q_TWF_DP_COLLECT, "==", :a_1
    
      label "TWF Duplicate"

      # TODO
      # • DISPLAY A HARD EDIT ERROR IF SAMPLE_ID FOR ANY TWO OR MORE SAMPLES ARE THE SAME 
      q_SAMPLE_ID_TWF_DUPLICATE_TWF_DP_COLLECT "Sample ID:",
      :help_text => "Affix one TWF label to the bottle. Enter the id on the sample id label for example: EC2224444 – WQ01",
      :data_export_identifier=>"TAP_WATER_TWF_SAMPLE[sample_number=4].SAMPLE_ID"
      a "EC| - WQ01", :integer
      dependency :rule=>"A"
      condition_A :q_TWF_DP_COLLECT, "==", :a_1 
    
      q_DP_BOTTLE1_FILLED "Was the TWF duplicate bottle 1 completely filled?",
      :help_text => "Enter status of the TWF duplicate bottle 1. 
        Select \"Completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"Partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"Not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,      
      :data_export_identifier=>"TAP_WATER_TWF.DP_BOTTLE1_FILLED"      
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"

      q_DP_BOTTLE2_FILLED "Was the TWF duplicate bottle 2 completely filled?",
      :help_text => "Enter status of the TWF duplicate bottle 2. 
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,      
      :data_export_identifier=>"TAP_WATER_TWF.DP_BOTTLE2_FILLED"      
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"

      q_DP_BOTTLE3_FILLED "Was the TWF duplicate bottle 3 completely filled?",
      :help_text => "Enter status of the TWF duplicate bottle 3. 
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,      
      :data_export_identifier=>"TAP_WATER_TWF.DP_BOTTLE3_FILLED"      
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    end
    
    # TODO 
    #     PROGRAMMER INSTRUCTIONS:
    #     •	LIMIT FREE TEXT TO 250 CHARACTERS.
    q_DP_SUPPLIES_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWF.DP_SUPPLIES_MISSING" 
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_DP_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_B :q_DP_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_C :q_DP_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5
    
    q_DP_REAS_BOTTLE_N_FILLED "Why was the TWF duplicate not completely collected?",
    :help_text => "Enter reasons that a bottle was not filled or was only partially filled. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWF_DUP_FILLED.DP_REAS_BOTTLE_N_FILLED" 
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_3 "None required"
    a_neg_5 "Other"
    dependency :rule=>"A or B or C"
    condition_A :q_DP_BOTTLE1_FILLED, "!=", :a_1
    condition_B :q_DP_BOTTLE2_FILLED, "!=", :a_1 
    condition_C :q_DP_BOTTLE3_FILLED, "!=", :a_1    
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_DP_REAS_BOTTLE_N_FILLED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are reasons a TWF duplicate bottle was not filled that were not listed above, enter them below",
    :data_export_identifier=>"TAP_WATER_TWF.DP_REAS_BOTTLE_N_FILLED_OTH" 
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_DP_REAS_BOTTLE_N_FILLED, "==", :a_neg_5
       
    q_REAS_TWF_DP_N_COLLECTED "Why was the TWF duplicate sample not collected?",
    :help_text => "Enter reasons the TWF duplicate was not collected. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWF_DUP_COLLECTED.REAS_TWF_DP_N_COLLECTED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_TWF_DP_COLLECT, "==", :a_2
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REAS_TWF_DP_N_COLLECTED_SUPPL "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWF.REAS_TWF_DP_N_COLLECTED_SUPPL" 
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REAS_TWF_DP_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWF_DP_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWF_DP_N_COLLECTED, "!=", :a_neg_5
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.    
    q_REAS_TWF_DP_N_COLLECTED_OTH "Other reason the TWF duplicate sample was not collected",
    :help_text => "If there are any reasons the TWF duplicate was not collected that were not listed above, enter them below.",
    :data_export_identifier=>"TAP_WATER_TWF.REAS_TWF_DP_N_COLLECTED_OTH"
    a "Specify:", :string
    dependency :rule=>"A"
    dependency :rule=>"C or (A and C) or (A and B and C) or (B and C) "
    condition_A :q_REAS_TWF_BL_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWF_BL_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWF_BL_N_COLLECTED, "==", :a_neg_5
    # ****TWF_DP END****
   
   
   # check this:  TWF160/(REASON_TWF_N_COLLECTED_OTH).
   # 
   #     DATA COLLECTOR INSTRUCTION:
   #     •  IF THERE ARE ANY REASONS THE TWF SAMPLE WAS NOT COLLECTED NOT LISTED UNDER REASON_TWF_N_COLLECTED, ENTER THEM BELOW.
   # 
   #     SPECIFY: ____________________________  
   # 
   #     PROGRAMMER INSTRUCTIONS:
   #     •  LIMIT FREE TEXT TO 250 CHARACTERS. 
   #     •  GO TO TWF_COMMENTS
   #    
   
    # TODO
    # PROGRAMMER INSTRUCTION:
    # • LIMIT FREE TEXT TO 250 CHARACTERS
    q_TWF_COMMENTS "Record any comments about the TWF collection:",
    :help_text => "Record here if you had any difficulties collecting the sample, if there were any unsual sampling conditions, if you have 
    any improvements to the sample collection procedure, etc. "
    a "Specify:", :string
    dependency :rule=>"(A and B and C and D) or (E and F) or (G and H) or I or J or K or L"
    condition_E :q_TWF_SUBSAMPLES, "!=", :a_1
    condition_F :q_TWF_OKAY, "!=", :a_2
    condition_A :q_TWF_SUBSAMPLES, "==", :a_2
    condition_B :q_TWF_SUBSAMPLES, "!=", :a_3
    condition_C :q_TWF_SUBSAMPLES, "!=", :a_4    
    condition_D :q_TWF_COLLECT, "==", :a_1
    condition_G :q_BL_BOTTLE1_FILLED, "==", :a_1
    condition_H :q_BL_BOTTLE2_FILLED, "==", :a_1
    condition_I :q_TWF_BLANK_COLLECT, "==", :a_1
    condition_J :q_TWF_BLANK_COLLECT, "==", :a_2
    condition_K :q_TWF_DP_COLLECT, "==", :a_1
    condition_L :q_TWF_DP_COLLECT, "==", :a_2             
    
    q_TIME_STAMP_3 "Insert date/time stamp", 
    :data_export_identifier=>"TAP_WATER_TWF.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
    # dependency :rule=>"A or B or C"
    # condition_A :q_TWF_SUBSAMPLES, "==", :a_1
    # condition_B :q_TWF_OKAY, "==", :a_2
    # condition_C :q_REASON_TWF_N_COLLECTED , "==", :a_neg_5
  end
end