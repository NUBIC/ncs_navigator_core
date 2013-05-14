# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: responses
#
#  answer_id         :integer
#  api_id            :string(255)
#  created_at        :datetime
#  datetime_value    :datetime
#  float_value       :float
#  id                :integer          not null, primary key
#  integer_value     :integer
#  lock_version      :integer          default(0)
#  question_id       :integer
#  response_group    :string(255)
#  response_other    :string(255)
#  response_set_id   :integer          not null
#  source_mdes_id    :string(36)
#  source_mdes_table :string(100)
#  string_value      :string(255)
#  survey_section_id :integer
#  text_value        :text
#  unit              :string(255)
#  updated_at        :datetime
#

require 'spec_helper'
require File.expand_path('../../shared/models/an_optimistically_locked_record', __FILE__)
require File.expand_path('../../shared/models/a_publicly_identified_record', __FILE__)

describe Response do
  describe 'import record fields' do
    subject { Response.new }

    describe '#source_mdes_table' do
      it 'exists' do
        lambda { subject.source_mdes_table }.should_not raise_error
      end
    end

    describe '#source_mdes_id' do
      it 'exists' do
        lambda { subject.source_mdes_id }.should_not raise_error
      end
    end

    describe '#source_mdes_record=' do
      class ResponseSpecFakeMdesWarehouseModel
        def self.mdes_table_name
          'fake_one'
        end

        def key
          ['00000-11111-66']
        end
      end

      before do
        subject.source_mdes_record = ResponseSpecFakeMdesWarehouseModel.new
      end

      it 'sets the source table' do
        subject.source_mdes_table.should == 'fake_one'
      end

      it 'sets the source id' do
        subject.source_mdes_id.should == '00000-11111-66'
      end
    end
  end

  describe "#answer_associated_with_question" do
    let!(:q) { Factory(:question,
      :text => 'What is your date of birth?',
      :reference_identifier => 'DOB',
      :data_export_identifier => 'TABLE_NAME.DOB') }
    let!(:a1) { Factory(:answer, :question => q, :response_class => 'date', :text => 'DATE') }

    let!(:a_other_q) { Factory(:answer, :question => Factory(:question),
      :response_class => 'answer', :text => 'FOO') }

    describe "on create" do
      it "is invalid if the answer_id is not associated with the response question" do
        response = Factory.build(:response, :question => q, :answer => a_other_q)
        response.should_not be_valid
      end
      it "raises error" do
        lambda { Factory(:response, :question => q, :answer => a_other_q) }.should raise_error
      end
    end

    describe "on update" do
      it "is invalid if the answer_id is not associated with the response question" do
        response = Factory(:response, :question => q, :answer => a1)
        response.answer = a_other_q
        response.should_not be_valid
      end
      it "raises error" do
        response = Factory(:response, :question => q, :answer => a1)
        response.answer = a_other_q
        lambda { response.save! }.should raise_error
      end
    end
  end

  it_should_behave_like 'a publicly identified record' do
    let(:a) { Factory(:answer) }
    let(:q) { Factory(:question) }

    let(:o1) { Factory(:response, :answer => a, :question => q) }
    let(:o2) { Factory(:response, :answer => a, :question => q) }
  end

  it_should_behave_like 'an optimistically locked record' do
    let(:a) { Factory(:answer) }
    let(:q) { Factory(:question) }

    subject { Factory(:response, :answer => a, :question => q) }

    def modify(winner, loser)
      winner.string_value = 'winner'
      loser.string_value = 'loser'
    end
  end

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

      it 'returns the string representation of the coded value' do
        response.reportable_value.should == '1'
      end
    end

    describe 'with a negative coded value' do
      let(:response) {
        create_response(:answer => question.answers.find_by_text('Refused'))
      }

      it 'returns the string representation of the coded value' do
        response.reportable_value.should == '-1'
      end
    end

    shared_context 'nil-handling reportable_value type' do
      describe 'without a value' do
        it 'returns nil' do
          response.reportable_value.should be_nil
        end
      end
    end

    describe 'with a string-valued answer' do
      include_context 'nil-handling reportable_value type'

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('string')
        )
      }

      describe 'with a value' do
        before do
          response.string_value = 'Fredricka'
        end

        it 'returns the string value' do
          response.reportable_value.should == 'Fredricka'
        end
      end
    end

    describe 'with an integer-valued answer' do
      include_context 'nil-handling reportable_value type'

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
        )
      }

      describe 'with a value' do
        before do
          response.integer_value = 6
        end

        it 'returns the string representation of the integer value' do
          response.reportable_value.should == '6'
        end
      end
    end

    describe 'with a datetime-valued answer' do
      include_context 'nil-handling reportable_value type'

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
        )
      }

      describe 'with a value' do
        before do
          response.datetime_value = Time.local(2010, 12, 27, 8, 39, 36)
        end

        it 'returns the MDES formatted string representation' do
          response.reportable_value.should == '2010-12-27T08:39:36'
        end
      end
    end

    describe 'with a date-valued answer' do
      include_context 'nil-handling reportable_value type'

      let(:questions_dsl) {
        <<-DSL
          q_ORIG_DUE_DATE "[Congratulations.] When is your baby due? ",
          :pick => :one,
          :data_export_identifier=>"EIGHTEEN_MTH_MOTHER.ORIG_DUE_DATE"
          a_1 "Due date", :date, :custom_class => "date"
        DSL
      }

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('date'),
        )
      }

      describe 'with a value' do
        before do
          response.datetime_value = Time.local(2001, 12, 25)
        end

        it 'returns the MDES formatted string representation' do
          response.reportable_value.should == '2001-12-25'
        end
      end
    end

    describe 'with a time-valued answer' do
      include_context 'nil-handling reportable_value type'

      let(:questions_dsl) {
        <<-DSL
          q_BEST_TTC1_1 "What would be a good time to reach her at this number?",
            :pick => :one,
            :data_export_identifier => "PBS_ELIG_SCREENER.BEST_TTC1_1"
            a_time :time, :custom_class => "time"
        DSL
      }

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('time'),
        )
      }

      describe 'with a value' do
        before do
          response.datetime_value = Time.local(2001, 12, 25, 8, 44, 11)
        end

        it 'returns the MDES formatted string representation' do
          response.reportable_value.should == '08:44'
        end
      end
    end

    describe 'with a float-valued answer' do
      include_context 'nil-handling reportable_value type'

      let(:questions_dsl) {
        <<-DSL
          q_BP_MID_UPPER_ARM_CIRC "UPPER ARM CIRCUMFERENCE, MEASURED AT THE MIDPOINT OF UPPER ARM (HUMERUS) LENGTH",
          :data_export_identifier=>"CHILD_BP.BP_MID_UPPER_ARM_CIRC",
          :pick => :one
          a_1 :float
        DSL
      }

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('float')
        )
      }

      describe 'with a value' do
        before do
          response.float_value = 1.1
        end

        it 'returns the string representation of the float value' do
          response.reportable_value.should == '1.1'
        end
      end
    end

    describe 'with a string-valued answer for a phone' do
      include_context 'nil-handling reportable_value type'

      let(:questions_dsl) {
        <<-DSL
          q_PHONE_NBR "Would you please tell me a telephone number where she can be reached? ",
          :pick => :one,
          :data_export_identifier=>"PHONE_NBR"
          a_phone "Phone number", :string, :custom_class => "phone"
        DSL
      }

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('string')
        )
      }

      describe 'with a phone value' do
        before do
          response.string_value = '312-555-1212'
        end

        it 'returns the MDES phone formatted string value' do
          response.reportable_value.should == '3125551212'
        end
      end

      describe 'with a string value' do
        before do
          response.string_value = 'No comment'
        end

        it 'returns a blank string' do
          response.reportable_value.should == ''
        end
      end

      describe 'with a string value including numbers' do
        before do
          response.string_value = 'PEnnsylvania 6-5000'
        end

        it 'returns the numbers' do
          response.reportable_value.should == '65000'
        end
      end
    end

    describe 'with a text-valued answer' do
      include_context 'nil-handling reportable_value type'

      let(:questions_dsl) {
        <<-DSL
          q_PPG005 "When would be a good time for you?"
          a_1 :text
        DSL
      }

      let(:response) {
        create_response(
          :answer => question.answers.find_by_response_class('text')
        )
      }

      describe 'with a value' do
        before do
          response.text_value = "Next Thursday at 2 o'clock"
        end

        it 'returns the text' do
          response.reportable_value.should == "Next Thursday at 2 o'clock"
        end
      end
    end

  end
end
