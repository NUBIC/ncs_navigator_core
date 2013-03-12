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
  it { should belong_to(:participant_consent) }

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

  describe "#associated_response_sets" do

    context "for a ParticipantConsent Survey" do
      let(:consent) { Factory(:participant_consent) }
      let(:rs) { Factory(:response_set, :participant_consent => consent) }

      it "returns an Array of one element - itself" do
        rs.associated_response_sets.should == [rs]
      end
    end

    context "for an Instrument Survey" do
      let(:instrument) { Factory(:instrument) }
      let!(:rs1) { Factory(:response_set, :instrument => instrument) }
      let!(:rs2) { Factory(:response_set, :instrument => instrument) }

      it "returns an Array all ResponseSets associated with the Instrument" do
        rs1.associated_response_sets.should == instrument.response_sets
        instrument.response_sets.size.should == 2
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
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.PREGNANT"
              answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
              Factory(:response, :survey_section_id => section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.DUE_DATE"
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
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.PREGNANT"
              answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
              Factory(:response, :survey_section_id => section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.DUE_DATE"
              answer = q.answers.select { |a| a.response_class == "date" }.first
              Factory(:response, :survey_section_id => section.id, :datetime_value => "2012-02-29", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.EMAIL"
              answer = q.answers.select { |a| a.response_class == "string" }.first
              Factory(:response, :survey_section_id => section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.ENGLISH"
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
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.PREGNANT"
              answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
              Factory(:response, :survey_section_id => section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.DUE_DATE"
              answer = q.answers.select { |a| a.response_class == "date" }.first
              Factory(:response, :survey_section_id => section.id, :datetime_value => "2012-02-29", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.EMAIL"
              answer = q.answers.select { |a| a.response_class == "string" }.first
              Factory(:response, :survey_section_id => section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
            when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.ENGLISH"
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
