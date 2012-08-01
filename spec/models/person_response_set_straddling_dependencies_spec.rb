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
                                      :data_export_identifier => "SIX_MTH_MOTHER.MULT_CHILD",
                                      :reference_identifier => "MULT_CHILD" )
    @question_current_rs = Factory(:question, :survey_section => @current_section,
                                   :data_export_identifier => "pre_populated_mult_child_answer_from_part_one_for_6MM",
                                   :reference_identifier => "pre_populated_mult_child_answer_from_part_one_for_6MM")

    @answer_preceding_rs =  Factory(:answer, :text => "whatchamacallit", :question => @question_preceding_rs)
    @answer_current_rs =  Factory(:answer, :question => @question_current_rs)

    Factory(:response, :response_set => @preceding_rs, :string_value => "whatchamacallit",
                       :answer => @answer_preceding_rs, :question => @question_preceding_rs,
                       :survey_section_id => @preceding_section.id )
  end

  it "a response set prepopulates appropriate values based on a former response set" do
    rs = @person.prepopulate_response_set(@current_rs, @current_survey)
    rs.responses.size.should == 1
    rs.responses.first.string_value.should == "whatchamacallit"
  end

end
