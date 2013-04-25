# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::PpgFollowUp do
  include SurveyCompletion

  context "updating the ppg status history" do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person)
      Factory(:ppg_detail, :participant => @participant, :desired_history_date => '2010-01-01')

      @ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
      @ppg2 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)
      @ppg3 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 3)
      @ppg4 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 4)
      @ppg5 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 5)

      @survey = create_follow_up_survey_with_ppg_status_history_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      @participant.ppg_status.local_code.should == 2
    end

    it "updates the ppg status to 1 if the person responds that they are pregnant" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.PREGNANT", @ppg1
        r.a "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.PPG_DUE_DATE_1", '2011-12-25'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 2

      OperationalDataExtractor::PpgFollowUp.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 1
      participant.ppg_status.local_code.should == 1
      participant.due_date.should == Date.parse("2011-12-25")
      participant.ppg_details.first.orig_due_date.should == "2011-12-25"
    end

    it "updates the ppg status to 3 if the person responds that they recently lost their child during pregnancy" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.PREGNANT", @ppg3
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PpgFollowUp.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 3
      participant.ppg_status.local_code.should == 3
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 2 if the person responds that they are trying" do
      take_survey(@survey, @response_set) do |r|
        r.yes "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.TRYING"
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PpgFollowUp.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 2
      participant.ppg_status.local_code.should == 2
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 3 if the person responds that they recently lost their child" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.TRYING", @ppg3
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PpgFollowUp.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 3
      participant.ppg_status.local_code.should == 3
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 4 if the person responds that they recently gave birth" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.TRYING", @ppg4
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PpgFollowUp.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 4
      participant.ppg_status.local_code.should == 4
      participant.due_date.should be_nil

    end

    it "updates the ppg status to 5 if the person responds that they are medically unable to become pregnant" do
      take_survey(@survey, @response_set) do |r|
        r.yes "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.MED_UNABLE"
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PpgFollowUp.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.size.should == 2
      participant.ppg_status_histories.first.ppg_status.local_code.should == 5
      participant.ppg_status.local_code.should == 5
      participant.due_date.should be_nil

    end

    it "sets the ppg_status_date to the date of the contact" do
      contact = Factory(:contact, :contact_date => '2525-12-25')
      Factory(:contact_link, :instrument => @instrument, :contact => contact, :person => @person)

      take_survey(@survey, @response_set) do |r|
        r.yes "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.TRYING"
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PpgFollowUp.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.ppg_status_histories.first.ppg_status_date.should == contact.contact_date
      participant.ppg_status_histories.first.ppg_status_date_date.should == contact.contact_date_date
    end

  end

  it "extracts telephone operational data from the survey responses" do

    home = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 1)
    work = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 2)
    cell = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3)
    frre = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 4)
    oth  = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", -5)

    person = Factory(:person)
    participant = Factory(:participant)
    person.telephones.size.should == 0

    survey = create_follow_up_survey_with_telephone_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.PHONE_NBR", '3125551234'
      r.a "#{OperationalDataExtractor::PpgFollowUp::INTERVIEW_PREFIX}.PHONE_TYPE", cell
    end

    response_set.responses.reload
    response_set.responses.size.should == 2

    OperationalDataExtractor::PpgFollowUp.new(response_set).extract_data

    person  = Person.find(person.id)
    person.telephones.size.should == 1
    telephone = person.telephones.first
    telephone.phone_type.local_code.should == 3
    telephone.phone_nbr.should == "3125551234"
    telephone.phone_rank_code.should == 1
  end

  it "extracts contact data from the SAQ survey responses" do
    home = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 1)
    work = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 2)
    cell = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3)
    oth  = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", -5)

    person = Factory(:person)
    participant = Factory(:participant)
    email = Factory(:email, :email => "asdf@asdf.asdf", :person => person)

    person.telephones.size.should == 0
    person.emails.size.should == 1

    survey = create_follow_up_survey_with_contact_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PpgFollowUp::SAQ_PREFIX}.HOME_PHONE", '3125551234'
      r.a "#{OperationalDataExtractor::PpgFollowUp::SAQ_PREFIX}.CELL_PHONE", '3125555678'
      r.a "#{OperationalDataExtractor::PpgFollowUp::SAQ_PREFIX}.WORK_PHONE", '3125559012'
      r.a "#{OperationalDataExtractor::PpgFollowUp::SAQ_PREFIX}.OTHER_PHONE", '3125553456'
      r.a "#{OperationalDataExtractor::PpgFollowUp::SAQ_PREFIX}.EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 5

    OperationalDataExtractor::PpgFollowUp.new(response_set).extract_data

    person  = Person.find(person.id)

    person.telephones.size.should == 4
    person.telephones.each do |t|
      t.phone_type.should_not be_nil
      t.phone_nbr[0,6].should == "312555"
      t.phone_rank_code.should == 1
    end

    person = Person.find(person.id)

    extracted_emails = person.emails.all
    extracted_emails.size == 2

    extracted_email_addresses = []
    extracted_emails.each { |email| extracted_email_addresses << email.email }

    extracted_email_addresses.should include("asdf@asdf.asdf")
    extracted_email_addresses.should include("email@dev.null")

    existing_email = extracted_emails.detect  { |e| e.email == "asdf@asdf.asdf" }
    extracted_email = extracted_emails.detect { |e| e.email == "email@dev.null" }

    # when an email of the same type of an existing primary email address, the existing address is demoted to secondary rank (2) and
    # newly extracted email has the primary rank (1)

    existing_email.email_rank_code.should == 2
    extracted_email.email_rank_code.should == 1

  end

end
