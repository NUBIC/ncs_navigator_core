# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::NonInterviewReport do
  include SurveyCompletion

  let(:person) { Factory(:person) }
  let(:participant) { Factory(:participant) }
  let(:survey) { Survey.last }
  let(:contact) { Factory(:contact) }

  let(:typ) { NcsCode.for_list_name_and_local_code("NIR_REASON_PERSON_CL1", 1) }
  let(:act) { NcsCode.for_list_name_and_local_code("REFUSAL_ACTION_CL1", 2) }
  let(:str) { NcsCode.for_list_name_and_local_code("REFUSAL_INTENSITY_CL1", 2) }
  let(:who) { NcsCode.for_list_name_and_local_code("NIR_INFORM_RELATION_CL2", 2) }

  context "with a NonInterviewReport survey" do

    before do
      f = "#{Rails.root}/internal_surveys/IRB_CON_NonInterviewReport.rb"
      Surveyor::Parser.parse File.read(f)
    end

    describe "extracting NonInterviewReport data" do

      it "sets the NonInterviewReport attributes to the Response values" do
        non_interview_report = NonInterviewReport.start!(person, participant, survey, contact)
        response_set = non_interview_report.response_set

        take_survey(survey, response_set) do |r|
          r.a "NON_INTERVIEW_REPORT.NIR_TYPE_PERSON_CODE", typ
          r.a "NON_INTERVIEW_REPORT.NIR", "nir", :value => "nir text"
          r.a "NON_INTERVIEW_REPORT.WHO_REFUSED_CODE", who
          r.a "NON_INTERVIEW_REPORT.REFUSER_STRENGTH_CODE", str
          r.a "NON_INTERVIEW_REPORT.REFUSAL_ACTION_CODE", act
        end

        response_set.responses.reload
        response_set.responses.size.should == 5

        OperationalDataExtractor::NonInterviewReport.new(response_set).extract_data

        nir = NonInterviewReport.find(non_interview_report.id)
        nir.nir.should == "nir text"
        nir.nir_type_person.should == typ
        nir.who_refused.should == who
        nir.refuser_strength.should == str
        nir.refusal_action.should == act
        nir.refusal_non_interview_reports.should be_blank
      end
    end
  end
end