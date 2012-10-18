# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: response_sets
#
#  access_code                               :string(255)
#  api_id                                    :string(255)
#  completed_at                              :datetime
#  created_at                                :datetime
#  id                                        :integer          not null, primary key
#  instrument_id                             :integer
#  participant_id                            :integer
#  processed_for_operational_data_extraction :boolean
#  started_at                                :datetime
#  survey_id                                 :integer
#  updated_at                                :datetime
#  user_id                                   :integer
#

require 'spec_helper'

require File.expand_path('../../shared/models/a_publicly_identified_record', __FILE__)

describe ResponseSet do

  it { should belong_to(:person) }
  it { should belong_to(:instrument) }
  it { should belong_to(:participant) }

  it_should_behave_like 'a publicly identified record' do
    let(:o1) { Factory(:response_set) }
    let(:o2) { Factory(:response_set) }
  end

  describe '#instrument' do
    it 'is the inverse of Instrument#response_set' do
      ResponseSet.reflections[:instrument].options[:inverse_of].should == :response_sets
    end
  end

  describe '#participant' do
    it 'is the inverse of Instrument#response_set' do
      ResponseSet.reflections[:participant].options[:inverse_of].should == :response_sets
    end
  end

  describe '#to_json' do
    let(:s) { Factory(:survey) }
    let(:rs) { ResponseSet.new(:api_id => 'foo', :survey => s) }
    let(:pa) { Factory(:participant) }

    let(:json) { JSON.parse(rs.to_json) }

    describe 'with a participant' do
      before do
        rs.participant = pa
      end

      it "returns the participant's public ID" do
        json['p_id'].should == pa.public_id
      end
    end

    describe 'without a participant' do
      it "returns null for the participant's public ID" do
        json['p_id'].should be_nil
      end
    end
  end

  context "with instruments" do
    describe "a participant who is in ppg1 - Currently Pregnant and Eligible" do

      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant, :high_intensity => true, :high_intensity_state => "pregnancy_one") }

      let(:access_code) { "ins-que-pregvisit1-int-ehpbhi-p2-v2-0" }
      let(:status1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1) }

      it "creates a response set for the instrument with prepopulated answers" do

        participant.person = person

        pv1survey = Survey.find_by_access_code(access_code)
        if pv1survey.blank?
          pv1survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => access_code)
        end

        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)

        section   = Factory(:survey_section, :survey => pv1survey)
        question  = Factory(:question, :survey_section => section, :data_export_identifier => "name", :reference_identifier => "prepopulated_name")
        answer    = Factory(:answer, :question => question)

        ResponseSet.where(:user_id => person.id).should be_empty
        instrument_type = NcsCode.for_list_name_and_local_code('INSTRUMENT_TYPE_CL1', 1)

        rs, ins = prepare_instrument(person, participant, pv1survey)
        rs.save!
        rs = ResponseSet.where(:user_id => person.id).first
        rs.should_not be_nil
        rs.responses.should_not be_empty
        rs.responses.first.string_value.should == person.name
      end

    end

  end

  context "knowing if the user answered questions in each section" do
    before(:each) do

      @survey = create_survey_with_many_sections
      @survey.sections_with_questions.size.should == 5
    end

    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }

    describe "a survey that has no responses" do

      it "knows that the response set does not have responses in each section" do
        survey_section = @survey.sections.first
        response_set, instrument = prepare_instrument(person, participant, @survey)
        response_set.save!
        response_set.responses.size.should == 0

        response_set.has_responses_in_each_section_with_questions?.should be_false

      end

    end

    describe "a survey that has a few responses but not in all sections" do

      it "knows that the response set does not have responses in each section" do
        response_set, instrument = prepare_instrument(person, participant, @survey)
        response_set.save!
        response_set.responses.size.should == 0

        @survey.sections_with_questions.each do |section|
          section.questions.each do |q|
            case q.data_export_identifier
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
              answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
              Factory(:response, :survey_section_id => section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DUE_DATE"
              answer = q.answers.select { |a| a.response_class == "date" }.first
              Factory(:response, :survey_section_id => section.id, :datetime_value => "2012-02-29", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            end
          end
        end

        response_set.responses.reload
        response_set.responses.size.should == 2

        response_set.has_responses_in_each_section_with_questions?.should be_false

      end

      it "knows that the response set does not have responses in the last section with questions" do

        response_set, instrument = prepare_instrument(person, participant, @survey)
        response_set.save!
        response_set.responses.size.should == 0

        @survey.sections_with_questions.each do |section|
          section.questions.each do |q|
            case q.data_export_identifier
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
              answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
              Factory(:response, :survey_section_id => section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DUE_DATE"
              answer = q.answers.select { |a| a.response_class == "date" }.first
              Factory(:response, :survey_section_id => section.id, :datetime_value => "2012-02-29", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.EMAIL"
              answer = q.answers.select { |a| a.response_class == "string" }.first
              Factory(:response, :survey_section_id => section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
              # SKIPPING THIS SECTION
            end
          end
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        response_set.has_responses_in_each_section_with_questions?.should be_false

      end

    end

    describe "a survey that has at least one response in all sections" do

      it "knows that the response set does have responses in each section" do
        response_set, instrument = prepare_instrument(person, participant, @survey)
        response_set.save!
        response_set.responses.size.should == 0

        @survey.sections_with_questions.each do |section|
          section.questions.each do |q|
            case q.data_export_identifier
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
              answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
              Factory(:response, :survey_section_id => section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DUE_DATE"
              answer = q.answers.select { |a| a.response_class == "date" }.first
              Factory(:response, :survey_section_id => section.id, :datetime_value => "2012-02-29", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.EMAIL"
              answer = q.answers.select { |a| a.response_class == "string" }.first
              Factory(:response, :survey_section_id => section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
              answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
              Factory(:response, :survey_section_id => section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            end
          end
        end

        response_set.responses.reload
        response_set.responses.size.should == 4

        response_set.has_responses_in_each_section_with_questions?.should be_true

      end

    end

  end

end
