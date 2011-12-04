# -*- coding: utf-8 -*-
require 'spec_helper'

describe Response do
  describe '#reportable_value' do
    let(:questions_dsl) {
      <<-DSL
      q_r_fname "First name",
        :pick=>:one
        a :string
        a_1 "Josephine"
        a_neg_1 "Refused"
        a_neg_2 "Don't know"
      DSL
    }

    let(:survey) {
      load_survey_string(<<-SURVEY)
survey "test survey" do
  section "test section" do
    #{questions_dsl}
  end
end
      SURVEY
    }

    let(:question) { survey.sections.first.questions.first }

    def create_response(options={})
      Response.new( { :question => question }.merge(options) )
    end

    describe 'with a positive coded value' do
      let(:response) {
        create_response(:answer => question.answers.find_by_text('Josephine'))
      }

      it 'works' do
        response.reportable_value.should == '1'
      end
    end

    describe 'with a negative coded value' do
      let(:response) {
        create_response(:answer => question.answers.find_by_text('Refused'))
      }

      it 'works' do
        response.reportable_value.should == '-1'
      end
    end

    describe 'with a string value' do
      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('string'),
          :string_value => 'Fredricka'
        )
      }

      it 'works' do
        response.reportable_value.should == 'Fredricka'
      end
    end

    describe 'with an integer value' do
      let(:questions_dsl) {
        <<-DSL
          q_RETURN_JOB "Number",
          :pick => :one,
          :data_export_identifier=>"BIRTH_VISIT_2.RETURN_JOB"
          a_num "Number", :integer
          a_neg_7 "Doesn’t plan to return to work"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"
        DSL
      }

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('integer'),
          :integer_value => 6
        )
      }

      it 'works' do
        response.reportable_value.should == 6
      end
    end

    describe 'with a datetime value' do
      let(:questions_dsl) {
        <<-DSL
          q_TIME_STAMP_8 "Insert date/time stamp",
          :data_export_identifier=>"BIRTH_VISIT_2.TIME_STAMP_8"
          a :datetime, :custom_class => "datetime"
        DSL
      }

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('datetime'),
          :datetime_value => Time.local(2010, 12, 27, 8, 39, 36)
        )
      }

      it 'works' do
        response.reportable_value.should == '2010-12-27T08:39:36'
      end
    end
  end
end
