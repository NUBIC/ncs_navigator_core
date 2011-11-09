require 'spec_helper'

describe PpgFollowUpOperationalDataExtractor do

  before(:each) do
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(PpgDetail)
    create_missing_in_error_ncs_codes(PpgStatusHistory)
    create_missing_in_error_ncs_codes(Telephone)
    create_missing_in_error_ncs_codes(Email)
  end

  context "updating the ppg status history" do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant, :person => @person)
      @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person)
      Factory(:ppg_detail, :participant => @participant)

      @ppg1 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1", :local_code => 1)
      @ppg2 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2", :local_code => 2)
      @ppg3 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3", :local_code => 3)
      @ppg4 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4", :local_code => 4)
      @ppg5 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 5", :local_code => 5)

      @survey = create_follow_up_survey_with_ppg_status_history_operational_data
      @survey_section = @survey.sections.first
      @response_set, @instrument = @person.start_instrument(@survey)

      @response_set.responses.size.should == 0
      @participant.ppg_status.local_code.should == 2
    end
    
    it "updates the ppg status to 1 if the person responds that they are pregnant" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.PPG_DUE_DATE_1"
          answer = q.answers.select { |a| a.response_class == "date" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :datetime_value => "2011-12-25", :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 2

      PpgFollowUpOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 1
      participant.ppg_status.local_code.should == 1
      participant.due_date.should == "2011-12-25"

    end

    it "updates the ppg status to 3 if the person responds that they recently lost their child during pregnancy" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "3" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      PpgFollowUpOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 3
      participant.ppg_status.local_code.should == 3
      participant.due_date.should be_nil

    end
    
    it "updates the ppg status to 2 if the person responds that they are trying" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.TRYING"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      PpgFollowUpOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 2
      participant.ppg_status.local_code.should == 2
      participant.due_date.should be_nil

    end
    
    
    it "updates the ppg status to 3 if the person responds that they recently lost their child" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.TRYING"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "3" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      PpgFollowUpOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 3
      participant.ppg_status.local_code.should == 3
      participant.due_date.should be_nil

    end
    
    
    it "updates the ppg status to 4 if the person responds that they recently gave birth" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.TRYING"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "4" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      PpgFollowUpOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 4
      participant.ppg_status.local_code.should == 4
      participant.due_date.should be_nil

    end
    
    it "updates the ppg status to 5 if the person responds that they are medically unable to become pregnant" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.MED_UNABLE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      PpgFollowUpOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 5
      participant.ppg_status.local_code.should == 5
      participant.due_date.should be_nil

    end

    
  end
  
  it "extracts telephone operational data from the survey responses" do
    
    home = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Home", :local_code => 1)
    work = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Work", :local_code => 2)
    cell = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Cell", :local_code => 3)
    frre = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Friend/Relative", :local_code => 4)
    oth  = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Other", :local_code => -5)

    person = Factory(:person)
    person.telephones.size.should == 0

    survey = create_follow_up_survey_with_telephone_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0
      
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125551234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PpgFollowUpOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_TYPE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{cell.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 2
    
    PpgFollowUpOperationalDataExtractor.extract_data(response_set)
    
    person  = Person.find(person.id)
    person.telephones.size.should == 1
    telephone = person.telephones.first
    telephone.phone_type.local_code.should == 3
    telephone.phone_nbr.should == "3125551234"
    
  end
  
  
  it "extracts contact data from the SAQ survey responses" do
    home = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Home", :local_code => 1)
    work = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Work", :local_code => 2)
    cell = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Cell", :local_code => 3)
    oth  = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Other", :local_code => -5)

    person = Factory(:person)
    person.telephones.size.should == 0
    person.emails.size.should == 0

    survey = create_follow_up_survey_with_contact_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0
    
    survey_section.questions.size.should == 5
      
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PpgFollowUpOperationalDataExtractor::SAQ_PREFIX}.HOME_PHONE"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125551234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PpgFollowUpOperationalDataExtractor::SAQ_PREFIX}.CELL_PHONE"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125555678", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PpgFollowUpOperationalDataExtractor::SAQ_PREFIX}.WORK_PHONE"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125559012", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PpgFollowUpOperationalDataExtractor::SAQ_PREFIX}.OTHER_PHONE"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125553456", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PpgFollowUpOperationalDataExtractor::SAQ_PREFIX}.EMAIL"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
      
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 5
    
    PpgFollowUpOperationalDataExtractor.extract_data(response_set)
    
    person  = Person.find(person.id)
    
    person.telephones.size.should == 4
    person.telephones.each do |t|
      t.phone_type.should_not be_nil
      t.phone_nbr[0,6].should == "312555"
    end
    
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
    person.emails.first.email_type.local_code.should == -4
    
  end

end