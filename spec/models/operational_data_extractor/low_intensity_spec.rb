# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::LowIntensityPregnancyVisit do
  include SurveyCompletion

  context "updating the ppg status history" do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)
      Factory(:ppg_detail, :participant => @participant, :desired_history_date => '2010-01-01')
      # setup verification
      PpgStatusHistory.where(:participant_id => @participant).should have(1).entry

      @ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
      @ppg2 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)
      @ppg3 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 3)
      @ppg4 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 4)
      @ppg5 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 5)

      @survey = create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)

      @participant.ppg_status.local_code.should == 2
    end

    it "handles due dates entered in the MDES format (YYYYMMDD)" do
      survey_section = @survey.sections.first
      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "date" }.first
          Factory(:response, :survey_section_id => survey_section.id, :datetime_value => "20111226", :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 2

      OperationalDataExtractor::LowIntensityPregnancyVisit.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 1
      participant.ppg_status.local_code.should == 1
      participant.due_date.should == Date.parse("2011-12-26")
      participant.ppg_details.first.due_date_2.should == "2011-12-26"
    end

    it "updates the ppg status to 1 if the person responds that they are pregnant" do
      take_survey(@survey, @response_set) do |r|
        r.yes "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT"
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.DUE_DATE", '2011-12-25'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 2

      OperationalDataExtractor::LowIntensityPregnancyVisit.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 1
      participant.ppg_status.local_code.should == 1
      participant.due_date.should == Date.parse("2011-12-25")
      participant.ppg_details.first.due_date_2.should == "2011-12-25"
    end

    it "updates the ppg status to 3 if the person responds that they recently lost their child during pregnancy" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT", @ppg3
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::LowIntensityPregnancyVisit.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 3
      participant.ppg_status.local_code.should == 3
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 2 if the person responds that they are trying" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT", @ppg2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::LowIntensityPregnancyVisit.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 2
      participant.ppg_status.local_code.should == 2
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 4 if the person responds that they recently gave birth" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT", @ppg4
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::LowIntensityPregnancyVisit.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 4
      participant.ppg_status.local_code.should == 4
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 5 if the person responds that they are medically unable to become pregnant" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.PREGNANT", @ppg5
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::LowIntensityPregnancyVisit.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 5
      participant.ppg_status.local_code.should == 5
      participant.due_date.should be_nil

    end

  end

  context "creating a birth institution and address record" do

    before(:each) do
      @state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
      @hospital = NcsCode.for_list_name_and_local_code("ORGANIZATION_TYPE_CL1", 1)

      @person = Factory(:person)
      @participant = Factory(:participant)
      part_person_link = Factory(:participant_person_link, :participant => @participant, :person => @person)

      survey = create_lo_i_quex_with_birth_institution_operational_data
      response_set, instrument = prepare_instrument(@person, @participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.BIRTH_PLAN", @hospital
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.BIRTH_PLACE", "FAKE HOSPITAL MEMORIAL"
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_ADDRESS_1", '123 Hospital Way'
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_ADDRESS_2", ''
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_STATE", @state
        r.a "#{OperationalDataExtractor::LowIntensityPregnancyVisit::PREGNANCY_VISIT_LI_2_INTERVIEW_PREFIX}.B_ZIPCODE", '65432'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::LowIntensityPregnancyVisit.new(response_set).extract_data

      @institute = @participant.person.institutions.first
    end

    it "extracts institution and birth address operational data" do
      @participant.person.institutions.first.addresses.size.should == 1
      address = @participant.person.institutions.first.addresses.first
      address.to_s.should == "123 Hospital Way Chicago, Illinois 65432"
    end

    it "extracts institutional data" do
      @institute.institute_name.should == "FAKE HOSPITAL MEMORIAL"
    end

    it "associates the institution with the birth address" do
      @institute.addresses.first.address_one.should == '123 Hospital Way'
    end

    it "associates the birth address with the person, through an institution-person link" do
      @participant.person.institutions.first.addresses.first.address_one.should == '123 Hospital Way'
    end

  end

end
