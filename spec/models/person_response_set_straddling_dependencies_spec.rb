require 'spec_helper'

describe "Straddled dependencies" do
  before(:each) do
    @person = Factory(:person)

    @preceding_survey = Factory(:survey)
    @current_survey = Factory(:survey)

    @preceding_section =  Factory(:survey_section, :survey => @preceding_survey)
    @current_section =  Factory(:survey_section, :survey => @current_survey)

    @preceding_rs = Factory(:response_set, :survey => @preceding_survey, :person => @person)
    @current_rs = Factory(:response_set, :survey => @current_survey, :person => @person)

    @question_preceding_rs =  Factory(:question, :survey_section => @preceding_section,
                                      :data_export_identifier => "BIRTH_VISIT_LI.RELEASE", :reference_identifier => "BIRTH_VISIT_LI.RELEASE" )
    @question_current_rs = Factory(:question, :survey_section => @current_section,
                                   :data_export_identifier => "pre_populated_release_answer_from_part_one", :reference_identifier => "pre_populated_release_answer_from_part_one")

    @answer_preceding_rs =  Factory(:answer, :text => "whatchamacallit", :question => @question_preceding_rs, :reference_identifier => "1")
    @answer_preceding_rs2 =  Factory(:answer, :text => "twix", :question => @question_preceding_rs, :reference_identifier => "2")

    @answer_current_rs =  Factory(:answer, :text => "whatchamacallit", :question => @question_current_rs, :reference_identifier => "1")
    @answer_current_rs2 =  Factory(:answer, :text => "twix", :question => @question_current_rs, :reference_identifier => "2")

    @preceding_response = Factory(:response, :response_set_id => @preceding_rs, :answer => @answer_preceding_rs2, :question => @question_preceding_rs, :survey_section_id => @preceding_section )
  end

  it "a response set prepopulates appropriate values based on a former response set" do
    rs = @person.prepopulate_response_set(@current_rs, @current_survey)
    rs.responses.size.should == 1
    rs.responses.first.answer.should == @answer_current_rs2
    @current_rs.responses.first.answer.should == @answer_current_rs2
    @answer_current_rs2.should_not == @answer_preceding_rs2
    @answer_current_rs2.reference_identifier.should == @answer_preceding_rs2.reference_identifier
  end

end
