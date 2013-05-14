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
  it { should belong_to(:non_interview_report) }

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

  describe '#to_mustache' do
    let(:rs) { ResponseSet.new }

    describe 'with a Survey' do
      include NcsNavigator::Core::Surveyor::SurveyTaker

      let(:survey) do
        Surveyor::Parser.new.parse <<-END
          survey "test" do
            section "one" do
              q_helper_c_fname "q_helper_c_fname", :display_type => :hidden, :custom_class => 'helper'
              a 'value', :string

              q_weight "How much does {{c_fname}} weigh?"
              a :integer
            end
          end
        END
      end

      before do
        rs.survey = survey
      end

      it 'fills in Mustache helpers' do
        respond(rs) do |r|
          r.answer 'helper_c_fname', :value => 'First'
        end

        rs.save!

        rs.to_mustache.render('{{c_fname}}').should == 'First'
      end

      describe 'and an unanswered helper question' do
        it 'maintains the substitution template' do
          rs.to_mustache.render('{{c_fname}}').should == '{{c_fname}}'
        end
      end
    end
  end

  describe "#contact_link" do
    let(:contact) { Factory(:contact) }
    let!(:contact_link) { Factory(:contact_link, :contact => contact) }

    context "for a ParticipantConsent Survey" do
      let(:consent) { Factory(:participant_consent, :contact => contact) }
      let(:rs) { Factory(:response_set, :participant_consent => consent) }

      it "returns the first contact_link for the consent's contact" do
        rs.contact_link.should == contact_link
      end
    end

    context "for a NonInterviewReport Survey" do
      let(:nir) { Factory(:non_interview_report, :contact => contact) }
      let(:rs) { Factory(:response_set, :non_interview_report => nir) }

      it "returns the first contact_link for the nir's contact" do
        rs.contact_link.should == contact_link
      end
    end

    context "for an Instrument Survey" do
      let(:inst) { Factory(:instrument) }
      let!(:cl) { Factory(:contact_link, :instrument => inst) }
      let(:rs) { Factory(:response_set, :instrument => inst) }

      it "returns the contact_link for the instrument" do
        rs.contact_link.should == cl
      end
    end

    context "without an MDES association" do
      let(:rs) { Factory(:response_set, :instrument => nil,
                                        :participant_consent => nil,
                                        :non_interview_report => nil) }
      it "returns nil" do
        rs.contact_link.should be_nil
      end
    end
  end

  describe "#event" do
    let(:contact) { Factory(:contact) }
    let(:event) { Factory(:event) }
    let!(:contact_link) { Factory(:contact_link, :contact => contact, :event => event) }

    context "for a ParticipantConsent Survey" do
      let(:consent) { Factory(:participant_consent, :contact => contact) }
      let(:rs) { Factory(:response_set, :participant_consent => consent) }

      it "returns the event associated with the consent" do
        rs.event.should == event
      end
    end

    context "for a NonInterviewReport Survey" do
      let(:nir) { Factory(:non_interview_report, :contact => contact) }
      let(:rs) { Factory(:response_set, :non_interview_report => nir) }

      it "returns the event associated with the non_interview_report" do
        rs.event.should == event
      end
    end

    context "for an Instrument Survey" do
      let(:inst) { Factory(:instrument) }
      let!(:cl) { Factory(:contact_link, :instrument => inst, :event => event) }
      let(:rs) { Factory(:response_set, :instrument => inst) }

      it "returns the event associated with the instrument" do
        rs.event.should == event
      end
    end

    context "without an MDES association" do
      let(:rs) { Factory(:response_set, :instrument => nil,
                                        :participant_consent => nil,
                                        :non_interview_report => nil) }
      it "returns nil" do
        rs.event.should be_nil
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

    context "for a NonInterviewReport Survey" do
      let(:nir) { Factory(:non_interview_report) }
      let(:rs) { Factory(:response_set, :non_interview_report => nir) }

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

  describe 'operational data extraction' do
    # RMS20130415: I'm adding a spec for the existing behavior.
    # Not an endorsement of using callbacks for complex logic.
    it 'happens on save when complete' do
      rs = FactoryGirl.build(:response_set, :completed_at => Date.new(2012, 1, 8))
      OperationalDataExtractor::Base.should_receive(:process).with(rs)
      rs.save!
    end

    it 'does not happen on save when not complete' do
      rs = FactoryGirl.build(:response_set, :completed_at => nil)
      OperationalDataExtractor::Base.should_not_receive(:process)
      rs.save!
    end

    it 'does not happen when complete but in importer mode' do
      ResponseSet.importer_mode do
        rs = FactoryGirl.build(:response_set, :completed_at => Date.new(2012, 1, 8))
        OperationalDataExtractor::Base.should_not_receive(:process).with(rs)
        rs.save!
      end
    end
  end
end
