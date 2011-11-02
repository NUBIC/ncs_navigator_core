survey "INS_QUE_InternetUseContactPref_SUR_EHPBHI_P2_V1.0" do
  section "Interview", :reference_identifier=>"InternetUseContactPref_SUR" do
    q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"INTERNET_USAGE.TIME_STAMP_1"
    a :datetime
    
    q_ABLE_PARTICIPATE "What are the following ways you are able to participate in National Children’s Study data collection?",  
    :help_text => "Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"INTERNET_USAGE_PARTICIPATE.ABLE_PARTICIPATE"
    a_1 "Telephone"
    a_2 "Postal mail"
    a_3 "Email/Internet/Web"
    a_4 "Interview with provider staff"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_PREFER_CONTACT "Do you usually prefer business contacts and acquaintances to contact you first via:",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.PREFER_CONTACT"
    a_1 "Telephone"
    a_2 "Email"
    a_3 "Postal mail"
    a_4 "Text messaging"
    a_5 "Appointment/Face to face only"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"    
    
    label_0003 "We have a few questions about your familiarity and usage of the internet (World Wide Web)."
    
    q_EVER_CONNECT "Do you ever connect to the web/internet for either work or personal use?",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.EVER_CONNECT"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    q_USE_WEB "On average, how often do you use a web/internet browser?",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.USE_WEB"
    a_1 "More than 4 times a day"
    a_2 "1 to 4 times a day"
    a_3 "A few times a week"
    a_4 "Once a week"
    a_5 "Once a month or less"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_EVER_CONNECT, "!=", :a_2
    
    q_HAVE_EMAIL "Do you have an email address?",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.HAVE_EMAIL"
    a_1 "Yes"
    a_2 "No"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    group "Email information" do
      dependency :rule=>"A"
      condition_A :q_HAVE_EMAIL, "==", :a_1
      
      q_CHECK_EMAIL "How often would you say you log on to check your email?",
      :pick => :one,
      :data_export_identifier=>"INTERNET_USAGE.CHECK_EMAIL"
      a_1 "1 to 5 times a day (or more)"
      a_2 "Once a day"
      a_3 "1-3 times a week"
      a_4 "Less than once a week"
      a_5 "Once every 2 weeks"
      a_6 "Once a month"
      a_7 "Rarely"
      a_8 "Never"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    
      q_OK_EMAIL_ADDR "May we have your email address to contact you in the future?",
      :pick => :one,
      :data_export_identifier=>"INTERNET_USAGE.OK_EMAIL_ADDR"
      a_1 "Yes"
      a_2 "No"
      a_neg_1 "Refused"
      a_neg_2 "Don’t know"
    end
    
    # TODO
    # PROGRAMMER INSTRUCTION:
    # • THIS QUESTION WILL ONLY BE ASKED AFTER THE FIRST PN EVENT IS COMPLETED.
    # • IF THREE MONTH CALL,  GO TO PREFER_SURVEY.
    # • IF NINE MONTH CALL, AND THREE MONTH CALL WAS COMPLETED, GO TO 0010. 
    # • IF NINE MONTH CALL AND THREE MONTH CALL WERE NOT COMPLETED, GO TO PREFER_SURVEY.
    
    q_EMAIL "What is the best email address to reach you?",
    :help_text => "Ask this question only after the \"first PN event\" is completed. Skip if it's \"three or nine month call\".
    Show example of valid email address such as maryjane@email.com",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.EMAIL"
    a "Enter e-mail address:", :string
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    dependency :rule=>"A"
    condition_A :q_OK_EMAIL_ADDR, "==", :a_1
    
    q_PREFER_SURVEY "In which way would you prefer to take this survey?",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.PREFER_SURVEY"
    a_1 "Over the phone"
    a_2 "Mailed to me and completed on paper"
    a_3 "Emailed to me and completed online"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    label_0010 "Please provide some feedback about how this survey was completed. Tell us how much you agree or disagree 
    with the following statements by responding with strongly disagree, somewhat disagree, somewhat agree or strongly agree."
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • FOR {DATA COLLECTION MODE} INSERT THE NAME OF THE TYPE OF DATA COLLECTION PARTICIPANT IS ASSIGNED TO RECEIVE. 
    q_DC_MODE_SIMPLE "{DATA COLLECTION MODE} is simple to complete.",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.DC_MODE_SIMPLE"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Somewhat agree"
    a_4 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • PRELOAD DATA COLLECTION MODE PARTICIPANT IS ASSIGNED TO RECEIVE. 
    q_DC_MODE_CONVENIENT "{DATA COLLECTION MODE} is convenient",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.DC_MODE_CONVENIENT"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Somewhat agree"
    a_4 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    # TODO
    # PROGRAMMER INSTRUCTIONS:
    # • FOR DATA COLLECTION MODE, PRELOAD TYPE OF DATA COLLECTION PARTICIPANT IS ASSIGNED TO RECEIVE. 
    # • FOR ALTERNATE DATA COLLECTION MODE 1, PRELOAD ONE OF THE REMAINING DATA COLLECTION MODES THE PARTICIPANT IS NOT ASSIGNED TO.  
    # • FOR ALTERNATE DATA COLLECTION MODE 2, PRELOAD THE REMAINING DATA COLLECTION MODE THE PARTICIPANT IS NOT ASSIGNED TO.  
    q_DC_MODE_CHOICE "If I were given a choice, I would choose a {DATA COLLECTION MODE} over a {DATA COLLECTION MODE }] 
    or {DATA COLLECTION MODE 2}.",
    :pick => :one,
    :data_export_identifier=>"INTERNET_USAGE.DC_MODE_CHOICE"
    a_1 "Strongly disagree"
    a_2 "Somewhat disagree"
    a_3 "Somewhat agree"
    a_4 "Strongly agree"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"
    
    label_END "Thank you for taking the time to answer these questions, your answers are important to us. Your  Research Coordinator 
    will be in touch with you about your next Study event.  {You will receive a data collection mode survey again in about six months.}",
    :help_text => "Display bracketed text for those completing the three month call event."
    
    q_TIME_STAMP_2 "Insert date/time stamp", :data_export_identifier=>"INTERNET_USAGE.TIME_STAMP_2"
    a :datetime
  end
end
    