# -*- coding: utf-8 -*-

require 'spec_helper'

describe SimplePostNatalOperationalDataExtractor do
  include SurveyCompletion

  context "extracting child name data" do

    before(:each) do
      @person = Factory(:person)
      @responses_set = Factory(:response_set, :person => @person)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_three_month_mother_int_child_detail_survey_with_child_name_operational_data
    end

    it "extracts the child name data from survey responses" do
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      take_survey(@survey, @response_set) do |a|
        a.str "#{SimplePostNatalOperationalDataExtractor::THREE_MONTH_MOTHER_PREFIX}.C_FNAME", 'Jo'
        a.str "#{SimplePostNatalOperationalDataExtractor::THREE_MONTH_MOTHER_PREFIX}.C_LNAME", 'Stafford'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 2

      SimplePostNatalOperationalDataExtractor.extract_data(@response_set)

      Person.where(:response_set_id == @response_set.id).first.first_name.should == "Jo"
      Person.where(:response_set_id == @response_set.id).first.last_name.should == "Stafford"
    end
  end

  context "extracting date of birth data" do

    before(:each) do
      @person = Factory(:person)
      @responses_set = Factory(:response_set, :person => @person)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_three_month_mother_int_child_detail_survey_with_date_of_birth_operational_data
    end

    it "extracts date of birth data from survey responses" do

      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      take_survey(@survey, @response_set) do |a|
        a.date "#{SimplePostNatalOperationalDataExtractor::THREE_MONTH_MOTHER_PREFIX}.CHILD_DOB", '01/01/2012'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      SimplePostNatalOperationalDataExtractor.extract_data(@response_set)

      Person.where(:response_set_id == @response_set.id).first.person_dob.should == "2012-01-01"
    end
  end

end
