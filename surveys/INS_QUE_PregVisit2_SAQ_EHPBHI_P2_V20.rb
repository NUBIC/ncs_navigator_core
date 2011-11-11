survey "INS_QUE_PregVisit2_SAQ_EHPBHI_P2_V2.0" do
  section "SELF-ADMINISTERED QUESTIONAIRE", :reference_identifier=>"PREG_VISIT_2_SAQ_2" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_SAQ_2.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
    
    label "Thank you for agreeing to participate in this study. This self-administered questionnaire will take about 5 minutes 
    to complete. Your answers are important to us. There are no right or wrong answers. You can always refuse to answer any question 
    or group of questions, and your answers will be kept confidential."
    
    label "We would now like to take a few minutes to ask some questions about your experience in the study."
    
    label "How important was each of the following in your decision to take part in the National Children’s Study?"
    
    q_LEARN "(How important was...) Learning more about my health or the health of my child?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.LEARN"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_HELP "(How important was...) Feeling as if I can help children now and in the future?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.HELP"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_RESEARCH "(How important was...) Helping doctors and researchers learn more about children and their health?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.RESEARCH"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"

    q_ENVIR "(How important was...) Helping researchers learn how the environment may affect children’s health?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.ENVIR"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"

    q_COMMUNITY "(How important was...) Feeling part of my community?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.COMMUNITY"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"

    q_KNOW_OTHERS "(How important was...) Knowing other women in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.KNOW_OTHERS"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"

    q_FAMILY "(How important was...) Having family members or friends support my choice to take part in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.FAMILY"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    
    q_DOCTOR "(How important was...) Having my doctor or health care provider support my choice to take part in the study?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.DOCTOR"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"
    
    q_STAFF "(How important was...) Feeling comfortable with the study staff who come to my home?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.STAFF"
    a_1 "Not at all important"
    a_2 "Somewhat important"
    a_3 "Very important"

    label "How negative or positive do each of the following people feel about you taking part in the National Children’s Study?"

    q_OPIN_SPOUSE "Your spouse or partner",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.OPIN_SPOUSE"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"
    
    q_OPIN_FAMILY "Other family members",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.OPIN_FAMILY"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"
     
    q_OPIN_FRIEND "Your friends",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.OPIN_FRIEND"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"
    
    q_OPIN_DR "Your doctor or health care provider",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.OPIN_DR"
    a_1 "Very Negative"
    a_2 "Somewhat Negative"
    a_3 "Neither Positive or Negative"
    a_4 "Somewhat Positive"
    a_5 "Very Positive"
    a_6 "Not Applicable"    

    q_EXPERIENCE "In general, has your experience with the National Children’s Study been…",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.EXPERIENCE"
    a_1 "Mostly negative"
    a_2 "Somewhat negative"
    a_3 "Neither negative nor positive"
    a_4 "Somewhat positive"
    a_5 "Mostly positive"
    
    q_IMPROVE "In your opinion, how much do you think the National Children’s Study will help improve the health 
    of children now and in the future?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.IMPROVE"
    a_1 "Not at all"
    a_2 "A little"
    a_3 "Some"
    a_4 "A lot"

    q_INT_LENGTH "Did you think the interview was",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.INT_LENGTH"
    a_1 "Too short"
    a_2 "Too long, or"
    a_3 "Just about right?"
    
    q_INT_STRESS "Do you think the interview was",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.INT_STRESS"
    a_1 "Not at all stressful"
    a_2 "A little stressful"
    a_3 "Somewhat stressful, or"
    a_4 "Very stressful?"
    
    q_INT_REPEAT "If you were asked, would you participate in an interview like this again?",
    :pick => :one,
    :data_export_identifier=>"PREG_VISIT_2_SAQ_2.INT_REPEAT"
    a_1 "Yes"
    a_2 "No"
    
    label_END_EVAL "Thank you for participating in the National Children’s Study and for taking the time to complete this survey.", 
    :help_text => "If SAQ is completed as a PAPI, SCs must provide instructions and a business reply envelope for participant to return"

    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"PREG_VISIT_2_SAQ_2.TIME_STAMP_2"
    a :datetime, :custom_class => "datetime"
  end 
end              
