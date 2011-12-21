require 'spec_helper'

describe LowIntensityPregnancyVisitOperationalDataExtractor do

  before(:each) do
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(PpgDetail)
    create_missing_in_error_ncs_codes(PpgStatusHistory)
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  end

  context "updating the ppg status history" do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)
      Factory(:ppg_detail, :participant => @participant)

      @ppg1 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1", :local_code => 1)
      @ppg2 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2", :local_code => 2)
      @ppg3 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3", :local_code => 3)
      @ppg4 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4", :local_code => 4)
      @ppg5 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 5", :local_code => 5)

      @survey = create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data
      @survey_section = @survey.sections.first
      @response_set, @instrument = @person.start_instrument(@survey)

      @response_set.responses.size.should == 0
      @participant.ppg_status.local_code.should == 2
    end

    it "updates the ppg status to 1 if the person responds that they are pregnant" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{LowIntensityPregnancyVisitOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{LowIntensityPregnancyVisitOperationalDataExtractor::INTERVIEW_PREFIX}.DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "date" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :datetime_value => "2011-12-25", :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 2

      LowIntensityPregnancyVisitOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 1
      participant.ppg_status.local_code.should == 1
      participant.due_date.should == Date.parse("2011-12-25")

    end

    it "updates the ppg status to 3 if the person responds that they recently lost their child during pregnancy" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{LowIntensityPregnancyVisitOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "3" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      LowIntensityPregnancyVisitOperationalDataExtractor.extract_data(@response_set)

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
        when "#{LowIntensityPregnancyVisitOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      LowIntensityPregnancyVisitOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 2
      participant.ppg_status.local_code.should == 2
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 4 if the person responds that they recently gave birth" do

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{LowIntensityPregnancyVisitOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "4" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      LowIntensityPregnancyVisitOperationalDataExtractor.extract_data(@response_set)

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
        when "#{LowIntensityPregnancyVisitOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "5" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      LowIntensityPregnancyVisitOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 1
      participant.ppg_status_histories.first.ppg_status.local_code.should == 5
      participant.ppg_status.local_code.should == 5
      participant.due_date.should be_nil

    end

  end


end
