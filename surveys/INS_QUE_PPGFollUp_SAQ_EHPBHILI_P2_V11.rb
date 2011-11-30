survey "INS_QUE_PPGFollUp_SAQ_EHPBHILI_P2_V1.1" do
  section "Pregnancy probability group follow-up SAQ ", :reference_identifier=>"PPGFollUp_SAQ" do
    q_DATE "Please enter today’s date.",
    :data_export_identifier=>"PPG_SAQ.DATE"
    a "Date", :string, :custom_class => "date"

    q_PREGNANT "Because we are interested in pregnancy, it is important for us to know if you’re currently pregnant. Are you pregnant now?",
    :data_export_identifier=>"PPG_SAQ.PREGNANT",
    :pick => :one
    a_1 "Yes, I’m pregnant"
    a_2 "No, I’m not pregnant"

    q_PPG_DUE_DATE "Please tell us when your baby is due.",
    :pick => :one,
    :data_export_identifier=>"PPG_SAQ.PPG_DUE_DATE"
    a_date "Due Date:", :string
    a_2 "I don’t know the baby’s due date"
    dependency :rule=>"A"
    condition_A :q_PREGNANT, "==", :a_1

    q_TRYING "Are you currently trying to become pregnant?",
    :data_export_identifier=>"PPG_SAQ.TRYING",
    :pick => :one
    a_1 "Yes"
    a_2 "No"
    dependency :rule=>"A"
    condition_A :q_PREGNANT, "==", :a_2

    label_CLOSE_1 "Thank you for answering our questions. Someone from the National Children’s Study will contact you to
    tell you more about the Study and possibly schedule an interview or home visit."
    dependency :rule=>"A"
    condition_A :q_PREGNANT, "==", :a_1

    label_CLOSE_2 "Thank you for answering our questions. We’ll contact you again in a few months to ask a few more quick questions."
    dependency :rule=>"A"
    condition_A :q_PREGNANT, "==", :a_2

    q_CONTACT "To help us keep in touch with you, please provide us with all of your current contact information below and
    let us know the best way to reach you by marking the box beside your preference.",
    :data_export_identifier=>"PPG_SAQ.CONTACT"
    a :text

    q_HOME_ADDRESS "Residence (Street address, City, State, Zip Code)",
    :data_export_identifier=>"PPG_SAQ.HOME_ADDRESS"
    a :text

    q_MAIL_ADDRESS "Mailing Address (if different)",
    :data_export_identifier=>"PPG_SAQ.MAIL_ADDRESS"
    a :text

    q_PHONE "Please provide us with all preferred, private telephone numbers where you can be reached.",
    :data_export_identifier=>"PPG_SAQ.PHONE"
    a :string

    q_HOME_PHONE "Home: ",
    :data_export_identifier=>"PPG_SAQ.HOME_PHONE"
    a :string

    q_WORK_PHONE "Work: ",
    :data_export_identifier=>"PPG_SAQ.WORK_PHONE"
    a :string

    q_CELL_PHONE "Cell: ",
    :data_export_identifier=>"PPG_SAQ.CELL_PHONE"
    a :string

    q_OTHER_PHONE "Other: ",
    :data_export_identifier=>"PPG_SAQ.OTHER_PHONE"
    a :string

    q_EMAIL "Please provide us with the most private e-mail where you can be reached.",
    :data_export_identifier=>"PPG_SAQ.EMAIL"
    a "E-Mail: ", :string

    q_END "Thank you very much for completing this questionnaire. All of your responses are very important.
    If you have any questions, please call the toll-free number that is provided in the cover letter you received with this questionnaire.
    Please return this completed questionnaire in the postage-paid envelope we provided."
  end
end
