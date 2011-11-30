survey "INS_ENV_TapWaterPestTechCollect_DCI_EHPBHI_P2_V1.0" do
  section "TECHNICIAN-COLLECT TAP WATER PESTICIDES (TWQ) SAMPLE COLLECTION", :reference_identifier=>"TapWaterPestTech_DCI" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"TAP_WATER_TWQ.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"

    q_TWQ_SUBSAMPLES "What TWQ samples should be collected at this visit?",
    :help_text => "Check site office visit specifications. Select all that apply. Note: you may only have the following combinations -
    \"Participant TWQ\" or \"Technician TWQ\" or \"Technician TWQ\" and \"Technician TWQ blank\" or
    \"Technician TWQ\" and \"Technician TWQ duplicate\" ",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWQ_SUBSAMPLES.TWQ_SUBSAMPLES"
    a_1 "Participant TWQ"
    a_2 "Technician TWQ"
    a_3 "Technician TWQ blank"
    a_4 "Technician TWQ duplicate"

    label "You may only select \"Technician TWQ blank\" or \"Technician TWQ duplicate\". Re_enter selection"
    dependency :rule=>"A and B"
    condition_A :q_TWQ_SUBSAMPLES, "==", :a_3
    condition_B :q_TWQ_SUBSAMPLES, "==", :a_4

    label "The invalid input is detected for the question above. Please verify the input. Note: you may only have the following combinations -
    \"Participant TWQ\" or \"Technician TWQ\" or \"Technician TWQ\" and \"Technician TWQ blank\" or
    \"Technician TWQ\" and \"Technician TWQ duplicate\""
    dependency :rule=>"A and (B or C or D)"
    condition_A :q_TWQ_SUBSAMPLES, "==", :a_1
    condition_B :q_TWQ_SUBSAMPLES, "==", :a_2
    condition_C :q_TWQ_SUBSAMPLES, "==", :a_3
    condition_D :q_TWQ_SUBSAMPLES, "==", :a_4

    q_TWQ_OKAY "We would like to collect a tap water sample. Is that okay with you?",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWQ.TWQ_OKAY"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_TWQ_SUBSAMPLES, "==", :a_2

    group "Tap water sample information" do
      dependency :rule=>"A"
      condition_A :q_TWQ_OKAY, "==", :a_1

      q_TWQ_LOCATION "Can you show us a faucet where we can collect the sample? We would prefer to sample from a kitchen faucet",
      :help_text => "Consider any room equipped for preparing meals as a kitchen.
      If there are two faucets in the kitchen or two kitchens, ask the participant which one is used the most for preparing meals and
      collect the sample there if available.
      Collect the sample from the cold water faucet if there are separate hot and cold faucets.
      Select the collection location.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.TWQ_LOCATION"
      a_1 "Kitchen"
      a_2 "Bathroom sink/tub"
      a_neg_5 "Other"

      # TODO
      # PROGRAMMER INSTRUCTIONS:
      # • LIMIT FREE TEXT TO 250 CHARACTERS.

      q_TWQ_LOCATION_OTH "Specify other location",
      :data_export_identifier=>"TAP_WATER_TWQ.TWQ_LOCATION_OTH"
      a "Specify", :string
      dependency :rule=>"A"
      condition_A :q_TWQ_LOCATION, "==", :a_neg_5

      q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"TAP_WATER_TWQ.TIME_STAMP_2"
      a :datetime, :custom_class => "datetime"

      label "Tap water pesticides (TWQ) sample collection instructions"

      label "- Put on a clean pair of powder-free disposable gloves."

      label "- Obtain the TWQ sample collection kit."

      label "- Collect the sample following the instructions in the TWQ sample collection sop. The TWQ sample is comprised of two,
      1-liter glass amber bottles. "

      label "- Fill each of the two bottles one at a time"

      q_TWQ_COLLECT "Did you collect the TWQ sample?",
      :help_text => "Select yes if either one or two bottles was filled partially or completely.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.TWQ_COLLECT"
      a_1 "Yes"
      a_2 "No"
    end
    group "TWQ Sample information" do
      dependency :rule=>"A"
      condition_A :q_TWQ_COLLECT, "==", :a_1

      label "TWQ Sample"

      # **** TWQ_SAMPLE ****

      # TODO
      # • DISPLAY A HARD EDIT ERROR IF SAMPLE_ID FOR ANY TWO OR MORE SAMPLES ARE THE SAME
      q_SAMPLE_ID_TWQ_SAMPLE_TWQ_COLLECT "Sample ID:",
      :help_text => "Affix one twq label to the bottle. Enter the id on the sample id label for example: EC2224444 – WQ01",
      :data_export_identifier=>"TAP_WATER_TWQ_SAMPLE[sample_number=2].SAMPLE_ID"
      a "EC| - WQ01", :integer

      q_BOTTLE1_FILLED "Was bottle 1 completely filled?",
      :help_text => "Enter filled status of the twq sample bottle 1.
        Select \"Completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"Partially filled\" to indicate that the bottle was filled lower than the shoulder.
        Select \"Not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.BOTTLE1_FILLED"
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"

      q_BOTTLE2_FILLED "Was the twq blank bottle 2 completely filled?",
      :help_text => "Enter filled status of the twq sample bottle 2.
        Select \"Completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"Partially filled\" to indicate that the bottle was filled lower than the shoulder.
        Select \"Not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.BOTTLE2_FILLED"
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    end

    q_REAS_BOTTLE_N_FILLED "Why was the sample only partially collected?",
    :help_text => "Enter reasons that a bottle was not filled or was only partially filled. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWQ_REASON_FILLED.REAS_BOTTLE_N_FILLED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A or B"
    condition_A :q_BOTTLE1_FILLED, "!=", :a_1
    condition_B :q_BOTTLE2_FILLED, "!=", :a_1

    # TODO
    #     PROGRAMMER INSTRUCTIONS:
    #     • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_SUPPLIES_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWQ.SUPPLIES_MISSING"
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_B :q_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_C :q_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REAS_BOTTLE_N_FILLED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are reasons a twq bottle was not filled that were not listed above, enter them below",
    :data_export_identifier=>"TAP_WATER_TWQ.REAS_BOTTLE_N_FILLED_OTH"
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_REAS_BOTTLE_N_FILLED, "==", :a_neg_5

    q_TWQ_FILTERED "Is the water filtered? for example is there a drinking water filter visible on the faucet where you are
    going to collect the sample?",
    :help_text => "Select \"Yes\" if you see a filter on the tap, but you cannot bypass it. Select \"No\" if there is a filter on the tap,
    but you turned it off or by-passed it prior to collecting the sample, or if you do not see a filter on the tap. Select \"Don’t know\" if
    you see something that looks like a filter that you cannot bypass, and you are not sure if it is a water filter.",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWQ.TWQ_FILTERED"
    a_1 "Yes"
    a_2 "No"
    a_neg_2 "Don’t know"
    dependency :rule=>"(A and B) or E"
    # ((C and D and E) or (C and E) or (D and E))"
    condition_A :q_BOTTLE1_FILLED, "==", :a_1
    condition_B :q_BOTTLE2_FILLED, "==", :a_1
    # condition_C :q_REAS_BOTTLE_N_FILLED, "==", :a_1
    # condition_D :q_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_E :q_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_TWQ_NONE_SUPPL_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWQ.TWQ_NONE_SUPPL_MISSING"
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_B :q_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_C :q_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5

    q_REASON_TWQ_N_COLLECTED "Why was the TWQ sample not collected?",
    :help_text => "Select all that apply.",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWQ_N_COLLECTED.REASON_TWQ_N_COLLECTED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_TWQ_COLLECT, "==", :a_2

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REASON_TWQ_N_COLLECTED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are any reasons the twq sample was not collected not that were not listed under above, enter them below",
    :data_export_identifier=>"TAP_WATER_TWQ.REASON_TWQ_N_COLLECTED_OTH"
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_REASON_TWQ_N_COLLECTED, "==", :a_neg_5
    # **** TWQ_SAMPLE END****

    # ****TWQ_BLANK****
    q_TWQ_BLANK_COLLECT "Did you collect a twq blank sample?",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWQ.TWQ_BLANK_COLLECT"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"(D and E and F) or (A and C) or (B and C) or (A and B and C) "
    condition_A :q_REASON_TWQ_N_COLLECTED, "==", :a_1
    condition_B :q_REASON_TWQ_N_COLLECTED, "==", :a_2
    condition_C :q_REASON_TWQ_N_COLLECTED, "!=", :a_neg_5
    condition_D :q_TWQ_SUBSAMPLES, "==", :a_2
    condition_E :q_TWQ_SUBSAMPLES, "==", :a_3
    condition_F :q_TWQ_COLLECT, "==", :a_1

    group "TWQ Blank" do
      dependency :rule=>"A"
      condition_A :q_TWQ_BLANK_COLLECT, "==", :a_1

      label "TWQ Blank"

      # TODO
      # • DISPLAY A HARD EDIT ERROR IF SAMPLE_ID FOR ANY TWO OR MORE SAMPLES ARE THE SAME
      q_SAMPLE_ID_TWQ_BLANK_TWQ_BLANK_COLLECT "Sample ID:",
      :help_text => "Affix one twq label to the bottle. Enter the id on the sample id label for example: EC2224444 – WQ01",
      :data_export_identifier=>"TAP_WATER_TWQ_SAMPLE[sample_number=3].SAMPLE_ID"
      a "EC| - WQ01", :integer

      q_BL_BOTTLE1_FILLED "Was the twq blank bottle 1 completely filled?",
      :help_text => "Enter status of the twq blank bottle 1.
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.BL_BOTTLE1_FILLED"
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"

      q_BL_BOTTLE2_FILLED "Was the twq blank bottle 2 completely filled?",
      :help_text => "Enter status of the twq blank bottle 2.
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.BL_BOTTLE2_FILLED"
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    end

    q_BL_REAS_BOTTLE_N_FILLED "Why was the sample only partially collected?",
    :help_text => "Enter reasons that a bottle was not filled or was only partially filled. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWQ_REASON_FILLED2.BL_REAS_BOTTLE_N_FILLED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A or B"
    condition_A :q_BL_BOTTLE1_FILLED, "!=", :a_1
    condition_B :q_BL_BOTTLE2_FILLED, "!=", :a_1

    # TODO
    #     PROGRAMMER INSTRUCTIONS:
    #     •	LIMIT FREE TEXT TO 250 CHARACTERS.
    q_BL_SUPPLIES_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWQ.BL_SUPPLIES_MISSING"
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_BL_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_B :q_BL_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_C :q_BL_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5

    q_BL_REAS_BOTTLE_N_FILLED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are reasons a twq blank bottle was not filled that were not listed under bl_reas_bottle_n_filled, enter them below",
    :data_export_identifier=>"TAP_WATER_TWQ.BL_REAS_BOTTLE_N_FILLED_OTH"
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_BL_REAS_BOTTLE_N_FILLED, "==", :a_neg_5

    q_REAS_TWQ_BL_N_COLLECTED "Why was the blank sample not collected?",
    :help_text => "Select the reason the blank sample was not collected. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWQ_BLANK_COLLECTED.REAS_TWQ_BL_N_COLLECTED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_TWQ_BLANK_COLLECT, "==", :a_2

    q_TWQ_BL_NONE_SUPPL_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWQ.TWQ_BL_NONE_SUPPL_MISSING"
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWQ_BL_N_COLLECTED, "!=", :a_neg_5

    # TODO
    #     PROGRAMMER INSTRUCTION:
    #     •	LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REAS_TWQ_BL_N_COLLECTED_OTH "Other reason the twq blank sample was not collected",
    :help_text => "If there are any reasons the twq blank was not collected that were not listed above, enter them below.",
    :data_export_identifier=>"TAP_WATER_TWQ.REAS_TWQ_BL_N_COLLECTED_OTH"
    a "Specify:", :string
    dependency :rule=>"A"
    dependency :rule=>"C or (A and C) or (A and B and C) or (B and C) "
    condition_A :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_neg_5
    # ****TWQ_BLANK END****

    # ****TWQ_DP ****
    q_TWQ_DP_COLLECT "Did you collect a twq duplicate sample?",
    :pick => :one,
    :data_export_identifier=>"TAP_WATER_TWQ.TWQ_DP_COLLECT"
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A and B and C"
    condition_A :q_TWQ_SUBSAMPLES, "==", :a_2
    condition_B :q_TWQ_SUBSAMPLES, "==", :a_4
    condition_C :q_TWQ_COLLECT, "==", :a_1

    group "TWQ Duplicate" do
      dependency :rule=>"A"
      condition_A :q_TWQ_DP_COLLECT, "==", :a_1

      label "TWQ Duplicate"

      # TODO
      # • DISPLAY A HARD EDIT ERROR IF SAMPLE_ID FOR ANY TWO OR MORE SAMPLES ARE THE SAME
      q_SAMPLE_ID_TWQ_DUPLICATE_TWQ_DP_COLLECT "Sample ID:",
      :help_text => "Affix one twq label to the bottle. Enter the id on the sample id label for example: EC2224444 – WQ01",
      :data_export_identifier=>"TAP_WATER_TWQ_SAMPLE[sample_number=4].SAMPLE_ID"
      a "EC| - WQ01", :integer

      q_DP_BOTTLE1_FILLED "Was the twq duplicate bottle 1 completely filled?",
      :help_text => "Enter status of the twq duplicate bottle 1.
        Select \"Completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"Partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"Not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.DP_BOTTLE1_FILLED"
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"

      q_DP_BOTTLE2_FILLED "Was the twq duplicate bottle 2 completely filled?",
      :help_text => "Enter status of the twq duplicate bottle 2.
        Select \"completely filled\" to indicate that the bottle was filled to the shoulder.
        Select \"partially filled\" to indicate that the bottle was not filled to the shoulder.
        Select \"not filled\" to indicate that the water bottle was not filled.",
      :pick => :one,
      :data_export_identifier=>"TAP_WATER_TWQ.DP_BOTTLE2_FILLED"
      a_1 "Completely filled"
      a_2 "Partially filled"
      a_3 "Not filled"
    end
    # TODO
    #     PROGRAMMER INSTRUCTIONS:
    #     •	LIMIT FREE TEXT TO 250 CHARACTERS.
    q_DP_SUPPLIES_MISSING "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWQ.DP_SUPPLIES_MISSING"
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_DP_REAS_BOTTLE_N_FILLED, "==", :a_1
    condition_B :q_DP_REAS_BOTTLE_N_FILLED, "==", :a_2
    condition_C :q_DP_REAS_BOTTLE_N_FILLED, "!=", :a_neg_5

    q_DP_REAS_BOTTLE_N_FILLED "Why was the sample only partially collected?",
    :help_text => "Enter reasons that a bottle was not filled or was only partially filled. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWQ_DUP_FILLED.DP_REAS_BOTTLE_N_FILLED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A or B"
    condition_A :q_DP_BOTTLE1_FILLED, "!=", :a_1
    condition_B :q_DP_BOTTLE2_FILLED, "!=", :a_1

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_DP_REAS_BOTTLE_N_FILLED_OTH "Other reason why the sample was only partially collected",
    :help_text => "If there are reasons a twq duplicate bottle was not filled that were not listed above, enter them below",
    :data_export_identifier=>"TAP_WATER_TWQ.DP_REAS_BOTTLE_N_FILLED_OTH"
    a "Specify:", :string
    dependency :rule=>"C"
    condition_C :q_DP_REAS_BOTTLE_N_FILLED, "==", :a_neg_5

    q_REAS_TWQ_DP_N_COLLECTED "Why was the twq duplicate sample not collected?",
    :help_text => "Enter reasons the twq duplicate was not collected. Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWQ_DUP_COLLECTED.REAS_TWQ_DP_N_COLLECTED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_TWQ_DP_COLLECT, "==", :a_2

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REAS_TWQ_DP_N_COLLECTED_SUPPL "What supplies were missing from the kit?",
    :help_text => "Enter any supplies missing from the kit. If more than one supply is missing, enter multiple supplies followed by a comma.",
    :data_export_identifier=>"TAP_WATER_TWQ.REAS_TWQ_DP_N_COLLECTED_SUPPL"
    a "Specify: ", :string
    dependency :rule=>"(A and C) or (A and B and C)"
    condition_A :q_REAS_TWQ_DP_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWQ_DP_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWQ_DP_N_COLLECTED, "!=", :a_neg_5

    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • LIMIT FREE TEXT TO 250 CHARACTERS.
    q_REAS_TWQ_DP_N_COLLECTED_OTH "Other reason the twq duplicate sample was not collected",
    :help_text => "If there are any reasons the twq duplicate was not collected that were not listed above, enter them below.",
    :data_export_identifier=>"TAP_WATER_TWQ.REAS_TWQ_DP_N_COLLECTED_OTH"
    a "Specify:", :string
    dependency :rule=>"A"
    dependency :rule=>"C or (A and C) or (A and B and C) or (B and C) "
    condition_A :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_1
    condition_B :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_2
    condition_C :q_REAS_TWQ_BL_N_COLLECTED, "==", :a_neg_5
    # ****TWQ_DP END****

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • LIMIT FREE TEXT TO 250 CHARACTERS
    q_TWQ_COMMENTS "Record any comments about the twq collection:",
    :help_text => "Record here if you had any difficulties collecting the sample, if there were any unsual sampling conditions, if you have
    any improvements to the sample collection procedure, etc.",
    :data_export_identifier=>"TAP_WATER_TWQ.TWQ_COMMENTS"
    a "Specify:", :string
    dependency :rule=>"(A and B and C and D) or (E and F) or (G and H) or I or J or K or L"
    condition_E :q_TWQ_SUBSAMPLES, "!=", :a_1
    condition_F :q_TWQ_OKAY, "!=", :a_2
    condition_A :q_TWQ_SUBSAMPLES, "==", :a_2
    condition_B :q_TWQ_SUBSAMPLES, "!=", :a_3
    condition_C :q_TWQ_SUBSAMPLES, "!=", :a_4
    condition_D :q_TWQ_COLLECT, "==", :a_1
    condition_G :q_BL_BOTTLE1_FILLED, "==", :a_1
    condition_H :q_BL_BOTTLE2_FILLED, "==", :a_1
    condition_I :q_TWQ_BLANK_COLLECT, "==", :a_1
    condition_J :q_TWQ_BLANK_COLLECT, "==", :a_2
    condition_K :q_TWQ_DP_COLLECT, "==", :a_1
    condition_L :q_TWQ_DP_COLLECT, "==", :a_2

    q_TIME_STAMP_3 "Insert date/time stamp",
    :data_export_identifier=>"TAP_WATER_TWQ.TIME_STAMP_3"
    a :datetime, :custom_class => "datetime"
    # dependency :rule=>"A or B or C"
    # condition_A :q_TWQ_SUBSAMPLES, "==", :a_1
    # condition_B :q_TWQ_OKAY, "==", :a_2
    # condition_C :q_REASON_TWQ_N_COLLECTED , "==", :a_neg_5
  end
end
