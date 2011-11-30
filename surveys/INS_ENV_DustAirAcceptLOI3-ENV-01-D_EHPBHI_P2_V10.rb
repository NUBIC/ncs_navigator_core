survey "INS_ENV_DustAirAcceptLOI3-ENV-01-D_EHPBHI_P2_V1.0" do
  # TODO
  # NO DATA_EXPORT_IDENTIFIER in MDES 2.0
  section "CAPI", :reference_identifier=>"DustAirAcceptLOI3-ENV" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>""
    a :datetime, :custom_class => "datetime"

    label_DAA001 "Now I’m going to ask about the dust sampling you completed."

    q_LAST_VAC_LIVRM "When was the last time you had vacuumed your family/living room prior to completing the
    dust sample?",
    :help_text => "Enter two digit month, two digit day, and four digit year",
    :pick => :one,
    :data_export_identifier=>""
    a "Date", :string, :custom_class => "date"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • ALLOW 255 CHARACTERS FOR COMMENT.
    q_DUST_COLL_COMMENT "What did you think of the dust collection?",
    :pick => :one,
    :data_export_identifier=>""
    a "Comment", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_TIME_COLL_ACCEPT "Was the length of time it took to collect the sample acceptable?",
    :pick => :one,
    :data_export_identifier=>""
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_COMMENT_COLL "Do you have any other comments about the dust collection?",
    :pick => :one,
    :data_export_identifier=>""
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_COLL_OTHER_COMMENT "Other comment",
    :pick => :one,
    :data_export_identifier=>""
    a "Comment", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule =>"A"
    condition_A :q_COMMENT_COLL, "==", :a_1

    label_DAA007 "Now I am going to ask you about the air sampling that is going to be completed in your home.",
    :help_text => "Show air sampling device to participant."

    # TODO
    # PROGRAMMER INSTRUCTION:
    # • ALLOW 255 CHARACTERS FOR COMMENT.
    q_SAMPLER_COMMENT "What do you think about the air sampler that we are leaving in your home?",
    :pick => :one,
    :data_export_identifier=>""
    a "Comment", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_SIZE_ACCEPT "Is the size of the device acceptable?",
    :pick => :one,
    :data_export_identifier=>""
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_LOCAT_ACCEPT "Is the location of the device acceptable?",
    :pick => :one,
    :data_export_identifier=>""
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"

    q_DEVICE_30D "Do you have any concerns about the device being left in your home for the next 30 days?",
    :pick => :one,
    :data_export_identifier=>""
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
  end
end
